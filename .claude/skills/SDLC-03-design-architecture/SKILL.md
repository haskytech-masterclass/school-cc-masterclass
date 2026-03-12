---
skill: SDLC-03-design-architecture
description: System design, technical decisions, ADRs, and architecture documentation (project)
---

You are helping the user with software architecture - making and documenting technical decisions that shape how systems are built.

## Relationship to Other Skills

```
SDLC-00 (design-build-loop)
  Output: docs/planning/design-build-loop.md
      ↓
SDLC-01 (product-requirements)
  Output: docs/planning/backlog.md
      ↓
      ├─────────────────────────────────────────┐
      ▼                                         ▼
SDLC-02 (frontend-design)              SDLC-03 (architecture) ← THIS SKILL
  Output: docs/design/                   Output: docs/architecture/
      │                                         │
      └──────── API Contract ───────────────────┘
                (data shapes, endpoints)
      │                                         │
      ▼                                         ▼
SDLC-04 (build)
  Reads both design + architecture docs
```

SDLC-02 and SDLC-03 run **in parallel** — they inform each other through the API contract.

---

## Document Storage

**Inputs:**
- `docs/planning/design-build-loop.md` — Technical constraints from CHALLENGE section
- `docs/planning/backlog.md` — User stories (current epic or full backlog)
- `docs/design/{screen}.md` — Frontend expectations (if UI-driven)

**Outputs:**
- `docs/architecture/system.md` — Overall system design (long-term)
- `docs/architecture/specs/{feature}.md` — Feature-specific specs (per-epic)
- `docs/architecture/adr/ADR-NNN-{title}.md` — Decision records (accumulates)

Create directories if they don't exist.

---

## Two Modes

### Foundation Mode (run once, early)

**When:** After SDLC-00/01, before first epic build

**Purpose:** Establish long-term architecture direction

**Create:**
- `docs/architecture/system.md` — Components, data stores, integrations
- Initial ADRs for core decisions (database choice, auth approach, etc.)

### Feature Mode (run per-epic, parallel with SDLC-02)

**When:** Starting a new epic

**Purpose:** Design the technical approach for specific features

**Create:**
- `docs/architecture/specs/{feature}.md` — API, data model, logic
- New ADRs if significant decisions arise

**Update:**
- `system.md` if architecture evolves

---

## Workflow

### Foundation Mode

1. Read `docs/planning/design-build-loop.md` for scope and constraints
2. Read `docs/planning/backlog.md` to understand full scope
3. Design overall system architecture
4. Create `system.md` with components, data flow, integrations
5. Create ADRs for foundational decisions

### Feature Mode

1. Ask: **"Which epic or feature are we designing?"**
2. Read relevant user stories from backlog
3. Check `docs/design/{screen}.md` if frontend design exists
4. Create `specs/{feature}.md` with API contract, data model, logic
5. Create ADRs for any new significant decisions
6. Update `system.md` if this feature changes overall architecture

---

## Document Types

### System Architecture (`system.md`)

Long-term document. Include:

**Overview**
- Purpose and scope
- Key constraints and quality attributes

**Architecture Diagram**
- Component diagram (mermaid or ASCII)
- Data flow between components

**Components**
- Each component: responsibility, interfaces, dependencies, data owned

**Data Architecture**
- Data stores and their purposes
- Key entities and relationships

**Integrations**
- External systems and protocols
- Internal communication patterns

**Cross-Cutting Concerns**
- Auth, logging, error handling, config management

**Deployment**
- Infrastructure overview
- Environments

---

### Feature Spec (`specs/{feature}.md`)

Per-epic document. Include:

**Summary**
- What this feature does
- Which user stories it addresses

**API Contract**
- Endpoints (method, path, request, response)
- Data shapes frontend will receive

**Data Model**
- Tables/schemas with fields
- Indexes and constraints
- Migration notes if changing existing data

**Logic**
- Step-by-step flow
- Business rules
- Error handling table (error → handling)

**Dependencies**
- External services, libraries

**Open Questions**
- Decisions still needed

**Decisions Made**
- Link to relevant ADRs

---

### ADR (`adr/ADR-NNN-{title}.md`)

Accumulates over time. Include:

**Header**
- Date, status (Proposed/Accepted/Deprecated/Superseded)

**Context**
- What's the issue or decision needed?
- Constraints and forces at play

**Decision**
- What we decided ("We will...")

**Options Considered**
- Each option: description, pros, cons

**Consequences**
- Positive, negative, neutral outcomes

---

## Example: Feature Spec

`docs/architecture/specs/reddit-ingestion.md`:

```markdown
# Feature Spec: Reddit Ingestion

**Epic:** 1 - Reddit Ingestion
**Status:** Draft

## Summary

Fetch posts from r/localllama, normalize to JSON, store in PostgreSQL.

## User Stories

- US-001: Fetch Reddit posts on schedule
- US-002: Store posts with metadata

## API Contract

POST /ingest/reddit
  Body: { subreddit: string, limit?: number }
  Response: { ingested: number, errors: string[] }

GET /posts?source=reddit&since={timestamp}
  Response: { posts: Post[] }

### Data Shape

interface Post {
  id: string
  source: "reddit"
  title: string
  content: string
  author: string
  url: string
  created_at: timestamp
  metadata: { subreddit, score, num_comments }
}

## Data Model

CREATE TABLE posts (
  id UUID PRIMARY KEY,
  source VARCHAR(50) NOT NULL,
  external_id VARCHAR(255) NOT NULL,
  title TEXT NOT NULL,
  content TEXT,
  author VARCHAR(255),
  url TEXT,
  created_at TIMESTAMP NOT NULL,
  ingested_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB,
  UNIQUE(source, external_id)
);

## Logic

1. Call Reddit API (limit=100)
2. For each post: check duplicate, normalize, insert
3. Return count + errors

### Error Handling

| Error | Handling |
|-------|----------|
| Reddit API down | Log, retry in 5 min |
| Invalid post | Skip, log warning |
| DB failure | Fail batch, alert |

## Open Questions

- [ ] Ingestion frequency? (considering: 15 min)
- [ ] Data retention? (considering: 90 days)
```

---

## Guidelines

- **Foundation before feature** — Set up `system.md` before diving into feature specs
- **API contract first** — This is the handoff point to frontend and build
- **Document decisions** — ADRs capture the "why" for future reference
- **Keep specs actionable** — A builder should be able to implement from the spec
- **Update as you learn** — Architecture evolves; keep docs current
