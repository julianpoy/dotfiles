#!/bin/bash

# Essentials
sudo apt-get install -y curl gcc

# Fish
sudo apt-add-repository ppa:fish-shell/release-3 -y
sudo apt-get update
sudo apt-get install fish -y
sudo apt-get install fonts-powerline -y
sudo chsh -s /usr/bin/fish $USER
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
curl -sL $DOTFILES_URI/raw/master/fish-aliases.sh -o /tmp/fish-aliases.sh
fish -c "fish /tmp/fish-aliases.sh"

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
fish -c "nvm install 18"
fish -c "set --universal nvm_default_version 18"
fish -c "set --universal nvm_default_packages yarn neovim"

# NeoVim
curl -sL https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage -o ~/nvim.appimage
chmod +x ~/nvim.appimage
cd ~
~/nvim.appimage --appimage-extract
fish -c "alias vim='~/squashfs-root/usr/bin/nvim' && funcsave vim"

mkdir -p $HOME/.config/nvim
curl -sL $DOTFILES_URI/raw/master/init.lua -o $HOME/.config/nvim/init.lua

sudo apt-get install python3 python3-pip -y
sudo apt-get install python3 -y
pip3 install pynvim

sudo apt-get install ripgrep -y
sudo apt-get install fd-find -y

# Tmux
sudo apt-get install tmux -y
curl -sL $DOTFILES_URI/raw/master/.tmux.conf -o $HOME/.tmux.conf

# Other Utils
sudo apt-get install netcat -y

