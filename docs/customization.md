# Installation and recovery

## Start with a separate profile

From this checkout, choose an unused private directory outside your project. The following example uses a sibling directory named `dotclaude-trial`.

```sh
CLAUDE_CONFIG_DIR="$PWD/../dotclaude-trial" sh scripts/install.sh
```

For the default profile, follow the [README installation steps](../README.md#install). Existing files at matching paths keep their contents, including older dotclaude files. To adopt newer instructions or permissions, compare the installed files with the current source and review the differences before merging them. Reinstalling leaves previously configured hooks and permissions active. The installer prints the destination and the path of any backup it creates. Claude Code must use the same configuration directory to see those instructions.

For a smaller install, inspect a Markdown file in [commands](../config/commands/) or [agents](../config/agents/) and copy only what you need. If it names an agent or skill, include that dependency. For example, `/tdd` names `tdd-guide`, whose frontmatter names `tdd-workflow`. [Command](../config/commands/tdd.md) · [Agent](../config/agents/tdd-guide.md) · [Skill](../config/skills/tdd-workflow/SKILL.md)

## Settings and context

The [sample settings](../config/settings.json) are optional. Review each change against your own settings and edit the file manually. Use a separate project configuration for exceptions you need in only one repository. Measure context use in a representative task with your own host settings and enabled integrations.

Some skills describe workflows from larger projects. Check their prerequisites before invoking an external integration. Installing the Markdown collection does not install upstream plugins or provide credentials for them.

## Restore a backup

Stop sessions using the profile before restoring it. Run the uninstaller for the same target and review the backup it proposes before confirming.

```sh
CLAUDE_CONFIG_DIR="$PWD/../dotclaude-trial" sh scripts/uninstall.sh
```

For the default profile, run `sh scripts/uninstall.sh` without the environment override. The uninstaller stages the selected snapshot before it replaces the profile. It retains the displaced profile separately for recovery. Read the paths printed by the script. A backup or displaced profile can contain settings, private session data and credentials from the original directory. Keep these folders private. [Uninstaller](../scripts/uninstall.sh) · [Security and privacy](../SECURITY.md)

## Export the shared instructions

Run the converter from the destination project using the path to your checkout. If you already have instructions there, generate into an empty directory, compare the files and merge the parts you want.

```sh
sh /path/to/dotclaude/scripts/convert.sh codex
```

| Argument | Output in the current directory |
| --- | --- |
| `codex` | `AGENTS.md` |
| `gemini` | `GEMINI.md` |
| `cursor` | `.cursor/rules/dotclaude.mdc` |
| `aider` | `.aider.conf.yml` and `dotclaude-conventions.md` |

The export carries the shared working preferences. Claude Code agents, commands, skills and settings remain in their original format. [Converter](../scripts/convert.sh)
