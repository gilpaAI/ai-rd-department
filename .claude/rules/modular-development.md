# Modular Development Strategy

## Core Principle

All software projects are built in **modules** — small, self-contained units of work that each pass a quality gate before the next module begins. No module starts until the previous one is approved by Gil.

## Module Sizing

- **Target: ~30 minutes of agent work** per module
- Acceptable range: 15-45 minutes
- If a module looks like it will take longer, split it further
- Each module must produce a testable, demonstrable result

## What Makes a Good Module

A module is **self-contained**:
- Has clear inputs (what must exist before starting)
- Has clear outputs (what exists after completion)
- Can be tested independently
- Can be demonstrated to Gil without needing the rest of the project

Examples of good modules:
- "Set up project scaffolding with CLI entry point that prints help text"
- "Add user model with database migration and basic CRUD tests"
- "Build login page with form validation — no backend yet, mock responses"

Examples of bad modules:
- "Build the backend" (too large, not testable in isolation)
- "Add type definitions" (too small, nothing to demonstrate)
- "Implement features 1-5" (multiple deliverables, no single focus)

## Quality Gate

After completing a module, the agent MUST:

1. **Self-validate** against the module's acceptance criteria
2. **Run all tests** and confirm they pass
3. **Commit and push** the module's code
4. **Present to Gil** with:
   - What was built (1-2 sentences)
   - Test results (pass/fail summary)
   - How to verify (a command to run or thing to check)
   - What's next (the next module, briefly)
5. **Wait for Gil's approval** before starting the next module

If Gil requests changes, fix them and re-present before moving on.

## Quality Gate Checklist

The agent must verify each item before presenting to Gil:
- [ ] Code implemented and compiles/runs without errors
- [ ] Tests written and passing
- [ ] No lint errors or warnings
- [ ] Acceptance criteria from the module spec are met
- [ ] Code committed and pushed to the project repo

## Session Boundaries

- One session = one module (target)
- If a module completes early in a session, the agent presents the gate — it does NOT start the next module without approval
- If a module cannot complete in one session, the agent lands the plane: commits progress, notes what's remaining, and picks it up next session

## Module Sequencing

During epic decomposition (`/pm:epic-decompose`):
- Modules are numbered sequentially (001, 002, 003...)
- Each module lists its dependencies explicitly
- The first module is always the foundation (scaffolding, config, basic structure)
- Later modules build on earlier ones
- Parallel modules are allowed only if they truly don't share files

## Failure Handling

- If a module fails QA on first attempt: fix and re-present
- If a module fails QA a second time: escalate to Gil with details of what's going wrong
- Never skip a quality gate to "save time"

## Resuming Multi-Module Projects

When resuming (`/resume`):
- Check GitHub Issues for module completion status
- Report: "Modules 1-3 complete. Module 4 is next: {title}. Shall I continue?"
- Pick up at the next pending module — never re-do completed ones
