---
name: market-research
description: >
  Conducts structured market research for a product, SaaS, or micro-SaaS idea.
  Starts by framing scope in a brainstorm with the user (product, niche, competitors,
  features) and ends by delivering a detailed Market Map saved as a .md file.
  Use WHENEVER the user wants to investigate a market, validate a product idea, understand
  who buys / how much they pay / what alternatives exist / the size of the opportunity — or
  says things like "run a market research", "is this market worth it?", "who are the customers?",
  "is there room for this?", even without using the word "research".
  This is the first skill in the Product OS: what it discovers feeds the Benchmark and Interviews.
---

# Market Research

This skill understands a market **before** thinking about a solution. The classic mistake builders
make is jumping straight to "I'll create an app for X". Here the order is reversed: first understand
who buys, what hurts, how they solve it today and how much they pay — and only then decide if it's
worth building.

The output is a **Market Map**: a document that separates fact from assumption, shows the math
behind each estimate, and ends with an honest confidence rating and what still needs validation.

Work in three phases, in order. Do not skip Phase 0.

---

## Phase 0 — Framing (brainstorm with the user)

**Why it exists:** research quality depends entirely on how well the scope is defined.
"Market research for a scheduling app" is too vague and produces a generic, useless report.
"Scheduling for freelance nail technicians who currently use WhatsApp" produces sharp research.
This phase exists to move from the first to the second — **together** with the user, not in their place.

**How to run it (this is a brainstorm, not a form):**

Don't fire blank questions. From what the user said, **propose an initial framing** and let them correct it.
People refine much better by reacting to a proposal than by answering "what's your niche?". Present
your first cut of these four items:

1. **Product** — describe in one sentence what the product does (no jargon, no feature list).
2. **Niche / segment** — who *specifically* buys. Push for specificity: not "beauty professionals" but
   "freelance nail techs who do home visits". Wide niches dilute everything else in the analysis.
3. **Competitors / alternatives** — 3 to 5 candidates, including "dumb" alternatives (spreadsheet,
   WhatsApp, notebook). The most common alternative is almost never a direct competitor — it's the manual way.
4. **Core features** — the 2-3 things the product would do. Just to bound the research scope,
   not to design the product yet.

After proposing, ask at most 1-2 questions to resolve the biggest ambiguities. When the framing
is reasonable, **lock the scope** in a short block and confirm before continuing:

```
## Locked scope
Product:      [one sentence]
Niche:        [who, specific]
Competitors:  [3-5]
Features:     [2-3]
```

If the user said "just run it, don't ask too many questions", reduce the phase to a single scope
proposal + "confirm this?" and continue. But don't skip it: a wrong scope wastes the entire research.

---

## Phase 1 — Collection

**First, check if web search is available.**

- **With web search:** research live. Good sources by information type:
  - Real customer pain and language → Reddit, niche forums, groups, reviews ("what they hate")
  - Competitors and features → Product Hunt, AppSumo, G2, Capterra, competitor sites
  - Pricing → pricing pages, "how much do you pay for" threads, reviews
  - Demand / trend → Google Trends, search volume, community growth
  - Buyer profile → LinkedIn, job descriptions, professional communities
  Cite the source for each factual claim. Prefer the customer's literal language over your paraphrase.

- **Without web search:** do the best with your own knowledge, but **explicitly warn at the top of the
  report** that the data was not verified live and needs validation. Flag everything that's an estimate.
  Don't fake precision you don't have.

**Investigate the 5 dimensions** (this is the report's backbone):

1. **Segments** — who buys; sub-segments; which is most attractive and why.
2. **Pains** — what hurts, how often, the impact (financial/time/emotional), and
   **how they solve it today** (the current alternative is the real competition).
3. **Existing solutions** — what already exists, what's table stakes, and where the
   gaps / recurring complaints are.
4. **Willingness to pay** — observed price ranges, common billing model, and what the customer
   already pays today (even if it's just time).
5. **Size and dynamics** — how many potential customers, market growing or shrinking, any change
   (regulatory, technological, behavioral) opening a window.

---

## Phase 2 — Synthesis (full, detailed report)

Build the report using the template below. The user asked for depth: each section should be **dense and
specific**, not generic bullets. When data is missing, say "not found" instead of making something up.

**Non-negotiable synthesis rules:**

- **Separate fact from assumption.** Mark each relevant claim as `[fact: source]` or `[assumption]`.
  A report that mixes both is worse than none — it creates false confidence.
- **Never invent a number.** Every size or price estimate comes **with the math shown**, preferably
  bottom-up (e.g., "≈ 40k freelance nail techs in the state × 30% with a work smartphone × $30/mo = ...").
  Showing the premise lets the user disagree with it.
- **End with honesty.** The final section states the confidence level and the 3 biggest unknowns — which
  become direct input for the Benchmark and Discovery Interviews.

### Report template (use this exact structure)

```markdown
# Market Map — [niche]
> Scope: [product in one sentence] · Generated on [date] · [with / without] live search

## Summary
[3-5 sentences: what the market is, the central pain, and the overall read in one line.]

## 1. Segments
[Sub-segments in order of attractiveness. For each: who they are, relative size,
why they are (or aren't) attractive. Recommend the initial target segment and justify it.]

## 2. Main pains
[Prioritized list. For each pain: description in the customer's language, frequency,
impact ($/time), and HOW they solve it today. Mark fact/assumption.]

## 3. Existing solutions
[Overview of what's out there. Mandatory features (table stakes).
Recurring customer complaints. Open gaps = opportunity.]

## 4. Willingness to pay
[Observed price ranges, dominant billing model, what they pay today.
Every estimate with the math shown.]

## 5. Size and dynamics
[Bottom-up estimate with explicit assumptions. Trend (growing/shrinking).
Opportunity window, if any.]

## Read
**Confidence:** [high / medium / low] — [why in one sentence]
**Signal:** [dig deeper / explore more / signals to kill]
**3 biggest unknowns to validate:**
1. [...] → next step: [benchmark / interview]
2. [...]
3. [...]
```

---

## Output — save to Product OS

The deliverable is a **.md file**, not just a chat response. It accumulates in the user's Product OS,
where reports become a comparison baseline over time.

- Save the report as a Markdown file in the environment's output location
  (in Claude.ai/Cowork: `/mnt/user-data/outputs/`).
- Use a consistent, traceable name: `market-map-[niche-kebab]-[YYYY-MM-DD].md`.
- Share the file with the user (use `present_files` if available). Give just a 2-3 line summary
  in chat — the content is in the file, don't repeat it all.

---

## Pitfalls (where this usually fails)

- **Skipping Phase 0** → generic report. The framing is half the value.
- **Niche too wide** → averages that mean nothing. Always push for specificity.
- **Treating the manual alternative as non-competition** → WhatsApp/spreadsheet IS the competitor to beat.
- **Inventing numbers to look complete** → destroys trust in the entire document. "Not found"
  is a legitimate answer and more useful than a made-up one.
- **Confusing research with validation** → this skill maps the market; it surfaces unknowns, but
  validation with real people is the Discovery Interviews skill. Don't conclude "validated" here.
