---
name: problem-formulation
description: >
  Transforms evidence (benchmark, interviews, market map) into a sharp, singular problem definition —
  the art of cutting. Outputs two formats side by side: causal ("[segment] [pain] because [cause]")
  and job-to-be-done ("When [situation], [persona] wants [outcome]"). Includes a detector that
  rejects solutions disguised as problems. REQUIRES the Benchmark wedge (competitive-benchmark skill);
  interviews are optional — with them the definition is "validated", without them it's a "hypothesis".
  Use WHENEVER the user wants to define/sharpen a problem, move from a solution idea to the real
  problem, write a problem statement, decide on focus — phrases like "what's the actual problem?",
  "help me define the problem", "this is too vague", "turn this into a clear problem", even without
  saying "formulation". Fourth skill in the Product OS: consumes the wedge/interviews and feeds
  Prioritization and MVP.
---

# Problem Formulation

This is the **cutting** skill — the most underrated in the Product OS. Builders usually know how to
develop, but freeze when it's time to reduce: they define problems too broadly, bundle several into one,
and disguise solutions as problems. The result is a bloated MVP that never ships.

The work here is the opposite of adding: it's **choosing one problem, one segment, and discarding the
rest (for now)**. A sharp definition is what makes a ridiculously small MVP possible afterward.

The fundamental rule: **focus on the problem, never the solution.**

```
✗ "I'll create a scheduling system."               (that's a solution)
✓ "Freelance nail techs lose clients because
   they reschedule everything manually via WhatsApp." (that's a problem)
```

---

## Prerequisite — Benchmark required, interviews optional

**Locate the wedge (required):** check sent files and the Product OS folder (in
Claude.ai/Cowork: `/mnt/user-data/uploads/` and `/mnt/user-data/outputs/`, looking for `benchmark-*.md`).
If there is no Benchmark anywhere, **STOP** and offer to run the competitive-benchmark skill first —
without the wedge there's no focus to sharpen.

**Locate interviews (optional):** look for `interview-synthesis-*.md`.
- **If they exist** → use as primary evidence; the definition comes out marked as **validated**.
- **If they don't exist** → formulate from the wedge alone, but mark the definition as a **hypothesis**
  and recommend running the discovery-interviews skill to validate before investing in building.

Never declare a problem "validated" without real interviews. Honesty in this marking is what prevents
building on top of a comfortable assumption.

---

## Phase 0 — the cut (brainstorm with the user)

From the wedge (and interviews, if available), **list the candidate problems** that appear in the
evidence. There's almost always more than one. Propose which one to choose and why, and help the user fix:

- **One** problem.
- **One** specific segment (not "beauty professionals", but "freelance nail techs who do home visits").

Cutting means saying no to the other problems — not forever, but for now. Record the discarded ones;
they return in the "what this problem is NOT" section.

---

## Process

1. **Gather the evidence.** Literal quotes from interviews, complaint patterns from the benchmark,
   strong signals. The definition must sound like how the customer talks — not how you would describe it.
2. **Build the structured detail** (who · trigger · frequency · impact · current solution · limitation).
3. **Distill into the two formats** (causal + JTBD).
4. **Run the disguised-solution detector** (below). Always.
5. **Mark confidence** (validated / hypothesis).

### Disguised-solution detector (run on every definition)

If the definition contains solution language — "system for", "app", "platform", "tool",
"automate", "dashboard" — then it's a solution, not a problem. Rewrite to the underlying problem.

**Test:** ask "why?" until you reach a human pain that would exist even if no product existed.
That pain is the problem.

```
✗ "There's no billing tool for freelancers."
   → why does that matter? → because they get stiffed.
✓ "Freelancers lose money to clients who reschedule and don't pay,
   and today have no way to charge upfront without awkwardness."
```

---

## Deliverable (use this exact structure)

```markdown
# Problem — [segment]
> Based on: [benchmark + syntheses, if any] · [validated / hypothesis] · [date]

## Definition (two formats side by side)
**Causal:** [specific segment] [pain] because [cause].
**JTBD:**   When [situation/trigger], [persona] wants [motivation], in order to [outcome].

## Detail
Who suffers:    [specific persona — who feels it, who pays, who decides]
Trigger:        [when / in what context the problem appears]
Frequency:      [how recurring — numbers if available]
Impact:         [$ / time / consequence]
Current solution: [how they solve it today, even if a workaround]
Limitation:     [why the current solution fails]

## Evidence
[Literal quotes + number of interviews that confirm.
 OR, without interviews: "Not yet validated with customers — based on benchmark/research."]
**Confidence:** [validated / hypothesis]

## What this problem is NOT
[The problems and segments cut in this round — deliberately left out.]

## Next step
[If hypothesis → discovery-interviews. If validated → prioritization / MVP definition.]
```

Save: `problem-[niche-kebab]-[YYYY-MM-DD].md`. In chat, show only the two sentences + confidence.

---

## Pitfalls (where this usually fails)

- **Solution disguised as a problem** → mistake #1. The detector exists for this; always run it.
- **Problem or segment too broad** → "everyone" is not a segment. The wider it is, the more impossible
  it becomes to cut a small MVP afterward.
- **Multiple problems bundled into one** → force the choice of one. "And" in the middle of a sentence
  is usually a sign there are two problems there.
- **Declaring "validated" without interviews** → without a synthesis, it's a hypothesis. Period.
- **Rewriting the pain in your own words** → loses the customer's language, which is what makes the
  definition resonate and becomes the product text afterward. Preserve the quotes.
- **Confusing with prioritization** → here you sharpen ONE already-chosen problem. Choosing among several
  with a framework (RICE/ICE) is the next skill, prioritization.
