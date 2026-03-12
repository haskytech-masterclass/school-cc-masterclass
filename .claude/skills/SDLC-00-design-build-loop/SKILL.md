---
name: design-build-loop
description: Structured process for building tools for yourself - from noticing an itch to shipping and iterating. Use when starting a new personal tool, validating an idea, or reflecting on something you've built.
---

# Design-Build-Loop Skill

A disciplined process for solo builders creating tools they'll use themselves. Prevents overbuilding, ensures you're solving the right problem, and documents decisions as you go.

## When to Use This Skill

- Starting a new personal tool or project
- Validating whether an idea is worth building
- Reflecting on something you've been dogfooding
- Documenting a build journey for future reference

## The Process

```
1. ITCH      → Articulate the problem clearly
2. CHALLENGE → Stress-test assumptions
3. BUILD     → Minimum testable version
4. DOGFOOD   → Use it yourself, log friction
5. REFLECT   → Decide: iterate, pivot, or ship
```

## How to Invoke

When the user wants to use this skill, determine which phase they're in:

| User Says | Phase |
|-----------|-------|
| "I want to build..." / "I have an idea for..." | Start at ITCH |
| "Should I build this?" / "Is this worth it?" | CHALLENGE |
| "I've been using X for a week..." | DOGFOOD/REFLECT |
| "New design loop for [name]" | Create new document, start at ITCH |
| "Update design loop for [name]" | Find existing doc, continue from current phase |

---

## Phase 1: ITCH (5-10 min)

**Goal**: Clearly articulate the problem before touching code.

### Prompt the User

Ask them to complete:
```
"When I ________, I want to ________ so I can ________."

"My current workaround is ________, which is painful because ________."

"I'll know this is solved when ________."
```

### Challenge If Needed

If their answers are vague, push back:
- "What specifically triggers this frustration?"
- "How often does this actually happen?"
- "What would 'done' look like — be concrete?"

### Document

Fill in the ITCH section of the template (see below).

---

## Phase 2: CHALLENGE (10-15 min)

**Goal**: Stress-test assumptions before committing.

### Play Devil's Advocate

Ask:
1. "What assumptions are you making that might be wrong?"
2. "What simpler solution might you be overlooking?"
3. "What's the laziest version that still tests the idea?"
4. "If this fails, what would that look like?"

### Simulate Fresh Eyes

"If someone who's never seen this problem looked at your proposed solution, what would confuse them? What would they expect that isn't there?"

### Define Kill Criteria

Help them state: "If [condition], this isn't working and I should stop."

### Form Hypothesis

Help them write: "I believe [solution] will [outcome]. I'll know when [observable result]."

### Document

Fill in the CHALLENGE section of the template.

---

## Phase 3: BUILD (hours, not days)

**Goal**: Create the minimum testable thing.

### Guide the Build

Ask: "What's the smallest version that would let you test your hypothesis?"

Constraints to suggest:
- "Don't over-engineer — you want to use this today"
- "Optimize for 'works' over 'pretty'"
- "Skip edge cases until core is validated"

### Build It

Use Claude Code to implement. Keep it minimal.

### Document

Note what was built, key decisions made, and anything deferred.

---

## Phase 4: DOGFOOD (days to 1-2 weeks)

**Goal**: Use the tool in real conditions and log friction.

### Set Up Friction Logging

Instruct user to note every moment of annoyance:
- What were you doing?
- What went wrong or felt off?
- How severe? (1 = minor annoyance, 3 = blocks me)

### After Dogfood Period

When user returns, help them categorize:
1. **Quick fixes** (< 30 min, clear solution)
2. **Worth doing eventually** (real problem, needs thought)
3. **Tolerable** (annoying but not worth the effort)
4. **Design flaw signals** (indicates something is fundamentally wrong)

### Document

Fill in the DOGFOOD section with friction log and categorization.

---

## Phase 5: REFLECT (15-30 min)

**Goal**: Decide what happens next.

### Guide Reflection

Ask:
1. "Did you actually use it?"
2. "Did it solve the job you defined in Phase 1?"
3. "Was your hypothesis validated or invalidated?"
4. "What's the highest-leverage next improvement?"
5. "Are you at risk of overcomplicating this?"

### Decision Framework

| Outcome | Next Step |
|---------|-----------|
| Core works, minor friction | Iterate (fix top issues, back to BUILD) |
| Core works, ready to polish | Add UI polish, docs, etc. |
| Core doesn't work, idea still valid | Pivot approach (back to CHALLENGE) |
| Core doesn't work, idea is flawed | Kill it, move on |
| Never used it | Probably didn't need it — kill or rethink |

### Document

Fill in the REFLECT section with decision and next steps.

---

## Document Storage

**Location**: `./docs/planning/design-build-loop.md` (relative to the project root)

Create the directory if it doesn't exist.

---

## Template

When starting a new design-build-loop, create a new file with this template:

```markdown
# Design-Build-Loop: [Project Name]

**Created**: [date]
**Status**: ITCH | CHALLENGE | BUILD | DOGFOOD | REFLECT | SHIPPED | KILLED
**Last Updated**: [date]

---

## 1. ITCH

### The Job to Be Done
> When I ________, I want to ________ so I can ________.

### Current Workaround
> My current workaround is ________, which is painful because ________.

### Success Criteria
> I'll know this is solved when ________.

### Notes
[Any additional context about when/how often this problem occurs]

---

## 2. CHALLENGE

### Assumptions Being Made
- [ ] [Assumption 1]
- [ ] [Assumption 2]

### Simpler Alternatives Considered
| Alternative | Why Not (or Why Maybe) |
|-------------|------------------------|
| [Option] | [Reasoning] |

### Hypothesis
> I believe [solution] will [outcome].
> I'll know this is true when [observable result].

### Kill Criteria
> If [condition], this isn't working and I should stop.

### Decision
- [ ] Proceed to BUILD
- [ ] Pivot idea
- [ ] Kill it

---

## 3. BUILD

### What Was Built
[Description of the minimum version]

### Key Decisions
| Decision | Rationale |
|----------|-----------|
| [Choice made] | [Why] |

### Deferred for Later
- [Thing not built yet]
- [Edge case ignored]

### Build Date
[date]

---

## 4. DOGFOOD

### Dogfood Period
[Start date] → [End date]

### Friction Log

| Date | What I Was Doing | What Went Wrong / Felt Off | Severity (1-3) |
|------|------------------|---------------------------|----------------|
| | | | |
| | | | |
| | | | |

### Categorized Issues

**Quick Fixes (< 30 min)**
- [ ] [Issue]

**Worth Doing Eventually**
- [ ] [Issue]

**Tolerable (not worth fixing)**
- [Issue]

**Design Flaw Signals**
- [Issue — indicates fundamental rethink needed]

---

## 5. REFLECT

### Usage Reality
- Did I actually use it? [Yes/No/Sometimes]
- How often? [Daily/Weekly/Rarely/Never]

### Hypothesis Validation
- Was the core hypothesis validated? [Yes/No/Partially]
- Evidence: [What happened that proves/disproves it]

### Decision

- [ ] **Iterate** — Fix top issues, continue dogfooding
- [ ] **Polish** — Core works, ready to add UI/docs/etc.
- [ ] **Pivot** — Rethink the approach (back to CHALLENGE)
- [ ] **Kill** — Not worth continuing
- [ ] **Ship** — Ready for broader use

### Next Steps
1. [Specific action]
2. [Specific action]

### Lessons Learned
[What would you do differently next time?]

---

## Iteration Log

### Iteration 1: [date]
**Phase**: [BUILD/DOGFOOD/REFLECT]
**Changes**: [What changed]
**Result**: [What happened]

### Iteration 2: [date]
...

---

## Final Status

**Outcome**: SHIPPED | KILLED | ONGOING
**Summary**: [One paragraph on what happened with this project]
**Time Invested**: [Rough estimate]
```

---

## Example Interaction

**User**: "I want to build a quick way to capture thoughts without switching apps"

**Assistant**:
Let's run through the design-build-loop. Starting with **ITCH** — let's articulate the problem clearly.

Complete these statements:

1. "When I ________, I want to ________ so I can ________."
2. "My current workaround is ________, which is painful because ________."
3. "I'll know this is solved when ________."

Take your time — being specific here prevents building the wrong thing.

---

**User**: "I've been using my quick-capture tool for a week"

**Assistant**:
Great, you're in the **DOGFOOD** phase. Let's process what you learned.

1. Did you actually use it? How often?
2. What friction did you notice? Walk me through the moments of "ugh, this is annoying."
3. Any moments where it worked exactly as hoped?

Let's build your friction log and categorize the issues.

---

## Methodology Sources

This skill synthesizes:
- **Jobs-to-be-Done (JTBD)** — Phase 1: clarifying the job
- **Lean UX** — Phase 2-3: hypothesis-driven, minimal builds
- **Design Thinking** — Phase 1-2: problem before solution
- **Dogfooding** — Phase 4: using your own tool
- **Double Diamond** — Overall: diverge (understand) then converge (solve)

Adapted for solo builders who are their own first user.
