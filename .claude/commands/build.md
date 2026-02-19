Gil has approved the plan. Begin development.

**IMPORTANT: Follow the Modular Development Strategy (`.claude/rules/modular-development.md`).
Build ONE module at a time. Stop at each quality gate for Gil's approval.**

0. **Session Protocol** (MANDATORY — do this before anything else):
   - Read `.ai/context-map.md` in the R&D Dep repo (this directory) if it exists — see `.claude/rules/context-protocol.md`
   - Output: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
   - Log ALL significant actions this session to BOTH `.claude/internal/DISCUSSION_LOG.md` AND `.claude/logs/interactions.jsonl` (see `.claude/rules/interaction-logging.md`)
   - This includes: module starts, module completions, quality gate results, commits, errors
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
5. **Initialize AI Context Map in the project repo** (see `.claude/rules/context-protocol.md`):
   ```bash
   cd ../[project-repo]
   # If .ai/context-map.md already exists, read it and emit the audit log
   if [ -f ".ai/context-map.md" ]; then
     # Read .ai/context-map.md to orient yourself — extract file count from header
     # Emit: [AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.
     # Check staleness (>24h): run `npx ai-cartographer refresh` if needed
     npx ai-cartographer status 2>/dev/null || true
   else
     # First run: install and generate the map
     npm init -y 2>/dev/null  # Ensure package.json exists
     npm install -D ai-cartographer
     npx ai-cartographer init --free
     npx ai-cartographer hooks install
     # Then read .ai/context-map.md and emit: [AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.
   fi
   ```
   **ALWAYS emit after reading:** `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
6. Parse it into an epic: /pm:prd-parse [feature-name]
7. Create GitHub issues in the project repo: /pm:epic-oneshot [feature-name]
8. **Identify the next module to build:**
   - Check GitHub Issues for the epic's modules (sorted by number)
   - Find the first module with status `open` (not `in-progress` or `closed`)
   - If resuming, skip completed modules
9. **Build the current module:**
   - Adopt the appropriate role (FE/BE/DevOps/etc.)
   - Work in the project repo directory (not the R&D Dep directory)
   - **Log every significant action** to `.claude/internal/DISCUSSION_LOG.md` (see `.claude/rules/interaction-logging.md`)
   - Track progress in Beads: `bd claim [task-id]`
   - Focus only on this module's acceptance criteria — do not start the next module
10. **Quality Gate — MANDATORY STOP:**
    - Run all tests and confirm they pass
    - Self-validate against the module's acceptance criteria
    - Commit and push the module's code
    - Mark the module as complete: `bd close [task-id]`
    - **Present to Gil:**
      ```
      ✅ Module {N} Complete: {Module Title}

      What was built:
      - {1-2 sentence summary}

      Test results:
      - {pass/fail summary}

      How to verify:
      - {command to run or thing to check}

      Next module:
      - Module {N+1}: {title} — {1 sentence description}

      Approve to continue?
      ```
    - **STOP and wait for Gil's response.** Do NOT start the next module.
11. If Gil approves, go to step 8 for the next module.
12. At session end (or after final module): land the plane
    - `bd sync`
    - Commit and push all changes to the project repo
    - File any remaining work as beads issues
