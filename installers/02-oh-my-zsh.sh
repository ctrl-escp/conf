#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "02/12 · Oh My Zsh + plugins"

PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

# ── Oh My Zsh ────────────────────────────────────────────
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_already "Oh My Zsh (~/.oh-my-zsh)"
else
    print_installing "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_verified "Oh My Zsh installed"
    else
        print_failed "~/.oh-my-zsh not found after installation"
        exit 1
    fi
fi

# ── zsh-autosuggestions ───────────────────────────────────
if [ -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    print_already "zsh-autosuggestions"
else
    print_installing "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
    if [ -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        print_verified "zsh-autosuggestions"
    else
        print_failed "zsh-autosuggestions clone failed"
        exit 1
    fi
fi

# ── zsh-syntax-highlighting ───────────────────────────────
if [ -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    print_already "zsh-syntax-highlighting"
else
    print_installing "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGINS_DIR/zsh-syntax-highlighting"
    if [ -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        print_verified "zsh-syntax-highlighting"
    else
        print_failed "zsh-syntax-highlighting clone failed"
        exit 1
    fi
fi
