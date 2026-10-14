#!/usr/bin/env bash
# SessionStart: reminder to reconcile the scaffolding with its template (specs/workflows/template-sync.spec.md).
# Never blocks. Silent when everything is fresh. bash 3.2.
set -u
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
M=.template-sync
if [ ! -f "$M" ]; then
  echo "template-sync: no $M marker. Run /template-sync down to record the template baseline."
  exit 0
fi
sha=$(sed -n 's/^sha=\([0-9a-f]\{40\}\).*/\1/p' "$M" | head -1)
day=$(sed -n 's/.*date=\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p' "$M" | head -1)

head=""
for b in master main; do
  if git rev-parse -q --verify "refs/remotes/template/$b" >/dev/null 2>&1; then
    head=$(git rev-parse "refs/remotes/template/$b")
    break
  fi
done
if [ -z "$head" ] && [ -n "${TEMPLATE_DIR:-}" ] && [ -d "$TEMPLATE_DIR/.git" ]; then
  head=$(git -C "$TEMPLATE_DIR" rev-parse HEAD 2>/dev/null || true)
fi

if [ -n "$head" ] && [ -n "$sha" ] && [ "$head" != "$sha" ]; then
  n=""
  if git rev-parse -q --verify "$sha" >/dev/null 2>&1 && git rev-parse -q --verify "$head" >/dev/null 2>&1; then
    n=$(git rev-list --count "$sha".."$head" 2>/dev/null || true)
  fi
  echo "template-sync: the template moved past the marker (${sha:0:7} -> ${head:0:7}${n:+, $n commits}). Run /template-sync down."
fi

if [ -n "$day" ]; then
  now=$(date +%s)
  then_s=$(date -j -f %Y-%m-%d "$day" +%s 2>/dev/null || date -d "$day" +%s 2>/dev/null || echo "$now")
  age=$(( (now - then_s) / 86400 ))
  if [ "$age" -gt 14 ]; then
    echo "template-sync: last reconciliation with the template was $day ($age days ago). Run /template-sync down."
  fi
fi
exit 0
