# MindSpark — High-Fidelity Wireframe Specifications (User-side)

Overview
- Purpose: Exact UI structure, spacing, contents, and interactions for the four previews (Welcome/Age → Topics → Levels → Quiz) plus Dashboard.
- Viewports: Desktop (1200px container), Tablet (768–1024px), Mobile (360–420px). Provide responsive rules when necessary.
- Design tokens summarized in the Admin spec (colors, spacings, typography) — reference in each section.

Global UI Elements
- App shell: top-left logo, top-right profile (avatar, dropdown), global progress pill, notifications icon.
- Footer: small links (Help, Privacy). Persisted only on full-screen views.
- Animations: CSS classes `ms-animate-bounce`, `ms-animate-fade`, `ms-animate-confetti`. Respect prefers-reduced-motion.

1) FIRST PREVIEW — Welcome / Age Group Selection
- Screen header:
  - Left: MindSpark wordmark.
  - Center: Title: "Welcome to MindSpark!"
  - Subtitle: "Choose your age group to begin your adventure."
- Age grid: 2 rows × 3 cards (desktop); 3 per row on tablet; stacked horizontally on mobile (scroll).
  - Card size: desktop 320×220px; border-radius 12px; elevated shadow.
  - Card content:
    - Top-left: age label (e.g., "Ages 0–3") — bold 18px.
    - Center-left: bouncing icon SVG (40–56px). Use `ms-animate-bounce` toggle.
    - Bottom-left: tagline (12–14px, dim color).
    - Footer row: trending topics teasers — horizontally scrollable chips (icon + label), 2–3 items; not clickable.
  - Selection behavior:
    - Unselected: neutral bg `--ms-bg-0`, 1px border.
    - Hover/focus: lift + glow.
    - Selected: gradient outline, slightly larger scale, checkmark badge.
- Primary CTA:
  - Button text: "Select Your Age Group…"
  - Disabled until selection. Show subtle tooltip when disabled on hover: "Pick an age group to continue."
- Accessibility:
  - Each card is a radio role group: role="radio", aria-checked.
  - Provide non-visual label text.
- Edge microcopy:
  - If age group has zero topics: small inline note under card: "No topics yet — be the first to try this age group!"

2) SECOND PREVIEW — Topic Selection
- Header:
  - Top-left back chevron: "Back" (returns to Age Selection).
  - Title: "Choose a Topic"
  - Right: "Go to Dashboard" link.
- Topics grid:
  - Desktop: 3 per row cards, tile size 320×180 px.
  - Tile content:
    - Icon top-left (40px).
    - Title (bold).
    - Badges row: "Active" (green) or "No questions" (gray).
    - Stats row: Levels (e.g., 100), Questions count, Estimated time.
    - Select button (primary) — entire tile clickable; selected tile shows filled outline.
    - Disabled state: opacity 0.45, cursor: not-allowed, simple tooltip: "No questions available".
- Rules:
  - Single-selection (radio). Selecting a new tile deselects previous.
  - Start Quiz button disabled until selection.
  - If user tries to trigger Start without selection (keyboard or script), show a toast: "Please select a topic first!" and soft ding audio.
- Keyboard:
  - Use arrow keys to move focus across tiles; press Enter to select.

3) THIRD PREVIEW — Level Selection
- Header:
  - Back button, Title "Levels", small subtitle: Topic name + progress pill.
  - Controls: page selector (1..20), search box (Quick jump to level).
- Level tiles:
  - Display 5 tiles per page horizontally (desktop) or vertically (mobile).
  - Each tile includes:
    - Prominent level number badge.
    - Subtext: question count.
    - Status icon: Lock (if locked), Progress bar (if in-progress), Check (if completed).
    - Score area if previously attempted: percentage + label (use scoring ladder).
    - Tile colors:
      - Locked: grayscale, lock overlay.
      - Unlocked: neutral border, hover highlight.
      - Completed: green gradient, score ribbon with text.
- Unlocking UI:
  - Locked tile tooltip: "Locked — complete Level X to unlock."
  - If user clicks locked tile, open modal with info and "Practice previous levels" CTA.
- Pagination:
  - Left/Right chevrons + page indicator. Also fast-jump dropdown for groups (1–20).
- Extra:
  - "Auto-advance" toggle to start next unlocked level automatically after completion.

4) FOURTH PREVIEW — Quiz Card Screen
- Layout:
  - Header: Level title, level number, question count, progress bar (x/y).
  - Main card (question):
    - Optional media area (image/video/audio) with captions.
    - Question text (large, 20–22px).
    - Answer area: 2–4 big option buttons (full-width or split grid on wide screens).
    - If option has image: image with label beneath.
    - For multi-select: checkboxes with "Submit" CTA; for single-choice: click to lock answer then immediate feedback (configurable).
  - Timer (optional): top-right small circular timer. Configurable globally/per-level.
  - Feedback:
    - On correct: green tick overlay and `ms-animate-confetti` microanimation.
    - On wrong: pulse red, display correct option highlight and explanation panel.
  - Controls:
    - Prev/Next question buttons.
    - "Quit & Save" button leading to confirmation dialog.
    - On completion show summary modal: overall score %, reward message, stats chart (pie or bar), CTA buttons: "Retry", "Next Level" (only if unlocked), "Back to Levels".
- Interaction rules:
  - Prevent accidental close with in-progress dialog.
  - Keyboard shortcuts: 1..4 for selection, enter for submit.
- Mobile specifics:
  - Option buttons stacked, large touch targets (min 44px).

Assets & Icons
- Icon set: 6 age icons, topic icons (vector SVGs).
- Animated SVGs for success/confetti.
- Small sound pack: ding (error), correct, incorrect (all < 20KB each).
- Provide spritesheet or single SVG with symbol use.

Deliverables in this file:
- Visual specs for spacing, font sizes, colors (refer to Admin design tokens).
- Microinteraction definitions (hover, focus, success/wrong).
- Accessibility check items per screen (tab order, ARIA labels, contrast).

End of wireframes.