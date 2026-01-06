#!/usr/bin/env bash

set -e  # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# =============================================================================
# 1. Install Homebrew (if not installed)
# =============================================================================
if ! command -v brew &> /dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "==> Homebrew already installed"
fi

# =============================================================================
# 2. Install Homebrew packages first (dependencies for everything else)
# =============================================================================
echo "==> Installing Homebrew packages..."
brew update

brew install git        # Needed for cloning Oh My Zsh plugins
brew install neovim
brew install tmux
brew install node
brew install lsd
brew install ripgrep
brew install fzf
brew install git-delta
brew install direnv
brew install rbenv
brew install nodenv
brew install pyenv
brew install --cask amethyst

# Install FZF key bindings and completion
echo "==> Configuring FZF..."
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

# Install Nerd Font
echo "==> Installing Nerd Font..."
brew install font-hack-nerd-font

# =============================================================================
# 3. Install Oh My Zsh (before symlinking .zshrc which depends on it)
# =============================================================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    # RUNZSH=no prevents it from switching to zsh immediately
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "==> Oh My Zsh already installed"
fi

# =============================================================================
# 4. Install Oh My Zsh plugins and themes
# =============================================================================
echo "==> Installing Oh My Zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# evalcache (speeds up shell startup)
if [ ! -d "$ZSH_CUSTOM/plugins/evalcache" ]; then
    git clone https://github.com/mroth/evalcache "$ZSH_CUSTOM/plugins/evalcache"
fi

# =============================================================================
# 5. Create symlinks (after Oh My Zsh is installed)
# =============================================================================
echo "==> Creating symlinks..."

# Helper function to create symlinks safely
link_file() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -f "$dest" ]; then
        mv "$dest" "$dest.backup"
        echo "    Backed up existing $dest to $dest.backup"
    fi

    ln -s "$src" "$dest"
    echo "    Linked $dest"
}

# Zsh config
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/zsh/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/zsh/.workrc" "$HOME/.workrc"

# Git config
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Tmux config
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Neovim config
mkdir -p "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/nvim/init.vim" "$HOME/.config/nvim/init.vim"

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# =============================================================================
# 6. Neovim setup
# =============================================================================
echo "==> Setting up Neovim..."

# Install vim-plug
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "    Installing vim-plug..."
    curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Python support for Neovim
pip3 install --user neovim

# =============================================================================
# 7. Tmux Plugin Manager (TPM)
# =============================================================================
echo "==> Setting up Tmux Plugin Manager..."

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo "    TPM installed. Press prefix + I in tmux to install plugins."
else
    echo "    TPM already installed"
fi

# =============================================================================
# 8. Node.js packages
# =============================================================================
echo "==> Installing global npm packages..."
npm install --global yarn

# =============================================================================
# Done!
# =============================================================================
echo ""
echo "==> Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Open Neovim and run: :PlugInstall"
echo "  3. Start tmux and press: prefix + I (to install tmux plugins)"
echo ""
