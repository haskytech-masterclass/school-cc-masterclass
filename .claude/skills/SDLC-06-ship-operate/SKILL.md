---
skill: SDLC-06-ship-operate
description: Deployment, monitoring, version tracking, and client delivery for solo dev with AI (project)
---

You are helping the user ship and operate software - getting code deployed reliably and keeping it running.

## Relationship to Other Skills

```
SDLC-05 (quality)
  Output: docs/quality/quality-summary.md (tests passed, coverage)
      │
      ▼
SDLC-06 (ship-operate) ← THIS SKILL
  Reads quality report, deploys with confidence
      │
      ▼
  Running in production
```

**Prerequisite:** SDLC-05 should have certified the build before deploying.

---

## Document Storage

**Inputs:**
- `docs/quality/quality-summary.md` — Proof that tests passed (from SDLC-05)
- Code ready to deploy (tagged in git)

**Outputs:**
- `deployments.log` — Append-only deploy history
- `docs/release-notes/v{version}.md` — Per-version release notes
- `docs/deployment-reports/{date}-{version}.md` — Deployment record (optional)

---

## Two Modes

### Simple Deploy (primary)

For single-environment deployments (most common case).

### Multi-Client Deploy (advanced)

For managing multiple clients with different versions. See Advanced section.

---

## Deploy Manifest

**The builder creates this file.** It declares what the app needs to run, without knowing anything about Coolify, servers, or infrastructure. The platform team (you) uses it to provision the app.

Create `deploy.yaml` in the repo root:

```yaml
# deploy.yaml — filled out by the builder, read by the platform team
app:
  name: client-acme-portal        # Human-readable app name
  repo: haskytech-basic/acme      # GitHub org/repo

services:
  - name: frontend
    type: frontend                 # frontend | backend | worker
    port: 3000
    domain: acme.haskytech.com     # Desired production domain
    build_args:                    # Env vars needed at BUILD time
      - NEXT_PUBLIC_API_URL
    env: []                        # Env vars needed at RUNTIME (not secrets)

  - name: backend
    type: backend
    port: 8000
    domain: api.acme.haskytech.com
    env:
      - DATABASE_URL               # Needs PostgreSQL provisioned
      - SECRET_KEY                 # Needs to be generated
      - OPENAI_API_KEY             # Client provides this
    database: postgresql            # Request a database

  - name: worker
    type: worker
    env:
      - DATABASE_URL               # Same as backend
      - CELERY_BROKER_URL          # Needs Redis provisioned
```

### What the builder fills in

- **App name and repo** — what it's called, where the code lives
- **Services** — each deployable piece (frontend, backend, worker)
- **Type** — maps to the Dockerfile patterns in SDLC-05
- **Port** — what the app listens on
- **Domain** — what URL the client wants
- **Env vars** — what the app needs (builder lists the names, platform team sets the values)
- **Database** — whether a database needs to be provisioned

### What the builder does NOT fill in

- Server IP or name
- Coolify app UUID
- Docker config
- Actual secret values

### Secret hygiene

The `deploy.yaml` lists env var **names only**, never values. Secret values are set directly in Coolify by the platform team. If a builder accidentally commits a secret value in `deploy.yaml`, it must be rotated immediately — the old value is considered compromised.

### Handoff process

**Current (manual):** Builder pushes repo with `deploy.yaml` to GitHub and notifies the platform team directly. Platform team reviews and provisions.

**Future (automated):** Builder opens a "Ready for deployment" PR containing the `deploy.yaml`. Platform team reviews the PR, provisions in Coolify, merges, and webhook auto-deploys. The PR becomes the audit trail of what was requested and when.

---

## First Deploy (Platform Setup)

**Only the platform team does this.** Translates the `deploy.yaml` into running infrastructure.

### 1. Pre-flight

- `deploy.yaml` exists in the repo
- SDLC-05 quality checks passed
- Dockerfile(s) present and match standard patterns
- **No SSH/execSync/Docker exec anti-pattern**: The app must NOT use SSH, `child_process.execSync`, or Docker socket/exec to communicate with other containers. Services that need data from other services must use HTTP APIs or direct DB connections. This pattern works locally but breaks in production containers that have no SSH access or Docker socket.

### 2. Provision in Coolify

For each service in `deploy.yaml`:

```bash
# 1. Create the app in Coolify (via API)
#    - Private repos: POST /api/v1/applications/private-github-app
#      with git_repository as "org/repo" and github_app_uuid
#    - Public repos: POST /api/v1/applications/public
#      with git_repository as full URL "https://github.com/org/repo"
#    - Set build_pack to "dockerfile", base_directory, ports_exposes
#
#    IMPORTANT: Do NOT use Docker Compose API for multi-service apps.
#    The /api/v1/applications/dockercompose endpoint doesn't support
#    git source params. Instead, create separate Dockerfile-based apps
#    and have them communicate via the Coolify network using container
#    UUIDs as hostnames (e.g., proxy_pass http://<backend-uuid>:8000).

# 2. Set environment variables
#    POST /api/v1/applications/<uuid>/envs
#    with {"key": "VAR", "value": "val", "is_preview": false}
#    - Secrets: generate or get from client

# 3. Provision database (if requested)
#    POST /api/v1/databases/postgresql
#    - Set DATABASE_URL in the app's env vars using internal URL
#    - Internal URL format: postgresql://user:pass@<db-uuid>:5432/dbname

# 4. Set up domain
#    - Backup DNS first: ~/bin/namecheap-dns backup haskytech.com
#    - Add DNS A record (Namecheap setHosts replaces ALL records!)
#    - PATCH /api/v1/applications/<uuid> with {"domains": "https://domain"}

# 5. Trigger first deploy
#    POST /api/v1/applications/<uuid>/restart
```

### 3. Verify Docker build locally before first deploy

```bash
# Build and run locally BEFORE triggering remote deploy
docker build -t <app-name>-test .
docker run --rm -e DATABASE_URL="postgresql://fake:fake@localhost:5432/fake" <app-name>-test
# Container should start and fail only at DB/external service connection
# If it fails earlier, fix locally — do not waste remote build cycles
```

### 4. First deploy

```bash
# Trigger deploy via Coolify API or UI
# Monitor logs: coolify-logs <app-name>
# Verify health check passes
```

### 4. Hand back to builder

Once running, the builder's workflow becomes:
- Work on `dev` branch → push when ready → platform team merges to main
- Issues → contact platform team

---

## Branch Strategy

```
main              ← Production. Push here = deploy. Only platform team touches this.
  └── dev         ← Builders work here. All commits go here.
```

**Rules:**
- Builders NEVER commit to or push to `main`
- All work happens on the `dev` branch
- Branches are NOT deleted after merge — they remain as history
- Only the platform team merges `dev` into `main`
- Merging to `main` triggers Coolify auto-deploy via webhook

---

## Builder Ship Workflow (SDLC-06 for builders)

This is what the builder's Claude Code runs when the work is done and SDLC-05 checks have passed.

### Step 0: Verify branch

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "dev" ]]; then
  echo "ERROR: You are on '$BRANCH'. Must be on the dev branch."
  echo "NEVER push directly to main."
  exit 1
fi
```

### Step 1: Final commit with "ready to deploy"

After all SDLC-05 checks pass, make a final commit signaling the branch is ready:

```bash
git add -A
git commit -m "ready to deploy: <short summary of what changed>

- SDLC-05 pre-deploy checks passed
- Build verified locally
- Lock file in sync"
```

### Step 2: Push the dev branch

```bash
git push -u origin $(git branch --show-current)
```

### Step 3: Notify platform team

Tell the user: "Branch `<branch-name>` is pushed and ready to deploy. The platform team can review and merge to `main` when ready."

**The builder's job ends here.** They do NOT merge to main. They do NOT trigger a deploy.

---

## Platform Team Deploy Workflow

**Only the platform team (you) does this.**

### Review and merge

```bash
# Review what's on the dev branch
git log main..dev --oneline

# Merge to main (triggers auto-deploy)
git checkout main
git merge dev
git push origin main
```

Or via GitHub PR: merge the `dev` branch into `main` via the GitHub UI.

### Manual deploy (when needed)

```bash
# Via Coolify API
source ~/secrets/infrastructure/coolify.env && \
  curl -s -X POST "$COOLIFY_URL/api/v1/applications/<uuid>/restart" \
  -H "Authorization: Bearer $COOLIFY_TOKEN"

# Or via Coolify UI
# Or: coolify-logs <app-name> to check status
```

### Version tagging

Tag releases in git before merging to main:

```bash
git tag -a v1.2.0 -m "Release v1.2.0: add invoice export, fix login timeout"
git push origin v1.2.0
```

Tags link to release notes at `docs/release-notes/v1.2.0.md`. The tag message should match the release notes summary.

### Run migrations (if applicable)

See Migration Runbook below. Key rules:
- **Backup database first** (production deploys)
- Apply migrations **before** the new code goes live (if additive)
- Verify migration succeeded before proceeding

### Verify after deploy

```bash
# Check health
curl -sf https://<domain>/health

# Check logs
coolify-logs <app-name>

# Check container status
ssh -i /Users/johnang/.ssh/hetzner_key root@<server-ip> \
  "docker ps --format '{{.Names}} {{.Status}}' | grep <app-name>"
```

### Smoke test checklist

After health check passes, verify core functionality works:

```markdown
- [ ] App loads in browser (no white screen / 500)
- [ ] Login works
- [ ] Primary user flow works (create/read/update)
- [ ] No new errors in logs (check last 50 lines)
- [ ] API responds to a test request
```

### Confirm monitoring

Before calling a deploy complete:

- [ ] Health check endpoint is being monitored (UptimeRobot or equivalent)
- [ ] No error spike in logs in the first 5 minutes
- [ ] If applicable: Sentry/error tracking shows no new issues

### Log it

Append to `deployments.log`:
```
2026-02-24_14:30 | v1.2.0 | SUCCESS | auto-deploy via webhook
2026-02-24_16:00 | v1.2.1 | SUCCESS | manual restart via API
```

---

## Rollback

If something breaks after deploy:

1. **Check what's currently deployed:** `coolify-logs <app-name>`
2. **Revert the git commit:** `git revert HEAD && git push` — triggers auto-redeploy of the previous working state
3. **Or redeploy a specific commit via Coolify UI** — select the previous deployment and redeploy

**Rule:** If in doubt, rollback first, investigate later. Revert the commit, let it auto-deploy, then figure out what went wrong.

---

## Release Notes

Create `docs/release-notes/v{version}.md`:

```markdown
# Release Notes: v1.2.0

**Date:** 2025-01-15

## Changes

### New Features
- Added export to CSV functionality
- Dashboard performance improvements

### Bug Fixes
- Fixed login timeout issue
- Fixed date formatting in reports

### Technical
- Upgraded dependencies
- Database migrations included
```

---

## Pre-Deploy Checklist

```markdown
## Deploy: v[X.Y.Z]

### Before
- [ ] Quality report exists (`docs/quality/quality-summary.md`)
- [ ] All tests passing
- [ ] Docker build succeeds locally (`docker build -t <app>-test .`)
- [ ] Docker container starts locally (`docker run --rm -e ... <app>-test`)
- [ ] Git tagged with version
- [ ] Release notes written

### Deploy
- [ ] Build successful
- [ ] Deployment complete
- [ ] Health check passing

### After
- [ ] Core functionality verified
- [ ] No errors in logs
- [ ] Deployment logged
```

---

## Health Check Endpoint

Your app should expose `/health`:

```python
@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": os.getenv("APP_VERSION", "unknown")
    }
```

---

## Example Interactions

**User**: "Deploy the latest"

**Response**:
1. Check `docs/quality/quality-summary.md` exists — verified
2. Verify git tag — v1.2.0
3. Run `./deploy.sh`
4. Verify health check passes
5. Append to `deployments.log`
6. Done: "v1.2.0 deployed successfully"

**User**: "Something's broken, roll back"

**Response**:
1. Check `deployments.log` for previous version
2. Run `./rollback.sh v1.1.0`
3. Verify health restored
4. Log the rollback
5. "Rolled back to v1.1.0. What symptoms were you seeing?"

---

## Migration Runbook

### When to apply migrations

- **Additive migrations** (add table, add column, add index): Apply **before** deploying new code. Old code ignores new columns.
- **Destructive migrations** (drop column, rename table): Apply **after** deploying new code that no longer uses the old schema. Two-phase approach.
- **Data backfills**: Always in a separate migration from schema changes. Test on a copy first if large.

### Two-phase migration for breaking schema changes

```
Phase 1: Deploy code that works with BOTH old and new schema
  → Add new column (nullable)
  → Code writes to both old and new columns
  → Backfill new column from old data

Phase 2: Deploy code that only uses new schema
  → Drop old column (in a separate migration)
```

### Before applying migrations (production)

```bash
# 1. Backup the database
ssh -i /Users/johnang/.ssh/hetzner_key root@<server-ip> \
  "docker exec <db-container> pg_dump -U <user> <dbname> > /tmp/backup-$(date +%Y%m%d).sql"

# 2. Apply migration
ssh -i /Users/johnang/.ssh/hetzner_key root@<server-ip> \
  "docker exec <app-container> alembic upgrade head"
  # or: python manage.py migrate
  # or: npx prisma migrate deploy

# 3. Verify
ssh -i /Users/johnang/.ssh/hetzner_key root@<server-ip> \
  "docker exec <db-container> psql -U <user> <dbname> -c '\dt'"
```

### Migration rollback

If a migration fails or breaks the app:

1. **Rollback the migration:** `alembic downgrade -1` (or equivalent)
2. **Revert the code:** `git revert HEAD && git push`
3. **Restore from backup** (last resort): `docker exec <db-container> psql -U <user> <dbname> < /tmp/backup-YYYYMMDD.sql`

---

## Staged Rollout (for risky changes)

For changes that affect critical flows (payments, auth, data integrity), consider a staged rollout:

### Option 1: Deploy to lowest-risk client first

If you have multiple clients on the same codebase:
1. Deploy to demo/staging client first
2. Verify for 24 hours
3. Deploy to production clients

### Option 2: Feature flag

For changes you want to test in production without full rollout:
1. Deploy the code behind a feature flag (env var)
2. Enable for one user/client
3. Monitor for issues
4. Enable for all

### When to use staged rollout

- Database schema changes
- Auth flow changes
- Payment integration changes
- Major dependency upgrades
- Changes to data export/import

For routine feature additions and bug fixes, direct deploy is fine.

---

## Advanced: Multi-Client Deploy

For managing multiple clients with different versions.

### Client Registry

Track versions per client in `client-registry.md`:

```markdown
# Client Registry

| Client | Version | Last Deploy | Notes |
|--------|---------|-------------|-------|
| acme-corp | v2.4.1 | 2025-01-15 | Production |
| beta-client | v2.5.0-rc | 2025-01-18 | Testing new feature |
| demo | v2.4.0 | 2025-01-10 | Sales demos |
```

### Deploy to Specific Client

```bash
./deploy.sh acme-corp v2.4.1
```

### Version Rollout Strategy

1. Deploy to lowest-risk client first (demo/staging)
2. Verify for a day
3. Deploy to other clients
4. Keep previous version noted for quick rollback

---

## Advanced: Incident Handling

### Incident Log

Keep `incidents.log` for learning:

```markdown
## 2025-01-18: API Timeout

**Duration:** 15 min
**Cause:** DB connection pool exhausted
**Resolution:** Increased pool size, restarted
**Prevention:** Added pool usage monitoring
```

### Incident Response Flow

```
ALERT → ASSESS → DECIDE (fix or rollback?) → VERIFY → DOCUMENT
```

### Post-Mortem Template

For significant incidents, create `docs/incidents/{date}-{title}.md`:
- Summary, timeline, impact
- Root cause
- Resolution
- Action items to prevent recurrence

---

## Advanced: Monitoring

### Simple Health Check (cron)

```bash
#!/bin/bash
# monitor.sh - run via cron every 5 min
if ! curl -sf http://yourapp.com/health > /dev/null; then
  echo "App is down!" | mail -s "ALERT" you@email.com
fi
```

### Free Monitoring Services

| Service | Free Tier |
|---------|-----------|
| UptimeRobot | 50 monitors |
| Healthchecks.io | 20 checks |
| Better Uptime | 10 monitors |

---

## Guidelines

- **Quality gate first** — Don't deploy without SDLC-05 certification
- **Rollback fast** — Restore service first, investigate later
- **Log everything** — Future you will thank present you
- **Tag versions** — Always know what's deployed
- **Verify after deploy** — Health check + quick functionality test
