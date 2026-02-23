---
name: obsidian
description: Use when working with Obsidian vaults, creating/searching/moving notes, or automating note management with the official obsidian CLI, especially with multiline or shell-unsafe content
---

# Obsidian

Obsidian vault = a normal folder on disk.

## Use the Official CLI

- Command name is `obsidian` (not `obsidian-cli`).
- Requires Obsidian desktop `1.12+` with `Settings -> General -> Command line interface` enabled.
- CLI registration adds `obsidian` to `PATH`; restart the shell after enabling.
- CLI talks to the running Obsidian app; first command should launch the app if needed.

## Vault Targeting

- If terminal `cwd` is inside a vault, that vault is used.
- Otherwise, the currently active vault is used.
- For deterministic scripts, pass `vault="<vault name>"` as the first argument.
- List known vaults: `obsidian vaults verbose`
- Show current vault path: `obsidian vault info=path`

## File Targeting

- `file=<name>` resolves with wikilink-style matching by file name.
- `path=<path>` targets an exact path from the vault root (recommended for automation).

## Official CLI Quick Reference

| Action | Command |
|--------|---------|
| Show help | `obsidian help` |
| Help for one command | `obsidian help create` |
| Open/create daily note | `obsidian daily` |
| Get daily note path | `obsidian daily:path` |
| Open note | `obsidian open path="Folder/Note.md"` |
| Read note | `obsidian read path="Folder/Note.md"` |
| Create note | `obsidian create path="Folder/New note.md" content="..."` |
| Append to note | `obsidian append path="Folder/New note.md" content="..."` |
| Prepend note | `obsidian prepend path="Folder/New note.md" content="..."` |
| Move/rename note | `obsidian move path="old/path.md" to="new/path.md"` |
| Delete note | `obsidian delete path="Folder/Note.md"` |
| Search paths | `obsidian search query="query"` |
| Search with matching lines | `obsidian search:context query="query"` |
| Copy output to clipboard | `obsidian read path="Folder/Note.md" --copy` |

## Key Points

- `vault="<name>"` must be the first argument when used.
- `create`, `append`, and `prepend` use `content=<text>`, with `open`/`overwrite` as flags.
- `move` updates links if `Automatically update internal links` is enabled in vault settings.
- Current CLI behavior is mostly silent/non-interactive; use `open` when you want the file focused in the app.
- For automation, prefer explicit `vault=...` and exact `path=...` values.

## Safe Content Passing

When content includes backticks, `$()`, or a lot of quotes, pass it via a temp file and command substitution.

**Temp file + heredoc (preferred):**
```zsh
tmp="$(mktemp)"
cat <<'EOF' > "$tmp"
... note content ...
EOF
obsidian vault="My Vault" create path="Folder/New note.md" content="$(cat "$tmp")"
rm "$tmp"
```

**Inline heredoc (no temp file):**
```zsh
obsidian create path="Folder/New note.md" content="$(cat <<'EOF'
... note content ...
EOF
)"
```

**Direct write to vault path (fallback):**
```zsh
vault_path="$(obsidian vault info=path)"
note="$vault_path/Folder/New note.md"
mkdir -p "${note%/*}"
cat <<'EOF' > "$note"
... note content ...
EOF
```

Verify with: `obsidian read path="Folder/New note.md"`
