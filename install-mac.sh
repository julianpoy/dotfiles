#!/bin/bash

DOTFILES_URI=${DOTFILES_URI:-https://github.com/julianpoy/dotfiles}

brew install fish jq btop python pynvim ripgrep fd neovim tree-sitter-cli tmux imagemagick

# Fish
sudo chsh -s /usr/bin/fish $USER
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
curl -sL $DOTFILES_URI/raw/master/fish-aliases.sh -o /tmp/fish-aliases.sh
fish -c "fish /tmp/fish-aliases.sh"

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
fish -c "set --universal nvm_default_packages yarn nx neovim typescript"
$DOTFILES_URI/nvmInstallVersion.sh 24.22

# NeoVim
git config --global core.editor "nvim"
mkdir -p $HOME/.config/nvim
curl -sL $DOTFILES_URI/raw/master/init.lua -o $HOME/.config/nvim/init.lua

# Tmux config
curl -sL $DOTFILES_URI/raw/master/.tmux.conf -o $HOME/.tmux.conf

# Claude config
mkdir -p $HOME/.claude/output-styles $HOME/.claude/skills/review-changes $HOME/.claude/skills/grill-me
curl -sL $DOTFILES_URI/raw/master/claude/settings.json -o $HOME/.claude/settings.json
curl -sL $DOTFILES_URI/raw/master/claude/CLAUDE.md -o $HOME/.claude/CLAUDE.md
curl -sL $DOTFILES_URI/raw/master/claude/output-styles/plainspoken.md -o $HOME/.claude/output-styles/plainspoken.md
curl -sL $DOTFILES_URI/raw/master/claude/skills/review-changes/SKILL.md -o $HOME/.claude/skills/review-changes/SKILL.md
curl -sL $DOTFILES_URI/raw/master/claude/skills/grill-me/SKILL.md -o $HOME/.claude/skills/grill-me/SKILL.md
claude plugin marketplace add SergioGhisler/cc-inline-images-mod
claude plugin install inline-images@cc-inline-images-mod

# Git config
git config --global --replace-all --bool push.autoSetupRemote true
