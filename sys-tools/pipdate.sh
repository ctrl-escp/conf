#!/bin/bash
# Update all outdated pip packages.
# Usage: pipdate [python-executable]
#   python-executable  path or name of the Python to use (default: python3)
set -euo pipefail

if [[ "$#" -eq 1 ]]; then
    PYEXEC="$1"
else
    PYEXEC="python3"
fi

if ! command -v "$PYEXEC" &>/dev/null; then
    echo "Python executable not found: $PYEXEC"
    exit 1
fi

echo "Using: $($PYEXEC --version) ($PYEXEC)"

# --user is invalid inside a virtualenv
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    USER_FLAG=()
else
    USER_FLAG=(--user)
fi

OUTDATED=$($PYEXEC -m pip list -o 2>/dev/null | awk 'FNR > 2 {print $1}') || {
    echo "Failed to query pip outdated packages. Aborting."
    exit 1
}

if [[ -z "$OUTDATED" ]]; then
    echo "No outdated packages found"
    exit 0
fi

package_count=$(echo "$OUTDATED" | wc -w | tr -d ' ')
echo "Updating $package_count package(s): $OUTDATED"

# Upgrade pip itself first if it's in the list
if echo "$OUTDATED" | grep -qw pip; then
    $PYEXEC -m pip install -U pip "${USER_FLAG[@]}"
fi

for package in $OUTDATED; do
    $PYEXEC -m pip install -U "$package" "${USER_FLAG[@]}"
done
