---
skill: SDLC-04-build
description: Implementation, coding, feature development, and refactoring (project)
---

You are helping the user with the build phase - writing code that turns designs and specifications into working software.

## Relationship to Other Skills

```
SDLC-02 (frontend-design)              SDLC-03 (architecture)
  Output: docs/design/                   Output: docs/architecture/
      │                                         │
      └─────────────────┬───────────────────────┘
                        ▼
                SDLC-04 (build) ← THIS SKILL
                  Reads specs, implements code
                        │
                        ▼
                SDLC-05 (quality-testing)
```

---

## Document Storage

**Inputs (check these first):**
- `docs/architecture/specs/{feature}.md` — API contract, data model, logic
- `docs/design/{screen}.md` — UI layout, components, interactions
- `docs/architecture/system.md` — Overall patterns to follow
- `docs/planning/backlog.md` — User stories and acceptance criteria

**Outputs:**
- Working code in the codebase
- Tests covering the implementation

---

## Workflow

### 0. Check Branch

**Before doing anything, verify you are on a `dev/*` branch:**

```bash
# Skip if not a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "WARNING: Not a git repository. Skipping branch check."
else
  BRANCH=$(git branch --show-current)
  if [[ "$BRANCH" != dev/* ]]; then
    echo "ERROR: You are on '$BRANCH'. All work must be on a dev/* branch."
    echo "Create one with: git checkout -b dev/your-feature-name"
    exit 1
  fi
fi
```

**NEVER commit directly to `main`.** Only the platform team merges to main. If you are on `main`, create a dev branch first:

```bash
git checkout -b dev/describe-the-work
```

Branch naming: `dev/add-invoice-export`, `dev/fix-login-timeout`, `dev/update-dashboard`

### 0b. Check for Existing Specs

**Before coding, look for documentation:**

```
docs/
├── architecture/
│   ├── system.md           ← Overall patterns
│   └── specs/{feature}.md  ← API, data model, logic
└── design/
    └── {screen}.md         ← UI expectations
```

**If specs exist:** Follow them. The decisions have been made.

**If no specs:** Proceed with step 1, but flag significant decisions. Consider creating a lightweight ADR for major technical choices.

### 1. Understand the Task

- What needs to be built or changed?
- What are the acceptance criteria? (from backlog)
- What does the spec say? (from architecture/design docs)

### 2. Explore the Codebase

- Find related existing code
- Understand current patterns and conventions
- Identify reusable components
- Check for existing tests

### 3. Plan the Implementation

- List files to create/modify
- Identify sequence of changes
- Note potential risks or edge cases
- Verify plan aligns with specs (if they exist)

### 4. Implement

Write code that is:
- **Correct** — Meets requirements, matches specs
- **Clear** — Readable and self-documenting
- **Consistent** — Follows existing patterns
- **Complete** — Includes error handling, logging

### 5. Verify

- Run existing tests
- Add new tests for new functionality
- Run linter and formatter (see Lint & Format below)
- Verify against acceptance criteria

---

## Using Specs Effectively

### From Architecture Spec

The `docs/architecture/specs/{feature}.md` tells you:

| Spec Section | What It Gives You |
|--------------|-------------------|
| API Contract | Exact endpoints, request/response shapes |
| Data Model | Tables to create, fields, indexes |
| Logic | Step-by-step algorithm to implement |
| Error Handling | What can fail and how to handle each |
| Open Questions | What still needs deciding (ask user) |

### From Design Doc

The `docs/design/{screen}.md` tells you:

| Design Section | What It Gives You |
|----------------|-------------------|
| Layout | Component structure, hierarchy |
| Components | What to build, states to handle |
| Interactions | Event handlers, animations |
| Responsive | Breakpoint behavior |

### When Specs Are Missing

If building without specs:
1. Ask clarifying questions before making big decisions
2. Document significant choices in code comments
3. Consider suggesting: "Should we create a quick spec for this first?"

---

## Implementation Checklist

```markdown
## Build: [Feature Name]

### Pre-Implementation
- [ ] Read architecture spec (if exists)
- [ ] Read design doc (if exists)
- [ ] Review acceptance criteria from backlog
- [ ] Identify affected files and components
- [ ] Check for reusable code/patterns

### Implementation
- [ ] Create/modify data models
- [ ] Implement business logic
- [ ] Add API endpoints (if needed)
- [ ] Build UI components (if needed)
- [ ] Handle error cases per spec

### Compatibility & Migrations
- [ ] API changes are backward-compatible (old clients still work)
- [ ] DB migrations are additive (add columns, don't rename/drop in the same release)
- [ ] Large data backfills are in a separate migration from schema changes
- [ ] If API endpoints changed: update OpenAPI spec or API docs (`docs/architecture/specs/`)

### Quality
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Add structured logging (see Observability below)
- [ ] Lint and format pass (see Lint & Format below)
- [ ] Verify against acceptance criteria

### Business Rule Testing
- [ ] **Classify the feature:** Does it implement, affect, or depend on business rules?
  - Business rules = calculations, rate logic, pricing, eligibility, validation, state transitions, date-based behavior
  - If YES → complete the items below
  - If NO (pure CRUD, UI layout, navigation) → skip this section
- [ ] **Identify the rules:** List the specific business rules this feature implements or affects
  - Check `docs/business-rules/` and `docs/architecture/specs/` for documented rules
  - If rules are undocumented, document them first (even a 5-line summary)
- [ ] **Write rule-output tests:** For each business rule, write at least one test that:
  - Provides a specific input (not just "valid data")
  - Asserts the specific calculated output (not just "status 200" or "element visible")
  - Example: entry on rest day → assert `ot_2_0x_hours == 8.0`, NOT just assert entry was created
- [ ] **Test the boundary:** Include at least one edge case test per rule

### Post-Implementation
- [ ] All tests pass
- [ ] Manual verification complete
- [ ] Update spec status to "Implemented" (if spec exists)
```

---

## Code Quality Standards

**Naming**
- Descriptive, intention-revealing names
- Follow language conventions
- Consistent with existing codebase

**Functions**
- Single responsibility
- Clear inputs and outputs
- Reasonable size

**Error Handling**
- Handle errors at appropriate levels
- Provide actionable error messages
- Log with sufficient context

**Comments**
- Explain "why", not "what"
- Document public APIs
- Prefer self-documenting code

---

## Observability

When adding new features, include basic observability so issues are debuggable in production.

**Structured logging** — use key-value pairs, not free-form strings:

```python
# Python (FastAPI)
import logging
logger = logging.getLogger(__name__)

# Good
logger.info("order_created", extra={"order_id": order.id, "user_id": user.id, "total": order.total})

# Bad
logger.info(f"Created order {order.id} for user {user.id}")
```

```typescript
// Node.js / Next.js API routes
console.log(JSON.stringify({ event: "order_created", order_id: order.id, user_id: user.id }));
```

**Key metrics to log for new features:**
- Request counts and response times for new endpoints
- Error counts with error type
- Business events (order created, user signed up, export completed)

**Correlation IDs** — if the app handles requests across services, pass a request ID through:
```python
# FastAPI middleware
@app.middleware("http")
async def add_request_id(request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response
```

---

## Security Checklist

Before completing, verify:

- [ ] User input validated and sanitized
- [ ] Auth required on protected endpoints
- [ ] Authorization checked for resources
- [ ] No hardcoded secrets
- [ ] Parameterized queries (no SQL injection)
- [ ] Output encoded for context

---

## Lint & Format

Every project should have a linter and formatter configured. They catch bugs, prevent formatting drift across AI sessions, and keep diffs clean.

**Set up on first epic if missing.** Don't wait until later — the earlier it's in, the less churn.

### JavaScript / TypeScript (Node.js, Next.js, Vite)

| Tool | Purpose | Config File |
|------|---------|-------------|
| ESLint | Catch bugs (unused vars, missing await, etc.) | `eslint.config.js` (flat config) |
| Prettier | Consistent formatting | `.prettierrc` |

**Setup:**
```bash
npm install --save-dev eslint @eslint/js prettier
```

**Minimal ESLint flat config** (`eslint.config.js`):
```javascript
const js = require("@eslint/js");
module.exports = [
  js.configs.recommended,
  {
    languageOptions: { ecmaVersion: 2022, sourceType: "commonjs" },
    rules: { "no-unused-vars": ["error", { argsIgnorePattern: "^_" }] },
  },
  { ignores: ["node_modules/", "dist/", ".next/", "output/"] },
];
```

For ESM projects (`"type": "module"` in package.json), use `import`/`export default` instead of `require`/`module.exports`.

**Minimal Prettier config** (`.prettierrc`):
```json
{ "singleQuote": true, "trailingComma": "all", "printWidth": 100 }
```

**Scripts** (add to `package.json`):
```json
"lint": "eslint src/ tests/",
"lint:fix": "eslint src/ tests/ --fix",
"format": "prettier --write src/ tests/",
"format:check": "prettier --check src/ tests/"
```

### Python (FastAPI)

| Tool | Purpose | Config File |
|------|---------|-------------|
| Ruff | Lint + format (replaces flake8, isort, black) | `ruff.toml` or `[tool.ruff]` in `pyproject.toml` |

**Setup:**
```bash
pip install ruff  # or: poetry add --group dev ruff
```

**Minimal config** (`ruff.toml`):
```toml
line-length = 100
target-version = "py311"

[lint]
select = ["E", "F", "I", "UP"]  # pycodestyle, pyflakes, isort, pyupgrade
ignore = ["E501"]  # line length handled by formatter

[format]
quote-style = "double"
```

**Commands:**
```bash
ruff check .            # lint
ruff check . --fix      # lint + autofix
ruff format .           # format
ruff format . --check   # check formatting
```

### Verification (both stacks)

After implementing, before committing:
```bash
# JS
npx eslint src/ tests/ && npx prettier --check src/ tests/

# Python
ruff check . && ruff format . --check
```

If either fails, fix before committing. Prefix unused function parameters with `_` to satisfy no-unused-vars.

---

## Supported Platform Stacks

When creating new projects or adding services, use these stacks. They are battle-tested across all deployed apps, have standard Dockerfile patterns (see SDLC-05), and can be reliably deployed to Coolify.

| Layer | Supported Stack | Key Packages |
|-------|----------------|--------------|
| **Frontend (SPA)** | Vite + React + TypeScript | `vite`, `react`, `react-dom`, `typescript` |
| **Frontend (fullstack)** | Next.js + React + TypeScript | `next`, `react`, `react-dom`, `typescript` |
| **UI components** | shadcn/ui (uses Tailwind CSS + Radix UI under the hood) | `tailwindcss`, `@radix-ui/*`, `class-variance-authority`, `clsx`, `tailwind-merge` |
| **Backend API** | Python + FastAPI | `fastapi`, `uvicorn`, `pydantic` |
| **Database** | PostgreSQL | `psycopg2-binary` / `asyncpg` |
| **Background worker** | Python + Celery (or plain script) | `celery` |
| **Package manager (JS)** | npm or pnpm | Use whichever the project already uses |
| **Package manager (Python)** | Poetry or pip | Use whichever the project already uses |

### What NOT to introduce

Do not use these unless explicitly approved by the user. They are unsupported on the platform and have no deployment patterns:

- **Other JS frameworks**: Remix, Nuxt, SvelteKit, Astro
- **Other JS runtimes**: Bun, Deno
- **Other Python frameworks**: Django, Flask
- **Other backend languages**: Ruby, Java, Rust (Go is acceptable for existing Go services only)
- **Other databases**: MySQL, MongoDB, SQLite (for production)
- **Other CSS approaches**: CSS modules, styled-components, Emotion

If the task clearly requires something off this list, **ask the user first** before proceeding. Explain what's supported and why the alternative is being considered.

## Guidelines

- **Specs first** — Check for existing documentation before coding
- **Read before writing** — Understand the codebase first
- **Small commits** — Make incremental, reviewable changes
- **Test as you go** — Don't leave testing for the end
- **Ask when unclear** — Better to clarify than assume
- **Flag decisions** — If no spec exists, note significant choices made
- **Stay on-stack** — Use Supported Platform Stacks above; flag anything off-menu

## Example Interaction

**User**: "Build the Reddit ingestion feature"

**Response**:
1. Check for `docs/architecture/specs/reddit-ingestion.md` — found!
2. Read spec: API contract, data model, ingestion logic
3. Check for design doc — none (backend-only feature)
4. Create migration for `posts` table per spec
5. Implement ingestion service following logic steps
6. Add error handling per spec's error table
7. Write tests covering happy path and error cases
8. Mark spec as "Implemented"

**User**: "Add a quick export button to the dashboard"

**Response**:
1. Check for specs — none found
2. Ask: "What format should it export? CSV, JSON, both?"
3. Explore existing dashboard code for patterns
4. Implement based on answers
5. Suggest: "Want me to create a quick spec documenting these decisions?"
