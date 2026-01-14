#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Get the current directory name (basename)
dir_name=$(basename "$current_dir")

# Check if we're in a git repo and get the branch
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    # Use --no-optional-locks to avoid lock issues
    branch=$(git -C "$current_dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    git_info=" $(printf '\033[35m')on $(printf '\033[0m')$(printf '\033[35m') $branch$(printf '\033[0m')"
else
    git_info=""
fi

# Build the status line with Starship-style formatting
# Format: [directory] [on branch] [model]
printf "$(printf '\033[36m')$dir_name$(printf '\033[0m')$git_info $(printf '\033[34m')[$model_name]$(printf '\033[0m')"
