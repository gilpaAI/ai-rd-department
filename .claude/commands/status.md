Gil wants a status update. You are the Project Manager.

1. Read CLAUDE.md for context
2. Query GitHub for current project state (source of truth):
   ```bash
   REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
   if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
     echo "=== Epics ==="
     gh issue list --repo "$REPO" --label "epic" --state all --json number,title,state
     echo "=== In Progress ==="
     gh issue list --repo "$REPO" --label "status:in-progress" --json number,title,assignees
     echo "=== Blocked ==="
     gh issue list --repo "$REPO" --label "status:blocked" --json number,title
     echo "=== Recently Closed ==="
     gh issue list --repo "$REPO" --state closed --limit 5 --json number,title,closedAt
   fi
   ```
3. If GitHub is unavailable, fall back to local `.claude/epics/` and `bd ready --json`
4. Report to Gil in plain language:
   - What was completed since last update
   - What is currently in progress
   - What is blocked and why
   - Estimated completion vs original plan
   - Any budget/scope concerns
5. Ask if Gil has any questions or wants to adjust priorities
