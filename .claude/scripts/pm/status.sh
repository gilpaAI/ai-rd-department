#!/bin/bash

echo "Getting status..."
echo ""
echo ""


echo "📊 Project Status"
echo "================"
echo ""

# GitHub-first: try querying GitHub Issues
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
  # GitHub path
  echo "📄 PRDs:"
  if [ -d ".claude/prds" ]; then
    total=$(ls .claude/prds/*.md 2>/dev/null | wc -l)
    echo "  Total: $total"
  else
    echo "  No PRDs found"
  fi

  echo ""
  echo "📚 Epics (GitHub):"
  epic_total=$(gh issue list --repo "$REPO" --label "epic" --state all --json number | jq length 2>/dev/null || echo 0)
  epic_open=$(gh issue list --repo "$REPO" --label "epic" --state open --json number | jq length 2>/dev/null || echo 0)
  epic_closed=$(gh issue list --repo "$REPO" --label "epic" --state closed --json number | jq length 2>/dev/null || echo 0)
  echo "  Open: $epic_open"
  echo "  Closed: $epic_closed"
  echo "  Total: $epic_total"

  echo ""
  echo "📝 Tasks (GitHub):"
  task_total=$(gh issue list --repo "$REPO" --label "task" --state all --json number | jq length 2>/dev/null || echo 0)
  task_open=$(gh issue list --repo "$REPO" --label "task" --state open --json number | jq length 2>/dev/null || echo 0)
  task_closed=$(gh issue list --repo "$REPO" --label "task" --state closed --json number | jq length 2>/dev/null || echo 0)
  in_progress=$(gh issue list --repo "$REPO" --label "status:in-progress" --json number | jq length 2>/dev/null || echo 0)
  blocked=$(gh issue list --repo "$REPO" --label "status:blocked" --json number | jq length 2>/dev/null || echo 0)
  echo "  Open: $task_open"
  echo "  In Progress: $in_progress"
  echo "  Blocked: $blocked"
  echo "  Closed: $task_closed"
  echo "  Total: $task_total"

else
  # Local fallback
  echo "📄 PRDs:"
  if [ -d ".claude/prds" ]; then
    total=$(ls .claude/prds/*.md 2>/dev/null | wc -l)
    echo "  Total: $total"
  else
    echo "  No PRDs found"
  fi

  echo ""
  echo "📚 Epics:"
  if [ -d ".claude/epics" ]; then
    total=$(ls -d .claude/epics/*/ 2>/dev/null | wc -l)
    echo "  Total: $total"
  else
    echo "  No epics found"
  fi

  echo ""
  echo "📝 Tasks:"
  if [ -d ".claude/epics" ]; then
    total=$(find .claude/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
    open=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
    closed=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
    echo "  Open: $open"
    echo "  Closed: $closed"
    echo "  Total: $total"
  else
    echo "  No tasks found"
  fi
fi

exit 0
