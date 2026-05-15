#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "03/12 · NVM + Node.js LTS"

_load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# ── NVM ──────────────────────────────────────────────────
if [ -d "$HOME/.nvm" ]; then
    print_already "NVM (~/.nvm)"
    _load_nvm
else
    print_installing "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    _load_nvm
    if [ -d "$HOME/.nvm" ]; then
        print_verified "NVM installed"
    else
        print_failed "~/.nvm not found after installation"
        exit 1
    fi
fi

# ── Node.js LTS ───────────────────────────────────────────
if command_exists node; then
    print_already "Node.js $(node --version)"
else
    print_installing "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    if command_exists node; then
        print_verified "Node.js $(node --version)"
    else
        print_failed "node not found after nvm install --lts"
        exit 1
    fi
fi

# ── npm sanity check ─────────────────────────────────────
if command_exists npm; then
    print_verified "npm $(npm --version)"
else
    print_warning "npm not found — may need to restart shell and re-run"
fi
