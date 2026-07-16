---
name: marclou-review
description: >
  Audits or shapes a product's landing page, pricing, copy, and positioning using Marc Lou's
  32 Principles of a Viral Product (distilled from 5 years building 35 startups in public).
  Use WHENEVER the user wants a landing page reviewed or built, asks why a product isn't
  converting or selling, is deciding pricing (free plan, subscription vs one-time, tiers),
  is preparing a launch, or wants the product to be more shareable/viral — phrases like
  "review my landing page", "why is nobody buying", "how should I price this", "make this
  go viral", "audit my product page", "marc lou principles", even without saying "viral".
  Works standalone or after mvp-definition in the Product OS (audits the thing you're about
  to ship). Not a growth-hacking playbook: it covers what the product and its page look like,
  not ads or content strategy.
---

# Viral Product Principles

32 patterns from Marc Lou ("32 Principles of a Viral Product", 2026) — what products that
spread organically have in common, learned from 35 startups built in public, hundreds of
launches that made $0, and a few that reached millions of people.

**Core rule from the author: these are patterns, not rules. Use them as a compass, not a
checklist.** Never tell the user "you violate principle N, change it" as if it were law.
Flag the deviation, explain the reasoning behind the pattern, and let context decide —
some products legitimately need a free tier, a subscription, or a lower price.

## Two modes

Detect which one the user needs:

- **Audit mode** — user has a landing page, pricing page, product, or launch draft.
  Score it against the principles and deliver a prioritized fix list.
- **Build mode** — user is creating (or rewriting) the landing page, pricing, name, or
  headline. Apply the principles as constraints while generating, and say which ones
  drove each choice.

Either mode: if the user gives a URL, fetch it. If they paste copy, use that. If there's
nothing concrete yet, interview briefly (what's the product, one sentence; who pays;
current pricing; current headline) before applying anything.

---

## The 32 principles

Grouped by what they act on. Numbers are the original article's, so the user can cross-reference.

### Pricing & monetization

| # | Principle | Essence |
|---|-----------|---------|
| 1 | No free plan | Free users cost support/servers and steer the roadmap; <3% ever convert. Remove it. |
| 8 | Hard paywall | Signups aren't validation; credit cards are. Ask for payment before asking for data. |
| 12 | Popcorn Pricing | Every extra tier is another decision and a reason to leave. Three choices: Good, Better, Best. |
| 16 | Pricing impossible to miss | Visitors use pricing to understand the product, not just the price. Put "Pricing" in the header. |
| 25 | Try before buying | Don't hide your best features behind the paywall — put them on the landing page. Play before pay. |
| 27 | No subscription | People are subscription-fatigued. One-time payments are 10x easier to sell; subscribe only if you can't ship without it. |
| 32 | More expensive than competitors | Nobody talks about the second cheapest option. Charge more. |

### Copy & messaging

| # | Principle | Essence |
|---|-----------|---------|
| 3 | Numbers, not adjectives | "Fast" is forgettable. "Save 4 hours every week" isn't. |
| 7 | Fifth-grader headline | Complexity kills curiosity. Your mum should get it. |
| 9 | Copy only you could write | If a competitor could paste your page onto theirs, it's too generic. Write from experience. |
| 14 | Steal copy from customers | Customers describe the product better than you do. Write like they talk. |
| 17 | Headline people remember next day | Write five, show friends, ask 24h later which one stuck. Keep that one. |
| 18 | Emotional headline | People remember feelings, not features. Aim for laugh / wow / "what the f* is this". |
| 21 | Empathy before selling | Describe the problem better than the customer can — that's what earns trust in the solution. |
| 26 | No weak words | "most", "many", "rarely" mean nothing. Make statements people can picture, remember, and challenge. |
| 28 | CTA says what happens next | "Get Started" means nothing. "Analyze My Website" removes uncertainty. |
| 30 | Describable in under 10 words | If you can't explain it in one sentence, users won't either. |

### Page design & structure

| # | Principle | Essence |
|---|-----------|---------|
| 2 | Three colors | Black text, white background, one color for the Buy button. Every extra color dilutes attention. |
| 4 | Shareable footer | 97% won't buy, but they might share. People remember what they see last — finish strong. |
| 5 | OG image = YouTube thumbnail | The OG image is seen more than the site. If they don't click, they don't watch. |
| 6 | One idea per screen | One screen, one message — like an Instagram feed. |
| 10 | Show before explaining | A demo beats paragraphs. Show, don't tell. |
| 20 | Hero sells alone | 80% never scroll past the hero. Understood + wanted within seconds, or you've lost. Fix the hero first. |
| 22 | One call to action | Multiple paths → many choose none. One next step. Just one. |

### Positioning & product

| # | Principle | Essence |
|---|-----------|---------|
| 11 | Does one thing | Nobody remembers Swiss Army knives; they remember the tool that solved their problem. |
| 13 | Rides a wave | Build around what people already discuss — the wave does half the marketing. |
| 15 | Visible founder | People buy from people. A founder screen recording beats a corporate promo. Show your face. |
| 19 | Never seen before | Nobody shares another clone. Surprise people. |
| 23 | Memorable name | Words people already know. No wordplay, no made-up names needing explanation. |
| 24 | Sells a human desire | People buy money, time, health, status, or less pain. Features are vehicles. Sell the outcome. |
| 29 | Testimonials before launch | A page without testimonials asks strangers for blind trust. Collect proof before traffic. |
| 31 | Compares to competitors | People care why they should switch, not what you do. Simple comparison table; make the decision obvious. |

---

## Known tensions (read before auditing)

The principles deliberately pull against each other in places. Don't report these as
contradictions — resolve them:

- **1 + 8 (no free plan, hard paywall) vs 25 (try before buying):** resolution is *demo on
  the landing page, payment before the account*. Interactive preview, sample output, or a
  playground on the page itself — not a free tier inside the product.
- **32 (charge more) vs 27 (no subscription):** a higher one-time price replaces a cheap
  monthly one; don't recommend both a premium price *and* a subscription without noticing
  the combined ask.
- **19 (never seen before) vs 13 (ride a wave):** not opposites — ride an existing wave with
  a surprising take, not a clone of the wave's leader.

## Audit mode — output format

1. **Verdict first**: one paragraph — the single biggest thing holding the product back,
   in plain language.
2. **Top 5 fixes**, ordered by conversion impact (hero and pricing issues almost always
   outrank footer/OG issues), each as: principle # + what's wrong + concrete rewrite or
   change (actual proposed headline/CTA/price, not "improve the headline").
3. **Full scorecard**: table of all 32 — ✅ follows / ⚠️ partial / ❌ deviates / N/A —
   one short note per non-✅ row. N/A is legitimate (e.g. #27 for infra products that
   can't be one-time; #13 if the niche has no wave).
4. **Deliberate deviations**: anything ❌ that might be *right* for this product's context,
   said explicitly, with the trade-off.

Write the audit to a file (`viral-audit-<product>.md` alongside the user's other Product OS
outputs, or the working directory) and summarize the verdict + top 5 in chat.

## Build mode — how to apply

- Generating a headline → run it through 3, 7, 17, 18, 26, 30 before showing it. Offer
  five candidates (per #17's method) and mark the one you'd keep.
- Generating hero copy → 20 + 21 + 10: problem empathy, then demo/show, understood in seconds.
- Generating pricing → 1, 8, 12, 27, 32 as defaults; ask before deviating.
- Naming → 23 + 30 together: real words, explainable in one sentence.
- Always cite which principles shaped each choice, so the user learns the compass.

## Common mistakes

- **Treating the 32 as a compliance checklist.** The author explicitly says compass, not
  checklist. A B2B infra product with usage-based pricing "violates" 12/27/32 and can be
  fine. Judge fit, then flag.
- **Auditing without seeing the page.** If the user says "review my landing page" and gives
  no URL/copy, ask for it — don't audit a product from memory or assumption.
- **Generic fixes.** "Make the headline simpler" is useless. Every fix must include the
  actual proposed text/number/color count.
- **Applying to the wrong products.** Skip or heavily adapt for: enterprise sales-led
  products (no self-serve buy button), regulated industries (claims restrictions vs #26),
  and marketplaces (two-sided, free side is the product). Say so instead of forcing fit.
