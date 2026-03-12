---
skill: SDLC-07-secure
description: Security review, threat modeling, vulnerability assessment, and secure coding (project)
---

You are helping the user with software security - reviewing code for vulnerabilities and ensuring secure practices.

## Relationship to Other Skills

```
SDLC-04 (build)
  Has: Basic security checklist (run while building)
      │
SDLC-05 (quality)
  Has: Security in code review
      │
SDLC-07 (secure) ← THIS SKILL
  For: Deeper review when needed
```

**Most security is handled by SDLC-04/05.** This skill is for when you need deeper analysis.

---

## When to Use This Skill

| Trigger | Activity |
|---------|----------|
| Building auth/payments | Threat model the design |
| Security concern raised | Focused security review |
| Before major release | Quick vulnerability scan |
| Handling sensitive data | Review data protection |

For routine development, the security checklist in SDLC-04 is sufficient.

---

## Security Basics (What SDLC-04 Covers)

```markdown
- [ ] Parameterized queries (no SQL injection)
- [ ] Passwords hashed with bcrypt/argon2
- [ ] No secrets in code (use env vars)
- [ ] HTTPS everywhere
- [ ] Input validation on user data
- [ ] Debug mode OFF in production
- [ ] Dependencies reasonably up to date
```

This covers 80% of real-world risks for small deployments.

---

## Common Vulnerability Patterns

### SQL Injection

```javascript
// BAD
db.query(`SELECT * FROM users WHERE id = ${userId}`);

// GOOD
db.query('SELECT * FROM users WHERE id = $1', [userId]);
```

### XSS (Cross-Site Scripting)

```javascript
// BAD
element.innerHTML = userInput;

// GOOD
element.textContent = userInput;
// Or sanitize if HTML needed:
element.innerHTML = DOMPurify.sanitize(userInput);
```

### Path Traversal

```javascript
// BAD
fs.readFileSync(`./uploads/${filename}`);

// GOOD
const safePath = path.resolve('./uploads', filename);
if (!safePath.startsWith(path.resolve('./uploads'))) {
  throw new Error('Invalid path');
}
fs.readFileSync(safePath);
```

### Secrets in Code

```javascript
// BAD
const apiKey = "sk-1234567890";

// GOOD
const apiKey = process.env.API_KEY;
```

---

## Quick Threat Model (When Needed)

For security-sensitive features, ask:

1. **What are we protecting?** (user data, payments, auth tokens)
2. **Who might attack it?** (random hackers, malicious users, insiders)
3. **How could they attack?** (injection, stolen credentials, API abuse)
4. **What's the impact?** (data breach, financial loss, reputation)
5. **How do we prevent it?** (validation, encryption, rate limiting)

Document answers in the feature spec or ADR.

---

## Deeper Review (OWASP Top 10)

When you need comprehensive security review, check against OWASP Top 10:

1. **Broken Access Control** — Can users access others' data?
2. **Cryptographic Failures** — Is sensitive data encrypted?
3. **Injection** — Are queries parameterized?
4. **Insecure Design** — Is there a fundamental flaw?
5. **Security Misconfiguration** — Debug mode? Default passwords?
6. **Vulnerable Components** — Run `npm audit` / `pip audit`
7. **Authentication Failures** — Strong passwords? Session security?
8. **Software Integrity** — Dependencies verified?
9. **Logging Failures** — Can you detect breaches?
10. **SSRF** — Does server fetch user-provided URLs?

Reference: https://owasp.org/Top10/

---

## Example Interactions

**User**: "Review the login flow for security"

**Response**:
1. Check password hashing (bcrypt/argon2?)
2. Review session management (secure cookies, expiry)
3. Check for brute force protection (rate limiting)
4. Verify no credentials in logs
5. Report findings

**User**: "We're adding payment processing"

**Response**:
1. Quick threat model: what's at risk, attack vectors
2. Recommend: use established payment provider (Stripe), don't store card data
3. Review integration code for token handling
4. Document security decisions in ADR

---

## Guidelines

- **Defense in depth** — Multiple layers of protection
- **Least privilege** — Minimum necessary permissions
- **Fail secure** — Deny access on errors
- **Don't trust input** — Validate everything from users
