#!/usr/bin/env bash
#
# Bootstrap script for setting up Neovim (this repo) + Zellij
# (github.com/Diaz1620/zellij-config) on a Linux machine — written for a
# ThinkPad T14, works on any x86_64 apt/dnf/pacman distro.
#
# What it does:
#   1. Installs kickstart.nvim's external requirements (git, make, gcc,
#      unzip, ripgrep, fd, a clipboard tool) via apt/dnf/pacman.
#   2. Installs the latest stable Neovim (distro package where recent
#      enough, otherwise the official release tarball into /opt).
#   3. Installs the latest Zellij release into ~/.local/bin.
#   4. Installs the JetBrainsMono Nerd Font into ~/.local/share/fonts.
#   5. Symlinks this repo to ~/.config/nvim, clones Diaz1620/zellij-config
#      (to ~/zellij-config) and symlinks it to ~/.config/zellij, backing up
#      anything already in those locations.
#
# Usage:
#   git clone git@github.com:Diaz1620/kickstart.nvim.git ~/kickstart.nvim
#   cd ~/kickstart.nvim
#   ./setup/thinkpad-setup.sh
#
# The script is idempotent: re-running it updates things in place.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZELLIJ_CONFIG_REPO="https://github.com/Diaz1620/zellij-config.git"
ZELLIJ_CONFIG_DIR="$HOME/zellij-config"
LOCAL_BIN="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$LOCAL_BIN" "$FONT_DIR"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Base packages
# ---------------------------------------------------------------------------
if command -v apt-get >/dev/null 2>&1; then
  PKG_MANAGER=apt
  info "Installing base packages with apt"
  sudo apt-get update
  sudo apt-get install -y git make gcc unzip curl xz-utils fontconfig \
    ripgrep fd-find xclip wl-clipboard
  # Ubuntu/Debian ship fd as "fdfind"; kickstart expects "fd" on PATH.
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
  fi
elif command -v dnf >/dev/null 2>&1; then
  PKG_MANAGER=dnf
  info "Installing base packages with dnf"
  sudo dnf install -y git make gcc unzip curl xz fontconfig \
    ripgrep fd-find xclip wl-clipboard
elif command -v pacman >/dev/null 2>&1; then
  PKG_MANAGER=pacman
  info "Installing base packages with pacman"
  sudo pacman -Syu --needed --noconfirm git make gcc unzip curl xz fontconfig \
    ripgrep fd xclip wl-clipboard
else
  echo "error: no supported package manager found (apt, dnf, or pacman)" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Neovim (latest stable)
# ---------------------------------------------------------------------------
install_neovim_tarball() {
  info "Installing Neovim from the official release tarball into /opt"
  curl -fsSL -o "$TMP_DIR/nvim.tar.gz" \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf "$TMP_DIR/nvim.tar.gz"
  ln -sf /opt/nvim-linux-x86_64/bin/nvim "$LOCAL_BIN/nvim"
}

case "$PKG_MANAGER" in
  pacman)
    # Arch's package tracks the latest stable release.
    sudo pacman -S --needed --noconfirm neovim
    ;;
  dnf)
    # Fedora's package is recent; fall back to the tarball if it's too old.
    sudo dnf install -y neovim
    if ! nvim --headless -c 'if !has("nvim-0.11") | cquit | endif' -c quit 2>/dev/null; then
      install_neovim_tarball
    fi
    ;;
  apt)
    # Debian/Ubuntu repos lag far behind; always use the official tarball.
    install_neovim_tarball
    ;;
esac

# ---------------------------------------------------------------------------
# 3. Zellij (latest release binary)
# ---------------------------------------------------------------------------
info "Installing Zellij into $LOCAL_BIN"
curl -fsSL \
  https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz |
  tar -xz -C "$LOCAL_BIN" zellij
chmod +x "$LOCAL_BIN/zellij"

# ---------------------------------------------------------------------------
# 4. Nerd Font (JetBrainsMono)
# ---------------------------------------------------------------------------
if ! fc-list | grep -qi 'JetBrainsMono Nerd Font'; then
  info "Installing JetBrainsMono Nerd Font"
  curl -fsSL -o "$TMP_DIR/JetBrainsMono.tar.xz" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
  mkdir -p "$FONT_DIR/JetBrainsMonoNerd"
  tar -xJf "$TMP_DIR/JetBrainsMono.tar.xz" -C "$FONT_DIR/JetBrainsMonoNerd"
  fc-cache -f "$FONT_DIR"
else
  info "JetBrainsMono Nerd Font already installed"
fi

# ---------------------------------------------------------------------------
# 5. Config repos and symlinks
# ---------------------------------------------------------------------------
if [ -d "$ZELLIJ_CONFIG_DIR/.git" ]; then
  info "Updating existing zellij-config clone"
  git -C "$ZELLIJ_CONFIG_DIR" pull --ff-only
else
  info "Cloning $ZELLIJ_CONFIG_REPO"
  git clone "$ZELLIJ_CONFIG_REPO" "$ZELLIJ_CONFIG_DIR"
fi

link_config() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$src" ]; then
    info "$dest already points at $src"
    return
  fi
  if [ -e "$dest" ]; then
    local backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    warn "backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  info "linked $dest -> $src"
}

link_config "$REPO_DIR" "$HOME/.config/nvim"
link_config "$ZELLIJ_CONFIG_DIR" "$HOME/.config/zellij"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
if ! printf '%s' "$PATH" | tr ':' '\n' | grep -qx "$LOCAL_BIN"; then
  warn "$LOCAL_BIN is not on your PATH. Add this to your shell profile:"
  echo '  export PATH="$HOME/.local/bin:$PATH"'
fi

info "All done. Next steps:"
echo "  1. Set your terminal's font to 'JetBrainsMono Nerd Font'."
echo "  2. Run 'nvim' once and let lazy.nvim install all plugins."
echo "  3. Run ':checkhealth' inside Neovim to verify the install."
echo "  4. Run ':Codeium Auth' to sign in to Windsurf/Codeium on this machine."
echo "  5. Run 'zellij' to start a session with your shared config."
