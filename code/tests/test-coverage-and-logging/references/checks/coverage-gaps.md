# Check: Coverage Gaps (setup detection + measuring + prioritizing)

This file covers three jobs: detecting how the project runs tests/coverage,
running it, and turning the result into a prioritized gap list.

## 1. Detect the setup (do this before running anything)

Look, in order, for the project's own conventions — prefer them over generic
commands:

- **JS/TS** — `package.json` `scripts.test` / `scripts.coverage`. Frameworks:
  Jest (`jest --coverage`), Vitest (`vitest run --coverage`). Tests usually
  `*.test.ts` / `*.spec.ts` next to source or under `__tests__/`.
- **Python** — `pyproject.toml` / `tox.ini` / `pytest.ini`. Pytest with coverage:
  `pytest --cov=<package> --cov-report=term-missing` (needs `pytest-cov`).
  Tests under `tests/` named `test_*.py`.
- **Ruby** — `Rakefile`, `.rspec`. RSpec + SimpleCov (coverage emitted to
  `coverage/`). Tests under `spec/` named `*_spec.rb`.
- **Go** — `go test ./... -cover` or `-coverprofile=cover.out` then
  `go tool cover`. Tests are `*_test.go` beside source.
- **Java/Kotlin** — Maven/Gradle + JaCoCo (`mvn test`, `gradle test jacocoTestReport`).
- **PHP** — PHPUnit + Xdebug/PCOV. **Rust** — `cargo test` + `cargo llvm-cov`.

Also detect: the **single run command**, the test **directory + naming**, and
the existing **mocking style** (named fakes? a library like `unittest.mock`,
`sinon`, `rspec-mocks`?). New tests must mirror all three.

If none of this is discoverable, ask the user for the command instead of guessing.

## 2. Run it

Run the detected command. Capture pass/fail and the coverage report. If the
coverage tool is missing, ask before installing it. If the suite is red, report
failures first.

## 3. Prioritize the gaps (within the chosen scope)

Don't dump every uncovered line. Rank by risk to readability/correctness:

1. **No test at all** for a new/changed function in scope — top priority.
2. **Uncovered branches** in high-stakes logic: money, auth/permissions, error
   handling, retries, boundary/edge conditions.
3. **Bug-fix commits with no regression test** — inspect recent commit messages
   in scope (`fix`, issue refs) and check whether a guarding test exists.
4. **Partially covered functions** where the happy path is tested but failure
   paths aren't.

Deprioritize (often fine to leave): trivial getters/setters/constructors,
generated code, framework boilerplate, pure config, simple pass-through glue.

## Output of this analysis

A prioritized list, each item: `file:function`, what's uncovered (no test / which
branch), risk level, and a one-line note on what a test should assert. This list
feeds step 6 of the workflow (propose → confirm → write).
