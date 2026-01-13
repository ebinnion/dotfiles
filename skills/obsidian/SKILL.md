---
name: obsidian
description: Use when working with Obsidian vaults, creating/searching/moving notes, or automating note management via obsidian-cli
---

# Obsidian

Obsidian vault = a normal folder on disk.

## Vault Structure

- Notes: `*.md` (plain text Markdown; edit with any editor)
- Config: `.obsidian/` (workspace + plugin settings; usually don't touch from scripts)
- Canvases: `*.canvas` (JSON)
- Attachments: whatever folder configured in Obsidian settings (images/PDFs/etc.)

## Find the Active Vault

Obsidian desktop tracks vaults here (source of truth):
- `~/Library/Application Support/obsidian/obsidian.json`

`obsidian-cli` resolves vaults from that file; vault name is typically the **folder name** (path suffix).

Fast vault lookup:
- If default is set: `obsidian-cli print-default --path-only`
- Otherwise, read `~/Library/Application Support/obsidian/obsidian.json` and use the vault entry with `"open": true`

Notes:
- Multiple vaults common (iCloud vs local, work/personal). Don't guess; read config.
- Avoid hardcoded vault paths in scripts; prefer reading config or using `print-default`.

## obsidian-cli Quick Reference

| Action | Command |
|--------|---------|
| Set default vault | `obsidian-cli set-default "<vault-folder-name>"` |
| Print default vault | `obsidian-cli print-default` / `--path-only` |
| Fuzzy search (interactive) | `obsidian-cli search` (opens selected note) |
| Search content | `obsidian-cli search-content "query"` |
| Open note by name | `obsidian-cli open "note name"` |
| Print note contents | `obsidian-cli print "note name"` |
| Create note | `obsidian-cli create "Folder/New note" --content "..."` |
| Open/create daily note | `obsidian-cli daily` |
| Move/rename (safe) | `obsidian-cli move "old/path" "new/path"` |
| Delete | `obsidian-cli delete "path/note"` |

## Key Points

- **Move command updates links**: `obsidian-cli move` updates `[[wikilinks]]` and Markdown links across the vault (main advantage over `mv`)
- **Create requires Obsidian URI**: Uses `obsidian://` handler, so Obsidian must be installed
- **Avoid dot-folders**: Don't create notes under hidden folders (`.something/...`) via URI; Obsidian may refuse
- **Direct edits work**: Open the `.md` file directly and edit; Obsidian picks up changes
- **Use print for reading**: `obsidian-cli print "note"` outputs note contents to stdout
- **Safe multi-line content**: Avoid passing Markdown in double quotes when it includes backticks or `$()`; use a single-quoted heredoc or write directly to the vault path instead
- **Verify after create**: Run `obsidian-cli print "note"` and confirm the last section is present
- **Vault flag**: Most commands accept `-v <vault-name>` to specify a non-default vault
