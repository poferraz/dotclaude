const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const crypto = require('node:crypto');
const readline = require('node:readline');
const { execFileSync, spawnSync } = require('node:child_process');

const source = path.resolve(__dirname, '../config');
const configured = process.env.CLAUDE_CONFIG_DIR ?? path.join(os.homedir(), '.claude');

function stat(file) {
  try {
    return fs.lstatSync(file);
  } catch (error) {
    if (error.code === 'ENOENT') return null;
    throw error;
  }
}

function fingerprint(root) {
  const digest = crypto.createHash('sha256');
  const buffer = Buffer.alloc(65536);
  function visit(file, relative) {
    const info = fs.lstatSync(file);
    const kind = info.isDirectory() ? 'directory' : info.isSymbolicLink() ? 'link' : 'file';
    digest.update(JSON.stringify([relative, kind, info.mode & 0o7777]) + '\n');
    if (kind === 'directory') {
      for (const name of fs.readdirSync(file).sort()) visit(path.join(file, name), path.join(relative, name));
    } else if (kind === 'link') {
      digest.update(JSON.stringify(fs.readlinkSync(file)) + '\n');
    } else if (info.isFile()) {
      const fileHash = crypto.createHash('sha256');
      const fd = fs.openSync(file, 'r');
      try {
        let length;
        while ((length = fs.readSync(fd, buffer, 0, buffer.length, null)) > 0) {
          fileHash.update(buffer.subarray(0, length));
        }
      } finally {
        fs.closeSync(fd);
      }
      digest.update(fileHash.digest('hex') + '\n');
    } else {
      throw new Error('Close active tools and remove special files from the configuration before retrying.');
    }
  }
  visit(root, '');
  return digest.digest('hex');
}

function copyTree(from, to) {
  // Both BSD and GNU cp -a preserve links, modes and platform file metadata.
  execFileSync('cp', ['-a', from, to]);
}

function snapshotDir(target, kind) {
  const timestamp = new Date().toISOString().replace(/\D/g, '');
  return fs.mkdtempSync(target + '.' + kind + '.' + timestamp + '.');
}

function saveManifest(directory, checksum) {
  fs.writeFileSync(path.join(directory, 'manifest.json'), JSON.stringify({ version: 1, sha256: checksum }), { mode: 0o600 });
}

function install(target, work) {
  const additions = [];
  function inspect(relative, input) {
    const output = path.join(target, relative);
    const existing = stat(output);
    const material = input && fs.lstatSync(input);
    if (!material || material.isDirectory()) {
      if (existing && !existing.isDirectory()) throw new Error('Expected a real directory at ' + output);
      if (!existing) additions.push({ output });
      if (material) {
        for (const name of fs.readdirSync(input)) inspect(path.join(relative, name), path.join(input, name));
      }
    } else {
      if (!material.isFile()) throw new Error('Unsupported packaged file: ' + input);
      if (!existing) additions.push({ output, input });
    }
  }

  if (!stat(target)) additions.push({ output: target });
  for (const name of ['CLAUDE.md', 'agents', 'skills', 'commands']) inspect(name, path.join(source, name));
  for (const name of ['rules', 'plans', 'sessions']) {
    const input = path.join(source, name);
    inspect(name, stat(input) ? input : null);
  }
  if (!additions.length) {
    console.log('All configuration paths already exist. Existing files were preserved.');
    return;
  }

  const original = stat(target) ? fingerprint(target) : null;
  const backup = snapshotDir(target, 'backup');
  const saved = path.join(backup, 'config');
  try {
    if (original === null) fs.mkdirSync(saved, { mode: 0o700 });
    else copyTree(target, saved);
    const checksum = fingerprint(saved);
    if (original !== null && (checksum !== original || fingerprint(target) !== original)) {
      throw new Error('Configuration changed or could not be copied faithfully. Retry with Claude closed.');
    }
    saveManifest(backup, checksum);
  } catch (error) {
    fs.rmSync(backup, { recursive: true, force: true });
    throw error;
  }
  console.log('Previous configuration retained at ' + saved);

  // Prepare complete files on the same filesystem, then add them exclusively.
  // Existing live files retain their inodes, hard links, ACLs and extended attributes.
  const published = [];
  try {
    for (const [index, change] of additions.entries()) {
      if (change.input) {
        change.copy = path.join(work, String(index));
        fs.copyFileSync(change.input, change.copy);
        change.checksum = fingerprint(change.copy);
      }
    }
    for (const change of additions) {
      if (change.copy) fs.linkSync(change.copy, change.output);
      else fs.mkdirSync(change.output, { mode: 0o700 });
      published.push(change);
    }
  } catch (error) {
    for (const change of published.reverse()) {
      if (change.copy) {
        const info = stat(change.output);
        if (info?.isFile() && info.ino === fs.statSync(change.copy).ino &&
            fingerprint(change.output) === change.checksum) fs.unlinkSync(change.output);
      } else {
        if (stat(change.output)?.isDirectory() && !fs.readdirSync(change.output).length) fs.rmdirSync(change.output);
      }
    }
    throw error;
  }
  console.log('Installed missing files in ' + target + '. Existing files were preserved.');
}

function recoverPending(target) {
  const marker = target + '.dotclaude-restore';
  const info = stat(marker);
  if (!info) return;
  if (!info.isFile()) throw new Error('Invalid restore marker at ' + marker);
  const name = fs.readFileSync(marker, 'utf8');
  const prefix = path.basename(target) + '.recovery.';
  if (!name.startsWith(prefix) || !/^\d{17}\.[a-zA-Z0-9]+$/.test(name.slice(prefix.length))) {
    throw new Error('Invalid recovery name in ' + marker);
  }
  if (!stat(target)) {
    const directory = path.join(path.dirname(target), name);
    if (!stat(directory)?.isDirectory()) throw new Error('Invalid interrupted restore directory.');
    const recovery = path.join(directory, 'config');
    if (!stat(recovery)?.isDirectory()) throw new Error('Expected recovery configuration at ' + recovery);
    fs.renameSync(recovery, target);
    console.log('Recovered the previous configuration after an interrupted restore.');
  }
  fs.unlinkSync(marker);
}

function activateRestore(target, staged, original) {
  if (original === null) {
    if (stat(target)) throw new Error('Configuration appeared during preparation. Retry with Claude closed.');
    fs.renameSync(staged, target);
    return;
  }
  const backup = snapshotDir(target, 'recovery');
  const saved = path.join(backup, 'config');
  const marker = target + '.dotclaude-restore';
  let moved = false;
  try {
    saveManifest(backup, original);
    fs.writeFileSync(marker, path.basename(backup), { flag: 'wx', mode: 0o600 });
    fs.renameSync(target, saved);
    moved = true;
    if (fingerprint(saved) !== original) throw new Error('Configuration changed during preparation. Retry with Claude closed.');
    fs.renameSync(staged, target);
  } catch (error) {
    if (moved) {
      if (stat(target)) throw new Error('Configuration changed concurrently. The previous tree remains at ' + saved);
      fs.renameSync(saved, target);
    }
    fs.rmSync(marker, { force: true });
    fs.rmSync(backup, { recursive: true, force: true });
    throw error;
  }
  fs.unlinkSync(marker);
  console.log('Previous configuration retained at ' + saved);
}

function backupList(target) {
  const parent = path.dirname(target);
  const prefix = path.basename(target) + '.backup.';
  return fs.readdirSync(parent).filter(name => {
    const suffix = name.slice(prefix.length);
    return name.startsWith(prefix) && /^(?:\d{14}|\d{17}\.[a-zA-Z0-9]+)$/.test(suffix) &&
      fs.lstatSync(path.join(parent, name)).isDirectory();
  }).sort().reverse().map(name => path.join(parent, name));
}

async function restore(target, staged, currentHash) {
  const backups = backupList(target);
  if (!backups.length) throw new Error('No backup found for the selected configuration.');
  const stream = readline.createInterface({ input: process.stdin, terminal: false });
  const lines = stream[Symbol.asyncIterator]();
  try {
    let selected = backups[0];
    if (backups.length > 1) {
      backups.forEach((name, i) => console.log((i + 1) + ') ' + name));
      process.stdout.write('Restore which backup? [1]: ');
      const answer = await lines.next();
      if (answer.done) return;
      const choice = answer.value.trim() || '1';
      if (!/^\d+$/.test(choice) || !backups[Number(choice) - 1]) throw new Error('Invalid backup selection.');
      selected = backups[Number(choice) - 1];
    }
    console.log('Selected backup: ' + selected);
    const legacy = /^\d{14}$/.test(selected.slice((target + '.backup.').length));
    if (legacy) console.log('Legacy snapshot. No original checksum was recorded.');
    process.stdout.write('Restore this snapshot and preserve the current configuration for recovery? [y/N]: ');
    const confirm = await lines.next();
    if (confirm.done || !/^(y|yes)$/i.test(confirm.value.trim())) return;
    const input = legacy ? selected : path.join(selected, 'config');
    if (!stat(input)?.isDirectory()) throw new Error('Backup configuration is missing or invalid.');
    const original = fingerprint(input);
    if (!legacy) {
      const manifestPath = path.join(selected, 'manifest.json');
      if (!stat(manifestPath)?.isFile()) throw new Error('Backup manifest is missing or invalid.');
      let manifest;
      try {
        manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
      } catch {
        throw new Error('Backup manifest could not be read.');
      }
      if (manifest?.version !== 1 || manifest.sha256 !== original) throw new Error('Backup contents do not match the saved checksum.');
    }
    copyTree(input, staged);
    if (fingerprint(staged) !== original) throw new Error('Backup could not be copied faithfully. Current configuration preserved.');
    activateRestore(target, staged, currentHash);
    console.log('Restored ' + target);
  } finally {
    stream.close();
  }
}

async function main() {
  if (!configured || !path.isAbsolute(configured)) throw new Error('Use an absolute configuration directory.');
  const target = path.resolve(configured);
  const parent = path.dirname(target);
  if (target === parent || target === os.homedir() || !fs.statSync(parent).isDirectory()) throw new Error('Select a dedicated configuration directory.');
  const repo = path.dirname(source);
  const physicalTarget = path.join(fs.realpathSync(parent), path.basename(target));
  const userDirectory = fs.realpathSync(os.homedir());
  if (repo === physicalTarget || repo.startsWith(physicalTarget + path.sep) || physicalTarget.startsWith(repo + path.sep) ||
      userDirectory === physicalTarget || userDirectory.startsWith(physicalTarget + path.sep)) throw new Error('Select a dedicated configuration directory outside this checkout.');
  if (process.argv.length === 3) {
    // The kernel releases this lock even if a transaction is killed. Keep the
    // lock file in place so concurrent callers always lock the same inode.
    const lock = target + '.dotclaude-lock';
    const file = stat(lock);
    if (file && !file.isFile()) throw new Error('Expected a regular lock file at ' + lock);
    process.umask(0o077);
    const args = process.platform === 'darwin' ? ['lockf', '-k', '-t', '0'] : ['flock', '-n'];
    const result = spawnSync(args[0], [...args.slice(1), lock, process.execPath, __filename, process.argv[2], '--locked'], { stdio: 'inherit' });
    if (result.error) throw result.error;
    if (result.status !== 0) process.exitCode = result.status || 1;
    return;
  }
  if (process.argv[3] !== '--locked') throw new Error('Unknown arguments.');
  recoverPending(target);
  const existing = stat(target);
  if (existing && !existing.isDirectory()) throw new Error('The configuration root must be a real directory.');
  const work = fs.mkdtempSync(path.join(parent, '.dotclaude-stage-'));
  try {
    if (process.argv[2] === 'install') install(target, work);
    else if (process.argv[2] === 'uninstall') await restore(target, path.join(work, 'new'), existing ? fingerprint(target) : null);
    else throw new Error('Unknown operation.');
  } finally {
    fs.rmSync(work, { recursive: true, force: true });
  }
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
