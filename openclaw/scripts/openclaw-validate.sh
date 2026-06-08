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

echo "==> Checking OpenClaw tracked files"
assert_exists "$DOTFILES_DIR/openclaw/README.md"
assert_exists "$DOTFILES_DIR/openclaw/config.patch.json"
assert_exists "$DOTFILES_DIR/openclaw/scripts/openclaw-setup.sh"
assert_exists "$DOTFILES_DIR/openclaw/scripts/openclaw-validate.sh"
for file in AGENTS.md HEARTBEAT.md IDENTITY.md MEMORY.md TOOLS.md USER.md; do
    assert_exists "$DOTFILES_DIR/openclaw/workspace/$file"
done

echo "==> Checking shell syntax"
bash -n "$DOTFILES_DIR/openclaw/scripts/openclaw-setup.sh"
bash -n "$DOTFILES_DIR/openclaw/scripts/openclaw-validate.sh"

echo "==> Checking JSON syntax"
node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$DOTFILES_DIR/openclaw/config.patch.json"

echo "==> Checking tracked OpenClaw files for obvious secret literals"
if grep -R -E 'sk-(proj|live|org|admin)?-[A-Za-z0-9_-]{20,}' "$DOTFILES_DIR/openclaw" >/dev/null; then
    fail "OpenClaw files contain an OpenAI-looking secret"
fi

echo "==> Checking isolated setup links"
tmp_home="$(mktemp -d)"
fakebin="$(mktemp -d)"
fake_log="$(mktemp)"
trap 'rm -rf "$tmp_home" "$fakebin" "$fake_log"' EXIT
mkdir -p "$tmp_home/.openclaw" "$tmp_home/.codex"
printf '{"gateway":{"mode":"local"}}\n' > "$tmp_home/.openclaw/openclaw.json"
printf '{"OPENAI_API_KEY":"fake-openai-key"}\n' > "$tmp_home/.codex/auth.json"

cat > "$fakebin/openclaw" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$OPENCLAW_FAKE_LOG"
case "$1 $2" in
    "config get")
        exit 0
        ;;
    "plugins list")
        printf '{"plugins":[{"id":"codex"},{"id":"openai"},{"id":"telegram"},{"id":"workboard"}]}\n'
        exit 0
        ;;
    "models auth")
        if [ "$3" = "list" ]; then
            printf '{"profiles":[]}\n'
            exit 0
        fi
        if [ "$3" = "paste-api-key" ]; then
            cat >/dev/null
            exit 0
        fi
        ;;
    "config patch")
        if [ "${3:-}" = "--stdin" ]; then
            cat >/dev/null
        fi
        exit 0
        ;;
    "--version ")
        printf 'OpenClaw fake\n'
        exit 0
        ;;
esac
exit 0
EOF
chmod +x "$fakebin/openclaw"

HOME="$tmp_home" PATH="$fakebin:$PATH" OPENCLAW_FAKE_LOG="$fake_log" \
    "$DOTFILES_DIR/openclaw/scripts/openclaw-setup.sh" \
    --no-install-cli \
    --skip-onboard \
    --dotfiles "$DOTFILES_DIR" >/dev/null

for file in AGENTS.md HEARTBEAT.md IDENTITY.md MEMORY.md TOOLS.md USER.md; do
    assert_symlink_target "$tmp_home/.openclaw/workspace/$file" "$DOTFILES_DIR/openclaw/workspace/$file"
done

grep -q 'models auth paste-api-key' "$fake_log" || fail "setup did not import OpenClaw auth profile"
grep -q 'config patch --file' "$fake_log" || fail "setup did not apply config patch"
grep -q 'config patch --stdin' "$fake_log" || fail "setup did not write plugin allowlist"

echo "All OpenClaw orchestrator checks passed."
