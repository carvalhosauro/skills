---
name: mvp-definition
description: >
  Defines the smallest thing possible that delivers value for a problem — cutting taken to the extreme.
  Isolates the "value moment" (the single instant the customer gains something) and cuts everything not
  essential for that moment to happen, producing a minimum scope (IN), an explicit cut list (OUT), a
  case-by-case recommended build approach (manual/concierge, no-code, or code), and the success signal.
  Uses the formulated problem and prioritization when they exist; also runs standalone. Use WHENEVER
  the user is going to define what to build, find the smallest version, decide where to start, or feels
  the scope is too large — phrases like "what's the MVP?", "what do I build first?", "this is too big
  to start", "smallest version of this", "how do I start small", even without saying "MVP". Sixth skill
  in the Product OS: consumes the problem/prioritization and feeds delivery planning and experiments.
---

# MVP Definition

This skill is the art of **cutting taken to the extreme**: given a problem, what's the *smallest* thing
that already delivers value? For people who work and build at the same time, this is the most decisive
skill — because the biggest enemy isn't lack of ideas, it's scope that grows until you never ship.

The wrong reflex is to add ("+ dashboard, + financials, + AI, + app"). The right reflex is to subtract
until it hurts. The canonical example:

```
Problem:    Nail tech loses bookings.
Wrong MVP:  Full system + dashboard + financials + AI + app.
Right MVP:  Availability page + shareable link + WhatsApp.
```

---

## Prerequisite — uses the pipeline when it exists (soft gate)

Look in the Product OS (in Claude.ai/Cowork: `/mnt/user-data/uploads/` and `/mnt/user-data/outputs/`):

- `problem-*.md` → the problem to tackle (and whether it's a hypothesis or validated).
- `prioritization-*.md` → confirmation that this is the #1 problem to solve now.

Use them when they exist. **If none exist**, ask the user if they want to follow the full pipeline
or jump straight to MVP with a raw problem description:
- **Full pipeline** → invoke the `prioritization` skill using the Skill tool (cascades through
  problem-formulation → competitive-benchmark → market-research as needed).
- **Raw description** → ask the user to describe the problem and continue, but note that this is
  a bigger bet and the pipeline skills exist to reduce that risk.

If the problem is marked as a **hypothesis**, remember that the best MVP may be precisely the one that
validates the hypothesis most cheaply (see "build approach").

---

## Phase 0 — one problem, one value moment (brainstorm)

1. **Confirm one problem** (if there's a prioritization, confirm it's #1).
2. **Isolate the value moment:** the single instant the customer comes out ahead. It's not "use the app" —
   it's "get the appointment without 8 back-and-forth messages", "receive payment before the service", etc.
   Everything in the MVP exists to make that instant happen. If something doesn't serve it, it's a cut candidate.

Lock the value moment before listing any features.

---

## Process

### 1. List the candidate scope
Everything that seems necessary. Don't filter yet.

### 2. Cut with the single question
For each item, ask: **"does the value moment happen without this?"**
- If yes → goes to OUT (don't build now).
- If no → stays in IN. It's the set you *can't remove* without killing the value.

### 3. Smallest test
Look at the IN and ask: is there an even smaller version that delivers the same moment? There almost
always is. Replace a screen with a link, automation with manual action, registration with a spreadsheet.
Force one more cut.

### 4. Recommend the build approach (case by case, no bias)
Evaluate which validates fastest **in this situation**, considering: what needs to happen at the value
moment, the expected volume/repetition, and the user's time/context.
- **Manual / concierge** — you do it by hand behind the scenes. Great for validating before coding anything;
  bad if you need to scale immediately.
- **No-code** — build with ready-made tools. Fast for standard flows; limits customization.
- **Code** — when the value depends on something manual/no-code can't do, or when already validated.
Recommend one with a justification; don't push dogma in either direction.

### 5. Define the success signal
How you'll know it worked — a **behavior**, not a vanity metric. "10 real bookings via link in 2 weeks"
counts; "I thought it looked nice" doesn't. Without a success signal, it's not an MVP, it's just a build.

---

## Deliverable (use this exact structure)

```markdown
# MVP — [problem / product]
> Based on: [problem + prioritization, if any] · [validated problem / hypothesis] · [date]

## Value moment
[The single instant the customer gains something.]

## Minimum scope (IN)
[The set that can't be removed without killing the value. Keep it short.]

## Don't build now (OUT)
[Everything that was cut — explicitly, to resist the temptation later.]

## Build approach
**Recommended:** [manual/concierge | no-code | code] — [why in this situation].

## Success signal
[Measurable behavior + timeframe. How you'll know it worked.]

## Next step
[Delivery planning / first experiment.]
```

Save: `mvp-[niche-kebab]-[YYYY-MM-DD].md`. In chat, show only the value moment + IN scope + signal.

---

## Pitfalls (where this usually fails)

- **"MVP" that's a complete product** → if the IN list has a dashboard, financials, and AI, it's not
  minimum. Go back to the value moment and cut again.
- **Building before isolating the value moment** → leads to orphan features that serve nothing.
- **Skipping the smallest test** → there's almost always a smaller version; not building is cheaper than
  building.
- **Confusing MVP with v1** → the MVP exists to learn, not to impress. Ugly and manual that teaches
  beats beautiful that doesn't validate.
- **MVP without a success signal** → without a criterion, you won't know if it worked and will "improve"
  forever.
- **The "+AI/+dashboard" reflex** → every addition must pass the single question. When in doubt, cut.
