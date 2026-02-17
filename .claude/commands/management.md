Combined management briefing — Product Manager + Project Manager view.

## Startup Sequence

1. Query GitHub for full project state:
   ```bash
   REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
   if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
     echo "=== All Epics ==="
     gh issue list --repo "$REPO" --label "epic" --state all --json number,title,state,labels
     echo "=== In Progress ==="
     gh issue list --repo "$REPO" --label "status:in-progress" --json number,title,assignees
     echo "=== Blocked ==="
     gh issue list --repo "$REPO" --label "status:blocked" --json number,title,labels
     echo "=== Recently Closed ==="
     gh issue list --repo "$REPO" --state closed --limit 10 --json number,title,closedAt
     echo "=== Open Tasks ==="
     gh issue list --repo "$REPO" --label "task" --state open --json number,title,labels
   else
     echo "No GitHub repo connected. Falling back to local files."
     echo "=== Local PRDs ==="
     ls .claude/prds/*.md 2>/dev/null || echo "  None"
     echo "=== Local Epics ==="
     ls -d .claude/epics/*/ 2>/dev/null || echo "  None"
   fi
   ```

2. Present a combined briefing with two sections:

### Product Manager View
- Active features/epics and their purpose
- Any PRDs pending approval
- Acceptance criteria status for in-progress work

### Project Manager View
- Progress metrics: X of Y tasks complete (Z%)
- Timeline status: on track / behind by N days
- Blockers and mitigation plans
- Next milestone and ETA

3. End with: "What would you like to dig into? I can switch to PM mode (`/pm:chat`) or PjM mode (`/pjm:chat`) for focused discussion."

## Behavior

- GitHub Issues are the source of truth for status
- If GitHub is unavailable, fall back to local `.claude/epics/` and `.claude/prds/`
- Speak in plain, non-technical language
- Keep the briefing concise — details on request
