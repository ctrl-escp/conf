#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "05/12 · Dev tools (Python LSP, Node LSP, shellcheck)"

_load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# ── pip install helper ────────────────────────────────────
# Handles two failure modes:
#   1. pip not installed at all
#   2. PEP 668 "externally-managed-environment" (Ubuntu 23.04+)
_pip_install() {
    local pkg=$1
    local err
    err=$(python3 -m pip install --user "$pkg" 2>&1) && return 0
    if echo "$err" | grep -q "externally-managed"; then
        python3 -m pip install --user --break-system-packages "$pkg"
    else
        echo "$err" >&2
        return 1
    fi
}

# ── Python tools ──────────────────────────────────────────
if command_exists python3; then
    # Ensure pip is available
    if ! python3 -m pip --version >/dev/null 2>&1; then
        print_installing "python3-pip not found — installing..."
        case $DISTRO in
            ubuntu|debian|wsl) sudo apt install -y python3-pip ;;
            fedora)            sudo dnf install -y python3-pip ;;
            centos|rhel)       sudo yum install -y python3-pip ;;
            *) print_warning "Cannot auto-install pip on $DISTRO — skipping Python tools" ;;
        esac
    fi

    if python3 -m pip --version >/dev/null 2>&1; then
        print_installing "Installing Python language tools via pip..."
        failed=()
        for pkg in "python-lsp-server[all]" black isort flake8 pylint mypy; do
            if _pip_install "$pkg" >/dev/null 2>&1; then
                print_success "pip: $pkg"
            else
                failed+=("$pkg")
                print_warning "pip: $pkg — failed"
            fi
        done

        if python3 -m black --version >/dev/null 2>&1; then
            print_verified "black $(python3 -m black --version 2>&1 | head -1)"
        else
            print_warning "black not importable — ~/.local/bin may not be in PATH yet"
        fi

        [ ${#failed[@]} -gt 0 ] && \
            print_warning "Some packages failed: ${failed[*]}"
    else
        print_warning "pip still unavailable — skipping Python language tools"
    fi
else
    print_warning "python3 not found — skipping Python language tools"
fi

# ── Node.js tools ─────────────────────────────────────────
_load_nvm
if command_exists npm; then
    print_installing "Installing Node.js language tools via npm..."
    if npm install -g typescript typescript-language-server eslint prettier 2>/dev/null; then
        for cmd in tsc typescript-language-server eslint prettier; do
            if command_exists "$cmd"; then
                print_verified "$cmd"
            else
                print_warning "$cmd not found after npm install"
            fi
        done
    else
        print_warning "Some npm packages failed — run manually if needed"
    fi
else
    print_warning "npm not found — skipping Node.js language tools (run 03-nvm.sh first)"
fi

# ── shellcheck ────────────────────────────────────────────
if command_exists shellcheck; then
    print_already "shellcheck $(shellcheck --version | grep version: | awk '{print $2}')"
else
    print_installing "Installing shellcheck..."
    case $DISTRO in
        macos)              brew install shellcheck ;;
        ubuntu|debian|wsl)  sudo apt install -y shellcheck ;;
        fedora)             sudo dnf install -y ShellCheck ;;
        *)  print_warning "Please install shellcheck manually" ;;
    esac
    if command_exists shellcheck; then
        print_verified "shellcheck $(shellcheck --version | grep version: | awk '{print $2}')"
    else
        print_warning "shellcheck not found after installation"
    fi
fi
