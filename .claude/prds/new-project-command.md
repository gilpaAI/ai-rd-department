---
name: new-project-command
description: Add a /new-project Claude skill that clearly handles brand new standalone projects — distinct from /idea which handles modifications to existing ones
status: backlog
created: 2026-02-17T19:45:00Z
updated: 2026-02-17T19:45:00Z
repo: gilpaAI/ai-rd-department
---

# PRD: /new-project Command

## Problem Statement

The current `/idea` command is used for everything — new standalone projects and modifications to existing ones. There is no distinction in the workflow, which causes confusion:

- A brand new project needs a local folder, git init, and a fresh project structure
- A modification to an existing project does not need any of those
- Gil has no way to signal which type of work he's starting without the command guessing

This ambiguity means setup steps (folder creation, git init) either always happen (wasting time for modifications) or never happen (requiring manual setup for new projects).

## Solution

Add a **`/new-project`** Claude skill, purpose-built for starting brand new standalone projects:

- Guides Gil through a PM discovery session (same quality as `/idea`)
- Asks for the parent folder location to create the project in
- Creates the local project folder
- Initializes a git repository in that folder (`git init`)
- Creates a PRD in the R&D Dep management repo
- Produces a project plan and budget estimate
- Presents everything to Gil for approval before work begins

The existing `/idea` command remains unchanged — it handles ideas for modifications, additions, or exploration within existing projects.

## Target User

- **Gil** — the CEO/Stakeholder who starts all new projects through the AI R&D department

## User Stories

### US-1: Clear Distinction at Session Start
As Gil, I want a dedicated command for new standalone projects, so that the system knows from the start whether I'm creating something new or changing something existing.

**Acceptance Criteria:**
- [ ] `/new-project` exists as a Claude skill and is documented
- [ ] `/idea` and `/new-project` are clearly differentiated in the help or documentation
- [ ] Running `/new-project` never prompts for an existing repo to attach to

### US-2: Guided Project Setup
As Gil, I want `/new-project` to guide me through describing the project and then set up the local folder and git repo automatically, so I don't have to do it manually.

**Acceptance Criteria:**
- [ ] PM asks the standard discovery questions (problem, target user, success, constraints)
- [ ] PM summarizes the idea back and confirms with Gil
- [ ] Command asks: "Where should I create the project folder?" (Gil provides a path)
- [ ] Command creates the folder at the specified path
- [ ] Command runs `git init` inside the new folder
- [ ] Confirmation message shows the folder path and git status

### US-3: PRD and Plan Created
As Gil, I want a PRD and project plan produced as part of `/new-project`, so that I get the full management package for the new idea before development starts.

**Acceptance Criteria:**
- [ ] A PRD file is created in `.claude/prds/` in the R&D Dep repo
- [ ] A project plan with 3-5 milestones is produced
- [ ] A budget/effort estimate (S/M/L/XL) is provided
- [ ] All three (PRD, plan, estimate) are presented to Gil in a single summary
- [ ] Gil approves before any development begins

## Scope

### In Scope
- Create `.claude/commands/new-project.md` — the new skill file
- The skill includes: PM discovery, folder creation prompt, `git init`, PRD creation, project plan, budget estimate
- Update CLAUDE.md to document the distinction between `/idea` and `/new-project`

### Out of Scope
- GitHub repository creation (Gil chose local + git only)
- Modifying the existing `/idea` command behavior
- Any scaffolding or template files inside the new project (just an empty git repo)
- CI/CD setup or README generation for the new project

## Success Criteria

1. Running `/new-project` starts a PM discovery session and results in a local git-initialized folder
2. The workflow clearly signals "this is a new project" vs. the `/idea` workflow for modifications
3. Gil ends the session with: a new local folder, a git repo, a PRD, and a project plan — all ready to hand to the Technical Layer
4. No manual steps required beyond answering PM questions and providing a folder path

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Folder path provided by Gil doesn't exist | Low | Command creates parent directories or shows a clear error with fix |
| `git init` already exists in target folder | Low | Check first; warn Gil and ask for confirmation before proceeding |
| `/idea` and `/new-project` still feel overlapping | Medium | Add a one-line distinction to CLAUDE.md and both command files |

## Effort Estimate

- **Size: Small (S)**
- 2 files to create (new-project.md skill, plus CLAUDE.md update)
- No new tooling — pure Claude skill + shell commands
- Estimated: single session to implement, under 30 minutes
