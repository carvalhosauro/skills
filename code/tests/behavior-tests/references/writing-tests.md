# Writing Missing Tests

Read this before creating any test. The goal is tests that look like the project
wrote them, prove real **flows and business rules**, and stay green.

## Non-negotiables

- **Test files only.** Never edit source/production code to make a test pass. If
  a test can't pass because the source is wrong, stop and report the bug.
- **Match the project.** Same framework, same test directory, same file naming
  (`*_test.go`, `*.spec.ts`, `test_*.py`, `*_spec.rb`, …), same import style.
- **Prefer the highest level already in use** — request/handler/feature/
  integration over pure unit when the gap is a flow or cross-layer rule.
- **Match the mocking style.** Mock external I/O (API, DB, filesystem, clock,
  randomness) with **named fake classes**, not inline one-off stubs — unless the
  project clearly uses a specific mocking library, in which case use that.

## What each test should do

1. Assert real behavior/outcome (state change, response, invariant) — not that
   "nothing threw" and not only that a mock was called.
2. For each critical rule you add: **happy path + at least one bad path**
   (validation failure, forbidden state, missing auth, empty input, etc.).
3. Prefer the **untested flow or branch** over re-testing a happy path that
   already has a solid scenario test.
4. For a bug fix, write a **regression test** that fails against the old
   behavior and passes against the fix.
5. Keep it **F.I.R.S.T**: fast enough for the chosen level, independent,
   repeatable (fixed clock/seed), self-validating, timely.

## Process

1. Pick one gap from the prioritized list (flows/rules first).
2. Find a sibling test at the same level as a template for structure and fakes.
3. Write the test. Use Arrange–Act–Assert; one behavior (or one path) per test;
   a descriptive name that states scenario and expectation.
4. Run just that test. If red because of the test, fix the test. If red because
   of a real source defect, stop and report it as a finding.
5. Re-run the relevant suite to confirm nothing else broke.
6. Move to the next gap.

## Don't

- Don't chase 100% with trivial assertions on getters/generated code.
- Don't introduce a new test framework or assertion library.
- Don't write pure unit tests for glue when a flow/rule test would cover it.
- Don't write tests that depend on each other or on real external services
  (unless the project already runs true integration tests that way — then match).
- Don't weaken or skip an existing failing test to make the run green.

## After writing

List, in the report, every test file added/changed, the flow/rule and path
(happy/bad) each one closes, plus the coverage delta if available.
