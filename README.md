# AI Box

A Podman container with Claude Code and the Codex CLI, intended for running either tool in the current project directory.

## Install

The launcher runs the published image `ghcr.io/infrabits/ai-box:main`. Install the launcher scripts with:

```sh
./scripts/install.sh
```

Then run `claude-box` or `codex-box` from a project directory. The launcher mounts that directory at `/workspace` and uses the matching tool configuration from your home directory when available.

`claude-box` requires `CLAUDE_CODE_OAUTH_TOKEN` in the environment. Generate a long-lived token once with `claude setup-token` and export it.

GitHub Actions builds the image for pushes to `main`, version tags (`v*`), pull requests, and nightly at 03:17 UTC. Pushes and nightly builds publish `ghcr.io/<owner>/<repository>` to GitHub Container Registry; pull requests build without publishing. The nightly build fetches current base image and tooling versions.

Renovate is configured in [`renovate.json`](renovate.json) to update the base image and GitHub Actions. Enable the Renovate GitHub App for the repository to receive dependency update pull requests.
