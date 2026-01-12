# ebinnion dotfiles

Personal dotfiles and tooling snapshots that keep my local setup consistent.
This repo is tailored to my macOS environment and paths, so expect to tweak
things if you reuse it.

If you're interested in dotfiles in general, see https://dotfiles.github.io/.

## What's here

- `zshrc`: shell configuration, aliases, and local workflow shortcuts.
- `claude/settings.json`: Claude Code settings.
- `agents/`: Claude Code custom agent definitions (`.md` files).
- `skills/`: Claude Code skill definitions, organized by category.
- `sync.sh`: creates symlinks from `$HOME` to this repo.

## Installation

This repo is the source of truth. `sync.sh` creates symlinks from your home
directory pointing to files in this repo.

```bash
./sync.sh
```

The script will:
1. Symlink regular files (e.g., `~/.zshrc` → `dotfiles/zshrc`)
2. Symlink agent files from `agents/` to `~/.claude/agents/`
3. Auto-discover skills by finding `SKILL.md` files and symlink them to
   `~/.claude/skills/`, flattening nested directories (e.g.,
   `skills/superpowers/brainstorming/` becomes `~/.claude/skills/brainstorming`)
4. Prompt before removing stale symlinks in `~/.claude/agents/` and `~/.claude/skills/`

The script never overwrites real files—only existing symlinks are replaced.

To add files, edit the `SYMLINKS` block in `sync.sh`. To add agents, place a
`.md` file in `agents/`. To add skills, create a new directory under `skills/`
with a `SKILL.md` file.

## Notes

- Paths in `zshrc` are machine-specific and include local repos.
- Some tools assume Homebrew-managed installs (e.g., `nvm`, `rbenv`,
  `zsh-autosuggestions`, `starship`).
