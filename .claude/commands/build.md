Gil has approved the plan. Begin development.

1. Read CLAUDE.md for roles and rules
2. Run `bd ready --json` for context
3. Load the latest PRD from .claude/prds/
4. Parse it into an epic: /pm:prd-parse [feature-name]
5. Create GitHub issues: /pm:epic-oneshot [feature-name]
6. As Tech Lead, prioritize and sequence the tasks
7. Begin implementing tasks in order:
   - For each task, adopt the appropriate role (FE/BE/DevOps/etc.)
   - Track progress in Beads: `bd claim [task-id]`
   - When complete: `bd close [task-id]`
   - Run tests after each component
8. After each milestone, report to Gil via /status format
9. At session end: land the plane
   - `bd sync`
   - Commit and push all changes
   - File any remaining work as beads issues
