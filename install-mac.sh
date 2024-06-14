#!/bin/bash

DOTFILES_URI=${DOTFILES_URI:-https://github.com/julianpoy/dotfiles}

brew install fish jq python pynvim ripgrep fd neovim

# Fish
sudo chsh -s /usr/bin/fish $USER
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
curl -sL $DOTFILES_URI/raw/master/fish-aliases.sh -o /tmp/fish-aliases.sh
fish -c "fish /tmp/fish-aliases.sh"

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
fish -c "set --universal nvm_default_version 20"
fish -c "set --universal nvm_default_packages yarn nx neovim typescript tree-sitter-cli"
fish -c "nvm install 20"
fish -c "alias vim='~/.neovim-bin/squashfs-root/usr/bin/nvim' && funcsave vim"

mkdir -p $HOME/.config/nvim
curl -sL $DOTFILES_URI/raw/master/init.lua -o $HOME/.config/nvim/init.lua

# Tmux config
curl -sL $DOTFILES_URI/raw/master/.tmux.conf -o $HOME/.tmux.conf

# Git config
git config --global --add --bool push.autoSetupRemote true
