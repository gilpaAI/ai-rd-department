# GitHub Label Convention

Standard labels used across all repositories managed by CCPM.

## Label Scheme

### Type Labels
- `epic` — Parent issue representing a feature or initiative
- `task` — Individual work item within an epic

### Epic Association
- `epic:{name}` — Links a task to its parent epic (e.g., `epic:user-auth`)

### Status Labels (Mutually Exclusive)
- `status:backlog` — Planned but not started
- `status:in-progress` — Actively being worked on
- `status:blocked` — Cannot proceed, needs intervention

### Priority Labels
- `priority:high` — Must be done first
- `priority:medium` — Standard priority
- `priority:low` — Nice to have, do when available

### Feature Type Labels
- `feature` — New functionality
- `bug` — Fix for existing functionality
- `enhancement` — Improvement to existing feature

## Label Colors

| Label | Color |
|-------|-------|
| `epic` | `#7057ff` (purple) |
| `task` | `#0075ca` (blue) |
| `epic:*` | `#e4e669` (yellow) |
| `status:backlog` | `#d4c5f9` (light purple) |
| `status:in-progress` | `#fbca04` (yellow) |
| `status:blocked` | `#d93f0b` (red) |
| `priority:high` | `#b60205` (dark red) |
| `priority:medium` | `#fbca04` (yellow) |
| `priority:low` | `#0e8a16` (green) |

## Usage Rules

1. **Status labels are mutually exclusive** — a task has at most one `status:*` label
2. **Every task gets an `epic:{name}` label** — links it to the parent epic
3. **Status transitions**: `status:backlog` → `status:in-progress` → (closed)
4. **Blocked items** get `status:blocked` added, `status:in-progress` removed
5. **When closing an issue**, remove all `status:*` labels

## Creating Labels

Use the init script or create manually:
```bash
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')

# Type labels
gh label create "epic" --repo "$REPO" --color "7057ff" --description "Parent issue for a feature" --force
gh label create "task" --repo "$REPO" --color "0075ca" --description "Work item within an epic" --force

# Status labels
gh label create "status:backlog" --repo "$REPO" --color "d4c5f9" --description "Planned, not started" --force
gh label create "status:in-progress" --repo "$REPO" --color "fbca04" --description "Actively being worked on" --force
gh label create "status:blocked" --repo "$REPO" --color "d93f0b" --description "Cannot proceed" --force

# Priority labels
gh label create "priority:high" --repo "$REPO" --color "b60205" --description "Must do first" --force
gh label create "priority:medium" --repo "$REPO" --color "fbca04" --description "Standard priority" --force
gh label create "priority:low" --repo "$REPO" --color "0e8a16" --description "When available" --force
```

## Querying by Label

```bash
# All epics
gh issue list --repo "$REPO" --label "epic"

# Tasks for a specific epic
gh issue list --repo "$REPO" --label "epic:{name}"

# Current work
gh issue list --repo "$REPO" --label "status:in-progress"

# Blocked items
gh issue list --repo "$REPO" --label "status:blocked"

# High priority backlog
gh issue list --repo "$REPO" --label "status:backlog" --label "priority:high"
```
