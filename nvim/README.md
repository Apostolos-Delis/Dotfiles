# Installing Neovim for MacOS

First install Neovim

```bash
brew install neovim
```

Then install Plug
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then make sure to create the directory structure for nvim

```bash
mkdir -p ~/.config/nvim
curl -f -s -o ~/.config/nvim/init.vim \
https://raw.githubusercontent.com/Apostolos-Delis/Dotfiles/master/nvim/.nvimrc
```
Then to make sure the that all the python environments are setup:
```bash
python3 -m virtualenv ~/.config/nvim/env
source ~/.config/nvim/env/bin/activate
pip3 install neovim
pip install neovim
```
Finally to install all the plugins:
```bash
nvim +PlugInstall
```
