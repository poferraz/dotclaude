# dotclaude

<img src="images/header.jpg" alt="dotclaude cover artwork" width="360">

dotclaude is a collection of instructions for Claude Code. It gives you a planner, a debugger and review commands that you can call by name. For example, use `/plan` in a project to break down a change and review the proposed steps before editing.

## Install

Use macOS or Linux with Git, Node.js 18 or later and Claude Code 2.1 or later. Clone the repository and review the files you intend to use. To install the collection into your Claude Code configuration, run the installer from the checkout.

```sh
git clone https://github.com/poferraz/dotclaude.git
cd dotclaude
sh scripts/install.sh
```

The installer adds missing files and preserves files that already exist at the same paths. By default it uses `~/.claude`. To try it in a separate directory, set `CLAUDE_CONFIG_DIR` to an absolute path when running the installer. The optional settings example requires a manual merge. Review it alongside your current permissions and plugins before applying any changes. [Settings example](config/settings.json) · [Installation and recovery](docs/customization.md)

Open a new Claude Code session in your project. Try `/plan Add a print button to the monthly report`, then review the plan and decide whether to proceed.

## My role and what changed

I selected and combined the agents, skills and commands, using AI tools to help develop the configuration. The planner asks for approval before implementation. Its instructions are separate from the testing guide, which the test-driven-development agent loads when needed. [Planner](config/agents/planner.md) · [Test agent](config/agents/tdd-guide.md)

An earlier settings example approved `chmod` commands too broadly. The project removed that permission. Reviewing the research citations also led to narrower claims about what the studies actually tested. [Permission correction](https://github.com/poferraz/dotclaude/commit/712beeda72bf29511532d112e5b11e90e7da6b4d) · [Citation correction](https://github.com/poferraz/dotclaude/commit/72b04ee34b2ef5cfd7ad6a5943865b01ace58e40)

## Repository guide

| Where | What you will find |
| --- | --- |
| [Global instructions](config/CLAUDE.md) | Preferences shared across projects using this profile |
| [Agents](config/agents/), [commands](config/commands/) and [skills](config/skills/) | The Markdown instructions Claude Code uses for individual tasks |
| [Scripts](scripts/) | Local installation, backup restoration and export of the shared instructions for four other tools |
| [Sources and credits](MANIFEST.md) | Which material was adapted and who created it |
| [Research](docs/research-notes.md) | The papers that influenced the design and the limits of their findings |

[Security and privacy](SECURITY.md) · [Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md) · [MIT license](LICENSE)
