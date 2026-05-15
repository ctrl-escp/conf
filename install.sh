#!/usr/bin/env bash
# ====================================================================
# Development Environment Setup — orchestrator
#
# USAGE:
#   ./install.sh              # interactive: prompt for each step
#   ./install.sh -y           # automatic: run all required steps
#   ./install.sh <step>...    # selective: run only named steps
#
# STEPS (required):
#   prerequisites  zsh  oh-my-zsh  nvm  cli-tools  dev-tools
#   zsh-config  vim-config  nvim-config  eslint-config  sys-tools
#
# STEPS (optional — prompted interactively, skipped in auto mode):
#   git-config  zed-config
# ====================================================================

set -euo pipefail

if [[ $EUID -eq 0 && -z "${SUDO_USER:-}" ]]; then
    echo "Please don't run this script as root. It will use sudo when needed."
    exit 1
fi

CONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS="$CONF_DIR/installers"

# ── Step registry ─────────────────────────────────────────
# bash 3.2 (macOS default) has no associative arrays; use a case function instead.
_step_script() {
    case "$1" in
        prerequisites)  echo "00-prerequisites.sh" ;;
        zsh)            echo "01-zsh.sh" ;;
        oh-my-zsh)      echo "02-oh-my-zsh.sh" ;;
        nvm)            echo "03-nvm.sh" ;;
        cli-tools)      echo "04-cli-tools.sh" ;;
        dev-tools)      echo "05-dev-tools.sh" ;;
        zsh-config)     echo "06-zsh-config.sh" ;;
        vim-config)     echo "07-vim-config.sh" ;;
        nvim-config)    echo "08-nvim-config.sh" ;;
        eslint-config)  echo "09-eslint-config.sh" ;;
        sys-tools)      echo "10-sys-tools.sh" ;;
        git-config)     echo "11-git-config.sh" ;;
        zed-config)     echo "12-zed-config.sh" ;;
        *)              echo "" ;;
    esac
}

VALID_STEPS="prerequisites zsh oh-my-zsh nvm cli-tools dev-tools zsh-config vim-config nvim-config eslint-config sys-tools git-config zed-config"

REQUIRED_STEPS=(prerequisites zsh oh-my-zsh nvm cli-tools dev-tools
                zsh-config vim-config nvim-config eslint-config sys-tools)
OPTIONAL_STEPS=(git-config zed-config)

# ── Colors (minimal; each script has its own) ─────────────
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

_banner() {
    echo
    echo -e "${BOLD}${CYAN}=====================================================================${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BOLD}${CYAN}=====================================================================${NC}"
}

_run_step() {
    local name=$1
    local script="$INSTALLERS/$(_step_script "$name")"
    if [ ! -f "$script" ]; then
        echo -e "  ${YELLOW}⚠${NC} Script not found: $script"
        return 1
    fi
    bash "$script"
}

_prompt_step() {
    local name=$1
    printf "\n  Install %-18s? [Y/n] " "$name"
    if [ -t 0 ] || [ -c /dev/tty ]; then
        read -r answer </dev/tty
    else
        # No terminal available (CI/pipe) — default to yes
        answer="y"
        echo "y (no tty, defaulting to yes)"
    fi
    case "${answer:-y}" in
        [Yy]*|"") return 0 ;;
        *)         return 1 ;;
    esac
}

# ── Mode: selective (named args) ─────────────────────────
if [[ $# -gt 0 && "$1" != "-y" ]]; then
    _banner "Selective install: $*"
    for name in "$@"; do
        if [[ -z "$(_step_script "$name")" ]]; then
            echo "Unknown step: $name"
            echo "Valid steps: $VALID_STEPS"
            exit 1
        fi
        _run_step "$name"
    done
    echo
    echo -e "${GREEN}Done.${NC}"
    exit 0
fi

# ── Mode: auto (-y) ───────────────────────────────────────
if [[ "${1:-}" == "-y" ]]; then
    _banner "Automatic install (all required steps)"

    for name in "${REQUIRED_STEPS[@]}"; do
        _run_step "$name"
    done

    echo
    echo -e "${BOLD}${CYAN}=====================================================================${NC}"
    echo -e "${BOLD}  Optional components (skipped — install individually if needed)${NC}"
    echo -e "${BOLD}${CYAN}=====================================================================${NC}"
    echo
    echo "  Git config (.gitconfig, .gitignore):"
    echo "    $CONF_DIR/install.sh git-config"
    echo
    echo "  Zed editor settings:"
    echo "    $CONF_DIR/install.sh zed-config"
    echo
    echo -e "${BOLD}  Next steps:${NC}"
    echo "    1. Restart your terminal or run: exec zsh"
    echo "    2. Open nvim to bootstrap plugins: nvim"
    echo
    echo -e "${GREEN}Done.${NC}"
    exit 0
fi

# ── Mode: interactive (no args) ──────────────────────────
_banner "Interactive install — you will be prompted for each step"

all_steps=("${REQUIRED_STEPS[@]}" "${OPTIONAL_STEPS[@]}")

for name in "${all_steps[@]}"; do
    if _prompt_step "$name"; then
        _run_step "$name"
    else
        echo -e "  ${YELLOW}⊘${NC} Skipped: $name"
    fi
done

echo
echo -e "${BOLD}  Next steps:${NC}"
echo "    1. Restart your terminal or run: exec zsh"
echo "    2. Open nvim to bootstrap plugins: nvim"
echo
echo -e "${GREEN}Done.${NC}"
