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
| [Rubocop](rubocop/) | Ruby linting with Airbnb style guide |

## Installation

```bash
git clone https://github.com/apostolos-delis/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./release.sh
```

The install script symlinks configs to their expected locations:

```
~/.zshrc         -> zsh/.zshrc
~/.p10k.zsh      -> zsh/.p10k.zsh
~/.aliases       -> zsh/.aliases
~/.gitconfig     -> git/.gitconfig
~/.tmux.conf     -> tmux/.tmux.conf
~/.config/nvim/  -> nvim/init.vim
```

**Note:** Ghostty config should be manually symlinked or copied:
```bash
mkdir -p ~/.config/ghostty
ln -s $(pwd)/ghostty/config ~/.config/ghostty/config
```

## Dependencies

### Required

- [Homebrew](https://brew.sh/) - Package manager
- [Neovim](https://neovim.io/) - `brew install neovim`
- [Tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Ghostty](https://ghostty.org/) - Terminal emulator
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

Status bar styled with Atom One Dark colors.

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

Leader: `,`

#### File Navigation (FZF)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Find git files |
| `<leader>fm` | Find modified files |
| `<leader>fb` | Find buffers |
| `;` | Command palette |

#### Git (Fugitive)

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame |
| `<leader>gg` | Git grep |

#### Quick Edits

| Key | Action |
|-----|--------|
| `<leader>ev` | Edit vimrc |
| `<leader>ez` | Edit zshrc |
| `<leader>et` | Edit tmux.conf |
| `<leader>ea` | Edit aliases |

#### Linting (ALE)

- Auto-fix on save enabled
- Per-language formatters: black (Python), prettier (JS/TS), standardrb (Ruby)
- `<leader>ae` / `<leader>aE` - Navigate errors

#### Other

| Key | Action |
|-----|--------|
| `Ctrl+f` | Toggle NERDTree |
| `Ctrl+t` | Toggle Tagbar |
| `<leader>dw` | Delete trailing whitespace |
| `<leader>sp` | Toggle spell check |

### Git

- **Pager:** Delta with side-by-side diffs
- **Pull strategy:** Rebase

## Color Scheme

Atom One Dark is used consistently across all tools:

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#282c34` | Terminal, status bars |
| Foreground | `#abb2bf` | Primary text |
| Comment | `#5c6370` | Inactive elements |
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
│   └── .aliases
├── nvim/              # Neovim editor
│   ├── init.vim
│   └── UltiSnips/     # Code snippets
├── git/               # Git configuration
│   └── .gitconfig
├── rubocop/           # Ruby linting
│   └── .rubocop.yml
└── release.sh         # Installation script
```

## License

See [LICENSE](LICENSE) for details.
