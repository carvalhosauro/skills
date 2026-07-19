# Check: General Readability

Find the structural and naming smells that make code harder to read, even when
it works. These thresholds are guidelines, not lint rules — flag a violation
when it genuinely hurts clarity, not just because a number is exceeded by one.

## Function & file size

- **Functions over ~20 lines** that do more than one thing — candidates to split.
  (Very short functions, 4–20 lines, are the comfortable range.)
- **Files over ~500 lines** — likely holding multiple responsibilities; suggest
  splitting by responsibility.

## Single Responsibility

- A function doing several unrelated things (fetch + transform + format + log in
  one body). One thing per function.
- A module/class mixing unrelated responsibilities. One responsibility per module.

## Naming

- **Vague names** — `data`, `info`, `handler`, `manager`, `process`, `tmp`,
  `obj`, `result`, `doStuff`. Names should say what the thing *is* or *does*.
- **Non-specific names** — a name so generic it would return many grep hits and
  identify nothing. Prefer names specific enough to be near-unique in the
  codebase (a rough heuristic: fewer than ~5 grep hits).
- **Misleading names** — a name that says one thing while the code does another.

## Control flow

- **Deep nesting** — more than ~2 levels of indentation in a function. Suggest
  guard clauses / early returns to flatten it.
- **`else` after a returning guard**, arrow-shaped code, long `if/elif` ladders
  that would read better as a lookup or early returns.

## Exception messages

- Errors raised/thrown with a vague message (`"invalid input"`, `"error"`).
  A good message includes **the offending value and the expected shape**, e.g.
  `"expected status in [open, closed], got 'archive'"`. Flag messages that would
  leave a debugger guessing.

## Comments

- **WHAT-comments** restating the code (`// increment counter` over `i++`) — noise.
- **Missing WHY** — non-obvious code (a workaround, an ordering constraint, a
  magic tolerance) with no comment explaining *why* it's like that.
- **Comments stripped on refactor** — if a block clearly lost its explanatory
  comment during edits (intent/provenance gone), note it.
- **Missing docstring on public functions** — public/exported functions without
  a short intent + usage note.
- A comment that **references a bug/constraint** (issue number, commit SHA) is
  good — never flag those for removal.

## What is NOT worth flagging

- A 25-line function that genuinely does one cohesive thing and reads cleanly.
- Established domain names that are short but well-understood in the project.
- Self-explanatory code that needs no comment.

## Severity

- **high** — a long multi-responsibility function, a deeply nested tangle, or a
  misleading name in core logic.
- **medium** — vague naming, missing WHY on tricky code, weak exception messages.
- **low** — slightly-long functions, minor nesting, missing docstrings.

## Direction examples

- "Split `processOrder` (60 lines) — it validates, charges, and emails; extract each."
- "Rename `data` to `invoiceLines`; `data` is too generic to grep."
- "Flatten the 4-level nesting with early returns for the error cases."
- "Add the offending value to the `ValueError` message so failures are debuggable."
