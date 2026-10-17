# devcontainer-features
Dev container Features useful for SAP CAP Development

## Publishing to GHCR

This repo includes a GitHub Actions workflow that publishes the feature collection in `./src` to GitHub Container Registry (GHCR).

- Registry: `ghcr.io`
- Namespace: `<owner>/<repo>` (for this repo: `abdulbasitg/devcontainer-features`)

Trigger a publish by pushing a semver tag:

```sh
update version in src/cap-tools/devcontainer-feature.json
git tag v1.0.0
git push origin v1.0.0
```

After publishing, the features can be referenced from:

- `ghcr.io/<owner>/<repo>/cap-tools`
- `ghcr.io/<owner>/<repo>/ai-tools`

The `ai-tools` feature installs Claude Code, GitHub Copilot CLI, and OpenAI Codex CLI independently. These AI CLIs are disabled by default. Ripgrep, jq, and uv are enabled by default; ShellCheck and Python are disabled by default.

```json
{
	"features": {
		"ghcr.io/<owner>/<repo>/ai-tools:1.0.0": {
			"install_claude": true,
			"install_copilot": false,
			"install_codex": true
	}
	}
}
```

