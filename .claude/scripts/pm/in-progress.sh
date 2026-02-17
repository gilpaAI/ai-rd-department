#!/bin/bash
echo "Getting status..."
echo ""
echo ""

echo "🔄 In Progress Work"
echo "==================="
echo ""

# GitHub-first: try querying GitHub Issues
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
  # GitHub path
  echo "📝 In Progress Issues (GitHub):"
  issues=$(gh issue list --repo "$REPO" --label "status:in-progress" --json number,title,labels,assignees 2>/dev/null)
  count=$(echo "$issues" | jq length 2>/dev/null || echo 0)

  if [ "$count" -gt 0 ]; then
    echo "$issues" | jq -r '.[] | "  #\(.number) - \(.title)\(if .assignees | length > 0 then " (@" + (.assignees[0].login) + ")" else "" end)"' 2>/dev/null
    echo ""
    echo "📊 Total in progress: $count"
  else
    echo "  No in-progress issues found."
    echo ""
    echo "💡 Start work with: /pm:next"
  fi

  echo ""
  echo "📚 Active Epics (GitHub):"
  epics=$(gh issue list --repo "$REPO" --label "epic" --state open --json number,title 2>/dev/null)
  epic_count=$(echo "$epics" | jq length 2>/dev/null || echo 0)

  if [ "$epic_count" -gt 0 ]; then
    echo "$epics" | jq -r '.[] | "   • #\(.number) - \(.title)"' 2>/dev/null
  else
    echo "   No active epics."
  fi

else
  # Local fallback
  found=0

  if [ -d ".claude/epics" ]; then
    for updates_dir in .claude/epics/*/updates/*/; do
      [ -d "$updates_dir" ] || continue

      issue_num=$(basename "$updates_dir")
      epic_name=$(basename $(dirname $(dirname "$updates_dir")))

      if [ -f "$updates_dir/progress.md" ]; then
        completion=$(grep "^completion:" "$updates_dir/progress.md" | head -1 | sed 's/^completion: *//')
        [ -z "$completion" ] && completion="0%"

        task_file=".claude/epics/$epic_name/$issue_num.md"
        if [ -f "$task_file" ]; then
          task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
        else
          task_name="Unknown task"
        fi

        echo "📝 Issue #$issue_num - $task_name"
        echo "   Epic: $epic_name"
        echo "   Progress: $completion complete"

        if [ -f "$updates_dir/progress.md" ]; then
          last_update=$(grep "^last_sync:" "$updates_dir/progress.md" | head -1 | sed 's/^last_sync: *//')
          [ -n "$last_update" ] && echo "   Last update: $last_update"
        fi

        echo ""
        ((found++))
      fi
    done
  fi

  echo "📚 Active Epics:"
  for epic_dir in .claude/epics/*/; do
    [ -d "$epic_dir" ] || continue
    [ -f "$epic_dir/epic.md" ] || continue

    status=$(grep "^status:" "$epic_dir/epic.md" | head -1 | sed 's/^status: *//')
    if [ "$status" = "in-progress" ] || [ "$status" = "active" ]; then
      epic_name=$(grep "^name:" "$epic_dir/epic.md" | head -1 | sed 's/^name: *//')
      progress=$(grep "^progress:" "$epic_dir/epic.md" | head -1 | sed 's/^progress: *//')
      [ -z "$epic_name" ] && epic_name=$(basename "$epic_dir")
      [ -z "$progress" ] && progress="0%"

      echo "   • $epic_name - $progress complete"
    fi
  done

  echo ""
  if [ $found -eq 0 ]; then
    echo "No active work items found."
    echo ""
    echo "💡 Start work with: /pm:next"
  else
    echo "📊 Total active items: $found"
  fi
fi

exit 0
