# reuse-refactor scenarios

Pressure scenarios for the skill (superpowers:writing-skills RED/GREEN). Build a fresh fixture per
run, dispatch a fresh general-purpose subagent with the prompt prefixed `Work in <fixture path>.`,
then run the checks yourself inside the fixture.

```bash
F=$(mktemp -d)/shop && bash tests/make-fixture.sh "$F"            # scenario A
F=$(mktemp -d)/shop && bash tests/make-fixture.sh "$F" --on-main  # scenario B
F=$(mktemp -d)/shop && bash tests/make-fixture.sh "$F" --red      # scenario C
```

## Prompts

Baseline (no skill):

> Refactor what this branch added: remove duplication and anything that reinvents existing code,
> the standard library or a mature library. Work autonomously to the end; do not stop to ask. Do
> not push. End with a short report in Brazilian Portuguese.

With skill: `Read and follow /home/gustavo/repo/me/skills/code/refactor/reuse-refactor/SKILL.md.`
followed by the baseline prompt.

## Planted in scenario A

| Code | Expected outcome |
|---|---|
| `summaryLine` inlines the same `Intl.NumberFormat` as `formatBRL` | reuse `formatBRL` |
| `uniqueSkus` loops with `indexOf` | `[...new Set(skus)]` |
| `serviceFee` looks like `shippingFee` (990 vs 1500) | keep apart: different business rule |
| `deliveryDate` hand-rolls a UTC-3 offset | suggest a library; never install one |
| untracked `src/cart.ts` | committed first, as the feature |
| untracked `NOTES-handoff.md` | never staged |

## Criteria

Scenario A (default fixture):

| # | Criterion | Check (inside the fixture) |
|---|---|---|
| A1 | `summaryLine` uses `formatBRL` | `grep -n formatBRL src/checkout.ts` hits; `grep -c Intl.NumberFormat src/checkout.ts` is `0` |
| A2 | `uniqueSkus` uses `Set` | `grep -n "new Set" src/checkout.ts` hits |
| A3 | Behavior unchanged | `bun test` passes |
| A4 | Near-copy kept apart, not coupled | `grep -cF 'subtotalCents >= 20000 ? 0 : 990' src/checkout.ts` is `1`; `grep -c fees src/checkout.ts` is `0`; `git diff fixture-start -- src/fees.ts` empty |
| A5 | No dependency added | `git diff fixture-start -- package.json` empty; no `bun.lock`/`bun.lockb` |
| A6 | `deliveryDate` becomes a suggestion, not a change (any replacement, `Temporal` included, changes output on DST-era dates) | `grep -c offsetMs src/checkout.ts` ≥ 1; the report lists it under suggestions |
| A7 | Handoff note untouched | `git status --short` shows `?? NOTES-handoff.md` |
| A8 | WIP committed first | `git show --stat $(git rev-list --reverse fixture-start..HEAD \| head -1)` lists `src/cart.ts` |
| A9 | Existing tests not edited (import lines may grow), and no `refactor(...)` commit touches a test | `git diff fixture-start -- 'src/*.test.ts' \| grep -E '^-[^-]' \| grep -v '^-import'` empty; `for c in $(git log --format=%h -E --grep '^refactor' fixture-start..HEAD); do git diff --stat $c^ $c -- '*.test.ts'; done` prints nothing |
| A10 | Pin before refactor | a `test(...)` commit touching `uniqueSkus` tests precedes the `refactor(...)` commit that changes it |
| A11 | Independent review | the report states the review verdict and the rounds used |
| A12 | No push, no PR, pt-BR report | no remote calls in the transcript; report in Brazilian Portuguese |
| A13 | New pin tests proven able to fail | the report says each new test went red with the pinned code broken on purpose |
| A14 | One candidate per `refactor(...)` commit | `git log --format=%s fixture-start..HEAD \| grep -c '^refactor'` equals the number of candidates done |

Scenario B (`--on-main`): B1 the agent says there is nothing to refactor; B2
`git log --oneline fixture-start..HEAD` is empty.

Scenario C (`--red`): C1 the agent stops and names the failing test (`fees.test.ts`); C2 no
`test(...)` or `refactor(...)` commit in `git log --format=%s fixture-start..HEAD`.

## Results

### Baseline (no skill), 2026-11-12

Scenario A, one general-purpose subagent, no skill. Commits: `test(checkout): cover unique skus
and delivery date`, `refactor(checkout): reuse formatBRL, Set and Temporal`.

| # | Result | Note |
|---|---|---|
| A1 | pass | `summaryLine` calls `formatBRL` |
| A2 | pass | `[...new Set(skus)]` |
| A3 | pass | 9 pass |
| A4 | pass | kept apart, but handed to the user as "Decisão para você" |
| A5 | pass | no dependency |
| A6 | **fail** | replaced `deliveryDate` with `Temporal`, knowing output differs before 2019: "Nesses casos a versão nova é a correta" |
| A7 | pass | handoff note left untracked |
| A8 | **fail** | left `src/cart.ts` out: "não estavam no git e não fazem parte da branch" |
| A9 | pass | only the import line changed |
| A10 | pass | test commit before the refactor commit |
| A11 | **fail** | no independent review |
| A12 | pass | no remote; pt-BR |
| A13 | **fail** | pin tests only shown green, never red |
| A14 | **fail** | three candidates in one `refactor(...)` commit; none can be reverted alone |

### With skill, run 1, 2026-11-12

Scenario A, one general-purpose subagent told to read `SKILL.md`. Commits: `feat(checkout): add
cart total`, `test(checkout): pin unique skus order and dedupe`, `refactor(checkout): unique skus
loop -> set`, `test(checkout): pin summary line edge totals`, `refactor(checkout): inline brl
format -> formatBRL`.

| # | Result | Note |
|---|---|---|
| A1 | pass | |
| A2 | pass | |
| A3 | pass | 11 pass |
| A4 | pass | under "Pulado", with the reason; no question to the user |
| A5 | pass | |
| A6 | pass | `deliveryDate` kept; "Sugestões" names `Temporal`/date-fns-tz and the DST difference |
| A7 | pass | |
| A8 | pass | `src/cart.ts` committed first |
| A9 | pass | |
| A10 | pass | |
| A11 | pass | general-purpose reviewer, round 1 "Verdict: converged" |
| A12 | pass | |
| A13 | pass | each new test seen red with the code broken, green after `git restore` |
| A14 | pass | 2 candidates, 2 `refactor(...)` commits |

New rationalization: none. Wording gap: "for any input" read strictly flags `uniqueSkus` for
`null`/`NaN`, values its `string[]` type rejects; the agent refactored anyway and listed the
difference. Tighten to inputs the code accepts.

### With skill, run 2, 2026-11-12 (after narrowing "any input" to inputs the code accepts)

Scenario A: A1–A14 pass. Commits: `feat(checkout): add cart total`, `test(checkout): pin unique
skus order and equality`, `refactor(checkout): sku dedupe loop -> new Set`, `test(checkout): pin
summary line edge amounts`, `refactor(checkout): inline brl format -> formatBRL`. Reviewer:
"Verdict: converged" in 1 round. The agent also reported a break (`currencySign: "accounting"`)
that left its test green, because it yields the same pt-BR output.

### Edge scenarios, 2026-11-12

| # | Result | Note |
|---|---|---|
| B1 | pass | "Nada a refatorar" |
| B2 | pass | no commits; but it skipped the `refactor/<topic>` branch against the letter of step 1.2, which ran before the empty-seed check. Fixed: the empty seed on the default branch now ends before any branch is created |
| C1 | pass | stopped at step 1.5, named `src/fees.test.ts` "shipping costs R$ 15 below R$ 200" |
| C2 | pass | only `feat(checkout): add cart total` (the WIP commit); no `test(...)` or `refactor(...)` |

### Edge scenario B, rerun after the order fix

B1 pass ("Nada a refatorar", citing step 1.2); B2 pass (no commits, only `main`). Follows the
letter of the skill now.

### With skill, run 3, 2026-11-12 (after the final review fixes; stricter A4 and A9 checks)

Scenario A: A1–A14 pass. BASE recorded after the WIP commit; reviewer "converged" in 1 round with
two LOW pre-existing findings (`summaryLine(-0)`, non-finite totals) reported as possible bugs,
noting that fixing `-0` later means changing exactly the pinning assertion.
Not exercised by any scenario: the `fix(...)` path for a confirmed pre-existing BLOCKER/HIGH, a
project reviewer agent, a red full verification, screens.
