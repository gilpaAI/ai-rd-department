---
name: modular-development
description: Change the CCPM development strategy to build software in small, independent modules with quality gates between each
status: backlog
created: 2026-02-17T20:24:47Z
updated: 2026-02-17T20:24:47Z
repo: gilpaAI/ai-rd-department
---

# PRD: Modular Development Strategy

## Problem Statement

When building large software projects, the current workflow decomposes an epic into many tasks and attempts to build them all in a single session. This creates risk:
- No intermediate QA — bugs compound across modules
- Gil has no visibility until everything is "done"
- A bad architectural decision in task 2 wastes all work in tasks 3-9
- Sessions can run long, hitting context limits or token caps
- No natural checkpoint to course-correct

## Solution

Restructure the CCPM framework to enforce **modular, gated development**:
- Every project is decomposed into **modules** — self-contained units of ~30 minutes of agent work
- Each module has its own **quality gate**: tests pass, code works, Gil reviews and approves
- The agent **stops after each module** and presents results before proceeding
- No module starts until the previous one is approved

## Target User

- Gil (CEO/Stakeholder) — gains control and visibility over development
- AI agents — get clear, scoped work with defined "done" criteria

## User Stories

### US-1: Module-Sized Decomposition
As Gil, I want epics broken into modules sized for a single ~30-minute session, so that each session produces a complete, testable deliverable.

**Acceptance Criteria:**
- [ ] `/pm:epic-decompose` creates modules capped at ~30 min of agent work
- [ ] Each module is self-contained: it can be built, tested, and demoed independently
- [ ] Modules have explicit inputs (what exists before) and outputs (what exists after)
- [ ] Module dependencies are clearly marked — sequential vs parallel

### US-2: Quality Gate Enforcement
As Gil, I want the build workflow to stop after each module for my approval, so that I can catch issues early and course-correct.

**Acceptance Criteria:**
- [ ] `/build` executes one module at a time, not all at once
- [ ] After completing a module, the agent presents: what was built, test results, how to verify
- [ ] Agent waits for Gil's explicit approval before starting the next module
- [ ] If Gil requests changes, the agent addresses them before moving on

### US-3: Module Quality Checklist
As Gil, I want each module to pass a standard quality checklist before I'm asked to review, so that basic issues are caught automatically.

**Acceptance Criteria:**
- [ ] Each module runs through: code implemented, tests written and passing, no lint errors
- [ ] Agent self-validates against the module's acceptance criteria
- [ ] Agent presents a clear pass/fail summary at the gate
- [ ] Failed checks are fixed before presenting to Gil

### US-4: Session Resumability
As Gil, I want to be able to resume a project at any module boundary, so that work spans multiple sessions naturally.

**Acceptance Criteria:**
- [ ] `/resume` shows which modules are complete and which is next
- [ ] A new session can pick up exactly where the last one left off
- [ ] Module state (complete/in-progress/pending) is tracked in GitHub issues

## Scope

### In Scope
- Update `/pm:epic-decompose` — module sizing guidelines (~30 min each)
- Update `/build` command — single-module execution with quality gate
- Create `/rules/modular-development.md` — the philosophy and rules
- Update `/resume` command — module-aware session resumption
- Update `CLAUDE.md` — document the modular workflow

### Out of Scope
- Retroactive changes to existing projects (Cartographer, etc.)
- Automated deployment pipelines (module "deploy" = commit and push for now)
- UI/dashboard for module tracking (GitHub Issues is sufficient)

## Success Criteria

1. A new project built with `/build` stops after each module for Gil's approval
2. Each module is testable and demonstrable on its own
3. Gil can resume a multi-module project in a new session without losing progress
4. No module exceeds ~30 minutes of agent work

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Modules too small = too much overhead | Medium | Target 30 min, allow 15-45 min range |
| Agent ignores gates in long sessions | High | Bake enforcement into `/build` command logic |
| Hard to size modules accurately | Low | Use rough heuristics; adjust with experience |

## Effort Estimate

- **Size: Small (S)**
- 5-6 files to create or update
- No new tooling or repos — all within CCPM framework
- Estimated: single session to implement
