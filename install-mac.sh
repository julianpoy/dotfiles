#!/bin/bash

DOTFILES_URI=${DOTFILES_URI:-https://github.com/julianpoy/dotfiles}

brew install fish jq btop python pynvim ripgrep fd neovim tmux tmate

# Fish
sudo chsh -s /usr/bin/fish $USER
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
curl -sL $DOTFILES_URI/raw/master/fish-aliases.sh -o /tmp/fish-aliases.sh
fish -c "fish /tmp/fish-aliases.sh"

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
$DOTFILES_URI/nvmInstallVersion.sh 24.7
fish -c "set --universal nvm_default_version 24.7"
fish -c "set --universal nvm_default_packages yarn nx neovim typescript tree-sitter-cli"

# NeoVim
git config --global core.editor "nvim"
mkdir -p $HOME/.config/nvim
curl -sL $DOTFILES_URI/raw/master/init.lua -o $HOME/.config/nvim/init.lua

# Tmux config
curl -sL $DOTFILES_URI/raw/master/.tmux.conf -o $HOME/.tmux.conf

# Tmate config
curl -sL $DOTFILES_URI/raw/master/.tmate.conf -o $HOME/.tmate.conf

# Git config
git config --global --replace-all --bool push.autoSetupRemote true
