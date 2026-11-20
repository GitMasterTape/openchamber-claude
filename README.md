# openchamber-claude

[OpenChamber](https://github.com/openchamber/openchamber) built straight from
its official source with its own Dockerfile, plus the
[Claude Code](https://docs.claude.com/en/docs/claude-code) CLI so the Claude
Agent provider can find `claude` inside the container.

No third-party prebuilt OpenChamber image is used. Each build:

1. Reads the latest OpenChamber **release** from GitHub (pre-releases and canary
   builds are skipped).
2. Checks out that release tag from `openchamber/openchamber` and confirms the
   commit matches the tag.
3. Builds it with OpenChamber's own `Dockerfile`, unmodified.
4. Adds Claude Code from npm (`@anthropic-ai/claude-code`, published by Anthropic).
5. Smoke-tests the image and pushes it to GitHub Container Registry.

```
ghcr.io/gitmastertape/openchamber-claude:latest
```

The exact OpenChamber commit and Claude Code version of the current build are
in `versions.json`, and the commit is also stored in the image label
`dev.openchamber.commit`.

## Tags

| Tag | Meaning |
|---|---|
| `latest` | Newest OpenChamber release + newest Claude Code |
| `2.7.3` | That OpenChamber release, with whatever Claude Code was current when it was last built |
| `2.7.3-cc2.1.329` | Exact pair, never changes |

## How updates work

`.github/workflows/build.yml` runs every 4 hours. If the latest OpenChamber
release, its commit, or the latest Claude Code version differs from
`versions.json`, it rebuilds and commits the new `versions.json`. Those
commits also keep GitHub from disabling the schedule for inactivity.

Run it by hand from **Actions → Build and publish → Run workflow** (tick
*force* to rebuild without a version change).

Claude Code's own auto-updater is turned off in the image
(`DISABLE_AUTOUPDATER=1`); new versions arrive through rebuilds.

## What you're still trusting

Building from source removes the middleman image, but the build still pulls
what OpenChamber's Dockerfile pulls: the `oven/bun` base image, Debian
packages, npm packages from `bun.lock`, OpenCode from npm, and a
digest-pinned `cloudflared`. That's the same set the official build uses.

## Using it in Dockge (TrueNAS)

1. Copy `compose.example.yaml` into your stack and adjust the host paths.
   Make sure the datasets are owned by UID/GID 1000.
2. In Dockge's `.env` box set `OPENCHAMBER_UI_PASSWORD` and either
   `ANTHROPIC_API_KEY` or `CLAUDE_CODE_OAUTH_TOKEN`.
3. **Deploy** / **Update** the stack.

To pick up new builds, click **Update** in Dockge, or run an updater like
[What's Up Docker](https://github.com/getwud/wud) to notify or auto-update
when `latest` changes.

## Login note

Anthropic only permits Claude Pro/Max subscription logins in its own
products. Using a subscription token through a third-party app like
OpenChamber may be blocked or against the terms; an Anthropic API key
(`ANTHROPIC_API_KEY`) is the supported option.
