#!/usr/bin/env bash
# Shared utilities sourced by all installer scripts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DIVIDER="────────────────────────────────────────────────────"

print_step() {
    echo
    echo -e "${BOLD}${CYAN}┌${DIVIDER}┐${NC}"
    printf "${BOLD}${CYAN}│${NC}  %-49s${BOLD}${CYAN}│${NC}\n" "$1"
    echo -e "${BOLD}${CYAN}└${DIVIDER}┘${NC}"
}

print_already()    { echo -e "  ${GREEN}✓ Already installed:${NC} $1"; }
print_installing() { echo -e "  ${BLUE}→${NC} $1"; }
print_verified()   { echo -e "  ${GREEN}✓ Verified:${NC} $1"; }
print_skipped()    { echo -e "  ${YELLOW}⊘ Skipped:${NC} $1"; }
print_status()     { echo -e "  ${BLUE}·${NC} $1"; }
print_success()    { echo -e "  ${GREEN}✓${NC} $1"; }
print_warning()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_error()      { echo -e "  ${RED}✗${NC} $1" >&2; }
print_failed()     { echo -e "  ${RED}✗ Failed:${NC} $1" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"; DISTRO="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
        OS="linux"
        if command -v lsb_release >/dev/null 2>&1; then
            DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/os-release ]; then
            DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/redhat-release ]; then
            DISTRO="rhel"
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        OS="windows"; DISTRO="wsl"
    else
        OS="unknown"; DISTRO="unknown"
    fi
}
