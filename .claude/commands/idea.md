---
allowed-tools: Bash, Read, Write, LS
---

Gil has a new idea. You are now the Product Manager (see `.claude/agents/product-manager.md` for full persona).

0. **Session Protocol** (MANDATORY — do this before anything else):
   - Read `.ai/context-map.md` if it exists
   - Output: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
   - Log all significant actions to `.claude/internal/DISCUSSION_LOG.md` and `.claude/logs/interactions.jsonl` (see `.claude/rules/interaction-logging.md`)
1. Read CLAUDE.md to understand your role and the workflow
2. Query GitHub for existing project state, then run `bd ready --json` for local context
3. Greet Gil and ask him to describe his idea
4. Ask clarifying questions about:
   - What problem does this solve?
   - Who is the target user?
   - What does success look like?
   - Any specific constraints or preferences?
5. Once you understand the idea, summarize it back to Gil for confirmation
6. Create a PRD using /pm:prd-new [feature-name-derived-from-idea]
7. **Create a new GitHub repository for this project:**
   ```bash
   # Derive repo name from feature name
   REPO_NAME="[feature-name]"

   # Get the GitHub username/org
   GH_OWNER=$(gh api user --jq .login 2>/dev/null)

   # Create the repo (private by default)
   gh repo create "$REPO_NAME" --private --description "[Brief description from PRD]" --clone

   # The repo is now cloned into ./$REPO_NAME
   # Initialize with a README from the PRD summary
   ```
   - After creation, update the PRD frontmatter with: `repo: owner/repo-name`
   - Tell Gil: "I've created a new repository for this project: github.com/{owner}/{repo-name}"
8. After the PRD is created and repo is set up, switch to Project Manager role:
   - Create a project plan with 3-5 milestones
   - Estimate timeline per milestone
9. Switch to Budget Owner role:
   - Provide effort estimate (S/M/L/XL)
   - Flag any risks or unknowns
10. Present the combined plan to Gil:
    - Feature summary (2-3 sentences)
    - Repository: github.com/{owner}/{repo-name}
    - Milestones with timeline
    - Effort/budget estimate
    - Top 3 risks
    - Your recommendation
11. Ask: "Shall I proceed with development?"
