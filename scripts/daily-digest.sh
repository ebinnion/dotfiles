#!/bin/bash
DIGEST_DIR="$HOME/Obsidian/Second Brain/02 Journals/Automattic Digests"
TODAY=$(date +"%Y-%m-%d")

[ -f "$DIGEST_DIR/$TODAY.md" ] && exit 0

claude --dangerously-skip-permissions --print "Run /context-a8c:digest"