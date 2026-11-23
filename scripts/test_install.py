"""Exercise the installer and recovery entry points in disposable profiles."""

import fcntl
import os
import sys
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parent


class ConfigTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix="dotclaude-test-")
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.profile = self.root / "test profile"
        tools = self.root / "bin"
        tools.mkdir()
        # The installer only needs the Claude CLI version. Never launch a session.
        claude = tools / "claude"
        claude.write_text("#!/bin/sh\necho '2.1.0 (fixture)'\n")
        claude.chmod(0o755)
        self.env = dict(os.environ, PATH=str(tools) + os.pathsep + os.environ["PATH"],
                        CLAUDE_CONFIG_DIR=str(self.profile))
        self.env.pop("NODE_OPTIONS", None)

    def command(self, action, answer="", success=True, **extra):
        result = subprocess.run(["sh", str(SCRIPTS / (action + ".sh"))], cwd=self.root,
                                env={**self.env, **extra}, input=answer,
                                capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode == 0, success, result.stderr)
        return result.stdout

    def snapshots(self, kind="backup"):
        return list(self.root.glob("test profile." + kind + ".*"))

    def test_install_repeat_and_restore_preserve_user_files(self):
        self.profile.mkdir()
        (self.profile / "CLAUDE.md").write_text("My instructions")
        (self.profile / "settings.json").write_text("{}")
        (self.profile / "notes.md").write_text("Personal notes")
        (self.profile / "notes-link").symlink_to("notes.md")
        self.command("install")
        self.assertEqual((self.profile / "CLAUDE.md").read_text(), "My instructions")
        self.assertEqual((self.profile / "settings.json").read_text(), "{}")
        self.assertEqual(os.readlink(self.profile / "notes-link"), "notes.md")
        self.assertTrue((self.profile / "agents/planner.md").is_file())
        self.command("install")
        self.assertEqual(len(self.snapshots()), 1)
        self.assertEqual(self.snapshots()[0].stat().st_mode & 0o777, 0o700)
        (self.profile / "notes.md").write_text("After installing")
        (self.profile / "new-file.txt").write_text("Keep me")
        self.command("uninstall", "n\n")
        self.assertTrue((self.profile / "new-file.txt").is_file())
        self.command("uninstall", "y\n")
        self.assertEqual((self.profile / "notes.md").read_text(), "Personal notes")
        self.assertFalse((self.profile / "agents").exists())
        saved = self.snapshots("recovery")[0] / "config"
        self.assertEqual((saved / "new-file.txt").read_text(), "Keep me")
        self.assertEqual((saved / "notes.md").read_text(), "After installing")

    def test_fresh_install_has_recoverable_empty_baseline(self):
        self.command("install")
        self.assertFalse((self.profile / "settings.json").exists())
        self.command("uninstall", "y\n")
        self.assertEqual(list(self.profile.iterdir()), [])
        self.assertTrue((self.snapshots("recovery")[0] / "config/CLAUDE.md").is_file())

    def test_missing_and_corrupt_snapshots_preserve_current_config(self):
        self.profile.mkdir()
        (self.profile / "own").write_text("Keep")
        self.command("uninstall", "y\n", success=False)
        self.command("install")
        backup = self.snapshots()[0]
        (backup / "config/own").write_text("Corrupted")
        self.command("uninstall", "y\n", success=False)
        (backup / "manifest.json").unlink()
        self.command("uninstall", "y\n", success=False)
        self.assertEqual((self.profile / "own").read_text(), "Keep")
        self.assertEqual(self.snapshots("recovery"), [])

    def test_symlinks_protect_external_directories(self):
        external = self.root / "external"
        external.mkdir()
        self.profile.symlink_to(external, target_is_directory=True)
        self.command("install", success=False)
        self.profile.unlink()
        self.profile.mkdir()
        (self.profile / "agents").symlink_to(external, target_is_directory=True)
        self.command("install", success=False)
        self.assertEqual(list(external.iterdir()), [])
        self.assertEqual(self.snapshots(), [])

    def test_second_install_and_legacy_restore_with_spaces(self):
        self.profile.mkdir()
        self.command("install")
        legacy = self.root / "test profile.backup.20000101000000"
        legacy.mkdir()
        (legacy / "prior").write_text("Legacy file")
        self.command("uninstall", "2\ny\n")
        self.assertEqual((self.profile / "prior").read_text(), "Legacy file")
        self.assertTrue((self.snapshots("recovery")[0] / "config/CLAUDE.md").is_file())

    def test_failed_activation_rolls_back_current_tree(self):
        self.command("install")
        (self.profile / "new-file.txt").write_text("Keep me")
        shim = self.root / "fail-activation.cjs"
        shim.write_text("""
const fs = require('node:fs');
const rename = fs.renameSync;
fs.renameSync = (from, to) => {
  if (from.endsWith('/new') && to === process.env.CLAUDE_CONFIG_DIR) throw new Error('simulated activation failure');
  return rename(from, to);
};
""")
        self.command("uninstall", "y\n", success=False, NODE_OPTIONS="--require=" + str(shim))
        self.assertEqual((self.profile / "new-file.txt").read_text(), "Keep me")
        self.assertTrue((self.profile / "CLAUDE.md").is_file())
        self.command("uninstall", "y\n")  # Retry after the failed transaction.
        self.assertEqual(list(self.profile.iterdir()), [])

    def test_install_preserves_inode_permissions_and_user_attributes(self):
        self.profile.mkdir()
        notes = self.profile / "notes"
        notes.write_text("original")
        notes.chmod(0o640)
        os.link(notes, self.profile / "linked notes")
        if sys.platform == "darwin":
            subprocess.run(["xattr", "-w", "org.example.dotclaude", "fixture", str(notes)], check=True)
            def attribute(file):
                return subprocess.check_output(["xattr", "-p", "org.example.dotclaude", str(file)]).strip()
        else:
            os.setxattr(notes, "user.dotclaude", b"fixture")
            def attribute(file):
                return os.getxattr(file, "user.dotclaude")
        inode = notes.stat().st_ino
        self.command("install")
        self.assertEqual(notes.stat().st_ino, inode)
        self.assertEqual((self.profile / "linked notes").stat().st_ino, inode)
        self.assertEqual(notes.stat().st_mode & 0o777, 0o640)
        self.assertEqual(attribute(notes), b"fixture")
        self.assertEqual(attribute(self.snapshots()[0] / "config/notes"), b"fixture")
        self.command("uninstall", "y\n")
        self.assertEqual(attribute(notes), b"fixture")

    def test_killed_restore_recovers_displaced_current_profile_on_retry(self):
        self.command("install")
        note = self.profile / "personal"
        note.write_text("changed after installation")
        shim = self.root / "interrupt.cjs"
        shim.write_text("""
const fs = require('node:fs');
const rename = fs.renameSync;
fs.renameSync = (from, to) => {
  if (from.endsWith('/new') && to === process.env.CLAUDE_CONFIG_DIR) process.kill(process.pid, 'SIGKILL');
  return rename(from, to);
};
""")
        self.command("uninstall", "y\n", success=False, NODE_OPTIONS="--require=" + str(shim))
        self.assertFalse(self.profile.exists())
        self.assertEqual((self.snapshots("recovery")[0] / "config/personal").read_text(), "changed after installation")
        self.command("install")
        self.assertEqual(note.read_text(), "changed after installation")
        self.assertFalse((self.root / "test profile.dotclaude-restore").exists())

    def test_partial_install_failure_preserves_the_original_tree(self):
        self.profile.mkdir()
        (self.profile / "keep").write_text("keep")
        shim = self.root / "fail-link.cjs"
        shim.write_text("""
const fs = require('node:fs');
const link = fs.linkSync;
let count = 0;
fs.linkSync = (from, to) => {
  if (++count === 3) throw new Error('simulated write failure');
  return link(from, to);
};
""")
        self.command("install", success=False, NODE_OPTIONS="--require=" + str(shim))
        self.assertEqual([p.name for p in self.profile.iterdir()], ["keep"])
        self.assertEqual((self.snapshots()[0] / "config/keep").read_text(), "keep")
        self.command("install")
        self.assertTrue((self.profile / "agents/planner.md").is_file())

    def test_busy_target_is_untouched(self):
        lock = self.root / "test profile.dotclaude-lock"
        with lock.open("w") as held:
            fcntl.flock(held.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            self.command("install", success=False)
        self.assertFalse(self.profile.exists())


if __name__ == "__main__":
    unittest.main()
