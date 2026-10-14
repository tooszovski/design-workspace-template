# Typical tasks for a run

Seven tasks with no tie to a specific product. Each one exercises its own part of the scaffolding.

## 1. Onboarding

Three to five screens introducing the product, with a permission request (notifications or location) in the middle. What matters: skip and return paths, what happens when permission is denied, how progress is shown, how it reads at the largest text size. Exercises: research (current platform guidance on permission priming), alternatives in a DDR, text scaling.

## 2. A form with errors

Sign-up or checkout with five to eight fields, inline validation, and a server-side error that arrives after submit. What matters: visible labels, the format hint before the error, focus moving to the first error, a second tap while submitting. Exercises: element states, copy review, screen-reader order, failure modes "service error" and "long loading".

## 3. Empty feed

A content feed for a new user, a user whose filter matches nothing, and a user who lost the network. What matters: `empty` versus `empty-filtered` versus `offline`, an action out of each, the transition to the first item. Exercises: the states contract 4a/4b/4c, failure modes "empty data" and "no network".

## 4. A screen with sensitive data

Account or card details: balance, number, owner, a "show" control, a copy action. What matters: app-switcher cover, behavior under screen recording, partial masking, clipboard, lock-screen notifications from this flow, fake data in mockups. Exercises: the privacy part of the checklist, `spec:sensitive`, the handoff Privacy section.

## 5. Adapting to Dynamic Type

An existing dense screen (a list with metadata rows and a toolbar) reworked to survive the largest accessibility sizes. What matters: which rows stack, what truncates and what never does, toolbar overflow, fixed heights. Exercises: text scaling in the checklist, numbers against tokens, the control question on contradicting sizes.

## 6. Stale data and a slow network

A dashboard showing figures that update in the background, opened after a day offline on a slow connection. What matters: how staleness is signaled, what is shown while refreshing, a partial response where some cards load and others fail. Exercises: failure modes "stale data", "partial response", "long loading".

## 7. A new system pattern

Moving a section to a navigation pattern or a system material the product has never used, with symbols whose availability depends on the OS version. What matters: confirming the pattern and symbol availability per supported version, a fallback for older versions, the outdated-claims list. Exercises: research by primary sources, the "non-existent references" control question, version rollback in failure modes.
