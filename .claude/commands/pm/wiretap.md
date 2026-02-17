---
allowed-tools: Bash, Read
---

# Wiretap

View the internal "monologue" and handoffs between AI agents.

## Usage
```
/pm:wiretap [lines]
```

Default: last 20 entries. Pass a number for more/fewer.

## Instructions

### 1. Read the Log

Read `.claude/internal/DISCUSSION_LOG.md`. Extract the last N entries (default 20, or the number provided as $ARGUMENTS).

If $ARGUMENTS is a number, use that as the line count. If empty, use 20.

### 2. Format Output

Present entries as a conversation thread with role emojis:

```
🎧 **Internal Comms Channel**
============================

[10:01 AM] 👤 **Product Manager** -> 🏗️ **Architect**
  "PRD for 'User Dashboard' approved. Handing off for technical breakdown."

[10:05 AM] 🏗️ **Architect** -> 🔧 **Tech Lead**
  "Created epic/dashboard. Detected 3 parallel streams: API, UI, DB."

[10:15 AM] 🔧 **Tech Lead** -> 🤖 **Parallel Worker**
  "Starting work on Database Schema in .claude/epics/dashboard/001.md"
```

### Role Emoji Map
- 👤 Product Manager
- 📋 Project Manager
- 💰 Budget Owner
- 🏗️ Architect
- 🔧 Tech Lead
- 🎨 Frontend Developer
- ⚙️ Backend Developer
- 🧪 QA Engineer
- 🚀 DevOps Engineer
- ✏️ UX Designer
- 🤖 Parallel Worker
- 🗺️ Context Map
- 👔 Gil

### 3. JSONL Analysis (Optional)

If the user asks for "detailed" or "json" view, also read `.claude/logs/interactions.jsonl` and provide:
- Count of interactions by sender role
- Count by action type (spawn, handoff, commit, etc.)
- Timeline of the current epic

### 4. Status Check

If the log is empty (only has the header) or has no entries in the last 24 hours:
```
📡 No recent agent activity detected.
Last entry: {timestamp} ({time ago})
```

If the log file doesn't exist:
```
📡 No agent activity log found.
Initialize with: The log is created automatically when agents follow the interaction-logging rule.
```

### 5. Filter Options

If $ARGUMENTS contains a role name (e.g., "Architect"), filter entries to show only interactions involving that role.

If $ARGUMENTS contains an epic name (e.g., "ai-cartographer"), filter by trace_id in the JSONL log.
