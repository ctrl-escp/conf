#!/bin/bash
set -euo pipefail

clr='\033[0;33m'
clr2='\033[0;36m'
noclr='\033[0m'

log() { echo -e "${clr}[APTDATE]${noclr} ${clr2}${1}${noclr}"; }

if [ "${1:-}" = "clean" ]; then
    log "Removing cache"
    sudo rm -rf /var/lib/apt/lists/*
    sudo apt clean
fi

log "Updating repositories"
sudo apt -y update

log "Upgrading available packages"
sudo apt -y dist-upgrade

log "Fixing unmet dependencies"
sudo apt install -f -y

log "Cleaning up"
sudo apt -y autoremove

log "Done"
