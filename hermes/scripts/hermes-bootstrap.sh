#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALL_HERMES=false
SKIP_LINKS=false

usage() {
    cat <<'EOF'
Usage: hermes-bootstrap.sh [OPTIONS]

Install/link the Dotfiles-managed Hermes orchestrator configuration.

Options:
  --install-hermes     Install Hermes if it is not already on PATH.
  --no-install         Do not install Hermes; link/configure files only.
  --skip-links         Do not link Dotfiles files into ~/.hermes.
  --dotfiles PATH      Override Dotfiles repository path.
  -h, --help           Show this help.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --install-hermes)
            INSTALL_HERMES=true
            shift
            ;;
        --no-install)
            INSTALL_HERMES=false
            shift
            ;;
        --skip-links)
            SKIP_LINKS=true
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

backup_existing() {
    local dest="$1"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup="${dest}.backup.$(date -u +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "    Backed up $dest to $backup"
    fi
}

link_path() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        backup_existing "$dest"
    fi

    ln -s "$src" "$dest"
    echo "    Linked $dest"
}

install_hermes_if_needed() {
    if command -v hermes >/dev/null 2>&1; then
        echo "==> Hermes already installed: $(command -v hermes)"
        return
    fi

    if [ "$INSTALL_HERMES" != true ]; then
        echo "==> Hermes is not installed. Run:"
        echo "    $DOTFILES_DIR/hermes/scripts/hermes-bootstrap.sh --install-hermes"
        return
    fi

    local local_repo="${HERMES_REPO:-$HOME/Documents/repos/hermes-agent}"
    if [ -x "$local_repo/scripts/install.sh" ]; then
        echo "==> Installing Hermes from $local_repo"
        bash "$local_repo/scripts/install.sh" --skip-setup --skip-browser --hermes-home "$HOME/.hermes" --dir "$HOME/.hermes/hermes-agent"
    else
        echo "==> Installing Hermes from official installer"
        curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup --skip-browser
    fi
}

write_worker_wrapper() {
    local wrapper_dir="$HOME/.local/bin"
    local wrapper="$wrapper_dir/codex-worker"

    mkdir -p "$wrapper_dir"
    cat > "$wrapper" <<'EOF'
#!/usr/bin/env bash
exec hermes -p codex-worker "$@"
EOF
    chmod +x "$wrapper"
    echo "    Wrote $wrapper"
}

link_hermes_files() {
    mkdir -p "$HOME/.hermes/profiles/codex-worker" "$HOME/.agents"

    link_path "$DOTFILES_DIR/.agents/skills" "$HOME/.agents/dotfiles-skills"
    link_path "$DOTFILES_DIR/hermes/config.yaml" "$HOME/.hermes/config.yaml"
    link_path "$DOTFILES_DIR/hermes/SOUL.md" "$HOME/.hermes/SOUL.md"
    link_path "$DOTFILES_DIR/hermes/memories" "$HOME/.hermes/memories"
    link_path "$DOTFILES_DIR/hermes/skill-bundles" "$HOME/.hermes/skill-bundles"
    link_path "$DOTFILES_DIR/hermes/profiles/codex-worker/config.yaml" "$HOME/.hermes/profiles/codex-worker/config.yaml"
    link_path "$DOTFILES_DIR/hermes/profiles/codex-worker/SOUL.md" "$HOME/.hermes/profiles/codex-worker/SOUL.md"
    link_path "$DOTFILES_DIR/hermes/profiles/codex-worker/profile.yaml" "$HOME/.hermes/profiles/codex-worker/profile.yaml"
    link_path "$DOTFILES_DIR/hermes/profiles/codex-worker/memories" "$HOME/.hermes/profiles/codex-worker/memories"

    mkdir -p \
        "$HOME/.hermes/profiles/codex-worker/sessions" \
        "$HOME/.hermes/profiles/codex-worker/skills" \
        "$HOME/.hermes/profiles/codex-worker/logs" \
        "$HOME/.hermes/profiles/codex-worker/plans" \
        "$HOME/.hermes/profiles/codex-worker/workspace" \
        "$HOME/.hermes/profiles/codex-worker/cron" \
        "$HOME/.hermes/profiles/codex-worker/home"

    write_worker_wrapper
}

install_hermes_if_needed

if [ "$SKIP_LINKS" != true ]; then
    echo "==> Linking Hermes orchestrator files"
    link_hermes_files
fi

echo "==> Hermes orchestrator bootstrap complete"
