# Dotfiles

Personal dotfiles for a macOS development environment. Optimized for full-stack development with Python, JavaScript/TypeScript, and Ruby.

## What's Included

| Tool | Description |
|------|-------------|
| [Ghostty](ghostty/) | GPU-accelerated terminal emulator |
| [Tmux](tmux/) | Terminal multiplexer with vim-style navigation |
| [Zsh](zsh/) | Shell with Powerlevel10k prompt and plugins |
| [Neovim](nvim/) | Editor with LSP, linting, and snippets |
| [Git](git/) | Git config with delta for beautiful diffs |
| [Claude Code](claude/) | AI coding assistant configuration |
| [Codex CLI](codex/) | OpenAI coding assistant configuration |
| [OpenClaw](openclaw/) | Control UI and Workboard orchestrator for parallel Codex sessions |
| [Rubocop](rubocop/) | Ruby linting with Airbnb style guide |

## Installation

```bash
git clone https://github.com/apostolos-delis/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./release.sh
```

The install script symlinks configs to their expected locations:

```
~/.zshrc              -> zsh/.zshrc
~/.p10k.zsh           -> zsh/.p10k.zsh
~/.aliases            -> zsh/.aliases
~/.workrc             -> zsh/.workrc
~/.gitconfig          -> git/.gitconfig
~/.tmux.conf          -> tmux/.tmux.conf
~/.config/nvim/       -> nvim/ (entire directory)
~/.config/ghostty/    -> ghostty/config
~/.claude/settings.json -> claude/settings.json
~/.claude/CLAUDE.md   -> claude/CLAUDE.md
~/.claude/commands/   -> claude/commands/*.md
~/.claude/skills/     -> .agents/skills/*
~/.claude/RTK.md      -> claude/RTK.md
~/.codex/config.toml  -> codex/config.toml
~/.codex/AGENTS.md    -> codex/AGENTS.md
~/.codex/skills/*     -> .agents/skills/* plus gstack skills from ~/.gstack/repos/gstack
~/.codex/RTK.md       -> codex/RTK.md
~/.openclaw/workspace/*.md -> openclaw/workspace/*.md
~/.openclaw/workspace/memory/ -> live OpenClaw memory notes (created, not tracked)
~/.agents/dotfiles-skills -> .agents/skills/
~/.tmux/plugins/tpm/  -> Tmux Plugin Manager (cloned)
```

## Dependencies

### Required

- [Homebrew](https://brew.sh/) - Package manager
- [Neovim](https://neovim.io/) - `brew install neovim`
- [Tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [TPM](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager (auto-installed)
- [Ghostty](https://ghostty.org/) - Terminal emulator
- [Claude Code](https://claude.ai/code) - AI coding assistant
- [Codex CLI](https://developers.openai.com/codex/) - AI coding assistant
- [OpenClaw](https://github.com/openclaw/openclaw) - Control UI and Workboard orchestrator for Codex sessions
- [RTK](https://github.com/rtk-ai/rtk) - Token-optimized CLI proxy for agent shell commands
- [Bun](https://bun.sh/) - Required for gstack skill installation (`brew install oven-sh/bun/bun`)
- [Oh-My-Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme
- [FZF](https://github.com/junegunn/fzf) - `brew install fzf`
- [Delta](https://github.com/dandavison/delta) - `brew install git-delta`
- [lsd](https://github.com/lsd-rs/lsd) - `brew install lsd`

### Language Tooling

- **Node.js**: via [NVM](https://github.com/nvm-sh/nvm)
- **Python 3**: with black, isort, flake8
- **Ruby**: via [rbenv](https://github.com/rbenv/rbenv)

## Configuration Details

### Ghostty

Minimal, fast terminal with transparency and blur.

- **Theme:** Atom One Dark
- **Font:** JetBrains Mono 14pt
- **Features:** 85% opacity, hidden titlebar, Option-as-Alt
- **Quick Terminal:** `Ctrl+`` for Quake-style dropdown

### Tmux

Prefix: `Ctrl+a`

| Key | Action |
|-----|--------|
| `v` | Vertical split |
| `s` | Horizontal split |
| `h/j/k/l` | Resize panes |
| `Ctrl+h/j/k/l` | Navigate panes (vim-aware) |
| `Space` / `Backspace` | Next/previous window |
| `c` | New window |
| `x` | Kill pane |
| `R` | Reload config |
| `S` | Sync panes (toggle) |
| `C-c` | New session |
| `C-f` | Find session |
| `prefix + I` | Install plugins |

#### Plugins (via TPM)

| Plugin | What it does |
|--------|--------------|
| tmux-sensible | Universal sane defaults |
| tmux-resurrect | Save/restore sessions across restarts |
| tmux-continuum | Auto-save every 15min, auto-restore on start |
| tmux-yank | Better clipboard integration |

Status bar styled with Atom One Dark colors. Includes undercurl support for Neovim LSP diagnostics.

### Zsh

- **Theme:** Powerlevel10k with git status, execution time
- **Plugins:** git, zsh-autosuggestions, zsh-syntax-highlighting, docker, fzf

#### Useful Aliases

| Alias | Action |
|-------|--------|
| `l` / `la` / `ll` | List files (lsd) |
| `lt` | Tree view |
| `gsedit` | Open git-modified files in nvim |
| `csedit` | Open git-modified files in VS Code |
| `root` | cd to git repo root |
| `fedit` | Fuzzy find + edit file |
| `fd` | Fuzzy find + cd to directory |
| `killp <port>` | Kill process on port |
| `cs <dir>` | cd + ls |

### Neovim

Modern Lua-based configuration using **lazy.nvim** plugin manager. Plugins auto-install on first launch.

Leader: `,`

#### Plugin Manager

- **lazy.nvim** - Fast, lazy-loading plugin manager (bootstraps itself)
- Run `:Lazy` to manage plugins
- Run `:Mason` to install LSP servers, linters, formatters

#### File Navigation (Telescope)

| Key | Action |
|-----|--------|
| `,ff` | Find files |
| `,fg` | Find git files |
| `,gf` | Live grep (search in files) |
| `,fm` | Find modified files |
| `,fb` | Find buffers |
| `,fh` | Recent files |
| `,fr` | Resume last search |
| `;` | Command palette |

#### Git

| Key | Action |
|-----|--------|
| `,gs` | Git status (Fugitive) |
| `,gb` | Git blame |
| `,gd` | Git diff split |
| `,gg` | Live grep |
| `]c` / `[c` | Next/prev git hunk |
| `,hs` | Stage hunk |
| `,hr` | Reset hunk |
| `,hp` | Preview hunk |
| `,tB` | Toggle inline blame |

#### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `,rn` | Rename symbol |
| `,ca` | Code action |
| `,cf` | Format buffer |
| `,ae` / `,aE` | Next/prev diagnostic |
| `,ad` | Show diagnostic |

#### Buffers & Windows

| Key | Action |
|-----|--------|
| `Tab` / `S-Tab` | Next/prev buffer |
| `[b` / `]b` | Cycle buffers |
| `,bp` | Pick buffer by letter |
| `,bd` | Delete buffer |
| `Ctrl+h/j/k/l` | Navigate splits (tmux-aware) |

#### Quick Edits

| Key | Action |
|-----|--------|
| `,ei` | Edit init.lua |
| `,ek` | Edit keymaps.lua |
| `,ez` | Edit zshrc |
| `,et` | Edit tmux.conf |
| `,ea` | Edit aliases |

#### Text Objects (Treesitter)

| Key | Action |
|-----|--------|
| `daf` / `dif` | Delete around/inside function |
| `dac` / `dic` | Delete around/inside class |
| `daa` / `dia` | Delete around/inside argument |
| `dal` / `dil` | Delete around/inside loop |

#### Other

| Key | Action |
|-----|--------|
| `-` | Open file explorer (Oil) |
| `,dw` | Delete trailing whitespace |
| `,sp` | Toggle spell check |
| `,tc` | Toggle treesitter context |
| `Space` | Toggle search highlight |

#### Plugins

| Plugin | Purpose |
|--------|---------|
| telescope.nvim | Fuzzy finder |
| nvim-treesitter | Syntax highlighting, text objects |
| nvim-lspconfig | LSP configuration |
| mason.nvim | LSP/linter/formatter installer |
| blink.cmp | Autocompletion |
| gitsigns.nvim | Git signs, inline blame |
| vim-fugitive | Git commands |
| bufferline.nvim | Buffer tabs |
| lualine.nvim | Statusline |
| onedark.nvim | Colorscheme (with transparency) |
| oil.nvim | File explorer |
| which-key.nvim | Keybinding hints |
| rainbow-delimiters | Colorful brackets |

### Git

- **Pager:** Delta with side-by-side diffs
- **Pull strategy:** Rebase

### Claude Code

AI coding assistant with global settings and custom commands.

- **Model:** Opus
- **Plugins:** claude-hud (status line), pyright-lsp

#### Permissions

Pre-configured to allow common dev tools (git, npm, python, docker, etc.) and deny access to sensitive files (.env, secrets, private keys).

#### Custom Commands

| Command | Description |
|---------|-------------|
| `/review` | Review git changes for issues |
| `/explain` | Explain how code works |
| `/test` | Generate tests for a file |

#### Global Memory

`CLAUDE.md` contains coding preferences, environment info, and workflow guidelines that apply to all projects.

#### Shared Skills

Reusable skills are stored once in `.agents/skills/` and linked into both Claude and Codex.

Command-equivalent skills for Codex include:
- `$review`, `$test`, `$explain`
- `$branch`, `$create-pr`, `$rebase`
- `$plan-review`, `$create-hook`, `$explore-repo`

Run parity check:

```bash
./claude/scripts/check-command-skill-parity.sh
```

### Codex CLI

Codex uses:
- `codex/config.toml` for runtime settings
- `codex/AGENTS.md` for global behavior/context
- Shared skills from `.agents/skills/`
- gstack skills installed by `release.sh` into `~/.codex/skills/gstack-*`

#### gstack for Codex

`release.sh` clones or updates `https://github.com/garrytan/gstack` at `~/.gstack/repos/gstack` and runs:

```bash
./setup --host codex --prefix --quiet
```

This exposes gstack's workflow skills in Codex with namespaced skill names such as `$gstack-office-hours`, `$gstack-autoplan`, `$gstack-review`, `$gstack-qa`, `$gstack-ship`, `$gstack-investigate`, and `$gstack-cso`. Namespacing keeps them from colliding with local skills like `$review` and `$test`.

#### RTK for Claude Code and Codex

`release.sh` installs `rtk` with Homebrew, verifies the Rust Token Killer binary with `rtk gain`, links tracked RTK awareness files into `~/.claude/RTK.md` and `~/.codex/RTK.md`, then runs:

```bash
rtk init -g --hook-only --auto-patch
```

Claude Code uses a `PreToolUse` Bash hook (`rtk hook claude`) so supported shell commands are rewritten transparently. Codex uses the inline RTK rule in `codex/AGENTS.md`, so shell commands should be prefixed with `rtk`; `codex/RTK.md` is linked as a reproducible companion reference.

Codex setup intentionally does not commit RTK's generated absolute `@/path/to/.codex/RTK.md` reference because that path is machine-specific. The portable source of truth is the inline RTK section in `codex/AGENTS.md` plus the `codex/RTK.md` symlink.

### OpenClaw

OpenClaw is configured as the local control plane for parallel Codex coding lanes:

- `openclaw/config.patch.json` enables the Codex runtime, Workboard, default model, and auth profile.
- `openclaw/workspace/` seeds the OpenClaw agent with local operating context, including `SOUL.md`, `MEMORY.md`, and `TOOLS.md`.
- `openclaw/scripts/openclaw-setup.sh` is the entry point used by `release.sh`; it installs OpenClaw if missing, installs the Codex plugin, links workspace files, applies config, and imports Codex CLI API-key auth when available.
- `~/.openclaw/openclaw.json` is not symlinked because OpenClaw and its Control UI own live config writes.
- `~/.openclaw/workspace/memory/` is created as an untracked live directory for daily or noisy memory notes.

Install or update the config:

```bash
./release.sh
```

Open the Control UI:

```bash
openclaw dashboard
```

Useful checks:

```bash
openclaw status
openclaw gateway status
openclaw logs --follow
openclaw sessions list
openclaw workboard list
```

Codex runtime commands from an OpenClaw chat:

```text
/codex status
/codex models
/codex threads
/codex resume <thread-id>
/codex bind --cwd <path>
/codex stop
```

When Conductor already created a workspace, bind OpenClaw/Codex to that workspace instead of creating another worktree inside it.

Run the self-check:

```bash
openclaw/scripts/openclaw-validate.sh
```

## Color Scheme

Atom One Dark is used consistently across all tools:

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#282c34` | Terminal, status bars |
| Foreground | `#abb2bf` | Primary text |
| Comment | `#7a818e` | Inactive elements (brightened) |
| Red | `#e06c75` | Errors, deletions |
| Green | `#98c379` | Success, additions |
| Yellow | `#e5c07b` | Warnings |
| Blue | `#61afef` | Info, links |
| Cyan | `#56b6c2` | Active elements |
| Magenta | `#c678dd` | Special |

## Structure

```
Dotfiles/
├── ghostty/           # Terminal emulator
│   └── config
├── tmux/              # Terminal multiplexer
│   └── .tmux.conf
├── zsh/               # Shell configuration
│   ├── .zshrc
│   ├── .p10k.zsh
│   ├── .aliases
│   └── .workrc        # Work-specific config (sourced separately)
├── nvim/              # Neovim editor (Lua-based)
│   ├── init.lua       # Entry point, lazy.nvim bootstrap
│   └── lua/
│       ├── config/    # Core settings
│       │   ├── options.lua
│       │   ├── keymaps.lua
│       │   └── autocmds.lua
│       └── plugins/   # Plugin specs (lazy.nvim)
│           ├── ui.lua
│           ├── editor.lua
│           ├── telescope.lua
│           ├── treesitter.lua
│           ├── lsp.lua
│           ├── completion.lua
│           └── git.lua
├── git/               # Git configuration
│   └── .gitconfig
├── .agents/
│   └── skills/        # Shared skills for Claude + Codex
├── claude/            # Claude Code AI assistant
│   ├── settings.json  # Global settings and permissions
│   ├── CLAUDE.md      # Global memory/context
│   └── commands/      # Custom slash commands
├── codex/             # Codex CLI assistant
│   ├── config.toml
│   └── AGENTS.md
├── openclaw/          # OpenClaw control plane for Codex lanes
│   ├── config.patch.json
│   ├── scripts/
│   └── workspace/
├── rubocop/           # Ruby linting
│   └── .rubocop.yml
└── release.sh         # Installation script
```

## License

See [LICENSE](LICENSE) for details.
