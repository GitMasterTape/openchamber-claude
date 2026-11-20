# OpenChamber (arranhs/openchamber) with the Claude Code CLI bundled in.
#
# Build args are filled in by .github/workflows/build.yml:
#   OPENCHAMBER_VERSION  - tag of arranhs/openchamber to build on (e.g. 2.7.3)
#   CLAUDE_CODE_VERSION  - version of @anthropic-ai/claude-code (e.g. 2.1.50)
#   BASE_USER            - the user the base image runs as, so we can switch back

ARG OPENCHAMBER_VERSION=latest
FROM arranhs/openchamber:${OPENCHAMBER_VERSION}

ARG OPENCHAMBER_VERSION
ARG CLAUDE_CODE_VERSION=latest
ARG BASE_USER=root

USER root

# Install Claude Code system-wide so it lands on PATH for every user and is
# not hidden by a volume mounted over the home directory.
# Tries npm first, then bun (the upstream image is bun-based), then the
# official native installer as a last resort.
RUN set -eux; \
    if command -v npm >/dev/null 2>&1; then \
        npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"; \
        npm cache clean --force || true; \
    elif command -v bun >/dev/null 2>&1; then \
        BUN_INSTALL=/usr/local bun add -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"; \
        ln -sf /usr/local/bin/claude /usr/bin/claude 2>/dev/null || true; \
    else \
        export HOME=/opt/claude-code; mkdir -p "$HOME"; \
        if command -v curl >/dev/null 2>&1; then curl -fsSL https://claude.ai/install.sh -o /tmp/install.sh; \
        else wget -qO /tmp/install.sh https://claude.ai/install.sh; fi; \
        bash /tmp/install.sh "${CLAUDE_CODE_VERSION}"; \
        ln -sf "$(readlink -f /opt/claude-code/.local/bin/claude)" /usr/local/bin/claude; \
        chmod -R a+rX /opt/claude-code; rm -f /tmp/install.sh; \
    fi; \
    claude --version

# Updates come from rebuilding this image, not from Claude Code updating
# itself inside the container (which would be lost on recreate anyway).
ENV DISABLE_AUTOUPDATER=1

LABEL org.opencontainers.image.title="openchamber-claude" \
      org.opencontainers.image.description="arranhs/openchamber with the Claude Code CLI bundled" \
      dev.openchamber.version="${OPENCHAMBER_VERSION}" \
      com.anthropic.claude-code.version="${CLAUDE_CODE_VERSION}"

USER ${BASE_USER}
