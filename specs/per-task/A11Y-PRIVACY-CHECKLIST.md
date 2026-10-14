---
name: a11y-privacy-checklist
kind: template
purpose: Per-screen accessibility and privacy checklist — measured contrast, Dynamic Type, screen-reader order, touch targets, hiding and masking sensitive data; filled before review
owner: reviewer-a11y
---

# Accessibility and privacy checklist — <PROJECT_PREFIX>-NNN

> Saved next to `spec.md` as `a11y-privacy.md`. Mandatory when the screen shows personal, financial, health, or credential data, or introduces an interactive pattern new to the product. Otherwise optional: `reviewer-a11y` works from `domain/accessibility.spec.md` directly.
> The rules live in `domain/accessibility.spec.md` and `domain/color.spec.md`; this form does not restate them. It records **what was measured on this screen** and **what was decided** for sensitive data.
> An item that does not apply stays in the file as one line, `n/a: <why>`. It is never deleted.

## Part A. Accessibility, measured on this screen

### A1. Contrast

Every real pair in every mode. Compute, do not eyeball.

| Pair (text or icon / background) | Mode | Measured | Required | Pass |
|---|---|---|---|---|
| Body / surface | light | | | |
| Body / surface | dark | | | |
| Placeholder / field | light | | | |
| Disabled label / button | light | | | |
| Icon / accent | dark | | | |

### A2. Text scaling

| Check | Result |
|---|---|
| The largest standard text size: nothing truncates that carries meaning | |
| The largest accessibility size (iOS AX5, Android 200%, browser zoom 200%): layout reflows, no horizontal scroll | |
| Frames that change layout at large sizes (stacked instead of side by side) are drawn | |
| Fixed-height containers holding growing text: none, or listed with a reason | |

### A3. Screen-reader order

The order a screen reader walks the screen, written as a list. Where it differs from the visual order, `spec:focus-order` is on the frame.

1. <element>
2. <element>

Icon buttons without `spec:label`: <none | list>. Live regions (`spec:live`): <none | list>.

### A4. Touch targets

| Element | Visual size | Hit area | Spacing to neighbor |
|---|---|---|---|

Targets below the bar in `domain/accessibility.spec.md` carry `spec:hit-area`.

### A5. Motion and time

Reduced-motion variant: <drawn | n/a: why>. Timeouts on this screen: <none | how they are extended>.

## Part B. Privacy of the screen

Mark sensitive regions with a `spec:sensitive` layer so the handoff carries them. For each applicable item, three lines: **what is on the screen**, **what we decided**, **how the handoff says it**.

### B1. Inventory

Which fields on this screen are sensitive: card or account numbers, balances, documents, phone, email, address, health data, one-time codes, passwords, message contents, location. One line each.

### B2. App switcher and backgrounding

What the system snapshot shows when the app goes to the background: a privacy cover, a blurred screen, or the screen as is. A screen with balances, documents, or codes gets a cover; the cover frame is drawn.

### B3. Screenshots and screen recording

What the screen shows while it is being recorded or mirrored: hidden fields, a placeholder, or no change. On platforms that can block screenshots, whether this screen does, and why.

### B4. Masking in fields and lists

How each sensitive value is shown by default: fully masked, partially (for example, the last four digits), or in full. Is there a reveal control, does it auto-hide, and after how long. Secret fields have no autocorrection or suggestions; one-time code and password fields are annotated for system autofill.

### B5. Clipboard

Which values can be copied, and whether a copy expires. Full card or document numbers are not copyable in one tap unless the requirements demand it.

### B6. Notifications and the lock screen

What a notification from this flow shows on a locked device. Amounts, codes, and message contents are hidden on the lock screen by default.

### B7. Examples and placeholders

Mockups, placeholders, and handoff examples use obviously fake data: no real names, numbers, or addresses, including in exported PNGs.

### B8. Shoulder surfing and shared screens

Large-type or high-contrast modes do not reveal masked values. A "hide balances" setting, if the product has one, is respected on this screen.

## Part C. Three typical mistakes on this screen

1. <…>
2. <…>
3. <…>

## Cross-refs

- domain/accessibility.spec.md — the rules behind Part A
- domain/color.spec.md — how contrast is computed per mode
- domain/handoff.spec.md — where `spec:sensitive` and masking rules go for engineering
- workflows/review-pipeline.spec.md — control questions before the verdict
- workflows/research.spec.md — confirming platform claims, such as symbol or capture behavior per OS version
