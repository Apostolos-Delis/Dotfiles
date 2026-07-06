#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$DOTFILES_DIR/.agents/skills"
TARGET_DIRS=(
    "$HOME/.claude/skills"
    "$HOME/.codex/skills"
    "$HOME/.agents/skills"
)

link_skill() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ "$dest" -ef "$src" ]; then
        return
    fi

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        local backup
        backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "    Backed up existing $dest to $backup"
    fi

    ln -s "$src" "$dest"
    echo "    Linked $dest"
}

sync_catalog() {
    local dest_dir="$1"

    mkdir -p "$dest_dir"

    for skill_dir in "$SKILLS_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            local skill_name
            skill_name="$(basename "$skill_dir")"
            link_skill "$skill_dir" "$dest_dir/$skill_name"
        fi
    done
}

for target_dir in "${TARGET_DIRS[@]}"; do
    echo "==> Syncing shared skills to $target_dir"
    sync_catalog "$target_dir"
done
