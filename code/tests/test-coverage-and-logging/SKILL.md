---
name: test-coverage-and-logging
description: >-
  Runs the project's test suite, measures coverage, audits test quality and
  logging practices, and writes the missing tests it finds — following the
  project's own framework and conventions. Use this skill after a coding
  session, before a PR, or whenever the user asks to "run the tests", "check
  coverage", "what's untested", "add tests for this", "write tests", "improve
  test coverage", "audit the tests", "fix the logging", or "is this logged
  properly". It is the testing/logging counterpart to a readability hygiene
  review. Trigger it even when the user doesn't say "skill" — any request about
  test coverage, missing tests, test quality, or logging hygiene should use this.
---

# Test Coverage & Logging

Strengthen a codebase's safety net: run the suite, measure coverage, audit test
quality and logging, and fill the most important test gaps — in the project's
existing style.

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

Coverage is measured suite-wide regardless, but **gap analysis and any new tests
target the chosen scope** (e.g. only functions changed this session).

### 2. Detect the test setup

Before running anything, learn the project's conventions — read
`references/checks/coverage-gaps.md` for how. Identify:

- The test framework and the **single command** to run tests (check
  `package.json` scripts, `Makefile`, `pyproject.toml`, `Rakefile`, CI config).
- The coverage tool and command for this stack.
- Where tests live and how they're named (mirror this exactly when writing).
- The existing **mocking style** (named fake classes vs inline stubs vs a
  library). New tests must match it.

If you can't find a test command or coverage tool, ask the user rather than
guessing. **Do not install new frameworks or heavy dependencies without asking.**

### 3. Run the suite + coverage

Run the project's command and capture results.

- If tests are **failing**, surface the failures first and ask whether to
  proceed — don't pile new tests onto a red suite silently.
- If the coverage tool isn't installed, ask before adding it.
- Record the coverage numbers (overall and, if available, per-file for the
  scope).

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

### 5. Find the coverage gaps

Using the coverage report + the scope, build a prioritized list of what's
untested. See `references/checks/coverage-gaps.md` for prioritization. Roughly:

1. New/changed functions in scope with **no test at all** (highest).
2. Uncovered **branches** in logic that handles money, auth, errors, edge cases.
3. Recent bug-fix commits with **no regression test**.
4. Lower priority: trivial getters/setters, generated code, glue with no logic
   (often fine to leave uncovered — don't chase 100%).

### 6. Propose, confirm, then write the missing tests

Show the user the prioritized gap list and ask which to write (or "write all").
After they confirm, for each approved gap:

- Read `references/writing-tests.md` and follow it.
- Write the test in the project's framework, file location, and naming.
- Mock external I/O (API, DB, filesystem) with **named fake classes**, not
  inline stubs — matching the project's style.
- Keep tests **F.I.R.S.T**: fast, independent, repeatable, self-validating, timely.
- Run the new test(s). Iterate until green. If a test reveals a real bug in the
  source, **stop and report it** — don't edit the source to hide it.

### 7. Report

Write the report to `docs/audit/test-logging-YYYY-MM-DD_HH-MM.md` following
`references/report-template.md`, and print a short chat summary: suite result,
coverage before/after, tests added, and counts of open quality/logging findings.
Write the report in the user's language (default **pt-BR**).

## Principles

- **Match the project, don't reinvent it.** Same framework, same layout, same
  mocking style. A test that looks foreign is a maintenance burden.
- **Tests only.** Never touch source to make a test pass. A failing test that
  exposes a bug is a *finding*, not something to paper over.
- **Coverage is a signal, not a target.** Meaningful tests on real logic and
  branches beat a high percentage padded with trivial assertions.
- **Confirm before writing.** Generated tests are code the user now owns; let
  them choose what gets added.

## Scope notes

This skill covers tests, coverage, and logging. Magic values, dead code,
duplication, N+1, and typing/readability belong to the separate
`code-hygiene-review` skill. Dependency injection and project structure are
intentionally out of scope here.
