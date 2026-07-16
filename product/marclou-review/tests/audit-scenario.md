# Test scenario — audit mode

Regression test for `marclou-review`. Run it after any edit to `SKILL.md` by giving a fresh
subagent the skill file plus the prompt below, then scoring the output against the criteria.

## Prompt

> Read `product/marclou-review/SKILL.md` and follow it exactly as if it were your loaded
> skill instructions.
>
> User request: "Review my landing page, why is nobody buying?"
>
> The landing page copy (pasted by the user):
>
> ```
> # TaskFlowr — The Ultimate Productivity Solution
> TaskFlowr is a comprehensive, feature-rich platform leveraging AI to optimize workflows,
> streamline collaboration, manage tasks, track time, generate reports, and revolutionize
> how modern teams operate.
> [Get Started] [Learn More] [Book a Demo] [See Features]
> Most teams waste time. Many companies struggle with productivity.
> Pricing: Free plan • Starter $5/mo • Pro $9/mo • Team $19/mo • Business $29/mo •
> Enterprise: contact us (cheapest option in the market!)
> Colors: purple gradient hero, orange CTAs, teal accents, pink highlights, dark blue footer.
> No testimonials yet (launching next week).
> ```

## Pass criteria

- [ ] Detects **audit mode** (page copy provided → no interview, no build mode).
- [ ] Output leads with a **one-paragraph verdict** naming the single biggest blocker.
- [ ] **Top 5 fixes** ordered by conversion impact — hero/pricing issues rank above
      footer/OG issues — each citing principle #s and containing a **concrete rewrite**
      (actual proposed headline/CTA/prices, never "improve the headline").
- [ ] **Full 32-row scorecard** with ✅/⚠️/❌/N/A and a note per non-✅ row.
- [ ] **Deliberate deviations** section — must recognize the subscription (#27) as a
      legitimate deviation for a hosted team SaaS instead of demanding one-time pricing.
- [ ] Does **not** report the #1/#8 vs #25 tension as a contradiction — resolves it
      (demo on the page, payment before account).
- [ ] Audit written to a `viral-audit-*.md` file; chat message = verdict + top 5 only.

## Last run

2026-07-16 — PASS (scorecard 0 ✅ / 6 ⚠️ / 26 ❌; deviations flagged for #27, #1, #23).
