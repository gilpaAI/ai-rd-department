Resuming work on an existing project.

1. Read CLAUDE.md
2. Query GitHub for current project state (source of truth):
   ```bash
   REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
   if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
     echo "=== Open Epics ==="
     gh issue list --repo "$REPO" --label "epic" --state open --json number,title
     echo "=== In Progress ==="
     gh issue list --repo "$REPO" --label "status:in-progress" --json number,title,assignees
     echo "=== Blocked ==="
     gh issue list --repo "$REPO" --label "status:blocked" --json number,title
   fi
   ```
3. If GitHub unavailable, fall back to `bd ready --json` and local `.claude/epics/`
4. **Load Context Map** (see `.claude/rules/context-protocol.md`):
   - If `.ai/context-map.md` exists, read it
   - Emit: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
   - If map is missing, note: "No context map found — will generate on next build"
5. Check git log for recent changes
6. Summarize current state to Gil:
   - "Last session we completed X. Next up is Y. Shall I continue?"
6. If Gil confirms, continue development using /build workflow
