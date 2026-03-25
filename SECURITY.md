# Security Policy

## What This Repo Contains

This repository contains Claude Code configuration files only:
- Agent and skill definitions (markdown)
- Slash command definitions (markdown)
- Settings schema (`settings.json` template)
- MCP server configuration template (`mcp.json`)

**It does not contain:**
- API keys or tokens of any kind
- Personal data
- Credentials or secrets
- Machine-specific absolute paths (the settings template uses env vars)

## The Install Script

The install script (`install.sh`) copies files locally and installs plugins via
the Claude Code plugin marketplace system. It does not transmit data to any
third-party service. It does not make network requests beyond standard Claude
Code plugin installation.

## Credential Handling

All credentials referenced in `mcp.json` are environment variable references:

```json
"GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
```

Never store real credentials in config files. Always use environment variables.
The `.gitignore` excludes `settings.local.json` (where per-machine credentials
or overrides live) and `.env` files.

## Reporting a Vulnerability

If you find a security issue in this configuration — a hook that could be
exploited, a permission that's too broad, or a pattern that creates risk —
please open a GitHub issue tagged `security`.

For sensitive reports, use GitHub's private vulnerability reporting feature.

We aim to respond within 48 hours.

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | ✅ Yes     |
| < 1.0   | ❌ No      |
