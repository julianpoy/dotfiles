#!/bin/bash

DOTFILES_URI=${DOTFILES_URI:-https://github.com/julianpoy/dotfiles}

sudo apt-get update

sudo apt-get install -y \
  curl gcc jq zip unzip htop tmux vim python3 python3-pip \
  python3-pynvim \
  fish fonts-powerline \
  ripgrep fd-find \
  gh

sudo apt-get install -y netcat || sudo apt-get install -y netcat-openbsd

# Fish
sudo chsh -s /usr/bin/fish $USER
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
curl -sL $DOTFILES_URI/raw/master/fish-aliases.sh -o /tmp/fish-aliases.sh
fish -c "fish /tmp/fish-aliases.sh"

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
fish -c "set --universal nvm_default_version 22.12"
fish -c "set --universal nvm_default_packages yarn nx neovim typescript"
fish -c "nvm install 22.12"

# Nx
fish -c "set -Ux NX_REJECT_UNKNOWN_LOCAL_CACHE 0"

# NeoVim
sudo rm -rf ~/.neovim-bin
mkdir ~/.neovim-bin
wget https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O ~/.neovim-bin/nvim-linux64.tar.gz
sudo tar -C ~/.neovim-bin -xzf ~/.neovim-bin/nvim-linux64.tar.gz
fish -c "alias vim='~/.neovim-bin/nvim-linux64/bin/nvim' && funcsave vim"

mkdir -p $HOME/.config/nvim
curl -sL $DOTFILES_URI/raw/master/init.lua -o $HOME/.config/nvim/init.lua

# Tmux config
curl -sL $DOTFILES_URI/raw/master/.tmux.conf -o $HOME/.tmux.conf

# Git config
git config --global --add --bool push.autoSetupRemote true
