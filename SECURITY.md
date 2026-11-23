# Security and privacy

## Report a vulnerability

Send a private report to the maintainer through GitHub. Include the affected revision, the relevant configuration file and a synthetic example. Keep credentials, full configuration directories and private transcripts out of public issues. [Report privately](https://github.com/poferraz/dotclaude/security/advisories/new)

## What installation changes

The installer copies files into the chosen Claude Code profile. It leaves existing user files in place and prints backup locations. Installation and recovery operate on local files. Claude Code and any plugins you enable have their own data handling and permissions. [Installer](scripts/install.sh) · [Recovery guide](docs/customization.md)

The optional settings example requires a manual merge. Review its rules and the effective settings in your host. A user's existing hooks, plugins and project configuration may have effects beyond this collection. A Markdown instruction directs a model's behavior. Tool permissions and host settings control what the model can access.

The directory you back up or restore can contain logs, credentials, project paths and private settings. Keep copies in private storage and inspect their contents before sharing anything. For ordinary bug reports, use a short example with fictional paths and values.
