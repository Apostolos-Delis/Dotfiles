#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_exists() {
    [ -e "$1" ] || [ -L "$1" ] || fail "missing $1"
}

assert_symlink_target() {
    local link="$1"
    local target="$2"
    [ -L "$link" ] || fail "$link is not a symlink"
    local actual
    actual="$(readlink "$link")"
    [ "$actual" = "$target" ] || fail "$link points to $actual, expected $target"
}

echo "==> Checking Hermes tracked files"
assert_exists "$DOTFILES_DIR/hermes/config.yaml"
assert_exists "$DOTFILES_DIR/hermes/SOUL.md"
assert_exists "$DOTFILES_DIR/hermes/memories/MEMORY.md"
assert_exists "$DOTFILES_DIR/hermes/memories/USER.md"
assert_exists "$DOTFILES_DIR/hermes/profiles/codex-worker/config.yaml"
assert_exists "$DOTFILES_DIR/hermes/profiles/codex-worker/SOUL.md"
assert_exists "$DOTFILES_DIR/hermes/profiles/codex-worker/profile.yaml"
assert_exists "$DOTFILES_DIR/hermes/profiles/codex-worker/memories/MEMORY.md"
assert_exists "$DOTFILES_DIR/hermes/profiles/codex-worker/memories/USER.md"
assert_exists "$DOTFILES_DIR/hermes/skill-bundles/codex-pr-lane.yaml"

echo "==> Checking shell syntax"
for script in \
    "$DOTFILES_DIR/hermes/scripts/hermes-bootstrap.sh" \
    "$DOTFILES_DIR/hermes/scripts/hermes-kanban-create-codex-task" \
    "$DOTFILES_DIR/hermes/scripts/hermes-conductor-register-workspace" \
    "$DOTFILES_DIR/hermes/scripts/hermes-validate.sh"
do
    bash -n "$script"
done

echo "==> Checking YAML syntax"
ruby -ryaml -e 'ARGV.each { |path| YAML.load_file(path) }' \
    "$DOTFILES_DIR/hermes/config.yaml" \
    "$DOTFILES_DIR/hermes/profiles/codex-worker/config.yaml" \
    "$DOTFILES_DIR/hermes/profiles/codex-worker/profile.yaml" \
    "$DOTFILES_DIR/hermes/skill-bundles/codex-pr-lane.yaml"

echo "==> Checking memory seed budgets"
python3 - "$DOTFILES_DIR" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
checks = [
    (root / "hermes/memories/MEMORY.md", 2200),
    (root / "hermes/memories/USER.md", 1375),
    (root / "hermes/profiles/codex-worker/memories/MEMORY.md", 2200),
    (root / "hermes/profiles/codex-worker/memories/USER.md", 1375),
]
for path, limit in checks:
    text = path.read_text(encoding="utf-8")
    if len(text) > limit:
        raise SystemExit(f"{path} is {len(text)} chars, limit {limit}")
    if "\n§\n" not in text:
        raise SystemExit(f"{path} does not use Hermes memory delimiters")
PY

echo "==> Checking isolated bootstrap links"
tmp_home="$(mktemp -d)"
fake_repo=""
fakebin=""
fake_log=""
workspace_repo=""
trap 'rm -rf "$tmp_home" ${fake_repo:+"$fake_repo"} ${fakebin:+"$fakebin"} ${fake_log:+"$fake_log"} ${workspace_repo:+"$workspace_repo"}' EXIT
HOME="$tmp_home" "$DOTFILES_DIR/hermes/scripts/hermes-bootstrap.sh" --no-install --dotfiles "$DOTFILES_DIR" >/dev/null
assert_symlink_target "$tmp_home/.agents/dotfiles-skills" "$DOTFILES_DIR/.agents/skills"
assert_symlink_target "$tmp_home/.hermes/config.yaml" "$DOTFILES_DIR/hermes/config.yaml"
assert_symlink_target "$tmp_home/.hermes/SOUL.md" "$DOTFILES_DIR/hermes/SOUL.md"
assert_symlink_target "$tmp_home/.hermes/memories" "$DOTFILES_DIR/hermes/memories"
assert_symlink_target "$tmp_home/.hermes/skill-bundles" "$DOTFILES_DIR/hermes/skill-bundles"
assert_symlink_target "$tmp_home/.hermes/profiles/codex-worker/config.yaml" "$DOTFILES_DIR/hermes/profiles/codex-worker/config.yaml"
assert_symlink_target "$tmp_home/.hermes/profiles/codex-worker/SOUL.md" "$DOTFILES_DIR/hermes/profiles/codex-worker/SOUL.md"
assert_symlink_target "$tmp_home/.hermes/profiles/codex-worker/profile.yaml" "$DOTFILES_DIR/hermes/profiles/codex-worker/profile.yaml"
assert_symlink_target "$tmp_home/.hermes/profiles/codex-worker/memories" "$DOTFILES_DIR/hermes/profiles/codex-worker/memories"
assert_exists "$tmp_home/.local/bin/codex-worker"

echo "==> Checking task creation command composition"
fakebin="$(mktemp -d)"
fake_log="$(mktemp)"
cat > "$fakebin/hermes" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >> "$HERMES_FAKE_LOG"
printf '%s\n' '---' >> "$HERMES_FAKE_LOG"
EOF
chmod +x "$fakebin/hermes"

fake_repo="$(mktemp -d)"
git -C "$fake_repo" init -q
git -C "$fake_repo" config user.email test@example.com
git -C "$fake_repo" config user.name Tester
touch "$fake_repo/README.md"
git -C "$fake_repo" add README.md
git -C "$fake_repo" commit -q -m "initial"

(
    cd "$fake_repo"
    PATH="$fakebin:$PATH" HERMES_FAKE_LOG="$fake_log" \
        "$DOTFILES_DIR/hermes/scripts/hermes-kanban-create-codex-task" \
        --max-runtime 5m \
        --body "Make a tiny docs change." \
        "Smoke task"
)

grep -q '^kanban$' "$fake_log" || fail "task command did not call hermes kanban"
grep -q '^create$' "$fake_log" || fail "task command did not create a card"
grep -q '^Smoke task$' "$fake_log" || fail "task title missing"
grep -q '^--workspace$' "$fake_log" || fail "workspace flag missing"
grep -q '^worktree$' "$fake_log" || fail "worktree workspace missing"
grep -q '^--branch$' "$fake_log" || fail "branch flag missing"
grep -Eq '^apostolos/hermes_smoke_task_[0-9]{14}_[0-9]+$' "$fake_log" || fail "default branch name missing"
grep -q '^--skill$' "$fake_log" || fail "skill flag missing"
grep -q '^codex$' "$fake_log" || fail "codex skill missing"
grep -q '^github-pr-workflow$' "$fake_log" || fail "github-pr-workflow skill missing"

echo "==> Checking Conductor workspace registration command composition"
workspace_repo="$(mktemp -d)"
git -C "$workspace_repo" init -q
git -C "$workspace_repo" config user.email test@example.com
git -C "$workspace_repo" config user.name Tester
touch "$workspace_repo/README.md"
git -C "$workspace_repo" add README.md
git -C "$workspace_repo" commit -q -m "initial"
git -C "$workspace_repo" checkout -q -b apostolos/example_workspace
: > "$fake_log"

PATH="$fakebin:$PATH" HERMES_FAKE_LOG="$fake_log" \
    "$DOTFILES_DIR/hermes/scripts/hermes-conductor-register-workspace" \
    --max-runtime 10m \
    --body "Continue existing Conductor work." \
    "$workspace_repo" \
    "Conductor follow-up"

grep -q '^Conductor follow-up$' "$fake_log" || fail "Conductor task title missing"
grep -q '^worktree:' "$fake_log" || fail "Conductor workspace was not registered as worktree path"
grep -q '^apostolos/example_workspace$' "$fake_log" || fail "Conductor branch missing"
grep -q 'Do not create a nested worktree' "$fake_log" || fail "Conductor body missing nested-worktree guard"

echo "All Hermes orchestrator checks passed."
