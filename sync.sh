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
SKILLS_DESTS=(
	"$HOME/.claude/skills"
	"$HOME/.codex/skills"
)

# Agents configuration
AGENTS_SOURCE="agents"
AGENTS_DEST="$HOME/.claude/agents"

# Track created skills for stale cleanup
created_skill_names=()
created_skill_dirs=()

# Track created agents for stale cleanup
created_agent_names=()

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

is_created_agent() {
	local name="$1"
	local agent

	for agent in "${created_agent_names[@]}"; do
		if [[ "$agent" == "$name" ]]; then
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

# Phase 2: Agents symlinks
echo "Agents:"

# Find all .md files in agents directory and create symlinks
if [[ -d "$SCRIPT_DIR/$AGENTS_SOURCE" ]]; then
	mkdir -p "$AGENTS_DEST"

	for agent_file in "$SCRIPT_DIR/$AGENTS_SOURCE"/*.md; do
		[[ -e "$agent_file" ]] || continue

		agent_name="$(basename "$agent_file")"
		created_agent_names+=("$agent_name")

		dest_path="$AGENTS_DEST/$agent_name"

		# Remove existing symlink at destination (never delete real files/dirs)
		if [[ -L "$dest_path" ]]; then
			existing_target="$(readlink "$dest_path")"
			if [[ "$existing_target" == "$agent_file" ]]; then
				echo "  OK: $agent_name (already linked)"
				continue
			fi
			rm -f "$dest_path"
		elif [[ -e "$dest_path" ]]; then
			echo "  SKIP: $agent_name (destination exists and is not a symlink)"
			continue
		fi

		# Create symlink
		ln -s "$agent_file" "$dest_path"
		echo "  OK: $agent_name -> $dest_path"
	done
else
	echo "  No agents directory found."
fi

echo ""

# Phase 3: Skills symlinks
# First pass: discover all skills and check for conflicts
while IFS= read -r skill_file; do
	skill_dir="$(dirname "$skill_file")"
	skill_name="$(basename "$skill_dir")"

	if existing_index="$(find_created_skill_index "$skill_name")"; then
		echo "  CONFLICT: $skill_name already exists from ${created_skill_dirs[$existing_index]}"
		echo "            skipping $skill_dir"
		continue
	fi

	created_skill_names+=("$skill_name")
	created_skill_dirs+=("$skill_dir")
done < <(find "$SCRIPT_DIR/$SKILLS_SOURCE" -name "SKILL.md" 2>/dev/null | sed "s|$SCRIPT_DIR/||" | sort)

# Second pass: create symlinks in each destination
for skills_dest in "${SKILLS_DESTS[@]}"; do
	echo "Skills ($skills_dest):"
	mkdir -p "$skills_dest"

	for i in "${!created_skill_names[@]}"; do
		skill_name="${created_skill_names[$i]}"
		skill_dir="${created_skill_dirs[$i]}"
		source_path="$SCRIPT_DIR/$skill_dir"
		dest_path="$skills_dest/$skill_name"

		if [[ -L "$dest_path" ]]; then
			existing_target="$(readlink "$dest_path")"
			if [[ "$existing_target" == "$source_path" ]]; then
				echo "  OK: $skill_name (already linked)"
				continue
			fi
			rm -f "$dest_path"
		elif [[ -e "$dest_path" ]]; then
			echo "  SKIP: $skill_name (destination exists and is not a symlink)"
			continue
		fi

		ln -s "$source_path" "$dest_path"
		echo "  OK: $skill_name"
	done
	echo ""
done

echo ""

# Phase 4: Stale symlink cleanup
echo "Checking for stale symlinks..."
stale_found=false

# Check agents for stale symlinks
if [[ -d "$AGENTS_DEST" ]]; then
	for link in "$AGENTS_DEST"/*; do
		[[ -e "$link" || -L "$link" ]] || continue

		link_name="$(basename "$link")"

		# Skip if this was just created
		if is_created_agent "$link_name"; then
			continue
		fi

		# Only handle symlinks (don't touch regular files/dirs)
		if [[ -L "$link" ]]; then
			stale_found=true
			read -p "  Remove stale agent symlink $link? [y/N] " answer
			if [[ "$answer" =~ ^[Yy]$ ]]; then
				rm "$link"
				echo "  REMOVED: $link_name"
			else
				echo "  KEPT: $link_name"
			fi
		fi
	done
fi

# Check skills for stale symlinks in all destinations
for skills_dest in "${SKILLS_DESTS[@]}"; do
	if [[ -d "$skills_dest" ]]; then
		for link in "$skills_dest"/*; do
			[[ -e "$link" || -L "$link" ]] || continue

			link_name="$(basename "$link")"

			# Skip if this was just created
			if find_created_skill_index "$link_name" >/dev/null; then
				continue
			fi

			# Only handle symlinks (don't touch regular files/dirs)
			if [[ -L "$link" ]]; then
				stale_found=true
				read -p "  Remove stale skill symlink $link? [y/N] " answer
				if [[ "$answer" =~ ^[Yy]$ ]]; then
					rm "$link"
					echo "  REMOVED: $link_name"
				else
					echo "  KEPT: $link_name"
				fi
			fi
		done
	fi
done

if [[ "$stale_found" == false ]]; then
	echo "  No stale symlinks found."
fi

echo ""
echo "Done."
