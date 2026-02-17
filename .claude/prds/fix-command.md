---
name: fix-command
description: /fix slash command — orchestrated 3-agent bug fix workflow
status: backlog
repo: gilpaAI/R-D-Dep
created: 2026-02-17T20:00:00Z
updated: 2026-02-17T20:00:00Z
---

# PRD: /fix Command — Bug Fix Workflow

## Problem

There is no structured, repeatable process for fixing bugs in the R&D Department. When a bug is reported, the developer (or agent) investigates ad-hoc, fixes the code without a consistent analysis step, and may or may not verify the fix with tests. This leads to incomplete fixes, unverified changes, and context lost between debugging sessions.

## Solution

A `/fix <bug_description>` slash command that orchestrates three existing agents in a strict pipeline:

1. **Analyze** — `code-analyzer` agent finds the root cause and returns the specific file and line number
2. **Fix** — A constrained developer task edits *only* the file and line identified in step 1
3. **Verify** — `test-runner` agent runs relevant tests to confirm the fix

## Target User

Gil and any developer using the R&D Department workflow system.

## User Story

> As a developer, when I discover a bug, I want to run `/fix "describe the bug"` and have the system automatically locate the root cause, apply a targeted fix, and confirm it works — without me having to manually coordinate three separate tools.

## Acceptance Criteria

- [ ] Running `/fix <description>` triggers the code-analyzer agent with the description
- [ ] The analyzer output (file path + line number) is passed to the developer task
- [ ] The developer task is explicitly constrained: only edit the flagged file, only at the identified location
- [ ] The test-runner agent is invoked after the fix to verify correctness
- [ ] The command handles the case where no tests exist (graceful fallback message)
- [ ] The command lives at `.claude/commands/fix.md` in the R&D Dep repo

## Out of Scope

- Creating a new GitHub repository (this is an internal tooling change to R&D Dep)
- Multi-file refactoring as part of a fix
- Automatic issue creation for bug tracking (future enhancement)

## Key Decision: Constrained Fixer

The developer agent is explicitly limited to editing only the file and line number returned by the code-analyzer. It must not refactor unrelated code or touch other files. This constraint is enforced via the prompt in the command.

## Implementation Notes

The command is a single markdown file: `.claude/commands/fix.md`
No new agents are needed — all three components already exist.
The R&D Dep repo is the delivery target (no separate repo needed).
