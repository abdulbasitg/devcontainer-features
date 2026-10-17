#!/bin/sh
set -e

INSTALL_CLAUDE="${INSTALL_CLAUDE:-false}"
INSTALL_COPILOT="${INSTALL_COPILOT:-false}"
INSTALL_CODEX="${INSTALL_CODEX:-false}"
INSTALL_RIPGREP="${INSTALL_RIPGREP:-true}"
INSTALL_JQ="${INSTALL_JQ:-true}"
INSTALL_SHELLCHECK="${INSTALL_SHELLCHECK:-false}"
INSTALL_PYTHON="${INSTALL_PYTHON:-false}"
INSTALL_UV="${INSTALL_UV:-true}"
UV_VERSION="${UV_VERSION:-latest}"

if [ "$INSTALL_CLAUDE" = "true" ]; then
    echo "[ai-tools] Installing Claude Code CLI ..."
    npm install -g @anthropic-ai/claude-code
fi

if [ "$INSTALL_COPILOT" = "true" ]; then
    echo "[ai-tools] Installing GitHub Copilot CLI ..."
    npm install -g @github/copilot
fi

if [ "$INSTALL_CODEX" = "true" ]; then
    echo "[ai-tools] Installing OpenAI Codex CLI ..."
    npm install -g @openai/codex
fi

if [ "$INSTALL_RIPGREP" = "true" ] || [ "$INSTALL_JQ" = "true" ] || [ "$INSTALL_SHELLCHECK" = "true" ] || [ "$INSTALL_PYTHON" = "true" ]; then
    apt-get update -y
fi

if [ "$INSTALL_RIPGREP" = "true" ]; then
    echo "[ai-tools] Installing ripgrep ..."
    apt-get -y install --no-install-recommends ripgrep
fi

if [ "$INSTALL_JQ" = "true" ]; then
    echo "[ai-tools] Installing jq ..."
    apt-get -y install --no-install-recommends jq
fi

if [ "$INSTALL_SHELLCHECK" = "true" ]; then
    echo "[ai-tools] Installing ShellCheck ..."
    apt-get -y install --no-install-recommends shellcheck
fi

if [ "$INSTALL_PYTHON" = "true" ]; then
    echo "[ai-tools] Installing Python 3 with pip and venv support ..."
    apt-get -y install --no-install-recommends python3 python3-pip python3-venv
fi

if [ "$INSTALL_UV" = "true" ]; then
    echo "[ai-tools] Installing uv and uvx version ${UV_VERSION} ..."
    if [ "$UV_VERSION" = "latest" ]; then
        UV_INSTALL_URL="https://astral.sh/uv/install.sh"
    else
        UV_INSTALL_URL="https://astral.sh/uv/${UV_VERSION}/install.sh"
    fi
    UV_INSTALLER=$(mktemp)
    trap 'rm -f "$UV_INSTALLER"' 0
    curl -fsSL -o "$UV_INSTALLER" "$UV_INSTALL_URL"
    env UV_INSTALL_DIR="/usr/local/bin" sh "$UV_INSTALLER"
    rm -f "$UV_INSTALLER"
    trap - 0
fi