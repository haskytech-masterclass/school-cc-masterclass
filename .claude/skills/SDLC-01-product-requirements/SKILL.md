---
skill: SDLC-01-product-requirements
description: User stories, acceptance criteria, and functional specifications for software projects
---

You are helping the user with product planning - translating product vision into actionable development work.

## Document Storage

**Location:** `./docs/planning/` (relative to project root)

**Documents:**
- `backlog.md` — Master backlog with epics and stories
- `sprint-{n}.md` — Lightweight sprint plans (created when starting work)

Create the directory if it doesn't exist.

---

## Sprint Planning Workflow

This skill creates the **backlog**. When ready to start work:

1. Revisit `backlog.md` to select the next epic
2. Create `sprint-{n}.md` with:
   - Sprint goal (what epic/milestone we're tackling)
   - Selected stories from backlog
   - Any task breakdowns needed
   - Notes/decisions made during the sprint
3. Update story status in `backlog.md` as work progresses

Sprints are lightweight — no velocity tracking or formal ceremonies. Just a focused work plan for tackling the next epic.

---

## Relationship to Design-Build-Loop

The following artifacts are **handled by the design-build-loop skill** (SDLC-00) and should NOT be created here:

| Artifact | Where It Lives | Design-Build-Loop Section |
|----------|----------------|---------------------------|
| PRFAQ | `docs/planning/design-build-loop.md` | Section 1: ITCH (Job to Be Done, Success Criteria) |
| PRD / Goals | `docs/planning/design-build-loop.md` | Section 1: ITCH + Section 2: CHALLENGE |
| Scope Statement | `docs/planning/design-build-loop.md` | Section 3: BUILD (In Scope / Out of Scope) |
| Use Cases | `docs/planning/design-build-loop.md` | Section 3: BUILD (What to Build) |
| Success Metrics | `docs/planning/design-build-loop.md` | Section 2: CHALLENGE (Hypothesis, Kill Criteria) |

**This skill focuses on:** Breaking down the BUILD section into implementable user stories with functional details.

---

## Your Task

Help translate the design-build-loop's BUILD section into:
1. **User Stories** — What users need to do
2. **Functional Specifications** — How the system behaves
3. **Acceptance Criteria** — How we know it's done

All consolidated into a single `backlog.md` document.

---

## Workflow

### 1. Check for Design-Build-Loop

First, look for an existing design-build-loop document:
- Check `docs/planning/design-build-loop.md`
- If it exists, extract context from ITCH, CHALLENGE, and BUILD sections
- If not, suggest running the design-build-loop skill first

### 2. Create/Update Backlog

Generate or update `docs/planning/backlog.md` with:
- Epics (major feature areas)
- User stories with acceptance criteria
- Functional specifications for complex behaviors
- Priority (Must/Should/Could/Won't)

---

## Backlog Template

```markdown
# Backlog: [Project Name]

**Last Updated:** [Date]
**Design-Build-Loop:** [Link to docs/planning/design-build-loop.md]

---

## Overview

[Brief summary of what's being built — reference design-build-loop for full context]

---

## Epics

**Important:** Epics should be **chronological milestones**, not theme-based groupings. This ensures work flows sequentially rather than creating parallel workstreams.

| # | Epic | What's Delivered | Status |
|---|------|------------------|--------|
| 1 | [First milestone] | [What's working after this] | Not Started |
| 2 | [Second milestone] | [What's added/improved] | Not Started |
| 3 | [Third milestone] | [What's added/improved] | Not Started |

**Example (good):**
1. E1: Reddit Ingestion — Can fetch and store r/localllama posts
2. E2: Entity Extraction — Posts are processed and entities tagged
3. E3: Query Interface — Can browse entities and ask questions

**Example (bad — creates parallel work):**
- E1: Data Layer (all DB stuff)
- E2: Processing (all LLM stuff)
- E3: UI (all interface stuff)

---

## User Stories

### Epic 1: [Epic Name]

#### US-001: [Story Title]

**As a** [user type]
**I want** [goal/action]
**So that** [benefit/value]

**Acceptance Criteria:**
- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]

**Priority:** Must Have
**Dependencies:** [Other stories, systems, or APIs]

**Functional Details:**
- **Trigger:** [What initiates this action]
- **Inputs:** [What data is needed]
- **Process:** [What happens step by step]
- **Outputs:** [What the user sees/gets]
- **Error Cases:** [What can go wrong and how to handle it]

**Technical Notes:**
- [Implementation considerations]
- [Edge cases to handle]

---

#### US-002: [Story Title]

...

---

### Epic 2: [Epic Name]

#### US-003: [Story Title]

...

---

## Non-Functional Requirements

### Performance
- [Specific, measurable requirement]

### Security
- [Specific requirement]

### Data
- [Storage, retention, privacy requirements]

---

## Open Questions

- [ ] [Question] — Owner: [Name]

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| [Date] | Initial backlog created | [Name] |
```

---

## User Story Format

### Basic Structure
```
As a [user type]
I want [goal/action]
So that [benefit/value]
```

### Acceptance Criteria (Given/When/Then)
```
Given [initial context or state]
When [action is performed]
Then [expected outcome]
```

### Priority (MoSCoW)
- **Must Have** — Required for MVP, no workaround exists
- **Should Have** — Important but not critical, has workaround
- **Could Have** — Nice to have, include if time permits
- **Won't Have** — Explicitly out of scope for this iteration

---

## Functional Specification Elements

For complex stories, include:

| Element | Description |
|---------|-------------|
| **Trigger** | What initiates the action (user click, schedule, event) |
| **Inputs** | Data required (with validation rules) |
| **Process** | Step-by-step system behavior |
| **Outputs** | What the user sees or system produces |
| **Error Cases** | What can fail and how to handle each |
| **Business Rules** | Conditions and constraints that apply |
| **State Changes** | What data is created/updated/deleted |

---

## Validation Checklist

Before finalizing backlog:

- [ ] Every story has testable acceptance criteria
- [ ] No ambiguous terms ("fast", "easy", "user-friendly")
- [ ] Priority assigned using MoSCoW
- [ ] Dependencies identified
- [ ] Complex behaviors have functional details
- [ ] Stories trace back to design-build-loop BUILD section
- [ ] Open questions have owners

---

## Example Interaction

**User**: "Create the backlog for KB2"

**Response**:
1. Read `docs/planning/design-build-loop.md` for context
2. Extract BUILD section scope and decisions
3. Break down into chronological epics (Ingestion → Entity Extraction → Query Interface)
4. Write user stories for each epic
5. Add acceptance criteria and functional details
6. Create `docs/planning/backlog.md`

**User**: "Let's start working on Epic 1"

**Response**:
1. Review Epic 1 stories in backlog
2. Create `docs/planning/sprint-1.md`
3. Copy relevant stories, add task breakdown
4. Start work, log progress in sprint doc

---

## Lightweight Sprint Template

When starting work on an epic, create `sprint-{n}.md`:

```markdown
# Sprint [N]: [Epic Name]

**Started:** [Date]
**Goal:** [One sentence — what's working when this is done]

---

## Stories This Sprint

From backlog:
- [ ] US-001: [Title]
- [ ] US-002: [Title]
- [ ] US-003: [Title]

---

## Tasks / Notes

### [Date]
- [What was done]
- [Decisions made]
- [Blockers encountered]

### [Date]
- ...

---

## Done When

- [ ] [Concrete acceptance criterion]
- [ ] [Concrete acceptance criterion]

---

## Retrospective

**What worked:**
-

**What didn't:**
-

**Carry forward:**
-
```

---

## Guidelines

- **Reference design-build-loop** — Don't duplicate ITCH/CHALLENGE content
- **Be specific** — "Display within 2 seconds" not "Display quickly"
- **User-centric** — Frame from user's perspective
- **Testable** — Every criterion should be verifiable
- **Right-sized** — Stories should be completable in 1-3 days
- **Independent** — Minimize dependencies between stories where possible
- **Chronological epics** — Each epic is a milestone, not a theme
