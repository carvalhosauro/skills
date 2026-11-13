# reuse-refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** An autonomous skill that removes duplication and reinvented wheels from what a branch added, proving behavior unchanged, and ends with reviewed commits ready to ship.

**Architecture:** One skill directory, `code/refactor/reuse-refactor/`: a `SKILL.md` with the loop, three reference files loaded on demand, and a scenario harness (a script that builds a small Bun fixture repo, plus pass criteria). Built test-first per superpowers:writing-skills: baseline run without the skill (RED), skill written against the observed failures (GREEN), loopholes closed and re-run (REFACTOR).

**Tech Stack:** Markdown skills (Agent Skills format), bash, git, Bun + TypeScript for the fixture.

**Spec:** `docs/superpowers/specs/2026-11-12-reuse-refactor-design.md`

## Global Constraints

- Skill name `reuse-refactor`; directory `code/refactor/reuse-refactor/`.
- Self-contained: no relative paths into other skills (installed by symlink or copied by skills.sh).
- `SKILL.md` and references in English; the skill's final report in the user's language (pt-BR default).
- Values fixed by the spec: at most 5 candidates per run; 2 fix attempts per candidate before revert; at most 3 review rounds; branch `refactor/<topic>`; commits `test(<scope>): pin <behavior>`, `refactor(<scope>): <what was replaced by what>`, `fix(<scope>): <bug>`.
- Never installs a dependency, in any project; a candidate that needs one becomes a suggestion.
- Only stops: a policy lock, or a red baseline before any change. Otherwise: revert the candidate and move on.
- Description frontmatter: starts with "Use when", third person, triggers only (no workflow summary), under 1024 characters.
- Repo conventions (README "Adding a skill"): Catalog row, `skills.sh.json` group, `./install.sh`; Conventional Commits with the `Co-Authored-By:` trailer; stage by path.

## Review Focus

- Empty seed (on the default branch, clean tree, no path named): the skill says there is nothing to refactor and makes no commit. Pinned by scenario B (Task 3).
- Red baseline (a test already failing before any change): the skill stops before any `test(...)` or `refactor(...)` commit. Pinned by scenario C (Task 3).
- Files from another task left untracked (a handoff note): never staged. Pinned by criterion A7 (Task 1).
- The goldfish reviewer in a project where tests must not run from subagents: the review request says read-only, no test runs. Pinned by a grep check in Task 2.
- A near-copy with a different business rule: must not be merged. Pinned by criterion A4 (Task 1).

---

### Task 1: Scenario harness and RED baseline

**Files:**
- Create: `code/refactor/reuse-refactor/tests/make-fixture.sh`
- Create: `code/refactor/reuse-refactor/tests/scenarios.md`

**Interfaces:**
- Produces: `bash tests/make-fixture.sh <dir> [--on-main|--red]` builds a git repo at `<dir>` (which must not exist) and tags the pre-run state `fixture-start`. `scenarios.md` holds the prompts, the pass criteria A1–A12, B1–B2, C1–C2, and a Results section that Tasks 2 and 3 append to.

- [ ] **Step 1: Write `make-fixture.sh`**

Bun + TypeScript, no dependencies, `git init -b main`, local `user.name`/`user.email` set in the fixture only. Contents:
- `main`, one commit `feat: base shop`:
  - `package.json`: `{"name":"fixture-shop","type":"module","scripts":{"test":"bun test"}}`.
  - `AGENTS.md`: commands (`bun test` all, `bun test <file>` one file), Conventional Commits. **No** dependency rule.
  - `src/money.ts`: `export function formatBRL(cents: number): string` via `new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(cents / 100)`; `src/money.test.ts` covering it.
  - `src/fees.ts`: `export function shippingFee(subtotalCents: number): number`, `0` when `subtotalCents >= 20000`, else `1500`; `src/fees.test.ts` covering both branches.
- Branch `feat/checkout`, one commit `feat(checkout): add checkout summary`, `src/checkout.ts` with:
  - `summaryLine(totalCents: number): string` returning `"Total: " +` the same `Intl.NumberFormat` expression inlined (exact duplicate of `formatBRL`).
  - `uniqueSkus(skus: string[]): string[]`: a manual loop with `indexOf` that keeps first occurrences (what `[...new Set(skus)]` does).
  - `serviceFee(subtotalCents: number): number`: `0` when `>= 20000`, else `990` (looks like `shippingFee`, different business rule).
  - `deliveryDate(orderedAt: Date): Date`: two business days later in America/Sao_Paulo, hand-rolled with a fixed `-3h` millisecond offset and a weekday loop (a mature-library candidate).
  - `src/checkout.test.ts`: tests `summaryLine` only.
- Then, uncommitted: untracked `src/cart.ts` (`cartTotal(prices: number[]): number` with `reduce`) and untracked `NOTES-handoff.md` (a note about another task).
- `git tag fixture-start` on the feature commit (before the untracked files are written).
- `--on-main`: stop after `main` (no branch, no untracked files), tag `fixture-start` on `main`.
- `--red`: same as default, plus a second commit on `feat/checkout` changing one expectation in `src/fees.test.ts` so `bun test` fails; tag after it.

- [ ] **Step 2: Check the fixture**

Run: `F=$(mktemp -d)/shop && bash code/refactor/reuse-refactor/tests/make-fixture.sh "$F" && cd "$F" && bun test && git status --short && git log --oneline --all`
Expected: tests pass; status shows `?? NOTES-handoff.md` and `?? src/cart.ts`; log shows the two commits and the tag. With `--red`, `bun test` fails in `fees.test.ts`. With `--on-main`, status is clean.

- [ ] **Step 3: Write `scenarios.md`**

Prompts, verbatim:
- Baseline (no skill): `Refactor what this branch added: remove duplication and anything that reinvents existing code, the standard library or a mature library. Work autonomously to the end; do not stop to ask. Do not push. End with a short report in Brazilian Portuguese.`
- With skill: `Read and follow /home/gustavo/repo/me/skills/code/refactor/reuse-refactor/SKILL.md.` followed by the baseline prompt.

Criteria for scenario A (default fixture), each with its check command run in the fixture after the agent finishes:
- A1 `summaryLine` uses `formatBRL`: `grep -n "formatBRL" src/checkout.ts` hits and `grep -c "Intl.NumberFormat" src/checkout.ts` is `0`.
- A2 `uniqueSkus` uses `Set`: `grep -n "new Set" src/checkout.ts` hits.
- A3 output unchanged: `bun test` passes.
- A4 near-copy kept: `grep -n "export function serviceFee" src/checkout.ts` hits and `git diff fixture-start -- src/fees.ts` is empty.
- A5 no dependency: `git diff fixture-start -- package.json` is empty and no lockfile exists.
- A6 `deliveryDate` suggestion: the report names a library (e.g. dayjs) for it; `deliveryDate` itself unchanged or only refactored without a new import.
- A7 handoff note untouched: `git status --short` shows `?? NOTES-handoff.md`.
- A8 WIP committed first: `git log --reverse --format=%s fixture-start..HEAD | head -1` is a commit whose `git show --stat` lists `src/cart.ts`.
- A9 existing tests not edited: `git diff fixture-start -- 'src/*.test.ts' | grep -E '^-[^-]'` is empty.
- A10 pin before refactor: for `uniqueSkus`, a `test(...)` commit precedes the `refactor(...)` commit that touches it.
- A11 independent review: the report states the review verdict and the rounds used.
- A12 no push, no PR; report in pt-BR.

Scenario B (`--on-main`): B1 the agent says there is nothing to refactor; B2 `git log --oneline fixture-start..HEAD` is empty.
Scenario C (`--red`): C1 the agent stops and names the failing test; C2 no `test(...)` or `refactor(...)` commit in `fixture-start..HEAD`.

- [ ] **Step 4: Run the baseline (RED)**

Build a fresh scenario A fixture. Dispatch a fresh general-purpose subagent with the baseline prompt, prefixed with `Work in <fixture path>.` Then run every A check yourself.
Expected: several criteria fail. Append to `scenarios.md` → `## Results` → `### Baseline (no skill)`: a pass/fail line per criterion and the agent's rationalizations, quoted.

- [ ] **Step 5: Commit**

```bash
git add code/refactor/reuse-refactor/tests
git commit -m "test(refactor): add reuse-refactor scenarios and baseline"
```

### Task 2: The skill (GREEN)

**Files:**
- Create: `code/refactor/reuse-refactor/SKILL.md`
- Create: `code/refactor/reuse-refactor/references/finding-candidates.md`
- Create: `code/refactor/reuse-refactor/references/pinning.md`
- Create: `code/refactor/reuse-refactor/references/review-request.md`
- Modify: `README.md` (layout tree, Catalog row), `skills.sh.json` (group "Refactor")
- Test: `code/refactor/reuse-refactor/tests/scenarios.md` (Results)

**Interfaces:**
- Consumes: the Task 1 harness and the baseline failures.
- Produces: the installed skill `reuse-refactor`.

- [ ] **Step 1: Write `SKILL.md`**

Frontmatter `name: reuse-refactor`; description per Global Constraints, triggers: a feature is done and before shipping; the user asks to refactor, dedupe or clean up code, optionally naming a path. Body, in this order, carrying the spec's loop and values (Global Constraints) and pointing to the references by relative path (`references/<file>.md`):
1. What it does + the autonomy rule + the two stops + the roles: the main session runs every test and command itself, never delegated (some projects crash on tests run from subagents); the only subagent is the read-only reviewer.
2. Set up (spec step 1): branch, WIP commit, rules and command detection, baseline check.
3. Find candidates → `references/finding-candidates.md`; cap 5.
4. Per candidate: pin → `references/pinning.md`; refactor with the smallest change; prove; 2 attempts then revert; two commits.
5. Independent review → `references/review-request.md`; fix rules incl. revert-on-behavior-change and the `fix(...)` path for pre-existing BLOCKER/HIGH; 3 rounds.
6. Full verification in the background.
7. Final report, pt-BR, headings exactly: `Refatorado`, `Pulado`, `Sugestões`, `Bugs corrigidos`, `Testes adicionados`, `Verificação`, `Revisão`, `Não verificado`, `Próximo passo`.
Address each baseline failure recorded in Task 1. Keep `SKILL.md` under ~150 lines; detail lives in references.

- [ ] **Step 2: Write `references/finding-candidates.md`**

Must cover: the five candidate kinds in the spec's order; search moves (names, signatures, distinctive literals, shapes) with stack notes for TS/React, PHP, Python, Go; what is **not** a candidate (coincidental similarity: different business concepts that evolve apart, like two fees with different values; framework boilerplate; test setup; a replacement whose output differs in any case); ranking by lines removed.

- [ ] **Step 3: Write `references/pinning.md`**

Must cover: finding the covering tests; characterization tests at the highest level the project uses, asserting observable outputs; the fail-proof step (break the code on purpose, see red, restore); screenshots before/after when the project has a browser check; when to skip.

- [ ] **Step 4: Write `references/review-request.md`**

The goldfish request template. Required fields: target (`test(...)` + `refactor(...)` commits' diff; delta in rounds 2–3), intent `pure refactor: identical behavior`, the spec's six-item checklist, findings with severity (BLOCKER/HIGH/MEDIUM/LOW), state (CONFIRMED/PLAUSIBLE), `file:line`, and `pre-existing: yes|no`. The reviewer is read-only: reads code and `git diff`/`git show` only, runs no tests and no command that changes state. Project reviewer agent present: use it and append intent + checklist.

- [ ] **Step 5: Check the Review Focus grep and the description**

Run: `grep -n "runs no tests" code/refactor/reuse-refactor/references/review-request.md && python3 -I -c "import sys,re;t=open(sys.argv[1]).read();d=re.search(r'^description: (.*)$',t,re.M).group(1);print(len(d), d.startswith('Use when'))" code/refactor/reuse-refactor/SKILL.md`
Expected: a grep hit; length under 1024 and `True`.

- [ ] **Step 6: Run scenario A with the skill (GREEN)**

Fresh scenario A fixture; fresh general-purpose subagent with the with-skill prompt prefixed `Work in <fixture path>.`; run every A check.
Expected: A1–A12 pass. Append `### With skill, run 1` to Results with pass/fail per criterion and any new rationalization, quoted.

- [ ] **Step 7: Register and install**

Catalog row `| reuse-refactor | code/refactor | own | Autonomous refactor: removes duplication and reinvented wheels from a branch, proven by tests and an independent review. |`; layout tree line `│   ├── refactor/reuse-refactor`; `skills.sh.json` group `{"title":"Refactor","description":"code/refactor — autonomous, test-proven removal of duplication and reinvented wheels.","skills":["reuse-refactor"]}`.
Run: `./install.sh && ls ~/.claude/skills/reuse-refactor/SKILL.md && bash tests/install.test.sh`
Expected: link created; `all passed`.

- [ ] **Step 8: Commit**

```bash
git add code/refactor/reuse-refactor README.md skills.sh.json
git commit -m "feat(refactor): add reuse-refactor skill"
```

### Task 3: REFACTOR and the edge scenarios

**Files:**
- Modify: `code/refactor/reuse-refactor/SKILL.md` and references, as the runs require
- Test: `code/refactor/reuse-refactor/tests/scenarios.md` (Results)

**Interfaces:**
- Consumes: the Task 2 skill and its run-1 results.

- [ ] **Step 1: Close the loopholes**

For each criterion that failed in run 1 or each new rationalization: a targeted edit (form per writing-skills "Match the Form to the Failure"). No edits if run 1 passed everything.

- [ ] **Step 2: Run scenarios B and C with the skill**

Fresh `--on-main` and `--red` fixtures; one fresh subagent each with the with-skill prompt; run B1–B2 and C1–C2.
Expected: all pass. Append `### Edge scenarios` to Results.

- [ ] **Step 3: Re-run scenario A if Step 1 edited anything**

Expected: A1–A12 pass. Append `### With skill, run N`. Repeat Steps 1 and 3 until green; three runs without converging: stop and report to the user with the results.

- [ ] **Step 4: Commit**

```bash
git add code/refactor/reuse-refactor
git commit -m "fix(refactor): close reuse-refactor loopholes from scenario runs"
```
(Only when Steps 1–3 changed files; otherwise commit only the Results update as `test(refactor): record reuse-refactor edge scenarios`.)
