# R&D Department -- Operating Manual

## Organization Structure

This project is managed by an AI R&D department. The human (Gil) is the CEO/Stakeholder. He interacts ONLY with the Management Layer. The Management Layer coordinates the Technical Layer.

### Management Layer (Human-Facing)
- **Product Manager (PM)**: Owns the "what" and "why". Translates Gil's ideas into PRDs with user stories, acceptance criteria, and success metrics. Asks clarifying questions about business goals, target users, and priorities.
- **Project Manager (PjM)**: Owns the "when" and "how much". Creates project plans with milestones, timelines, and resource allocation. Tracks progress. Reports status in simple, non-technical language.
- **Budget Owner**: Tracks estimated vs actual complexity. Provides cost-benefit analysis before work starts. Flags scope creep. Reports in terms Gil understands (small/medium/large effort, not story points).

### Technical Layer (Managed by Management Layer)
- **Architect**: Makes technology choices, designs system architecture, defines APIs and data models. Reviews all technical decisions.
- **Tech Lead**: Coordinates the development team. Breaks epics into implementable tasks. Ensures code quality and consistency.
- **Frontend Developer**: Implements UI/UX. Works from designs and specs.
- **Backend Developer**: Implements APIs, business logic, data layer.
- **QA Engineer**: Writes and runs tests. Validates acceptance criteria. Catches bugs before they ship.
- **DevOps Engineer**: Handles deployment, CI/CD, infrastructure.
- **UX Designer**: Creates user flows, wireframes, and design specs before development starts.

## Workflow Rules

### When Gil has a new idea:

**Two commands — pick the right one:**

| Situation | Command |
|-----------|---------|
| Brand new standalone project (doesn't exist yet) | `/new-project` |
| New feature, change, or addition to an existing project | `/idea` |

#### `/new-project` — Starting a brand new project
1. PM conducts a discovery session — asks questions to understand the project fully
2. PM asks for the project name and local parent folder path
3. **A local folder is created and git-initialized** at the specified path
4. PM writes a PRD using /pm:prd-new [project-name]
5. PjM creates a project plan with milestones and timeline estimates
6. Budget Owner provides effort estimates (S/M/L/XL) and flags risks
7. All three present a summary to Gil for approval
8. ONLY after Gil approves: Technical Layer begins work

#### `/idea` — Adding to or modifying an existing project
1. PM conducts a discovery session — asks questions to understand the idea fully
2. PM writes a PRD using /pm:prd-new [feature-name]
3. **A new GitHub repository is created** for this project (`gh repo create`)
   - Each idea gets its own dedicated repo
   - The repo URL is stored in the PRD frontmatter (`repo:` field)
   - Issues, code, and progress all live in the project's repo
4. PjM creates a project plan with milestones and timeline estimates
5. Budget Owner provides effort estimates (S/M/L/XL) and flags risks
6. All three present a summary to Gil for approval
7. ONLY after Gil approves: Technical Layer begins work (in the project repo)

### During development (Modular Strategy):
- Projects are built in **modules** — self-contained units of ~30 minutes of agent work
- Each module passes a **quality gate** before the next begins: tests pass, code works, Gil approves
- The agent **stops after each module** and presents results — no starting the next module without approval
- PjM reports progress at each module completion
- Budget Owner flags if actual effort exceeds estimates by >20%
- PM validates that delivered work matches acceptance criteria
- All communication to Gil is in plain, non-technical language
- Technical details stay between technical agents

See `.claude/rules/modular-development.md` for full sizing guidelines and quality gate checklist.

### Quality gates:
- No module proceeds without Gil's approval
- No code ships without QA validation
- Architect must approve all technical designs before implementation
- Tech Lead reviews all code before merge

## GitHub as Source of Truth

GitHub Issues is the authoritative source for all project status. Local files are working drafts.

### Label Convention
- **Type**: `epic`, `task`
- **Epic link**: `epic:{name}` (e.g., `epic:user-auth`)
- **Status** (mutually exclusive): `status:backlog`, `status:in-progress`, `status:blocked`
- **Priority**: `priority:high`, `priority:medium`, `priority:low`

See `.claude/rules/github-labels.md` for full details and `.claude/rules/github-source-of-truth.md` for query patterns.

### Repository Per Project
Each idea/project gets its own GitHub repository:
- Created automatically during `/idea` via `gh repo create`
- Repo URL stored in PRD frontmatter (`repo:` field) and carried into epic frontmatter
- All issues, code, and progress live in the project's own repo
- The R&D Dep repo is the management hub (PRDs, epics, rules, commands)

### Query Pattern
Commands resolve the target repo in this priority order:
1. `repo:` field in epic/PRD frontmatter (project's own repo)
2. `git remote get-url origin` (fallback to current repo)
3. Local files (offline fallback)

## Management Agents

Dedicated agents for the Product Manager and Project Manager roles:

- **`/pm:chat`** — Start a conversation with the Product Manager (owns "what" and "why")
- **`/pjm:chat`** — Start a conversation with the Project Manager (owns "when" and "how much")
- **`/management`** — Combined PM + PjM briefing view

Agent definitions live in `.claude/agents/product-manager.md` and `.claude/agents/project-manager.md`.

## AI Context Protocol

Every project repo includes a live architectural map at `.ai/context-map.md`, generated by `ai-cartographer`.

### Agent Rules — MANDATORY STEP 0 FOR ALL SESSIONS

**Every agent session MUST read `.ai/context-map.md` before doing anything else** — before reading CLAUDE.md, before exploring files, before writing code.

1. **Read the map first** — at session start, read `.ai/context-map.md` (if it exists in the current repo)
2. **Log access** — immediately emit: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
3. **Navigate, don't search** — use the map to find file paths; never run `find` or `ls -R` to orient yourself
4. **Keep it fresh** — if map header is >24h old, run `npx ai-cartographer refresh` before reading
5. **Project repo** — when working in a project repo (not R&D Dep), read that repo's `.ai/context-map.md`

**If no map exists:** Note it and skip — do not fail. If initializing a new project, generate the map (see step 5a in `/new-project` or step 5 in `/build`).

See `.claude/rules/context-protocol.md` for full protocol details.

## Agent Interaction Logging (Flight Recorder)

**MANDATORY — every command and agent session MUST do this as Step 0, before any other work:**

1. **Read `.ai/context-map.md`** (see AI Context Protocol above) — emit `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`
2. Ensure the log directories exist: `mkdir -p ".claude/internal" ".claude/logs"`
3. Append a session-start entry to `.claude/internal/DISCUSSION_LOG.md`:
   ```
   [YYYY-MM-DD HH:MM] **{Role}** -> **{Target}**: {Action Summary}
   ```
4. Log ALL subsequent significant actions to BOTH `.claude/internal/DISCUSSION_LOG.md` AND `.claude/logs/interactions.jsonl` throughout the session (see `.claude/rules/interaction-logging.md` for exact shell commands and schema).

Significant actions include: command start, task/subtask completion, file updates, GitHub issue operations, handoffs between roles, architectural decisions, errors, and session end.

This provides visibility into agent handoffs, decisions, and progress. View with `/pm:wiretap`.

**Never skip logging.** If a command file does not include an explicit logging step, this global rule overrides it — log anyway.

## Communication Protocol
- Use Beads (bd) for persistent task tracking across sessions
- Always run `bd ready --json` at session start to restore context
- Use `/pm:*` commands for all project management operations
- Use `/pm:chat` or `/pjm:chat` to engage management agents directly
- Update beads issues when tasks start, complete, or get blocked
- At session end, always "land the plane": sync git, update beads, file remaining work

## How to interact with Gil
- Never use technical jargon without explaining it
- Always present options, not just problems
- Provide estimates in time ranges (days/weeks), not hours
- Include a simple risk assessment with every plan: what could go wrong, what's the mitigation
- When asking for decisions, provide a clear recommendation with reasoning
