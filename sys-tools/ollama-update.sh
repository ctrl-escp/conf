#!/bin/bash
# ollama-update — pull the latest version of every locally installed Ollama model.
# Prints a line only for models that were actually updated; otherwise reports all up to date.
# Usage: ollama-update
set -euo pipefail

OLLAMA=$(command -v ollama 2>/dev/null) || { echo "ollama not found in PATH"; exit 1; }

before=$("$OLLAMA" list | awk 'NR>1 {print $1, $2}')
models=$(echo "$before" | awk '{print $1}')
total=$(echo "$models" | wc -l | tr -d ' ')

echo "Checking $total models for updates..."

while IFS= read -r model; do
    "$OLLAMA" pull "$model" >/dev/null 2>&1 || echo "Warning: failed to pull $model"
done <<< "$models"

after=$("$OLLAMA" list | awk 'NR>1 {print $1, $2}')

updated=0
updated_names=()
while IFS= read -r model; do
    id_before=$(echo "$before" | awk -v m="$model" '$1 == m {print $2}')
    id_after=$(echo "$after"  | awk -v m="$model" '$1 == m {print $2}')

    if [ -n "$id_before" ] && [ -n "$id_after" ] && [ "$id_before" != "$id_after" ]; then
        updated_names+=("$model")
        updated=$((updated + 1))
    fi
done <<< "$models"

if [ "$updated" -eq 0 ]; then
    echo "All $total models up to date"
else
    echo "Updated $updated/$total: ${updated_names[*]}"
fi
