#!/bin/bash
echo "Getting tasks..."
echo ""
echo ""

echo "🚫 Blocked Tasks"
echo "================"
echo ""

# GitHub-first: try querying GitHub Issues
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
  # GitHub path
  issues=$(gh issue list --repo "$REPO" --label "status:blocked" --json number,title,labels 2>/dev/null)
  count=$(echo "$issues" | jq length 2>/dev/null || echo 0)

  if [ "$count" -gt 0 ]; then
    echo "$issues" | jq -r '.[] | "⏸️  #\(.number) - \(.title)\n   Labels: \([.labels[].name] | join(", "))\n"' 2>/dev/null
    echo "📊 Total blocked: $count tasks"
  else
    echo "No blocked tasks found!"
    echo ""
    echo "💡 All tasks are either available or in progress."
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
        deps=$(echo "$deps" | sed 's/,/ /g')
        deps=$(echo "$deps" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        [ -z "$deps" ] && deps=""
      else
        deps=""
      fi

      if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
        task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
        task_num=$(basename "$task_file" .md)

        echo "⏸️ Task #$task_num - $task_name"
        echo "   Epic: $epic_name"
        echo "   Blocked by: [$deps]"

        open_deps=""
        for dep in $deps; do
          dep_file="$epic_dir$dep.md"
          if [ -f "$dep_file" ]; then
            dep_status=$(grep "^status:" "$dep_file" | head -1 | sed 's/^status: *//')
            [ "$dep_status" = "open" ] && open_deps="$open_deps #$dep"
          fi
        done

        [ -n "$open_deps" ] && echo "   Waiting for:$open_deps"
        echo ""
        ((found++))
      fi
    done
  done

  if [ $found -eq 0 ]; then
    echo "No blocked tasks found!"
    echo ""
    echo "💡 All tasks with dependencies are either completed or in progress."
  else
    echo "📊 Total blocked: $found tasks"
  fi
fi

exit 0
