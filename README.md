# openchamber-claude

[`arranhs/openchamber`](https://hub.docker.com/r/arranhs/openchamber) with the
[Claude Code](https://docs.claude.com/en/docs/claude-code) CLI bundled in, so
OpenChamber's Claude Agent provider can find `claude` inside the container.

Published to GitHub Container Registry:

```
ghcr.io/gitmastertape/openchamber-claude:latest
```

## Tags

| Tag | Meaning |
|---|---|
| `latest` | Newest OpenChamber + newest Claude Code |
| `2.7.3` | That OpenChamber version, with whatever Claude Code was current when it was last built |
| `2.7.3-cc2.1.50` | Exact pair, never changes |

## How updates work

`.github/workflows/build.yml` runs every 4 hours. It checks:

- the newest `x.y.z` tag of `arranhs/openchamber` on Docker Hub
- the `latest` version of `@anthropic-ai/claude-code` on npm

If either differs from `versions.json`, it rebuilds, pushes the new tags,
runs `claude --version` against the image as a smoke test, and commits the
new `versions.json`. Those commits also keep the scheduled workflow from
being auto-disabled for inactivity.

Run it by hand from **Actions → Build and publish → Run workflow** (tick
*force* to rebuild without a version change).

Claude Code's own auto-updater is turned off in the image
(`DISABLE_AUTOUPDATER=1`); new versions arrive through rebuilds.

## Using it in Dockge (TrueNAS)

1. After the first build, open the package on GitHub
   (**Profile → Packages → openchamber-claude → Package settings**) and set
   visibility to **Public** so TrueNAS can pull without logging in.
   (Or keep it private and run `docker login ghcr.io` on TrueNAS with a
   personal access token that has `read:packages`.)
2. In your OpenChamber stack, change the image to
   `ghcr.io/gitmastertape/openchamber-claude:latest`. See
   `compose.example.yaml` for the Claude-specific env and volume.
3. Check the container's user and home before adding the volume:
   `docker exec openchamber sh -c 'id; echo $HOME'`. Adjust the mount path
   to match, and make sure the TrueNAS dataset is owned by that UID.
4. **Update** the stack in Dockge.

### Pulling new builds onto TrueNAS

The workflow only publishes the image. To actually run a new build either:

- click **Update** on the stack in Dockge (pulls `latest` and recreates), or
- run an updater like [What's Up Docker](https://github.com/getwud/wud)
  on TrueNAS to notify or auto-update when `latest` changes.

## Login note

Anthropic only permits Claude Pro/Max subscription logins in its own
products. Using a subscription token through a third-party app like
OpenChamber may be blocked or against the terms; an Anthropic API key
(`ANTHROPIC_API_KEY`) is the supported option.
