#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "01/12 · zsh"

# ── Check ────────────────────────────────────────────────
if command_exists zsh; then
    print_already "$(zsh --version)"
else
    # ── Install ──────────────────────────────────────────
    print_installing "Installing zsh..."
    case $DISTRO in
        macos)              brew install zsh ;;
        ubuntu|debian|wsl)  sudo apt install -y zsh ;;
        fedora)             sudo dnf install -y zsh ;;
        centos|rhel)        sudo yum install -y zsh ;;
        *)  print_error "Unsupported distro: $DISTRO"; exit 1 ;;
    esac

    # ── Verify ───────────────────────────────────────────
    if command_exists zsh; then
        print_verified "$(zsh --version)"
    else
        print_failed "zsh not found after installation"
        exit 1
    fi
fi

# ── Set as default shell ──────────────────────────────────
current_shell=$(basename "$SHELL")
if [ "$current_shell" = "zsh" ]; then
    print_status "Default shell is already zsh"
else
    target=$(which zsh)
    print_installing "Setting zsh as default shell (current: $SHELL)..."
    if ! grep -q "$target" /etc/shells 2>/dev/null; then
        echo "$target" | sudo tee -a /etc/shells >/dev/null
    fi
    if chsh -s "$target"; then
        print_success "Default shell set to zsh (restart terminal to take effect)"
    else
        print_warning "chsh failed — run manually: chsh -s $target"
    fi
fi
