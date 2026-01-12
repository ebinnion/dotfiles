#!/bin/bash
set -euo pipefail

# Dotfile sync - creates symlinks from home directory to this repo (source of truth)
# Regular files: explicit mappings
# Skills: auto-discovered by finding SKILL.md files, flattened by parent directory name

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Regular file symlinks: SOURCE (in repo) -> DESTINATION (in home)
SYMLINKS="
zshrc                           ~/.zshrc
claude/settings.json            ~/.claude/settings.json
"

# Skills configuration
SKILLS_SOURCE="skills"
SKILLS_DEST="$HOME/.claude/skills"

# Track created skills for stale cleanup
created_skill_names=()
created_skill_dirs=()

find_created_skill_index() {
	local name="$1"
	local i

	for i in "${!created_skill_names[@]}"; do
		if [[ "${created_skill_names[$i]}" == "$name" ]]; then
			echo "$i"
			return 0
		fi
	done

	return 1
}

echo "Syncing dotfiles..."
echo ""

# Phase 1: Regular file symlinks
echo "Files:"
while IFS= read -r line; do
	# Skip empty lines and comments
	[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

	# Parse source and destination
	read -r source dest <<< "$line"
	if [[ -z "$dest" ]]; then
		continue
	fi

	# Expand tilde in destination
	dest="${dest/#\~/$HOME}"
	source_path="$SCRIPT_DIR/$source"

	if [[ ! -e "$source_path" ]]; then
		echo "  SKIP: $source (not found in repo)"
		continue
	fi

	# Create destination directory if needed
	dest_dir="$(dirname "$dest")"
	mkdir -p "$dest_dir"

	# Remove existing symlink at destination (never delete real files/dirs)
	if [[ -L "$dest" ]]; then
		existing_target="$(readlink "$dest")"
		if [[ "$existing_target" == "$source_path" ]]; then
			echo "  OK: $source -> $dest (already linked)"
			continue
		fi
		rm -f "$dest"
	elif [[ -e "$dest" ]]; then
		echo "  SKIP: $source -> $dest (destination exists and is not a symlink)"
		continue
	fi

	# Create symlink
	ln -s "$source_path" "$dest"
	echo "  OK: $source -> $dest"
done <<< "$SYMLINKS"

echo ""

# Phase 2: Skills symlinks
echo "Skills:"

# Find all SKILL.md files and create symlinks
while IFS= read -r skill_file; do
	# Get the parent directory (skill directory)
	skill_dir="$(dirname "$skill_file")"

	# Get just the skill name (immediate parent of SKILL.md)
	skill_name="$(basename "$skill_dir")"

	# Check for naming conflicts
	if existing_index="$(find_created_skill_index "$skill_name")"; then
		echo "  CONFLICT: $skill_name already exists from ${created_skill_dirs[$existing_index]}"
		echo "            skipping $skill_dir"
		continue
	fi

	# Track this skill
	created_skill_names+=("$skill_name")
	created_skill_dirs+=("$skill_dir")

	# Create skills destination directory if needed
	mkdir -p "$SKILLS_DEST"

	# Full paths
	source_path="$SCRIPT_DIR/$skill_dir"
	dest_path="$SKILLS_DEST/$skill_name"

	# Remove existing symlink at destination (never delete real files/dirs)
	if [[ -L "$dest_path" ]]; then
		existing_target="$(readlink "$dest_path")"
		if [[ "$existing_target" == "$source_path" ]]; then
			echo "  OK: $skill_name -> $dest_path (already linked)"
			continue
		fi
		rm -f "$dest_path"
	elif [[ -e "$dest_path" ]]; then
		echo "  SKIP: $skill_name -> $dest_path (destination exists and is not a symlink)"
		continue
	fi

	# Create symlink
	ln -s "$source_path" "$dest_path"
	echo "  OK: $skill_name -> $dest_path"
done < <(find "$SCRIPT_DIR/$SKILLS_SOURCE" -name "SKILL.md" 2>/dev/null | sed "s|$SCRIPT_DIR/||" | sort)

echo ""

# Phase 3: Stale symlink cleanup
echo "Checking for stale symlinks..."
stale_found=false

if [[ -d "$SKILLS_DEST" ]]; then
	for link in "$SKILLS_DEST"/*; do
		[[ -e "$link" || -L "$link" ]] || continue

		link_name="$(basename "$link")"

		# Skip if this was just created
		if find_created_skill_index "$link_name" >/dev/null; then
			continue
		fi

		# Only handle symlinks (don't touch regular files/dirs)
		if [[ -L "$link" ]]; then
			stale_found=true
			read -p "  Remove stale symlink $link? [y/N] " answer
			if [[ "$answer" =~ ^[Yy]$ ]]; then
				rm "$link"
				echo "  REMOVED: $link_name"
			else
				echo "  KEPT: $link_name"
			fi
		fi
	done
fi

if [[ "$stale_found" == false ]]; then
	echo "  No stale symlinks found."
fi

echo ""
echo "Done."
