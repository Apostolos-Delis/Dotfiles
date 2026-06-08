#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALL_CLI=true
UPGRADE_CLI=false
INSTALL_SERVICE=true
SKIP_ONBOARD=false
SKIP_PLUGINS=false
SKIP_AUTH=false
SKIP_CONFIG=false
SKIP_WORKSPACE=false
SET_PLUGIN_ALLOW=true
GATEWAY_MODE="none"

usage() {
    cat <<'EOF'
Usage: openclaw-setup.sh [OPTIONS]

Set up the Dotfiles-managed OpenClaw Codex orchestrator.

Options:
  --install-cli         Install OpenClaw if it is missing. Default.
  --no-install-cli      Do not install OpenClaw.
  --upgrade-cli         Run npm install -g openclaw@latest even if OpenClaw exists.
  --install-service     Install the gateway LaunchAgent/systemd service on first onboard. Default.
  --no-install-service  Do not install the gateway service during first onboard.
  --skip-onboard        Do not run first-run OpenClaw onboard.
  --skip-plugins        Do not install OpenClaw plugins.
  --skip-auth           Do not import Codex CLI API-key auth into OpenClaw.
  --skip-config         Do not apply openclaw/config.patch.json.
  --skip-workspace      Do not link workspace seed files.
  --skip-plugin-allow   Do not write plugins.allow from the installed plugin catalog.
  --gateway-start       Start the gateway service after setup.
  --gateway-restart     Restart the gateway service after setup.
  --gateway-status      Print gateway status after setup.
  --dotfiles PATH       Override Dotfiles repository path.
  -h, --help            Show this help.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --install-cli)
            INSTALL_CLI=true
            shift
            ;;
        --no-install-cli)
            INSTALL_CLI=false
            shift
            ;;
        --upgrade-cli)
            UPGRADE_CLI=true
            INSTALL_CLI=true
            shift
            ;;
        --install-service)
            INSTALL_SERVICE=true
            shift
            ;;
        --no-install-service)
            INSTALL_SERVICE=false
            shift
            ;;
        --skip-onboard)
            SKIP_ONBOARD=true
            shift
            ;;
        --skip-plugins)
            SKIP_PLUGINS=true
            shift
            ;;
        --skip-auth)
            SKIP_AUTH=true
            shift
            ;;
        --skip-config)
            SKIP_CONFIG=true
            shift
            ;;
        --skip-workspace)
            SKIP_WORKSPACE=true
            shift
            ;;
        --skip-plugin-allow)
            SET_PLUGIN_ALLOW=false
            shift
            ;;
        --gateway-start)
            GATEWAY_MODE="start"
            shift
            ;;
        --gateway-restart)
            GATEWAY_MODE="restart"
            shift
            ;;
        --gateway-status)
            GATEWAY_MODE="status"
            shift
            ;;
        --dotfiles)
            DOTFILES_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

DOTFILES_DIR="$(cd "$DOTFILES_DIR" && pwd)"

link_path() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        mv "$dest" "$dest.backup"
        echo "    Backed up existing $dest to $dest.backup"
    fi
    ln -s "$src" "$dest"
    echo "    Linked $dest"
}

install_openclaw() {
    if command -v openclaw >/dev/null 2>&1 && [ "$UPGRADE_CLI" = false ]; then
        echo "==> OpenClaw already installed: $(command -v openclaw)"
        openclaw --version
        return
    fi

    if [ "$INSTALL_CLI" = false ]; then
        echo "==> OpenClaw CLI is not installed or upgrade was requested but install is disabled."
        echo "    Run: npm install -g openclaw@latest"
        return
    fi

    if ! command -v npm >/dev/null 2>&1; then
        echo "==> npm is required to install OpenClaw. Install Node.js and rerun setup." >&2
        exit 1
    fi

    echo "==> Installing OpenClaw CLI"
    npm install -g openclaw@latest
}

openclaw_available() {
    command -v openclaw >/dev/null 2>&1
}

gateway_mode_configured() {
    openclaw config get gateway.mode --json >/dev/null 2>&1
}

random_token() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 24
    else
        node -e 'console.log(require("crypto").randomBytes(24).toString("hex"))'
    fi
}

run_first_onboard_if_needed() {
    if [ "$SKIP_ONBOARD" = true ] || gateway_mode_configured; then
        return
    fi

    local token
    token="$(random_token)"
    local args=(
        onboard
        --non-interactive
        --mode local
        --auth-choice skip
        --workspace "$HOME/.openclaw/workspace"
        --gateway-port 18789
        --gateway-bind loopback
        --gateway-auth token
        --gateway-token "$token"
        --skip-channels
        --skip-search
        --skip-skills
        --skip-ui
        --accept-risk
        --suppress-gateway-token-output
    )

    if [ "$INSTALL_SERVICE" = true ]; then
        args+=(--install-daemon)
    else
        args+=(--no-install-daemon --skip-health)
    fi

    echo "==> Running first-time OpenClaw onboard"
    openclaw "${args[@]}"
}

plugin_installed() {
    local plugin_id="$1"
    openclaw plugins list --json 2>/dev/null | node -e '
const id = process.argv[1];
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  try {
    const parsed = JSON.parse(input);
    const plugins = Array.isArray(parsed.plugins) ? parsed.plugins : [];
    process.exit(plugins.some(plugin => plugin && plugin.id === id) ? 0 : 1);
  } catch {
    process.exit(1);
  }
});
' "$plugin_id"
}

install_plugins() {
    if [ "$SKIP_PLUGINS" = true ]; then
        return
    fi

    if plugin_installed codex; then
        echo "==> OpenClaw Codex plugin already installed"
    else
        echo "==> Installing OpenClaw Codex plugin"
        openclaw plugins install @openclaw/codex
    fi
}

apply_config_patch() {
    if [ "$SKIP_CONFIG" = true ]; then
        return
    fi

    echo "==> Applying OpenClaw config patch"
    openclaw config patch --file "$DOTFILES_DIR/openclaw/config.patch.json"
}

profile_exists() {
    openclaw models auth list --provider openai --json 2>/dev/null | node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  try {
    const parsed = JSON.parse(input);
    const profiles = Array.isArray(parsed.profiles) ? parsed.profiles : [];
    process.exit(profiles.some(profile => profile && profile.id === "openai:codex-api-key") ? 0 : 1);
  } catch {
    process.exit(1);
  }
});
'
}

codex_api_key() {
    node -e '
const fs = require("fs");
const path = `${process.env.HOME}/.codex/auth.json`;
try {
  const parsed = JSON.parse(fs.readFileSync(path, "utf8"));
  const key = typeof parsed.OPENAI_API_KEY === "string" ? parsed.OPENAI_API_KEY.trim() : "";
  if (key) process.stdout.write(key);
} catch {}
'
}

import_codex_auth() {
    if [ "$SKIP_AUTH" = true ]; then
        return
    fi

    if profile_exists; then
        echo "==> OpenClaw OpenAI auth profile already exists"
        return
    fi

    local key
    key="$(codex_api_key)"
    if [ -z "$key" ]; then
        echo "==> No Codex CLI API key found at ~/.codex/auth.json."
        echo "    Configure OpenClaw auth manually:"
        echo "    openclaw models auth paste-api-key --provider openai --profile-id openai:codex-api-key"
        return
    fi

    echo "==> Importing Codex CLI API-key auth into OpenClaw"
    printf '%s\n' "$key" | openclaw models auth paste-api-key --provider openai --profile-id openai:codex-api-key
}

link_workspace_files() {
    if [ "$SKIP_WORKSPACE" = true ]; then
        return
    fi

    echo "==> Linking OpenClaw workspace files"
    for file in AGENTS.md HEARTBEAT.md IDENTITY.md MEMORY.md TOOLS.md USER.md; do
        link_path "$DOTFILES_DIR/openclaw/workspace/$file" "$HOME/.openclaw/workspace/$file"
    done

    if [ -e "$HOME/.openclaw/workspace/BOOTSTRAP.md" ] || [ -L "$HOME/.openclaw/workspace/BOOTSTRAP.md" ]; then
        mv "$HOME/.openclaw/workspace/BOOTSTRAP.md" "$HOME/.openclaw/workspace/BOOTSTRAP.md.backup"
        echo "    Backed up BOOTSTRAP.md"
    fi
}

write_plugin_allowlist() {
    if [ "$SET_PLUGIN_ALLOW" = false ]; then
        return
    fi

    echo "==> Writing explicit OpenClaw plugin allowlist"
    openclaw plugins list --json 2>/dev/null | node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  const parsed = JSON.parse(input);
  const ids = (Array.isArray(parsed.plugins) ? parsed.plugins : [])
    .map(plugin => plugin && plugin.id)
    .filter(id => typeof id === "string" && id.length > 0)
    .sort();
  process.stdout.write(JSON.stringify({ plugins: { allow: ids } }, null, 2));
});
' | openclaw config patch --stdin
}

handle_gateway() {
    case "$GATEWAY_MODE" in
        none)
            echo "==> OpenClaw setup complete. Open the dashboard with:"
            echo "    openclaw dashboard"
            ;;
        start)
            echo "==> Starting OpenClaw gateway"
            openclaw gateway start
            ;;
        restart)
            echo "==> Restarting OpenClaw gateway"
            openclaw gateway restart --safe --skip-deferral
            ;;
        status)
            openclaw gateway status
            ;;
    esac
}

install_openclaw

if ! openclaw_available; then
    echo "==> OpenClaw CLI is unavailable; skipping OpenClaw setup."
    exit 0
fi

run_first_onboard_if_needed
install_plugins
import_codex_auth
apply_config_patch
link_workspace_files
write_plugin_allowlist
handle_gateway
