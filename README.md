# ebinnion dotfiles

Personal dotfiles and tooling snapshots that keep my local setup consistent.
This repo is tailored to my macOS environment and paths, so expect to tweak
things if you reuse it.

If you're interested in dotfiles in general, see https://dotfiles.github.io/.

## What's here

- `zshrc`: shell configuration, aliases, and local workflow shortcuts.
- `sync.sh`: pulls selected files from `$HOME` into this repo.
- `claude/settings.json`: Claude Code settings.
- `claude/skills/`: Claude Code skill definitions I use locally.

## Syncing from my machine

`sync.sh` copies files from their source locations into this repo based on a
whitelist in the script. It overwrites destinations (and removes existing
directories) before copying, so use it with care. Each whitelist entry must
include a destination path.

```bash
./sync.sh
```

To add or remove tracked files, edit the `WHITELIST` block in `sync.sh`.

## Notes

- Paths in `zshrc` are machine-specific and include local repos.
- Some tools assume Homebrew-managed installs (e.g., `nvm`, `rbenv`,
  `zsh-autosuggestions`, `starship`).
