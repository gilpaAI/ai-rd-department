# GitHub as Source of Truth

GitHub Issues is the authoritative source for all project status data. Local files are working drafts.

## Core Principle

**GitHub Issues = canonical state. Local files = working drafts.**

When there's a conflict between GitHub and local files, GitHub wins for status fields (state, labels, assignments). Local files win for content (task descriptions, acceptance criteria, technical details).

## Query Pattern

All scripts and commands should follow this pattern:

```bash
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
  # GitHub path — preferred
  # Use gh issue list/view with --json for structured data
else
  # Local fallback — when GitHub is unavailable
  # Read from .claude/epics/ and .claude/prds/
fi
```

## What Lives Where

### GitHub Issues (Authoritative)
- Issue open/closed state
- Status labels (`status:backlog`, `status:in-progress`, `status:blocked`)
- Priority labels
- Assignments
- Comments and progress updates
- Epic-to-task relationships (via labels and sub-issues)

### Local Files (Working Drafts)
- PRD content (`.claude/prds/`)
- Epic technical details (`.claude/epics/*/epic.md`)
- Task descriptions and acceptance criteria (`.claude/epics/*/*.md`)
- Analysis files (`.claude/epics/*/*-analysis.md`)
- Progress tracking (`.claude/epics/*/updates/`)

### Synced Both Ways
- Task status — written to GitHub labels, read back by scripts
- Epic progress — calculated from GitHub issue states
- Completion percentage — derived from closed/total on GitHub

## Status Transitions

All status changes should be made on GitHub first, then reflected locally:

```bash
# Start work
gh issue edit $ISSUE --add-label "status:in-progress" --remove-label "status:backlog"

# Block work
gh issue edit $ISSUE --add-label "status:blocked" --remove-label "status:in-progress"

# Unblock
gh issue edit $ISSUE --add-label "status:in-progress" --remove-label "status:blocked"

# Complete
gh issue close $ISSUE
gh issue edit $ISSUE --remove-label "status:in-progress"
```

## Reading Status

```bash
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')

# Count by state
total=$(gh issue list --repo "$REPO" --label "task" --state all --json number | jq length)
open=$(gh issue list --repo "$REPO" --label "task" --state open --json number | jq length)
closed=$(gh issue list --repo "$REPO" --label "task" --state closed --json number | jq length)

# Count by status label
in_progress=$(gh issue list --repo "$REPO" --label "status:in-progress" --json number | jq length)
blocked=$(gh issue list --repo "$REPO" --label "status:blocked" --json number | jq length)
backlog=$(gh issue list --repo "$REPO" --label "status:backlog" --json number | jq length)
```

## Fallback Behavior

When GitHub is unavailable (no remote, no auth, offline):
1. Log a warning: "GitHub unavailable, using local files"
2. Read status from local frontmatter (`status:` field)
3. Continue with local data
4. Do NOT fail or block the user

## Important Rules

- Never skip the GitHub check — always try GitHub first
- Keep the fallback path working — users may work offline
- Don't cache GitHub state locally for status — always query fresh
- Local file content (descriptions, criteria) doesn't need to match GitHub exactly
- Follow `/rules/github-labels.md` for label conventions
