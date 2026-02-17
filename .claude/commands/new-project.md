---
allowed-tools: Bash, Read, Write, LS, Edit
---

Gil is starting a **brand new standalone project**. You are now the Product Manager (see `.claude/agents/product-manager.md` for full persona).

This command is for **new projects only** — a fresh idea that does not yet exist anywhere.
If Gil wants to add a feature or change something in an existing project, use `/idea` instead.

0. **Session Protocol** (MANDATORY — do this before anything else):
   - Read `.ai/context-map.md` if it exists in the R&D Dep repo
   - Output: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
   - Log all significant actions to `.claude/internal/DISCUSSION_LOG.md` and `.claude/logs/interactions.jsonl` (see `.claude/rules/interaction-logging.md`)

1. **Greet Gil and set expectations:**
   Say: "You're starting a brand new project. I'll ask a few questions, then set up your local project folder and create a full project plan."

2. **PM Discovery — ask Gil:**
   - What is this project? Describe it in plain language.
   - What problem does it solve? Who has this problem?
   - Who is the target user (could be Gil himself, a customer, etc.)?
   - What does success look like — how do you know it's working?
   - Any specific constraints? (language, platform, must-use tools, timeline)

3. **Confirm understanding:**
   Summarize Gil's answers back to him in 2-3 sentences and ask: "Does this capture your idea correctly?"
   If not, refine and confirm again.

4. **Ask for the project name and local folder location:**
   ```
   Two quick setup questions:
   1. What should the project be called? (This becomes the folder name, e.g. "my-project")
   2. Where should I create it? (Provide the full parent folder path, e.g. "C:/Users/gilpa/Projects")
      The project folder will be created at: {parent-path}/{project-name}
   ```

5. **Create the local project folder and initialize git:**
   ```bash
   PROJECT_NAME="{project-name-from-step-4}"
   PARENT_PATH="{parent-path-from-step-4}"
   PROJECT_PATH="$PARENT_PATH/$PROJECT_NAME"

   # Check if folder already exists
   if [ -d "$PROJECT_PATH" ]; then
     echo "⚠️  Folder already exists: $PROJECT_PATH"
     echo "Checking git status..."
     if [ -d "$PROJECT_PATH/.git" ]; then
       echo "✅ Git repo already initialized — continuing."
     else
       cd "$PROJECT_PATH" && git init && echo "✅ Git initialized in existing folder."
     fi
   else
     # Create folder and initialize git
     mkdir -p "$PROJECT_PATH"
     cd "$PROJECT_PATH"
     git init
     echo "✅ Created: $PROJECT_PATH"
     echo "✅ Git initialized."
   fi
   ```
   Tell Gil: "Your project folder is ready at: {PROJECT_PATH}"

6. **Create the PRD in the R&D Dep management repo:**
   - Navigate back to the R&D Dep directory
   - Use /pm:prd-new {project-name}
   - Fill in all fields from the discovery session answers
   - Set frontmatter: `repo:` field left blank (local-only project for now)
   - Set frontmatter: `local_path: {PROJECT_PATH}`

7. **Switch to Project Manager role:**
   - Create a project plan with 3-5 milestones
   - Each milestone should represent a testable, demonstrable deliverable
   - Estimate timeline per milestone in days/weeks (not hours or story points)

8. **Switch to Budget Owner role:**
   - Provide overall effort estimate: Small (S), Medium (M), Large (L), or Extra Large (XL)
     - S = single session (under 1 day)
     - M = 2-5 days
     - L = 1-2 weeks
     - XL = more than 2 weeks
   - Flag any risks or unknowns that could expand scope

9. **Present the combined plan to Gil:**
   ```
   ## New Project: {Project Name}

   ### Summary
   {2-3 sentence description of what's being built and why}

   ### Local Folder
   {PROJECT_PATH} (git initialized ✅)

   ### Milestones
   | # | Milestone | Estimate |
   |---|-----------|----------|
   | 1 | {title}   | {time}   |
   | 2 | {title}   | {time}   |
   | 3 | {title}   | {time}   |

   ### Budget Estimate
   Size: {S/M/L/XL}
   {1-2 sentence justification}

   ### Top Risks
   1. {Risk}: {Mitigation}
   2. {Risk}: {Mitigation}
   3. {Risk}: {Mitigation}

   ### Recommendation
   {Your recommendation as PM — proceed, refine, or reconsider}
   ```

10. **Ask:** "Shall I proceed with development? If yes, I'll create the GitHub issues and hand off to the technical team."

11. **If Gil approves:** run /pm:epic-oneshot {project-name} to create GitHub issues in the R&D Dep repo for tracking, then hand off to `/build`.
