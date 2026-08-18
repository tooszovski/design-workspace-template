#!/usr/bin/env bash
# Блокирует пуш в интеграционную и релизную ветки и любой force-push.
# Их пушит человек — см. specs/core/git-policy.spec.md.

set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')

case "$CMD" in
    *"git push"*) ;;
    *) exit 0 ;;
esac

PROTECTED="${INTEGRATION_BRANCH:-<INTEGRATION_BRANCH>} ${RELEASE_BRANCH:-<RELEASE_BRANCH>}"

deny() {
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
    exit 0
}

case "$CMD" in
    *--force*|*" -f "*|*--force-with-lease*)
        deny "Force-push запрещён политикой workspace (specs/core/git-policy.spec.md). Если ветка личная и вы уверены — выполните команду вручную." ;;
esac

for branch in $PROTECTED; do
    case "$branch" in "<"*">") continue ;; esac
    case "$CMD" in
        *" $branch"*|*":$branch"*)
            deny "Пуш в защищённую ветку '$branch' запрещён — её пушит человек (specs/core/git-policy.spec.md). Работайте в ветке design/<task-id>-<slug>." ;;
    esac
done

exit 0
