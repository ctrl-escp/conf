#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "10/12 · sys-tools (pipdate, ollama-update, aptdate)"

TOOLS_DIR="$CONF_DIR/sys-tools"

tools=("pipdate" "ollama-update")
[[ "$DISTRO" != "macos" ]] && tools=("aptdate" "${tools[@]}")

errors=0
for name in "${tools[@]}"; do
    src="$TOOLS_DIR/${name}.sh"
    if [ ! -f "$src" ]; then
        print_warning "sys-tools/${name}.sh not found — skipping"
        continue
    fi
    chmod +x "$src"
    sudo rm -f "/usr/local/bin/$name"
    sudo ln -s "$src" "/usr/local/bin/$name"
    if command_exists "$name"; then
        print_verified "$name → $src"
    else
        print_failed "$name not found in PATH after linking"
        ((++errors))
    fi
done

[ $errors -eq 0 ] || exit 1
