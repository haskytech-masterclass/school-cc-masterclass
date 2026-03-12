---
skill: SDLC-02-frontend-design
description: UI/UX design, wireframes, mockups, design systems, and developer handoff (project)
---

You are helping the user with frontend design - translating user stories into visual designs that a builder can implement.

## Relationship to Other Skills

```
SDLC-00 (design-build-loop)
  Output: docs/planning/design-build-loop.md
  Contains: ITCH (user needs), CHALLENGE, BUILD (scope)
      ↓
SDLC-01 (product-requirements)
  Output: docs/planning/backlog.md
  Contains: Epics, user stories, acceptance criteria
      ↓
SDLC-02 (frontend-design) ← THIS SKILL
  Input: Current epic's stories from backlog
  Output: Screen designs for those stories
      ↓
SDLC-04 (build)
  Picks up screen designs and implements
```

---

## Document Storage

**Inputs:**
- `docs/planning/design-build-loop.md` — High-level context (user needs from ITCH)
- `docs/planning/backlog.md` — User stories (focus on current epic only)
- `docs/planning/sprint-{n}.md` — If a sprint is active

**Outputs:**
- `docs/design/{screen-name}.md` — Per-screen design docs
- `docs/design/design-system.md` — Shared tokens/patterns (created when needed)

Create the directory if it doesn't exist.

---

## Workflow

### 1. Identify Scope

Ask: **"Which epic or sprint are we designing for?"**

Do NOT design the entire backlog. Design just-in-time for what's about to be built.

### 2. Gather Context

- Read `docs/planning/design-build-loop.md` for user needs (ITCH section)
- Read `docs/planning/backlog.md` for the current epic's stories
- Check `docs/design/design-system.md` if it exists (reuse existing patterns)

### 3. Create Screen Designs

For each screen needed by the current epic's stories:
1. Create `docs/design/{screen-name}.md`
2. Include layout, components, interactions, and edge cases
3. Reference design system tokens if available

### 4. Evolve Design System (When Needed)

After 2+ screens, patterns emerge. Create or update `docs/design/design-system.md` to capture:
- Shared colors, typography, spacing
- Reusable component patterns
- This grows organically, not upfront

---

## Document Types

### Screen Design

One file per screen/view. Include:

**Context**
- Which user stories this screen addresses
- User goal and entry points

**Layout**
- ASCII wireframe showing structure
- Component placement and hierarchy

**Components**
- Element breakdown (type, content, behavior)
- States: default, hover, active, disabled, loading, error, empty

**Interactions**
- What happens on click/submit/etc.
- Animations and transitions
- Validation and error handling

**Responsive Behavior**
- Layout changes by breakpoint (mobile/tablet/desktop)

**Accessibility**
- Keyboard navigation
- Screen reader considerations

### Design System

Created when patterns repeat across screens. Include:

**Tokens**
- Colors (brand, semantic, neutral)
- Typography scale
- Spacing scale
- Border radius, shadows

**Components**
- Buttons (variants, sizes, states)
- Form inputs
- Cards, modals, etc.

**Layout**
- Grid system
- Breakpoints

---

## Example Interaction

**User**: "Design the screens for Epic 1"

**Response**:
1. Read `docs/planning/design-build-loop.md` for context
2. Read `docs/planning/backlog.md`, find Epic 1 stories
3. Identify screens needed (e.g., "feed view", "post detail")
4. Create `docs/design/feed-view.md` with layout, components, interactions
5. Create `docs/design/post-detail.md`
6. Note if shared patterns emerge for future design-system.md

**User**: "We're on Epic 3 now, can you design the settings screen?"

**Response**:
1. Check existing `docs/design/design-system.md` for tokens to reuse
2. Read Epic 3 stories from backlog
3. Create `docs/design/settings.md` using established patterns
4. Update design-system.md if new patterns emerged
