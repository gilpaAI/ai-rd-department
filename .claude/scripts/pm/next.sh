#!/bin/bash
echo "Getting status..."
echo ""
echo ""

echo "📋 Next Available Tasks"
echo "======================="
echo ""

# GitHub-first: try querying GitHub Issues
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
  # GitHub path: open tasks not labeled blocked or in-progress
  all_open=$(gh issue list --repo "$REPO" --label "task" --state open --json number,title,labels 2>/dev/null)

  # Filter out tasks that have status:in-progress or status:blocked labels
  available=$(echo "$all_open" | jq '[.[] | select(.labels | map(.name) | (contains(["status:in-progress"]) or contains(["status:blocked"])) | not)]' 2>/dev/null)
  count=$(echo "$available" | jq length 2>/dev/null || echo 0)

  if [ "$count" -gt 0 ]; then
    echo "$available" | jq -r '.[] | "✅ Ready: #\(.number) - \(.title)\n   Labels: \([.labels[].name] | join(", "))\n"' 2>/dev/null
    echo "📊 Summary: $count tasks ready to start"
  else
    echo "No available tasks found."
    echo ""
    echo "💡 Suggestions:"
    echo "  • Check blocked tasks: /pm:blocked"
    echo "  • View all tasks: /pm:epic-list"
  fi

else
  # Local fallback
  found=0

  for epic_dir in .claude/epics/*/; do
    [ -d "$epic_dir" ] || continue
    epic_name=$(basename "$epic_dir")

    for task_file in "$epic_dir"/[0-9]*.md; do
      [ -f "$task_file" ] || continue

      status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
      if [ "$status" != "open" ] && [ -n "$status" ]; then
        continue
      fi

      deps_line=$(grep "^depends_on:" "$task_file" | head -1)
      if [ -n "$deps_line" ]; then
        deps=$(echo "$deps_line" | sed 's/^depends_on: *//')
        deps=$(echo "$deps" | sed 's/^\[//' | sed 's/\]$//')
        deps=$(echo "$deps" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        [ -z "$deps" ] && deps=""
      else
        deps=""
      fi

      if [ -z "$deps" ] || [ "$deps" = "depends_on:" ]; then
        task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
        task_num=$(basename "$task_file" .md)
        parallel=$(grep "^parallel:" "$task_file" | head -1 | sed 's/^parallel: *//')

        echo "✅ Ready: #$task_num - $task_name"
        echo "   Epic: $epic_name"
        [ "$parallel" = "true" ] && echo "   🔄 Can run in parallel"
        echo ""
        ((found++))
      fi
    done
  done

  if [ $found -eq 0 ]; then
    echo "No available tasks found."
    echo ""
    echo "💡 Suggestions:"
    echo "  • Check blocked tasks: /pm:blocked"
    echo "  • View all tasks: /pm:epic-list"
  fi

  echo ""
  echo "📊 Summary: $found tasks ready to start"
fi

exit 0
