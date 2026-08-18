#!/usr/bin/env bash
# Blocks pushes to the integration and release branches, and any force-push.
# A human pushes those — see specs/core/git-policy.spec.md.

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
        deny "Force-push is blocked by workspace policy (specs/core/git-policy.spec.md). If the branch is yours alone and you are sure, run the command manually." ;;
esac

for branch in $PROTECTED; do
    case "$branch" in "<"*">") continue ;; esac
    case "$CMD" in
        *" $branch"*|*":$branch"*)
            deny "Pushing to protected branch '$branch' is blocked — a human pushes it (specs/core/git-policy.spec.md). Work in a design/<task-id>-<slug> branch." ;;
    esac
done

exit 0
