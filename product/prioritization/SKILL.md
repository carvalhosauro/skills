---
name: prioritization
description: >
  Ranks a list of problems, opportunities, or features to answer "if I solve only one thing, which
  generates the most value?". Auto-recommends the right framework based on context (Opportunity
  Scoring for pains with interview data, ICE for early/solo ideas, RICE for features with estimable
  reach) and explains the choice. Pulls candidates from the Product OS (problems, gaps, patterns) when
  they exist. Shows the reasoning behind each score and flags low-confidence ones — no fake precision.
  Use WHENEVER the user needs to decide what to do first, compare ideas/features, choose between
  opportunities — phrases like "what do I do first?", "is X or Y more worth it?", "prioritize this for
  me", "which of these ideas is most valuable", even without saying "prioritization" or "RICE/ICE".
  Fifth skill in the Product OS: consumes problems/opportunities and feeds the Roadmap and MVP.
---

# Prioritization

This skill answers the most important question for someone with limited time and energy:
**"if I solve only one thing, which generates the most value?"** It separates *interesting* ideas from
*valuable* ones — and forces a decision instead of paralysis.

The care that runs through everything: **prioritization scores are estimates, not objective truth.**
A RICE number with one decimal place creates a false sense of science. That's why this skill always
shows the *reasoning* behind each score and flags low-confidence ones. The ranking guides the decision;
it doesn't replace it.

---

## Phase 0 — build the list and choose the method (brainstorm)

### 1. Gather the candidates

Look for candidates in the Product OS (in Claude.ai/Cowork: `/mnt/user-data/uploads/` and
`/mnt/user-data/outputs/`):

- `problem-*.md` → formulated problems (and the "cut candidates" within them).
- `benchmark-*.md` → gaps and alternative wedges.
- `interview-synthesis-*.md` → pain patterns with importance/satisfaction signals.

Present what you found as a candidate list and let the user **confirm, edit, and add** their own items.
If the Product OS is empty and the user doesn't have a list ready, invoke the `problem-formulation`
skill using the Skill tool — it will cascade through the full pipeline and produce candidates.

### 2. Define what is being prioritized

This determines the framework. Ask/infer: is the list of **problems/needs**, of **ideas/
opportunities**, or of **features** of an already-existing product?

### 3. Auto-recommend the framework (and explain)

Recommend one, justify in one line, and let the user switch:

- **Opportunity Scoring** → prioritizing **problems/needs** with interview data (importance and current
  satisfaction). Finds what's important AND underserved.
- **ICE** → prioritizing **ideas/opportunities early**, solo, with little data. Light and fast.
- **RICE** → prioritizing **features / roadmap items** when reach can be estimated.

---

## The frameworks (formulas and how to score)

### ICE
`Score = Impact × Confidence × Ease` — each axis 1 to 10.
- **Impact:** how much it moves the needle if it works.
- **Confidence:** how certain you are (from data, not wishful thinking).
- **Ease:** the inverse of effort — how simple it is to do.

### RICE
`Score = (Reach × Impact × Confidence) ÷ Effort`
- **Reach:** number of people/events affected per period (e.g., customers/month).
- **Impact:** fixed scale — 3 = massive, 2 = high, 1 = medium, 0.5 = low, 0.25 = minimal.
- **Confidence:** % — 100% high, 80% medium, 50% low. Penalizes guessing.
- **Effort:** person-months (or weeks). It's the only denominator — high effort tanks the score.

### Opportunity Scoring
`Opportunity = Importance + max(Importance − Satisfaction, 0)` — each axis 1 to 10.
- **Importance:** how important the outcome is to the customer (from interviews).
- **Satisfaction:** how well current solutions solve it today.
- High importance + low satisfaction = underserved gap = biggest opportunity.

---

## Scoring process

For each item, score the axes of the chosen framework and, **alongside each score, write the
justification in one line** (where it came from: interview, benchmark, estimate). Mark with `(?)`
every low-confidence score — they're the first things to validate before acting.

Don't massage scores to make a favorite win. If the ranking contradicts your intuition, that's
information — investigate the divergence instead of adjusting the numbers until you get the result
you wanted.

---

## Deliverable (use this exact structure)

```markdown
# Prioritization — [what is being prioritized]
> Framework: [ICE/RICE/Opportunity] — [why this one] · Source: [Product OS / user list] · [date]

## Ranking
| # | Item | [framework axes] | Score | Confidence |
|---|------|------------------|:-----:|:----------:|
| 1 | ...  | ...              |  ...  | high/low   |

## Justifications
[Per item: one line per axis stating where the score came from. Mark uncertain ones with (?).]

## Recommendation
**Do first:** [item #1] — [why it wins, in 1-2 sentences].
**Before acting, validate:** [the (?) scores that most influenced the ranking].
**Next step:** [MVP definition / roadmap / more interviews].
```

Save: `prioritization-[topic-kebab]-[YYYY-MM-DD].md`. In chat, show only the top 3 + recommendation.

---

## Pitfalls (where this usually fails)

- **False precision** → treating the score as truth. It's an estimate; the value is in comparing,
  not in the absolute number. Always expose the reasoning and uncertain scores.
- **Prioritizing features before validating the problem** → ranking features of a problem nobody has
  confirmed is optimizing the wrong thing. If problems are still hypotheses, prioritize *problems*
  first (Opportunity Scoring), not features.
- **Ignoring effort/confidence** → the most exciting idea is usually the most expensive and uncertain.
  RICE/ICE exist precisely to pull enthusiasm back to earth.
- **Massaging scores to make the favorite win** → defeats the purpose. Let the framework surprise you.
- **Analysis paralysis** → the goal is to decide and move. Ranked, chosen, go. Don't refine the
  score forever.
