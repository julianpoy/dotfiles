#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo apt-get update

sudo apt-get install -y \
  curl gcc jq zip unzip btop tmux tmate vim python3 python3-pip \
  python3-pynvim \
  fish fonts-powerline \
  ripgrep fd-find \
  gh

sudo apt-get install -y netcat || sudo apt-get install -y netcat-openbsd

# Fish
sudo chsh -s /usr/bin/fish "$USER"
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish"
fish -c "fish \"$DOTFILES_DIR/fish-aliases.sh\""

# NVM
fish -c "fisher install jorgebucaran/nvm.fish"
$DOTFILES_DIR/nvmInstallVersion.sh v24.7.0
fish -c "set --universal nvm_default_version v24.7.0"
fish -c "set --universal nvm_default_packages yarn nx neovim typescript tsx"

# NeoVim
sudo rm -rf ~/.neovim-bin
mkdir ~/.neovim-bin
wget https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz -O ~/.neovim-bin/nvim-linux-x86_64.tar.gz
sudo tar -C ~/.neovim-bin -xzf ~/.neovim-bin/nvim-linux-x86_64.tar.gz
fish -c "alias vim='~/.neovim-bin/nvim-linux-x86_64/bin/nvim' && funcsave vim"
fish -c "alias nvim='~/.neovim-bin/nvim-linux-x86_64/bin/nvim' && funcsave nvim"
git config --global core.editor "~/.neovim-bin/nvim-linux-x86_64/bin/nvim"

mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/init.lua" "$HOME/.config/nvim/init.lua"

# Tmux config
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Tmate config
ln -sf "$DOTFILES_DIR/.tmate.conf" "$HOME/.tmate.conf"

# Git config
git config --global --replace-all --bool push.autoSetupRemote true

# Run local install.sh for machine-local config if exists
if [ -f ~/install.sh ]; then
  bash ~/install.sh
fi

