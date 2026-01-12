#!/bin/bash

# Dotfile sync - copies files/dirs from source locations into this repo
# Format: SOURCE_PATH    DESTINATION (whitespace separated)
# Lines starting with # are comments

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

WHITELIST="
# Source                            Destination
~/.zshrc                            zshrc
~/.claude/settings.json             claude/settings.json
~/.claude/skills                    claude/skills
"

echo "Syncing dotfiles..."

while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Parse source and destination
    read -r source dest <<< "$line"
    if [[ -z "$dest" ]]; then
        echo "  SKIP: invalid whitelist entry (missing destination)"
        continue
    fi

    # Expand tilde
    source="${source/#\~/$HOME}"

    if [[ ! -e "$source" ]]; then
        echo "  SKIP: $source (not found)"
        continue
    fi

    # Create destination directory if needed
    dest_dir="$(dirname "$SCRIPT_DIR/$dest")"
    mkdir -p "$dest_dir"

    # Copy file or directory
    if [[ -d "$source" ]]; then
        rm -rf "$SCRIPT_DIR/$dest"
        cp -R "$source" "$SCRIPT_DIR/$dest"
        echo "  OK: $source -> $dest (dir)"
    else
        cp "$source" "$SCRIPT_DIR/$dest"
        echo "  OK: $source -> $dest"
    fi
done <<< "$WHITELIST"

echo ""
echo "Done. Git status:"
git -C "$SCRIPT_DIR" status --short
