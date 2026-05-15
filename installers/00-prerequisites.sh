#!/usr/bin/env bash
# Installs the tools that the remaining installer scripts themselves depend on:
# git, curl, wget, gpg.  Must run before any other step.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "00/12 · Prerequisites (git, curl, wget, gpg)"

case $DISTRO in

  macos)
    # git + curl ship with Xcode CLT; wget + gpg need Homebrew
    if ! command_exists git; then
        print_installing "Triggering Xcode Command Line Tools install..."
        xcode-select --install 2>/dev/null || true
        print_warning "Re-run this script after the Xcode CLT installer finishes"
        exit 1
    fi
    print_already "git ($(git --version))"
    print_already "curl"

    # Homebrew is required before we can install wget/gpg
    if ! command_exists brew; then
        print_installing "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add to PATH for Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        print_verified "Homebrew $(brew --version | head -1)"
    else
        print_already "Homebrew ($(brew --version | head -1))"
    fi

    for tool in wget gpg; do
        if command_exists "$tool"; then
            print_already "$tool"
        else
            print_installing "brew install $tool"
            brew install "$tool"
        fi
    done
    ;;

  ubuntu|debian|wsl)
    print_installing "apt install git curl wget gpg ca-certificates..."
    sudo apt update -qq
    sudo apt install -y git curl wget gpg ca-certificates
    ;;

  fedora)
    print_installing "dnf install git curl wget gpg..."
    sudo dnf install -y git curl wget gpg
    ;;

  centos|rhel)
    print_installing "yum install git curl wget gpg..."
    sudo yum install -y git curl wget gpg
    ;;

  *)
    print_warning "Unknown distro '$DISTRO' — skipping prerequisite install"
    ;;
esac

# ── Verify ────────────────────────────────────────────────
errors=0
for tool in git curl; do
    if command_exists "$tool"; then
        print_verified "$tool ($(${tool} --version 2>&1 | head -1))"
    else
        print_failed "$tool not found after installation"
        ((++errors))
    fi
done
# wget and gpg are optional (only needed for the eza fallback path on Debian)
for tool in wget gpg; do
    if command_exists "$tool"; then
        print_verified "$tool"
    else
        print_warning "$tool not found (needed only for the eza manual-install fallback)"
    fi
done

[ $errors -eq 0 ] || exit 1
