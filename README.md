# devcontainer-features

Dev Container Features for SAP CAP development.

## Features

### `cap-tools`

Installs SAP CAP development tools: `@sap/cds-dk`, MBT, Cloud Foundry CLI, SQLite, and the CAP MCP server. All installation switches are enabled by default.

### `ai-tools`

Provides Claude Code, GitHub Copilot CLI, OpenAI Codex CLI, and developer utilities. The three AI CLIs are disabled by default. Ripgrep, jq, and uv are enabled by default; ShellCheck and Python are disabled by default.

## Usage

Add both features under `features` in `.devcontainer/devcontainer.json`. This example enables every installation option:

```json
{
  "features": {
    "ghcr.io/abdulbasitg/devcontainer-features/cap-tools:2.0.0": {
      "install_cds_dk": true,
      "cds_dk_version": "latest",
      "install_mbt": true,
      "mbt_version": "latest",
      "install_cf_cli": true,
      "cf_cli_version": "v8",
      "install_sqlite3": true,
      "install_cdsmcp": true,
      "cdsmcp_version": "latest"
    },
    "ghcr.io/abdulbasitg/devcontainer-features/ai-tools:1.0.0": {
      "install_claude": true,
      "install_copilot": true,
      "install_codex": true,
      "install_ripgrep": true,
      "install_jq": true,
      "install_shellcheck": true,
      "install_python": true,
      "install_uv": true,
      "uv_version": "latest"
    }
  }
}
```

Set any `install_*` option to `false` to skip that tool. Version options can be pinned instead of using `latest`.

## Publishing

The GitHub Actions workflow publishes both features to GHCR on pushes to `main`, pushes of `v*.*.*` tags, or manual dispatch. Each feature's published version comes from its own `version` field in `src/<feature>/devcontainer-feature.json`; bump the version for each feature when releasing changes to it.