# Check: Coverage Gaps (setup detection + measuring + prioritizing)

This file covers three jobs: detecting how the project runs tests/coverage,
running it, and turning the result into a prioritized **behavior** gap list.

## 1. Detect the setup (do this before running anything)

Look, in order, for the project's own conventions — prefer them over generic
commands:

- **JS/TS** — `package.json` `scripts.test` / `scripts.coverage`. Frameworks:
  Jest (`jest --coverage`), Vitest (`vitest run --coverage`). Tests usually
  `*.test.ts` / `*.spec.ts` next to source or under `__tests__/`. Note whether
  the suite is mostly unit, request/handler, or Playwright/Cypress.
- **Python** — `pyproject.toml` / `tox.ini` / `pytest.ini`. Pytest with coverage:
  `pytest --cov=<package> --cov-report=term-missing` (needs `pytest-cov`).
  Tests under `tests/` named `test_*.py`.
- **Ruby** — `Rakefile`, `.rspec`. RSpec + SimpleCov (coverage emitted to
  `coverage/`). Tests under `spec/` named `*_spec.rb`. Prefer request/feature
  specs when the project already has them.
- **Go** — `go test ./... -cover` or `-coverprofile=cover.out` then
  `go tool cover`. Tests are `*_test.go` beside source.
- **Java/Kotlin** — Maven/Gradle + JaCoCo (`mvn test`, `gradle test jacocoTestReport`).
- **PHP** — PHPUnit + Xdebug/PCOV. **Rust** — `cargo test` + `cargo llvm-cov`.

Also detect: the **single run command**, the test **directory + naming**, the
**highest test level in use**, and the existing **mocking style**. New tests
must mirror all of these.

If none of this is discoverable, ask the user for the command instead of guessing.

## 2. Run it

Run the detected command. Capture pass/fail and the coverage report. If the
coverage tool is missing, ask before installing it. If the suite is red, report
failures first. Treat coverage as a map of cold spots, not a score to maximize.

## 3. Prioritize the gaps (within the chosen scope)

Don't dump every uncovered line. Rank by risk to **correct business behavior**:

1. **Untested flows** — multi-step or multi-layer paths in scope (API → domain →
   store, job pipeline, UI action → effect) with no scenario/integration test.
2. **Business rules / invariants** — money, auth/permissions, state transitions,
   eligibility, quotas — missing assertions or only mocked away.
3. **Happy + bad paths** — happy path tested but validation errors, forbidden
   states, empty inputs, or edge branches are not (or the reverse).
4. **Bug-fix commits with no regression test** — inspect recent commits in
   scope (`fix`, issue refs) and check for a guarding test.
5. **Trivial unit glue** — getters, setters, pure mappers, generated code —
   **deprioritize; usually do not propose writing these**.

Within equal rank, prefer new/changed code in the session scope.

## Output of this analysis

A prioritized list, each item: flow or rule name, `file`s involved, what's
missing (no flow test / no bad path / which branch), risk level, and a one-line
note on what the test should assert (happy and/or bad path). This list feeds
step 6 of the workflow (propose → confirm → write).
