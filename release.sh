#!/usr/bin/env bash

# Install homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Symlink all zsh directories
ln -s $(pwd)/zsh/.p10k.zsh ~/.p10k.zsh
ln -s $(pwd)/zsh/.zshrc ~/.zshrc
ln -s $(pwd)/zsh/.aliases ~/.aliases

# Symlink Git Config
ln -s $(pwd)/git/.gitconfig ~/.gitconfig

# Symlink Tmux Config
ln -s $(pwd)/tmux/.tmux.conf ~/.tmux.conf

# Symlink nvim Config
mkdir -p ~/.config/nvim
ln -s $(pwd)/nvim/init.vim ~/.config/nvim/init.vim

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Oh My Zsh Plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/mroth/evalcache ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/evalcache

source ~/.zshrc

# Install dependencies
brew update

brew install direnv
brew install rbenv
brew install nodenv
brew install pyenv
brew install neovim
brew install node
brew install lsd
brew install ripgrep
brew install tmux
brew install git-delta

brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install

brew tap homebrew/cask-fonts
brew install font-hack-nerd-font

# Neovim config

# Install vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

pip3 install neovim
