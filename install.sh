#!/bin/bash

# Essentials
sudo apt-get install -y curl gcc jq htop tmux vim
sudo apt-get install -y netcat || sudo apt-get install -y netcat-openbsd

# Fish
sudo apt-get install fish fonts-powerline -y
sudo chsh -s /usr/bin/fish $USER
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
curl -sL $DOTFILES_URI/raw/master/fish-aliases.sh -o /tmp/fish-aliases.sh
fish -c "fish /tmp/fish-aliases.sh"

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
fish -c "nvm install 18"
fish -c "set --universal nvm_default_version 18"
fish -c "set --universal nvm_default_packages yarn nx neovim typescript"

# NeoVim
mkdir ~/.neovim-bin
curl -sL https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage -o ~/.neovim-bin/nvim.appimage
chmod +x ~/.neovim-bin/nvim.appimage
cd ~/.neovim-bin
~/.neovim-bin/nvim.appimage --appimage-extract
fish -c "alias vim='~/.neovim-bin/squashfs-root/usr/bin/nvim' && funcsave vim"

mkdir -p $HOME/.config/nvim
curl -sL $DOTFILES_URI/raw/master/init.lua -o $HOME/.config/nvim/init.lua

sudo apt-get install python3 python3-pip -y
pip3 install pynvim

sudo apt-get install ripgrep fd-find -y

# Tmux config
curl -sL $DOTFILES_URI/raw/master/.tmux.conf -o $HOME/.tmux.conf

# Ngrok
curl -sL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok-v3-stable-linux-amd64.tgz
sudo tar xvzf /tmp/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
