#!/usr/bin/env bash
set -euo pipefail

# Minimal nice setup for Debian/Ubuntu
# curl-bash friendly, non-interactive, idempotent
# Meant to be used on distant hosts, new machines and containers, including dev containers

# Usage: curl -fsSL 'https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/min-setup-via-curl.sh' | bash

export DEBIAN_FRONTEND=noninteractive

echo "Updating package lists..."
echo "/////////////////////////"
sudo apt-get update

echo ""
echo "==> Installing packages..."
echo "//////////////////////////"
sudo apt-get install -y zsh htop neovim git trash-cli ripgrep

echo ""
echo "==> Downloading ~/.zshrc..."
echo "///////////////////////////"
curl -fsSL "https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/zsh/zshrc" -o ~/.zshrc

echo ""
echo "==> Configuring git..."
echo "//////////////////////"
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout

echo ""
# Set zsh as default shell for current user
CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)
if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "==> Setting zsh as default shell..."
	echo "///////////////////////////////////"
    sudo usermod -s "$ZSH_PATH" "$(whoami)"
else
    echo "==> zsh is already the default shell."
	echo "/////////////////////////////////////"
fi

echo ""
echo "==> Downloading ~/.config/nvim/init.lua..."
echo "//////////////////////////////////////////"
mkdir -p ~/.config/nvim
curl -fsSL "https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/nvim/init.lua" -o ~/.config/nvim/init.lua

# Tailscale hints
echo ""
if ! command -v tailscale &>/dev/null; then
    echo "==> Tailscale is not installed. To install:"
    echo "    curl -fsSL https://tailscale.com/install.sh | sh"
elif ! tailscale status &>/dev/null; then
    echo "==> Tailscale is installed but not running. To enable and give SSH access:"
    echo "    sudo tailscale up --ssh"
else
    echo "==> Tailscale is running (nice!). IP:"
    tailscale ip
    echo ""
    echo "==> Tailscale status:"
    tailscale status
fi

echo ""
echo "==> Done :)"