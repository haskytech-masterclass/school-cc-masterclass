---
skill: SDLC-05-quality-testing
description: Test strategy, automation, and client-visible quality artifacts for solo dev with AI (project)
---

You are helping the user verify and certify quality - validating what was built, running E2E tests, and generating proof of quality for clients.

## Relationship to Other Skills

```
SDLC-04 (build)
  Writes code + unit tests + integration tests
      │
      ▼
SDLC-05 (quality) ← THIS SKILL
  Validates the build, adds E2E, generates reports
      │
      ▼
SDLC-06 (ship-operate)
  Deploy with confidence
```

**Division of responsibility:**
- SDLC-04 writes tests while building (unit, integration)
- SDLC-05 validates the whole thing, adds E2E, certifies for release

---

## Document Storage

**Inputs:**
- Code produced by SDLC-04
- `docs/architecture/specs/{feature}.md` — Expected behavior
- `docs/design/{screen}.md` — Expected UI behavior

**Outputs:**
- `tests/e2e/` — E2E test files
- `reports/test-report.html` — Full test results
- `reports/coverage/` — Code coverage report
- `docs/quality/quality-summary.md` — Client-facing quality report

---

## Two Modes

### Feature Verification (after each epic)

**When:** After SDLC-04 completes a feature/epic

**Purpose:** Validate the build before moving on

**Activities:**
1. Run full test suite (unit + integration + existing E2E)
2. Review code for issues SDLC-04 might have missed
3. Add E2E tests for new critical flows
4. Flag any gaps or concerns

### Release Certification (before deploy)

**When:** Before deploying to production

**Purpose:** Generate proof of quality for stakeholders

**Activities:**
1. Run complete E2E suite
2. Generate test reports and coverage
3. Create quality summary document
4. Verify all critical paths pass

---

## Workflow

### Feature Verification

1. **Run existing tests** (detect stack):

   | Stack | Test command |
   |-------|-------------|
   | Python (pytest) | `pytest tests/unit tests/integration -v` |
   | Node.js (jest) | `npm test` |
   | Node.js (vitest) | `npx vitest run` |
   | Go | `go test ./...` |

2. **Review the code** (use Code Review Checklist below)

3. **Identify E2E gaps**
   - What new user flows were added?
   - Which are critical enough for E2E coverage?

3b. **Business rule coverage check**
   - For each feature that implements business rules:
     - Do the tests assert on **calculated output values**, not just CRUD success?
     - Can you find at least one test that would **fail if the business rule changed**?
   - **Red flag pattern:** A test creates data and only checks "it was created" or "it appears in the list" — without verifying the system applied the correct calculations to that data.
   - If business rule tests are missing, flag for SDLC-04 to fix before proceeding.

4. **Add E2E tests** for critical new flows

5. **Report status**
   - All tests pass? Ready to continue
   - Issues found? Flag for SDLC-04 to fix

### Release Certification

1. **Run pre-deploy build validation** (see Pre-Deploy Build Validation below)

2. **Run full test suite**
   ```bash
   ./test-full.sh
   ```

3. **Generate reports**
   ```bash
   pytest tests/ \
     --html=reports/test-report.html \
     --self-contained-html \
     --cov=app \
     --cov-report=html:reports/coverage
   ```

4. **Create quality summary** (see template below)

5. **Deliver artifacts** to client/stakeholder

---

## E2E Testing

E2E tests validate complete user flows through the real UI. SDLC-04 handles unit/integration; this skill handles E2E.

### What to Cover with E2E

| Priority | What to Test | Examples |
|----------|--------------|----------|
| **Critical** | Money, auth, data integrity | Payment flow, login, data export |
| **Core** | Main user workflows | Primary CRUD flows, key features |
| **Skip** | Edge cases, error states | Covered by unit/integration |

### E2E Test Structure

```javascript
// tests/e2e/checkout-flow.spec.js
import { test, expect } from '@playwright/test';

test.describe('Checkout Flow', () => {

  test('user can complete purchase', async ({ page }) => {
    // Arrange
    await page.goto('/products');

    // Act - complete the flow
    await page.getByText('Add to Cart').first().click();
    await page.getByRole('link', { name: 'Checkout' }).click();
    await page.getByLabel('Card number').fill('4242424242424242');
    await page.getByRole('button', { name: 'Pay' }).click();

    // Assert
    await expect(page.getByText('Order confirmed')).toBeVisible();
  });

  test('order persists after page refresh', async ({ page }) => {
    // ... verify data integrity
  });

});
```

### E2E Best Practices

- Test user journeys, not individual components
- Use realistic test data
- Clean up test data after runs
- Keep suite fast enough to run before deploys (~5 min max)

---

## Visual Regression Testing

Visual regression catches layout shifts, CSS regressions, and UI changes that functional E2E tests miss. Uses Playwright's built-in screenshot comparison — no extra tools needed.

### How It Works

1. **First run**: Playwright takes screenshots → saves as **baseline images** (golden files)
2. **Subsequent runs**: takes new screenshots, does pixel-by-pixel diff against baselines
3. **If diff exceeds threshold** → test fails, generates side-by-side comparison

### Adding to E2E Tests

```javascript
// Full page screenshot
test('dashboard renders correctly', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).toHaveScreenshot('dashboard.png');
});

// Element-level screenshot (more stable)
test('timecard table displays correctly', async ({ page }) => {
  await page.goto('/my-entries');
  const table = page.locator('[data-testid="entries-table"]');
  await expect(table).toHaveScreenshot('entries-table.png');
});
```

### Commands

```bash
# Generate/update baselines
npx playwright test --update-snapshots

# Run tests (compares against baselines)
npx playwright test

# Failed tests produce:
#   test-results/
#     dashboard-expected.png   ← baseline
#     dashboard-actual.png     ← what it saw
#     dashboard-diff.png       ← highlighted differences
```

### Configuration

In `playwright.config.ts`:
```typescript
expect: {
  toHaveScreenshot: {
    maxDiffPixelRatio: 0.01,  // 1% pixel tolerance (avoids antialiasing noise)
    animations: 'disabled',    // Freeze animations for stable screenshots
  },
},
```

### Caveats

- **Cross-OS font rendering**: Baselines taken on macOS won't match Linux (CI). Run in a consistent environment or use Docker for baseline generation.
- **Dynamic content**: Timestamps, random data, user avatars cause false failures. Mask with `mask: [page.locator('.timestamp')]` or use `stylePath` to hide dynamic elements.
- **Baseline maintenance**: Every intentional UI change requires `--update-snapshots`. Commit new baselines alongside the code change.
- **Element-level > full-page**: Prefer screenshotting specific components over full pages — less brittle, more targeted.

### When to Use

| Scenario | Visual Regression? |
|----------|--------------------|
| Data tables with calculated values | Yes — catches formatting, alignment |
| Forms and input layouts | Yes — catches CSS regressions |
| Dashboard / summary screens | Yes — catches layout shifts |
| Login page | No — too simple, functional test is enough |
| API-only features | No — nothing visual to screenshot |

### Test Environment Normalization

To reduce flaky tests, normalize the test environment:

- **Timezone:** Set `TZ=UTC` in test config or CI
- **Locale:** Set `LC_ALL=C` to avoid locale-dependent string sorting
- **Deterministic seeds:** If tests use random data, seed the RNG for reproducibility
- **Database cleanup:** Reset test DB between test runs (use transactions or truncation)
- **Timestamps:** Use frozen/mocked time in tests that depend on dates

---

## Pre-Deploy Build Validation

**MANDATORY before every deployment.** Do NOT trigger a Coolify deploy (or any remote deploy) until all checks below pass locally. Deploying without validation wastes server build time and creates cascading failures.

**Why this exists:** Audit of 69 deploy failures across all apps (Jan-Feb 2026) found ~60% were caused by lock file mismatches and build errors that could have been caught locally in seconds instead of via multi-minute deploy round-trips.

### Step 0: Verify branch

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != dev/* ]]; then
  echo "ERROR: You are on '$BRANCH'. Must be on a dev/* branch."
  exit 1
fi
```

Do NOT run quality checks on `main`. All work happens on `dev/*` branches.

### Step 1: Verify lock file is in sync

The deploy environment uses strict install commands. Run the same command locally:

| Package manager | Local check (must pass) | What it catches |
|----------------|------------------------|-----------------|
| npm | `npm ci` | package.json ↔ package-lock.json mismatch |
| pnpm | `pnpm install --frozen-lockfile` | package.json ↔ pnpm-lock.yaml mismatch |
| yarn | `yarn install --frozen-lockfile` | package.json ↔ yarn.lock mismatch |

If this fails, run the non-strict install (`npm install` / `pnpm install`) to regenerate the lock file, then commit both files.

### Step 2: Run the production build

Detect the stack and run the matching build check:

| Stack | Build check command |
|-------|-------------------|
| Next.js (npm) | `npm run build` |
| Next.js (pnpm) | `pnpm build` |
| Vite | `npm run build` (runs tsc + vite build) |
| Python FastAPI | `python -c "from app.main import app"` |
| Go | `go build ./...` |
| Node.js server | `node -e "require('./server.js')"` |

```bash
# Frontend (Next.js / Vite)
npm run build          # or: pnpm build

# Backend (Python FastAPI)
python -c "from app.main import app"   # verify app loads without errors

# Backend (Go)
go build ./...

# Backend (Node.js)
node -e "require('./server.js')"
```

Fix ALL errors before proceeding. Do not deploy hoping it will work — if it fails locally, it will fail on the server.

### Step 3: Verify Dockerfile (if applicable)

```bash
# Confirm Dockerfile exists
ls Dockerfile

# Check that any COPY paths in the Dockerfile actually exist
# e.g., if Dockerfile has: COPY --from=builder /app/public ./public
# then verify: ls public/
```

### Step 3b: Run Docker build AND run (if applicable)

**MANDATORY for Dockerized apps.** A passing `pnpm build` does NOT guarantee the Docker image builds or that the container starts. Build cache conflicts, missing runtime dependencies, and entrypoint errors are only caught by actually building and running the image.

```bash
# Build the image (use --no-cache for first verification of a new Dockerfile)
docker build -t <app-name>-test .

# Run the container with fake env vars to verify it starts
# Expected: container starts, fails only at DB/external service connection
docker run --rm \
  -e DATABASE_URL="postgresql://fake:fake@localhost:5432/fake" \
  -e NEXTAUTH_SECRET="testsecret" \
  <app-name>-test

# If the container fails before attempting DB/external connections,
# there is a build or runtime dependency issue that must be fixed.
```

Common issues this catches:
- **node_modules conflicts**: standalone output vs npm install (directory vs file)
- **Missing runtime deps**: packages needed at runtime but not in the final stage
- **Entrypoint errors**: config files importing unavailable modules
- **BuildKit cache**: stale layers causing "cannot replace directory with file"

### Step 4: Verify environment/config

- Correct branch is being deployed (check Coolify app config matches your git branch)
- Required environment variables are set in Coolify
- Database migrations are up to date (if applicable)

### Quick Reference

```bash
# One-liner for Node.js projects (npm):
npm ci && npm run build && echo "Ready to deploy"

# One-liner for Node.js projects (pnpm):
pnpm install --frozen-lockfile && pnpm build && echo "Ready to deploy"

# One-liner for Python FastAPI (pip):
pip install -r requirements.txt && python -c "from app.main import app" && echo "Ready to deploy"

# One-liner for Python FastAPI (Poetry):
poetry install && python -c "from app.main import app" && echo "Ready to deploy"

# One-liner for Go:
go build ./... && echo "Ready to deploy"
```

### Step 5: Security scan (optional, recommended for releases)

Run dependency vulnerability scans before major releases:

```bash
# Node.js
npm audit --audit-level=high

# Python
pip-audit                    # install: pip install pip-audit

# Go
govulncheck ./...            # install: go install golang.org/x/vuln/cmd/govulncheck@latest
```

These are informational — a high-severity finding should be reviewed but does not necessarily block deploy. Critical findings in auth/payment code should block.

**If any step fails, fix it locally first. Do NOT deploy to debug — the server build logs are not your compiler.**

---

## Stack Compatibility Check

**Run this before the first deploy of any new project or service.** It detects whether the project uses a supported stack or needs review.

### Detection Logic

Check the repo root (or service subdirectory) for these files:

```
Is it a supported Frontend?
├── Has next.config.* OR vite.config.*     → ✅ Supported
├── Has svelte.config.* OR nuxt.config.*   → ❌ Unsupported framework
├── Has bun.lockb                          → ❌ Unsupported runtime (Bun)
└── Has package.json but none of the above → ⚠️ Review — what framework is it?

Is it a supported Backend?
├── Has pyproject.toml + fastapi in deps   → ✅ Supported (Python FastAPI)
├── Has requirements.txt + fastapi in it   → ✅ Supported (Python FastAPI)
├── Has go.mod                             → ✅ Supported (Go, existing services only)
├── Has pyproject.toml + django in deps    → ❌ Unsupported (Django)
├── Has Gemfile                            → ❌ Unsupported (Ruby)
└── Has pom.xml or build.gradle            → ❌ Unsupported (Java)

Is it a supported Worker?
├── Has requirements.txt + Python script   → ✅ Supported
├── Has pyproject.toml + celery in deps    → ✅ Supported
└── Other                                  → ⚠️ Review

Does it have a valid Dockerfile?
├── Dockerfile exists                      → Check against patterns below
├── Dockerfile missing                     → ❌ STOP — create one from patterns below
└── Dockerfile doesn't match any pattern   → ⚠️ Review before deploying
```

### What to do when something is unsupported

**Do NOT silently deploy unsupported stacks.** Instead:

1. **STOP** the deploy process
2. **Tell the user:** "This project uses [X] which is not in our supported stack. Our platform supports Next.js/Vite for frontends and FastAPI for backends."
3. **Suggest alternatives:** "Should we rebuild the backend using FastAPI instead?" or "Should we get platform team approval to support [X]?"
4. **If approved as an exception:** The user must provide or approve a custom Dockerfile. Do not generate one from scratch for unsupported stacks.

---

## Standard Dockerfile Patterns

Every project fits one of **three patterns**. Detect which one by looking at what the app does, then use the matching template. The template auto-adapts based on what files exist in the repo.

### How to pick the right pattern

| Your app... | Pattern |
|-------------|---------|
| Serves a web UI (React, Next.js, Vite) | **Frontend** |
| Serves an API (FastAPI, Express) | **Backend** |
| Runs a process with no HTTP (bot, worker, agent) | **Worker** |

---

### Pattern 1: Frontend

Detect the variant from the repo:

| If the repo has... | Framework | Install command | Build output |
|--------------------|-----------|-----------------|-------------|
| `pnpm-lock.yaml` + `next.config.*` | Next.js + pnpm | `pnpm install --frozen-lockfile` | `.next/` |
| `package-lock.json` + `next.config.*` | Next.js + npm | `npm ci` | `.next/` |
| `package-lock.json` + `vite.config.*` | Vite + npm | `npm ci` | `dist/` |

**Next.js template:**

```dockerfile
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Detect: if pnpm-lock.yaml exists, use pnpm. Otherwise npm.
# --- pnpm variant ---
RUN npm install -g pnpm@8
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
# --- npm variant ---
# COPY package.json package-lock.json ./
# RUN npm ci

COPY . .

# Declare any NEXT_PUBLIC_* vars needed at build time
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN pnpm build   # or: npm run build

# Run as non-root
RUN adduser -D -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 3000
CMD ["pnpm", "start"]   # or: ["npm", "start"]
```

**Next.js standalone multi-stage** (for production-optimized builds):

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN adduser -D -u 1001 appuser
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
# Only if the project has a public/ directory:
# COPY --from=builder /app/public ./public
USER appuser
EXPOSE 3000
CMD ["node", "server.js"]
```

Note: standalone mode requires `output: "standalone"` in `next.config.js`.

**Vite template** (builds static files, served by nginx):

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Pre-deploy check:** `<install-cmd> && npm run build`
**Requires (Vite only):** `nginx.conf` in repo root

---

### Pattern 2: Backend

Detect the variant from the repo:

| If the repo has... | Stack | Install command |
|--------------------|-------|-----------------|
| `pyproject.toml` + `poetry.lock` | Python + Poetry | `poetry install` |
| `requirements.txt` | Python + pip | `pip install -r requirements.txt` |
| `go.mod` | Go | `go mod download` |
| `package.json` + `server.js` (no framework build) | Node.js | `npm ci` |

**Python template:**

```dockerfile
FROM python:3.11-slim
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# --- Poetry variant ---
RUN pip install poetry
COPY pyproject.toml poetry.lock* ./
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root
# --- pip variant ---
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Run as non-root
RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Go template:**

```dockerfile
FROM golang:1.24-alpine AS builder
WORKDIR /app
RUN apk add --no-cache git ca-certificates tzdata
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app-binary ./cmd/main

FROM alpine:3.19
RUN apk add --no-cache ca-certificates tzdata
RUN adduser -D -u 1000 appuser
WORKDIR /app
COPY --from=builder /app-binary /app/app-binary
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["/app/app-binary"]
```

**Node.js template** (simple server, no build step):

```dockerfile
FROM node:20-slim
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .
RUN adduser --disabled-password --uid 1001 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 3000
CMD ["node", "server.js"]
```

**Pre-deploy check (Python):** `<install-cmd> && python -c "from app.main import app"`
**Pre-deploy check (Go):** `go build ./...`
**Pre-deploy check (Node.js):** `npm ci && node -e "require('./server.js')"`

---

### Pattern 3: Worker

For bots, agents, Celery workers — anything that runs a process but doesn't serve HTTP.

```dockerfile
FROM python:3.12-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app
USER appuser
CMD ["python", "bot.py"]   # or: ["celery", ...] or whatever the entrypoint is
```

**Pre-deploy check:** `pip install -r requirements.txt && python -c "import bot"`

Note: no `EXPOSE` needed. No health check endpoint (unless the worker provides one).

**Shared-codebase worker** (e.g., Celery worker that uses the Backend's code): Use the Backend pattern's Dockerfile but change only the `CMD`:

```dockerfile
# Same Dockerfile as the backend, but:
CMD ["celery", "-A", "app.celery_worker", "worker", "--loglevel=info"]
```

---

### Notes on Variants

**Next.js + Prisma** (e.g., Smartaircon): Use the Frontend pattern but add `prisma generate` before the build:
```dockerfile
COPY prisma ./prisma/
RUN npx prisma generate
# then: RUN npm run build
```

**Multi-service repos** (e.g., keizen has `frontend/`, `backend/`, `celery/`): Each service gets its own Dockerfile in its subdirectory. Coolify points to the correct Dockerfile path per app. The patterns above still apply — just one per service.

---

### Dockerfile Validation Checklist

- [ ] **Strict install only:** `npm ci` / `--frozen-lockfile` — never `npm install` in a Dockerfile
- [ ] **Lock file committed:** The lock file matching the install command exists in the repo
- [ ] **COPY paths exist:** Every path referenced in `COPY` actually exists (especially multi-stage)
- [ ] **Non-root user:** Container runs as `appuser` (UID 1001), not root
- [ ] **Production env vars set:** `NODE_ENV=production` (Node.js), `PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1` (Python)
- [ ] **`.dockerignore` present** (see below)
- [ ] **Build args declared:** Any `NEXT_PUBLIC_*` / `VITE_*` env vars are declared as `ARG`
- [ ] **Config files present:** `nginx.conf` (Vite pattern), `prisma/` (if using Prisma)
- [ ] **Dockerfile committed:** The file actually exists in the repo

### Minimum `.dockerignore`

```
node_modules
.next
dist
.git
__pycache__
*.pyc
.env
.env.local
reports/
```

---

## Test Scripts

### Quick Test (unit + integration)

```bash
#!/bin/bash
# test.sh - run before any commit
set -e
pytest tests/unit tests/integration -v
echo "✅ Core tests passed"
```

### Full Test (includes E2E)

```bash
#!/bin/bash
# test-full.sh - run before deploy
set -e

echo "=== Unit + Integration ==="
pytest tests/unit tests/integration -v

echo "=== Starting App for E2E ==="
docker compose up -d
sleep 5

echo "=== E2E Tests ==="
npx playwright test

echo "=== Cleanup ==="
docker compose down

echo "=== Generating Reports ==="
pytest tests/ \
  --html=reports/test-report.html \
  --self-contained-html \
  --cov=app \
  --cov-report=html:reports/coverage

echo "✅ All tests passed. Reports in ./reports/"
```

---

## Code Review Checklist

Use this to validate what SDLC-04 built:

```markdown
## Code Review: [Feature Name]

### Correctness
- [ ] Logic matches spec/requirements
- [ ] Edge cases handled
- [ ] Error handling appropriate

### Architecture
- [ ] No SSH/execSync/Docker exec for inter-container communication (use HTTP APIs or direct DB access instead — SSH-based approaches break when containerized)

### Security
- [ ] Input validation present
- [ ] No hardcoded secrets
- [ ] SQL injection safe
- [ ] XSS safe (output encoded)

### Testing
- [ ] Unit tests cover new logic
- [ ] Integration tests cover new endpoints
- [ ] Tests verify behavior (not just coverage)
- [ ] **Business rule test check:** For features with business rules — at least one test asserts on a specific calculated output value (e.g., `assert hours == 8.0`), not just operation success (e.g., `assert status == 200`)

### Code Quality
- [ ] Clear naming
- [ ] Follows existing patterns
- [ ] No dead code

### Issues Found
- [ ] [File:line] - [Issue]

### Verdict
- [ ] Good to continue
- [ ] Needs fixes (return to SDLC-04)
```

---

## Client-Facing Quality Artifacts

### Quality Summary Document

Create `docs/quality/quality-summary.md`:

```markdown
# Quality Report: [Project Name] v[X.Y.Z]

**Generated:** [Date]
**Build:** [Commit hash or version]

---

## Test Summary

| Test Type | Passed | Failed | Skipped |
|-----------|--------|--------|---------|
| Unit | 47 | 0 | 0 |
| Integration | 23 | 0 | 0 |
| E2E | 8 | 0 | 0 |
| **Total** | **78** | **0** | **0** |

**Code Coverage:** 84%

---

## Critical Paths Verified

- ✅ User authentication (login, logout, password reset)
- ✅ [Core workflow 1]
- ✅ [Core workflow 2]
- ✅ Payment processing
- ✅ Data export

---

## Test Artifacts

- [Full Test Report](../reports/test-report.html)
- [Coverage Report](../reports/coverage/index.html)
- [E2E Recording](../reports/playwright-report/index.html)

---

## Notes

[Any caveats, known limitations, or areas for future improvement]
```

### What Clients Want to See

| Artifact | Purpose | Format |
|----------|---------|--------|
| Test Summary | Proof tests were run | Table with pass/fail counts |
| Coverage % | Proof code is tested | Single number + report link |
| Critical Paths | Proof key flows work | Checklist of E2E'd flows |
| Test Report | Detailed evidence | HTML report link |

---

## Risk-Based Test Strategy

When setting up testing for a new project:

| Risk Level | Test Investment | Examples |
|------------|-----------------|----------|
| **Critical** | Unit + Integration + E2E | Payments, auth, data export |
| **Core** | Unit + Integration + key E2E | Main CRUD, primary workflows |
| **Supporting** | Unit + Integration | Helpers, utilities |
| **Cosmetic** | Manual or skip | Styling, layout |

---

## Example Interactions

**User**: "Verify the Reddit ingestion feature"

**Response**:
1. Run existing test suite — all pass
2. Review code against `docs/architecture/specs/reddit-ingestion.md`
3. Check: error handling matches spec? Rate limiting implemented?
4. No E2E needed (backend-only feature)
5. Report: "Feature verified, ready to continue"

**User**: "We're about to deploy v1.0"

**Response**:
1. Run `./test-full.sh` — all 78 tests pass
2. Generate HTML test report and coverage
3. Create `docs/quality/quality-summary.md` with:
   - Test counts and coverage %
   - List of critical paths E2E'd
   - Links to detailed reports
4. Deliver: "Quality report ready at docs/quality/quality-summary.md"

---

## Guidelines

- **Don't duplicate SDLC-04's work** — It writes unit/integration tests while building
- **Focus on E2E** — Test complete user journeys, not components
- **Generate proof** — Clients want visible evidence of quality
- **Risk-based** — Not everything needs E2E; focus on critical paths
- **Fast feedback** — Keep E2E suite fast enough to run before deploys
