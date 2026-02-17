# Agent Interaction Logging

## Purpose

All agent actions are logged to provide visibility into the "hidden" conversations of the AI department. This serves as a flight recorder for debugging, auditing, and understanding how agents collaborate.

## Two Log Formats

### 1. Human-Readable Log (Primary)

**File:** `.claude/internal/DISCUSSION_LOG.md`

**When to log:** After completing any significant action:
- Finishing a task or subtask
- Updating a progress or status file
- Spawning a sub-agent or parallel worker
- Handing off work to another role
- Creating or closing GitHub issues
- Making architectural decisions
- Encountering blockers or errors
- Reading the context map (audit log)

**Format:** Append one line per action:
```
[YYYY-MM-DD HH:MM] **{Role}** -> **{Target}**: {Action Summary}
```

**Examples:**
```
[2026-02-17 16:30] **Product Manager** -> **Architect**: PRD for 'ai-cartographer' approved. Handing off for technical breakdown.
[2026-02-17 16:35] **Tech Lead** -> **GitHub #2**: Created issue: Project scaffolding — TypeScript CLI with config loading
[2026-02-17 16:40] **Backend Developer** -> **src/config.ts**: Implemented config loader with cosmiconfig and sensible defaults
[2026-02-17 16:45] **QA Engineer** -> **Tech Lead**: All tests passing. 22 files verified.
[2026-02-17 16:50] **DevOps Engineer** -> **GitHub**: Pushed commit 324c3be to main branch
```

**Role names** (use these exactly):
- Product Manager, Project Manager, Budget Owner
- Architect, Tech Lead
- Frontend Developer, Backend Developer
- QA Engineer, DevOps Engineer, UX Designer
- Parallel Worker, Context Map (for audit log entries)

**Target** can be:
- Another role name (for handoffs)
- A file path (for file updates)
- `GitHub #N` (for issue operations)
- `GitHub` (for git operations)
- `Gil` (for status reports)

### 2. Machine-Readable Log (JSONL)

**File:** `.claude/logs/interactions.jsonl`

**When to log:** Same triggers as human-readable log, but written as JSONL for future analysis.

**Schema:**
```json
{"timestamp":"2026-02-17T16:30:00Z","trace_id":"epic:ai-cartographer","sender":"Product Manager","receiver":"Architect","action":"handoff","artifact":".claude/prds/ai-cartographer.md","summary":"PRD approved, handing off for technical breakdown"}
```

**Fields:**
- `timestamp` — ISO 8601 UTC
- `trace_id` — Current epic or command context (e.g., `epic:ai-cartographer`, `cmd:build`)
- `sender` — Agent role performing the action
- `receiver` — Target role, file, or system
- `action` — One of: `spawn`, `file_update`, `commit`, `handoff`, `status`, `error`, `audit`
- `artifact` — File path or resource being touched
- `summary` — One-sentence description

## Implementation

### How to Log (for agents)

After completing a significant action, append to both logs:

```bash
# Get current timestamp
TS=$(date -u +"%Y-%m-%d %H:%M")
TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Append to human-readable log
echo "[$TS] **{Role}** -> **{Target}**: {Summary}" >> .claude/internal/DISCUSSION_LOG.md

# Append to JSONL log
echo '{"timestamp":"'$TS_ISO'","trace_id":"{epic_or_cmd}","sender":"{Role}","receiver":"{Target}","action":"{action_type}","artifact":"{file_path}","summary":"{Summary}"}' >> .claude/logs/interactions.jsonl
```

### Shortcut

If writing both logs is impractical in context, the human-readable log (DISCUSSION_LOG.md) takes priority. The JSONL log is secondary.

## Important Notes

- **Never skip logging** — even failed actions should be logged (with action: "error")
- **Keep summaries concise** — one sentence, max 100 characters
- **Log at natural boundaries** — don't log every line of code, log meaningful milestones
- **Preserve the log** — never truncate or delete entries; the log is append-only
- **Context carries forward** — include the trace_id so logs can be filtered by epic/command
