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

**Format:** Append a block per action — one header line + optional content lines:
```
[YYYY-MM-DD HH:MM] **{Role}** -> **{Target}**: {Action Summary}
  > {key detail or first line of transferred content}
  > {second key detail}
```

The `>` lines are optional but **required for handoffs and file updates** — include
the content being transferred (key decisions, artifact excerpt, or test results).

**Examples:**
```
[2026-02-17 16:30] **Product Manager** -> **Architect**: PRD for 'ai-cartographer' approved. Handing off.
  > Feature: LLM-powered codebase context map generator
  > Approach: content-hash caching + tiered classification; <$1/run
  > Acceptance: init/refresh/status commands working end-to-end

[2026-02-17 16:35] **Tech Lead** -> **GitHub #2**: Created issue: Project scaffolding
  > Title: TypeScript CLI with config loading
  > Labels: task, epic:ai-cartographer, status:backlog

[2026-02-17 16:40] **Backend Developer** -> **src/config.ts**: Implemented config loader
  > cosmiconfig integration, sensible defaults, schema validation
  > 4 tests passing; exports: loadConfig(), Config interface

[2026-02-17 16:45] **QA Engineer** -> **Tech Lead**: All tests passing. 22 files verified.
  > pytest: 22 passed, 0 failed | ruff: 0 errors | mypy: 0 errors

[2026-02-17 16:50] **DevOps Engineer** -> **GitHub**: Pushed commit 324c3be to main branch
  > Files changed: src/config.ts, tests/config.test.ts
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

**When to log:** Same triggers as human-readable log.

**Schema:**
```json
{
  "timestamp": "2026-02-17T16:30:00Z",
  "trace_id": "epic:ai-cartographer",
  "sender": "Product Manager",
  "receiver": "Architect",
  "action": "handoff",
  "artifact": ".claude/prds/ai-cartographer.md",
  "summary": "PRD approved, handing off for technical breakdown",
  "content": "Full or truncated content of what was transferred (first 2000 chars)"
}
```

**Fields:**
- `timestamp` — ISO 8601 UTC
- `trace_id` — Current epic or command context (e.g., `epic:ai-cartographer`, `cmd:build`)
- `sender` — Agent role performing the action
- `receiver` — Target role, file, or system
- `action` — One of: `spawn`, `file_update`, `commit`, `handoff`, `status`, `error`, `audit`
- `artifact` — File path or resource being touched
- `summary` — One-sentence description (max 100 chars)
- `content` — **Full content transferred** (first 2000 chars of artifact or inline payload). Required for `handoff` and `file_update` actions. Omit or `""` for simple status entries.

## Implementation

### How to Log (for agents)

After completing a significant action, append to both logs:

```bash
REPO_ROOT="/c/Users/gilpa/R&D Dep"
TS=$(date -u +"%Y-%m-%d %H:%M")
TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Ensure log directories exist
mkdir -p "$REPO_ROOT/.claude/internal" "$REPO_ROOT/.claude/logs"

# --- Human-readable log ---
# Simple action (status, commit):
echo "[$TS] **{Role}** -> **{Target}**: {Summary}" >> "$REPO_ROOT/.claude/internal/DISCUSSION_LOG.md"

# With content block (handoffs, file updates):
{
  echo "[$TS] **{Role}** -> **{Target}**: {Summary}"
  echo "  > {key detail 1}"
  echo "  > {key detail 2}"
} >> "$REPO_ROOT/.claude/internal/DISCUSSION_LOG.md"

# From an artifact file (first 20 lines):
{
  echo "[$TS] **{Role}** -> **{Target}**: {Summary}"
  head -20 "{artifact_path}" | grep -v '^---' | grep -v '^$' | head -5 | sed 's/^/  > /'
} >> "$REPO_ROOT/.claude/internal/DISCUSSION_LOG.md"

# --- JSONL log (with content field) ---
CONTENT=$(cat "{artifact_path}" 2>/dev/null | head -c 2000 | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""')
printf '{"timestamp":"%s","trace_id":"{trace}","sender":"{Role}","receiver":"{Target}","action":"{action}","artifact":"{file}","summary":"{Summary}","content":%s}\n' \
  "$TS_ISO" "$CONTENT" >> "$REPO_ROOT/.claude/logs/interactions.jsonl"
```

### Shortcut (content as inline string)

When content is known inline (not from a file):

```bash
printf '{"timestamp":"%s","trace_id":"cmd:build","sender":"Tech Lead","receiver":"GitHub","action":"commit","artifact":"src/runner.py","summary":"Module 2 complete","content":"%s"}\n' \
  "$TS_ISO" "Parallel runner with asyncio semaphore + health monitor + JSONL log" \
  >> "$REPO_ROOT/.claude/logs/interactions.jsonl"
```

### Shortcut (logs only)

If writing both logs is impractical in context, the human-readable log (DISCUSSION_LOG.md) takes priority. The JSONL log is secondary.

## New Project Log Initialization

When starting a **brand new project**, initialize fresh log files — do NOT append to logs from other projects:

```bash
# Fresh runtime JSONL for conductor-style projects
mkdir -p "{project_repo}/.conductor/logs"
> "{project_repo}/.conductor/logs/interactions.jsonl"

# Fresh discussion log if the project has its own .claude/ folder
if [ -d "{project_repo}/.claude" ]; then
  mkdir -p "{project_repo}/.claude/internal"
  {
    echo "# Agent Discussion Log"
    echo ""
    echo "> Internal communication channel for this project."
    echo "> Started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "{project_repo}/.claude/internal/DISCUSSION_LOG.md"
fi
```

**Note:** The R&D Dep `.claude/internal/DISCUSSION_LOG.md` is a shared management hub — always append to it. Only project-local logs start fresh.

## Important Notes

- **Never skip logging** — even failed actions should be logged (with action: "error")
- **Include content on handoffs** — a summary without the transferred payload is not enough
- **Keep content truncated** — max 2000 chars to avoid bloated log files
- **Preserve the log** — never truncate or delete entries; the log is append-only
- **Context carries forward** — include the trace_id so logs can be filtered by epic/command
