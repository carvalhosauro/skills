# Check: Test Quality

Audit existing tests (and tests adjacent to the scope) for the properties that
keep a suite trustworthy and cheap to maintain. Report problems; don't rewrite.

## F.I.R.S.T

- **Fast** — flag tests that sleep, hit the real network/DB/filesystem, or do
  heavy unmocked I/O on a unit-test path.
- **Independent** — flag tests that depend on execution order, share mutable
  global/state between cases, or rely on another test having run first.
- **Repeatable** — flag tests that depend on real time/`now()`, randomness
  without a seed, timezone, locale, or external state — anything that makes them
  pass on one machine/run and fail on another.
- **Self-validating** — flag tests with no real assertion (only prints/logs), or
  that "pass" as long as nothing throws without asserting the outcome.
- **Timely** — flag obvious gaps where new logic shipped with no test (this
  overlaps with coverage; note it here when the *test* is the missing artifact).

## Mocking

- **Inline stubs / ad-hoc mocks** for external I/O where the project elsewhere
  uses named fake classes — flag the inconsistency. External I/O (API, DB,
  filesystem, clock) should be mocked via a **named fake** that reads clearly,
  not a one-off inline object.
- **Over-mocking** — tests that mock the very thing they claim to verify, so they
  assert the mock instead of behavior.
- **Under-mocking** — unit tests that quietly reach a real external service.

## Other smells

- **Assertion-free tests** or tests that only check "did not throw".
- **Mystery-guest** tests that depend on unexplained fixture files.
- **Giant tests** asserting many unrelated things — hard to read failures.
- **Conditional logic in tests** (`if`/loops) that can skip the assertion.
- **Bug fix without a regression test** — a fix in the scope with no test that
  would have caught the original bug.
- **No single run command** — the suite can't be run with one documented command.

## What is NOT worth flagging

- Integration/e2e tests that legitimately use real I/O and are labeled as such.
- Snapshot tests where snapshots are the intended mechanism.
- Slightly long tests that read clearly and assert one behavior.

## Severity

- **high** — flaky/order-dependent tests, assertion-free tests, a bug fix with
  no regression test.
- **medium** — inconsistent mocking, under/over-mocking, giant multi-assert tests.
- **low** — stylistic mismatches, mild slowness.

## Direction examples

- "Seed the RNG (or inject a fixed clock) so `calculatesRefund` is repeatable."
- "Replace the inline `{ get: () => ... }` stub with the project's `FakeHttp`."
- "Add a regression test reproducing issue #482 before considering the fix done."
