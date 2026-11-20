# Adds the Claude Code CLI on top of an OpenChamber image that the workflow
# builds from the official source (github.com/openchamber/openchamber) using
# OpenChamber's own Dockerfile, unmodified.
#
# Build args (filled in by .github/workflows/build.yml):
#   BASE_IMAGE           - the locally built upstream image
#   CLAUDE_CODE_VERSION  - version of @anthropic-ai/claude-code to install

ARG BASE_IMAGE=openchamber-upstream:local
FROM ${BASE_IMAGE}

ARG CLAUDE_CODE_VERSION=latest

USER root

# Install system-wide into /usr/local so it stays on PATH even if a volume is
# mounted over parts of /home/openchamber. --prefix is needed because the
# upstream image sets NPM_CONFIG_PREFIX to the openchamber user's home.
RUN npm install -g --prefix /usr/local "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
 && npm cache clean --force \
 && claude --version

# Updates come from rebuilding this image, not from Claude Code updating
# itself inside the container (which would be lost on recreate anyway).
ENV DISABLE_AUTOUPDATER=1

LABEL org.opencontainers.image.title="openchamber-claude" \
      org.opencontainers.image.description="OpenChamber built from official source, with the Claude Code CLI bundled" \
      com.anthropic.claude-code.version="${CLAUDE_CODE_VERSION}"

# Same user as the upstream image
USER openchamber
