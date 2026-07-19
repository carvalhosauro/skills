# Check: Test Quality

Audit existing tests (and tests adjacent to the scope) for trustworthiness and
whether they protect **behavior** — not just that mocks were called. Report
problems; don't rewrite.

## Behavior vs theater

- **Flag tests that don't exercise a rule or flow** — they only assert a mock
  was invoked, a spy count, or that a trivial getter returned a stub.
- **Flag happy-path-only suites** for critical rules that have no bad-path /
  validation / error case.
- **Flag over-narrow unit tests** where the project already has (or clearly
  needs) a request/handler/feature test for the same behavior — note that the
  gap belongs one level up.

## F.I.R.S.T

- **Fast** — flag tests that sleep, hit the real network/DB/filesystem, or do
  heavy unmocked I/O on a path labeled as unit.
- **Independent** — flag tests that depend on execution order, share mutable
  global/state between cases, or rely on another test having run first.
- **Repeatable** — flag tests that depend on real time/`now()`, randomness
  without a seed, timezone, locale, or external state.
- **Self-validating** — flag tests with no real assertion (only prints/logs), or
  that "pass" as long as nothing throws without asserting the outcome.
- **Timely** — flag new logic/flows shipped with no behavior test.

## Mocking

- **Inline stubs / ad-hoc mocks** for external I/O where the project elsewhere
  uses named fake classes — flag the inconsistency.
- **Over-mocking** — tests that mock the unit under test's collaborators so
  thoroughly that no business rule is left to fail.
- **Under-mocking** — "unit" tests that quietly reach a real external service.

## Other smells

- **Assertion-free tests** or tests that only check "did not throw".
- **Mystery-guest** tests that depend on unexplained fixture files.
- **Giant tests** asserting many unrelated flows — hard to read failures.
- **Conditional logic in tests** (`if`/loops) that can skip the assertion.
- **Bug fix without a regression test**.
- **No single run command** — the suite can't be run with one documented command.

## What is NOT worth flagging

- Integration/e2e/request tests that legitimately use real I/O and are labeled
  as such — these are often *preferred* for flows.
- Snapshot tests where snapshots are the intended mechanism.
- Slightly long scenario tests that read clearly and assert one flow.

## Severity

- **high** — flaky/order-dependent tests; assertion-free tests; critical rule
  with no behavior test; bug fix with no regression test.
- **medium** — happy-path-only for a critical rule; over-mocking that hides
  behavior; inconsistent mocking.
- **low** — stylistic mismatches, mild slowness, redundant trivial units.

## Direction examples

- "Add a bad-path case: invalid status transition should return 422 / domain error."
- "Replace spy-only assertions with an assert on the persisted order state."
- "Lift this to a request spec — the rule spans handler + policy."
- "Seed the RNG (or inject a fixed clock) so `calculatesRefund` is repeatable."
