# reuse-refactor skill — design

**Date:** 2026-11-12
**Status:** approved 2026-11-12 (builder check done; open questions answered by the user)
**Builds on:** `code/implement/ponytail` (vendored), `code/frontend/pick-ui-library`

## Intent

The user vibe-codes: dictates the architecture, tests by running the app, and does not read the
generated code. Duplication and reinvented wheels pile up unseen. They want a skill that removes
them **on its own**: finds, refactors, proves the behavior did not change, gets an independent
review, fixes what the review confirms, and ends with commits ready to ship. It is the Vendevo
`/ship` loop applied to refactoring: act, verify, review, fix, converge. No "report and wait".

Pair with ponytail: ponytail prevents (reuse first while writing); reuse-refactor cures (after the
code exists). Both feed an Elephant + Goldfish workflow: the main session is the elephant (holds
the rules, runs the loop and the tests); fresh subagents are goldfish (review with no memory of how
the code was written).

## Goals

- Remove, in what the branch added, code that:
  - duplicates something already in the repo (helper, component, service, query, validation);
  - is duplicated inside the new code itself;
  - hand-rolls what the standard library or platform already does;
  - hand-rolls what an installed dependency already does;
  - hand-rolls tricky code a mature library does well (React web: pick with `pick-ui-library`).
- Act, never only report: implement, verify, review, fix, commit.
- Automatic proof for every change, so nobody has to read the diff: behavior pinned by tests
  before the change, the same tests green after it, unchanged.
- Front and back, in any stack whose tests the project can run.

## Non-goals

- Code review or audit reports (`hygiene-review`, `pr-review` do that).
- Feature changes or bug fixes. A refactor preserves behavior, bugs included; a bug found along the
  way goes in the final report. One exception (user's decision): a pre-existing bug the review
  confirms as BLOCKER or HIGH in code the refactor touched is fixed, in its own commit (step 4).
- Push, PR, merge (that is `/ship` in Vendevo, or the human elsewhere).
- Style churn, renames for taste, architecture rewrites, splitting functions by size.

## Anti-goals (failure even if it "works")

- A behavior change that slips through.
- An abstraction over two blocks that only look alike (premature coupling).
- A net diff that grows without replacing hand-rolled code with an existing piece.
- Stopping to ask the user what a sensible default answers.
- Editing or weakening an existing test to get green.

## Constraints

- **Self-contained skill directory.** It is installed by symlink or copied by skills.sh, so no
  relative paths into other skills; it carries the short guidance it needs (what counts as
  duplication, how to write a characterization test).
- **Project rules win:** test and verify commands, test constraints (pigz-api: `scripts/verify.sh`,
  one at a time, never from subagents), dependency rules (Vendevo: `bun add` needs confirmation),
  commit conventions, branch rules, guard hooks.
- Requires git. Does not need a remote.
- `SKILL.md` in English; the final report in the user's language (pt-BR by default).
- Lives at `code/refactor/reuse-refactor/`, with a Catalog row and a `skills.sh.json` group.

## Approaches

1. **One skill; the elephant runs the loop; a goldfish reviews** (chosen). The main session finds
   candidates, pins behavior, refactors and tests, one candidate at a time; a fresh subagent reviews
   only the diff against the intent "pure refactor, identical behavior". Works where tests cannot
   run from subagents (pigz-api), keeps every candidate atomic, mirrors `/ship`.
2. **One goldfish executor per candidate, in parallel worktrees.** Faster with many candidates, but
   parallel suites crash the user's WSL, refactors that touch the same shared file conflict, and a
   diff-seeded run rarely has more than a handful of candidates.
3. **Orchestrate the existing skills** (`hygiene-review` → `behavior-tests` → refactor). Reuses
   them, but both are report-first and ask for confirmation by design; making them autonomous
   would change skills the user also runs on their own.

The user handed over the "how" and asked for the recommended scope; approach 1 is the author's
pick.

## Decided

### Scope of a run

- **Default:** the seed is what the branch added: `git diff $(git merge-base HEAD <default>)`,
  plus uncommitted and untracked files. The search space for equivalents is the whole repo.
- **The user names a path:** the seed is that path; the search space is the whole repo.
- On the default branch with nothing new and no path: say there is nothing to refactor and stop.

### The loop

1. **Set up.**
   - On the default branch: create `refactor/<topic>` first.
   - Uncommitted and untracked changes are the feature (user's decision, as `/ship` does): commit
     them first, as they are, in normal Conventional Commits staged by path, so the refactor has a
     clean baseline to revert to. A half-done feature landing in the branch history is accepted.
     Files that are clearly from another task (drafts, handoff notes, scratch files) are never
     staged, and no candidate may touch them.
   - Read the project rules (`AGENTS.md`, `CLAUDE.md`, `.claude/rules/`) and detect: the test
     command for one file, the full verification command, lint and typecheck, the browser check
     (if the project has one), and test constraints.
   - Run the checks for the seed's area once. Red before any change: stop (nothing can be proven).
2. **Find candidates** from the seed: for each new function, component, query or block, search the
   repo for something that already does it (by name, signature, distinctive literals, shape), then
   stdlib/platform, installed dependencies, mature libraries. Add duplication inside the seed.
   Keep only candidates with a concrete replacement. Order by lines removed, biggest first.
   **At most 5 candidates per run.**
3. **Per candidate, sequentially and atomically:**
   1. **Pin.** Find the tests that cover the behavior. Missing: write characterization tests at the
      highest level the project already uses, against the current code, and run them green.
      **Prove each new test can fail** (author's call): break the code it pins on purpose (flip a
      condition, return a wrong value), watch the test go red, restore the code. A test that stays
      green does not pin anything: strengthen it or skip the candidate. A screen in the candidate
      and a browser check in the project: take the "before" screenshots now. Cannot pin it
      (untestable, or no green on current code): skip the candidate.
   2. **Refactor** with ponytail's rules: the smallest change; moved or merged code keeps its error
      handling and validation.
   3. **Prove.** The pinned tests, unchanged, plus the tests next to every touched file, lint and
      typecheck, all green. Screens: "after" screenshots compared with "before" (open both).
   4. **Not proven after 2 fix attempts:** revert the candidate's files, log why, next candidate.
   5. **Proven:** commit in two commits, so history shows the tests passing before and after:
      `test(<scope>): pin <behavior>` (only when new tests were written), then
      `refactor(<scope>): <what was replaced by what>`.
   - A candidate that needs a new dependency: never install it, in any project (author's call:
     choosing and pinning a library is the one supply-chain decision a refactor should not make
     alone; ponytail also only proposes). Skip it and list it as a suggestion in the final report.
4. **Independent review (goldfish).** Dispatch a fresh subagent with only: the target (the
   `test(...)` and `refactor(...)` commits' diff), the intent ("pure refactor: identical
   behavior"), and the checklist (behavior change, lost error handling or validation, abstraction
   over look-alikes, tests weakened or edited, a new test that would stay green if the behavior
   changed, net diff growth). Use the project's reviewer agent when one exists
   (Vendevo: `reviewer`), passing that intent. Fix CONFIRMED BLOCKER and HIGH only. A confirmed
   behavior change the refactor introduced: revert that candidate instead of arguing. A confirmed
   BLOCKER or HIGH that was already there before the refactor (user's decision): fix it in its own
   commit, first the test that reproduces it and fails, then the fix, as
   `fix(<scope>): <bug>`, kept apart from the refactor commits and called out in the final report,
   so `/ship` does not stop on it later. Rounds 2 and 3 review the delta. At
   most 3 rounds; still open after the 3rd: revert those candidates.
5. **Full verification** once at the end, with the project's full command, in the background.
   Red: fix, or revert the candidate that caused it, and run again.
6. **Final report**, short, in the user's language: candidates done (what replaced what, net
   lines), candidates skipped and why, suggestions (new dependencies, bugs found), tests added,
   verification and review results, what was not checked, and the next step (`/ship` when the
   project has it).

### Autonomy rule

When a candidate cannot be proven safe, revert it and move on; do not ask. The only stops are:
a policy lock (guard hook, deny rule, refused push), and a red baseline before any change.

### Roles

- Elephant (main session): everything, including every test run.
- Goldfish (fresh subagent): the review only, with the target, the intent and the checklist,
  never the conversation or the author's reasoning.

## Left to the builder

- Search heuristics for equivalents per stack (TS/React, PHP, Python, Go).
- How `SKILL.md` splits into references.
- The skill's own tests (writing-skills RED/GREEN): e.g. a fixture repo with planted duplication,
  a hand-rolled date diff, and a near-copy that must not be merged.
- Trigger wording in the description (after a feature is done and before shipping; "refactor",
  "dedupe", "clean up").
