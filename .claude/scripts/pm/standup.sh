#!/bin/bash

echo "📅 Daily Standup - $(date '+%Y-%m-%d')"
echo "================================"
echo ""

today=$(date '+%Y-%m-%d')

echo "Getting status..."
echo ""
echo ""

# GitHub-first: try querying GitHub Issues
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -n "$REPO" ] && gh issue list --repo "$REPO" --limit 1 &>/dev/null; then
  # GitHub path
  echo "📝 Recent Activity (GitHub):"
  echo "===================="
  echo ""

  # Recently updated issues (last 24h approximation via --limit)
  recent=$(gh issue list --repo "$REPO" --state all --limit 10 --json number,title,state,updatedAt 2>/dev/null)
  echo "$recent" | jq -r '.[] | "  • #\(.number) - \(.title) [\(.state)] (updated: \(.updatedAt[:10]))"' 2>/dev/null

  echo ""
  echo "🔄 Currently In Progress (GitHub):"
  in_progress=$(gh issue list --repo "$REPO" --label "status:in-progress" --json number,title,assignees 2>/dev/null)
  ip_count=$(echo "$in_progress" | jq length 2>/dev/null || echo 0)

  if [ "$ip_count" -gt 0 ]; then
    echo "$in_progress" | jq -r '.[] | "  • #\(.number) - \(.title)"' 2>/dev/null
  else
    echo "  No in-progress items."
  fi

  echo ""
  echo "🚫 Blocked (GitHub):"
  blocked=$(gh issue list --repo "$REPO" --label "status:blocked" --json number,title 2>/dev/null)
  bl_count=$(echo "$blocked" | jq length 2>/dev/null || echo 0)

  if [ "$bl_count" -gt 0 ]; then
    echo "$blocked" | jq -r '.[] | "  • #\(.number) - \(.title)"' 2>/dev/null
  else
    echo "  None blocked."
  fi

  echo ""
  echo "⏭️ Next Available Tasks (GitHub):"
  all_open=$(gh issue list --repo "$REPO" --label "task" --state open --json number,title,labels 2>/dev/null)
  available=$(echo "$all_open" | jq '[.[] | select(.labels | map(.name) | (contains(["status:in-progress"]) or contains(["status:blocked"])) | not)][:3]' 2>/dev/null)
  avail_count=$(echo "$available" | jq length 2>/dev/null || echo 0)

  if [ "$avail_count" -gt 0 ]; then
    echo "$available" | jq -r '.[] | "  • #\(.number) - \(.title)"' 2>/dev/null
  else
    echo "  No tasks ready."
  fi

  echo ""
  echo "📊 Quick Stats (GitHub):"
  total_tasks=$(gh issue list --repo "$REPO" --label "task" --state all --json number | jq length 2>/dev/null || echo 0)
  open_tasks=$(gh issue list --repo "$REPO" --label "task" --state open --json number | jq length 2>/dev/null || echo 0)
  closed_tasks=$(gh issue list --repo "$REPO" --label "task" --state closed --json number | jq length 2>/dev/null || echo 0)
  echo "  Tasks: $open_tasks open, $closed_tasks closed, $total_tasks total"
  echo "  In progress: $ip_count | Blocked: $bl_count"

else
  # Local fallback
  echo "📝 Today's Activity:"
  echo "===================="
  echo ""

  recent_files=$(find .claude -name "*.md" -mtime -1 2>/dev/null)

  if [ -n "$recent_files" ]; then
    prd_count=$(echo "$recent_files" | grep -c "/prds/" || echo 0)
    epic_count=$(echo "$recent_files" | grep -c "/epic.md" || echo 0)
    task_count=$(echo "$recent_files" | grep -c "/[0-9]*.md" || echo 0)
    update_count=$(echo "$recent_files" | grep -c "/updates/" || echo 0)

    [ $prd_count -gt 0 ] && echo "  • Modified $prd_count PRD(s)"
    [ $epic_count -gt 0 ] && echo "  • Updated $epic_count epic(s)"
    [ $task_count -gt 0 ] && echo "  • Worked on $task_count task(s)"
    [ $update_count -gt 0 ] && echo "  • Posted $update_count progress update(s)"
  else
    echo "  No activity recorded today"
  fi

  echo ""
  echo "🔄 Currently In Progress:"
  for updates_dir in .claude/epics/*/updates/*/; do
    [ -d "$updates_dir" ] || continue
    if [ -f "$updates_dir/progress.md" ]; then
      issue_num=$(basename "$updates_dir")
      epic_name=$(basename $(dirname $(dirname "$updates_dir")))
      completion=$(grep "^completion:" "$updates_dir/progress.md" | head -1 | sed 's/^completion: *//')
      echo "  • Issue #$issue_num ($epic_name) - ${completion:-0%} complete"
    fi
  done

  echo ""
  echo "⏭️ Next Available Tasks:"
  count=0
  for epic_dir in .claude/epics/*/; do
    [ -d "$epic_dir" ] || continue
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
        echo "  • #$task_num - $task_name"
        ((count++))
        [ $count -ge 3 ] && break 2
      fi
    done
  done

  echo ""
  echo "📊 Quick Stats:"
  total_tasks=$(find .claude/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
  open_tasks=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
  closed_tasks=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
  echo "  Tasks: $open_tasks open, $closed_tasks closed, $total_tasks total"
fi

exit 0
