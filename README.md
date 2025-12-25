# devcontainer-features
Dev container Features useful for SAP CAP Development

## Publishing to GHCR

This repo includes a GitHub Actions workflow that publishes the feature collection in `./src` to GitHub Container Registry (GHCR).

- Registry: `ghcr.io`
- Namespace: `<owner>/<repo>` (for this repo: `abdulbasitg/devcontainer-features`)

Trigger a publish by pushing a semver tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

After publishing, the feature can be referenced from:

- `ghcr.io/<owner>/<repo>/cap-tools`

