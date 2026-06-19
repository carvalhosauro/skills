# Writing Missing Tests

Read this before creating any test. The goal is tests that look like the project
wrote them, prove real behavior, and stay green.

## Non-negotiables

- **Test files only.** Never edit source/production code to make a test pass. If
  a test can't pass because the source is wrong, stop and report the bug.
- **Match the project.** Same framework, same test directory, same file naming
  (`*_test.go`, `*.spec.ts`, `test_*.py`, `*_spec.rb`, …), same import style.
- **Match the mocking style.** Mock external I/O (API, DB, filesystem, clock,
  randomness) with **named fake classes**, not inline one-off stubs — unless the
  project clearly uses a specific mocking library, in which case use that.

## What each test should do

1. Assert real behavior/outcome, not that "nothing threw" and not the mock.
2. Cover the path that was missing: prefer the **untested branch** (error case,
   boundary, edge) over re-testing the happy path that's already covered.
3. For a bug fix, write a **regression test** that fails against the old behavior
   and passes against the fix.
4. Keep it **F.I.R.S.T**: fast (no real I/O), independent (no shared mutable
   state, no order dependence), repeatable (inject a fixed clock/seed instead of
   real time/randomness), self-validating (a clear assertion), timely.

## Process

1. Pick one gap from the prioritized list.
2. Find a sibling test as a template for structure, imports, and fakes.
3. Write the test. Use Arrange–Act–Assert; one behavior per test; a descriptive
   name that states the scenario and expectation.
4. Run just that test. If red because of the test, fix the test. If red because
   of a real source defect, stop and report it as a finding.
5. Re-run the relevant suite to confirm nothing else broke.
6. Move to the next gap.

## Don't

- Don't chase 100% with trivial assertions on getters/generated code.
- Don't introduce a new test framework or assertion library.
- Don't write tests that depend on each other or on real external services.
- Don't weaken or skip an existing failing test to make the run green.

## After writing

List, in the report, every test file added/changed and the gap each one closes,
plus the coverage delta if available.
