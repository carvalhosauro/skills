---
name: behavior-tests
description: >-
  Strengthens behavior coverage: runs the suite, audits test quality and
  logging, and writes missing tests that protect flows, business rules, and
  happy + bad paths — not shallow unit tests of glue. Use after a coding
  session, before a PR, or when the user asks to "add tests for this flow",
  "cover the business rules", "happy and bad paths", "behavior/integration
  tests", "what's untested", "run the tests", "audit the tests", or "fix
  the logging". Prefer meaningful scenario tests over chasing % coverage.
  Counterpart to hygiene-review. Trigger even without saying "skill".
---

# Behavior Tests & Logging

Strengthen a codebase's safety net around **real behavior**: run the suite,
audit test quality and logging, and fill the gaps that matter — flows, business
rules, happy paths and bad paths — in the project's existing style.

Coverage % is a **signal**, not the goal. Prefer fewer tests that lock in
domain behavior over many unit tests of trivial glue.

## Hard safety rule

This skill may **create or edit test files only**. It must **never** modify
production/source code, config, or CI. If a test can't pass without a source
change, report that as a finding for the human — don't "fix" the source to make
a test green. Confirm with the user before writing any test files.

## Workflow

### 1. Resolve the scope

Ask the user (or use what they already said) what to focus on:

- **Session** — files changed this session (`git diff --name-only HEAD` plus
  `git ls-files --others --exclude-standard`).
- **Whole repo**.
- **Domain / path** — a directory, module, or glob they name.

Coverage may be measured suite-wide, but **gap analysis and any new tests
target the chosen scope** (flows and rules touched by that scope).

### 2. Detect the test setup

Before running anything, learn the project's conventions — read
`references/checks/coverage-gaps.md` for how. Identify:

- The test framework and the **single command** to run tests (check
  `package.json` scripts, `Makefile`, `pyproject.toml`, `Rakefile`, CI config).
- The coverage tool and command for this stack (optional signal).
- Where tests live and how they're named (mirror this exactly when writing).
- The highest level the project already uses (request/handler/feature vs pure
  unit) — **prefer that level** for new tests.
- The existing **mocking style** (named fake classes vs inline stubs vs a
  library). New tests must match it.

If you can't find a test command, ask the user rather than guessing. **Do not
install new frameworks or heavy dependencies without asking.**

### 3. Run the suite + coverage

Run the project's command and capture results.

- If tests are **failing**, surface the failures first and ask whether to
  proceed — don't pile new tests onto a red suite silently.
- If the coverage tool isn't installed, ask before adding it.
- Record coverage numbers if available (overall and per-file for the scope) —
  use them to find gaps, not as a target to maximize.

### 4. Audit test quality and logging (parallel subagents)

Dispatch **two** subagents in one turn via the Task tool, each report-only:

```
Review ONE category over these files: <scope file list + their tests>.
Read your checklist: references/checks/<FILE>. Detect the language first.
This is REPORT-ONLY — do not edit anything. Return findings as a JSON array:
{ "file","line","severity":"high|medium|low","title","why","direction" }.
Return [] if nothing. Output only the JSON array.
```

- Test quality → `references/checks/test-quality.md`
- Logging → `references/checks/logging.md`

### 5. Find the behavior gaps

Using the coverage report (if any) + reading the scope, build a prioritized
list of what's untested. See `references/checks/coverage-gaps.md`. Order:

1. **Flows** — end-to-end or multi-layer paths in the domain (request →
   domain → persistence, or equivalent) with no scenario test.
2. **Business rules / invariants** — money, auth, permissions, state machines,
   eligibility — missing or only partially asserted.
3. **Happy path + bad paths** — for each critical rule, both success and
   failure/validation/edge cases.
4. **Regressions** — recent bug-fix commits with no guarding test.
5. **Pure unit glue** — getters, mappers, trivial branches — **do not write**
   unless the user explicitly asks.

### 6. Propose, confirm, then write the missing tests

Show the user the prioritized gap list and ask which to write (or "write all").
After they confirm, for each approved gap:

- Read `references/writing-tests.md` and follow it.
- Write at the **highest appropriate level** the project already uses.
- For each critical rule, include **happy path and at least one bad path**.
- Mock external I/O with **named fake classes** (or the project's style).
- Keep tests **F.I.R.S.T**.
- Run the new test(s). Iterate until green. If a test reveals a real bug in the
  source, **stop and report it** — don't edit the source to hide it.

### 7. Report

Write the report to `docs/audit/test-logging-YYYY-MM-DD_HH-MM.md` following
`references/report-template.md`, and print a short chat summary: suite result,
coverage before/after (if measured), tests added (flows/rules covered), and
counts of open quality/logging findings.
Write the report in the user's language (default **pt-BR**).

## Principles

- **Behavior over percentage.** A test that locks a business rule beats ten
  that only assert mocks or getters.
- **Match the project, don't reinvent it.** Same framework, layout, mocking.
- **Tests only.** Never touch source to make a test pass.
- **Confirm before writing.** Generated tests are code the user now owns.

## Scope notes

This skill covers behavior tests, coverage-as-signal, and logging audit. Magic
values, dead code, duplication, N+1, typing/readability, boundaries, and
secrets belong to `hygiene-review`.
