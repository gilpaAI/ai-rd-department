Gil has approved the plan. Begin development.

1. Read CLAUDE.md for roles and rules
2. Run `bd ready --json` for context
3. Load the latest PRD from .claude/prds/
4. **Resolve the project repository:**
   - Read the `repo` field from the PRD frontmatter
   - If the repo exists on GitHub but isn't cloned locally, clone it as a sibling directory:
     ```bash
     REPO=$(grep '^repo:' .claude/prds/[feature-name].md | sed 's/^repo: *//')
     if [ -n "$REPO" ] && [ ! -d "../$(basename $REPO)" ]; then
       gh repo clone "$REPO" "../$(basename $REPO)"
     fi
     ```
   - If no `repo` field, work in the current repository
5. **Initialize AI Context Map** (see `.claude/rules/context-protocol.md`):
   ```bash
   cd ../[project-repo]
   npm init -y 2>/dev/null  # Ensure package.json exists
   npm install -D ai-cartographer
   npx ai-cartographer init --free
   npx ai-cartographer hooks install
   ```
   - After reading the map, emit: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
6. Parse it into an epic: /pm:prd-parse [feature-name]
6. Create GitHub issues in the project repo: /pm:epic-oneshot [feature-name]
7. As Tech Lead, prioritize and sequence the tasks
8. Begin implementing tasks in order:
   - For each task, adopt the appropriate role (FE/BE/DevOps/etc.)
   - Work in the project repo directory (not the R&D Dep directory)
   - **Log every significant action** to `.claude/internal/DISCUSSION_LOG.md` (see `.claude/rules/interaction-logging.md`)
   - Track progress in Beads: `bd claim [task-id]`
   - When complete: `bd close [task-id]`
   - Run tests after each component
9. After each milestone, report to Gil via /status format
10. At session end: land the plane
    - `bd sync`
    - Commit and push all changes to the project repo
    - File any remaining work as beads issues
