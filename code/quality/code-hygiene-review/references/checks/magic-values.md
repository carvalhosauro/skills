# Check: Magic Values

Find literal values that carry meaning but appear "raw" in the code, where a
named constant, enum, or config would make intent obvious.

## What to flag

- **Magic numbers** — numeric literals whose meaning isn't self-evident:
  `* 86400`, `if retries > 3`, `status == 2`, `price * 1.0825`, `timeout = 30000`.
  A named constant (`SECONDS_PER_DAY`, `MAX_RETRIES`, `TAX_RATE`) explains *why*.
- **Magic strings** — string literals used as keys, statuses, types, or
  routes that repeat or encode meaning: `if role == "admin"`, `state = "PENDING"`,
  `event.type === "checkout.completed"`. Prefer enums/constants.
- **Repeated literals** — the *same* literal appearing in multiple places is a
  strong signal: a single change now means hunting every copy.
- **Embedded config** — URLs, file paths, ports, table/collection names, feature
  flags hardcoded inline instead of pulled from config/constants.

## What is NOT a magic value (don't flag)

- `0`, `1`, `-1`, `2`, empty string/array used in obvious idioms (loop bounds,
  index math, first/last, boolean-ish toggles).
- Literals already adjacent to a clear name: `const TAX_RATE = 0.0825`.
- Values in tests/fixtures where the literal *is* the point of the test.
- Format strings, log messages, and user-facing copy (unless duplicated widely).

## Severity

- **high** — a repeated meaningful literal, or one controlling money, security,
  retries/limits, or external identifiers.
- **medium** — a single non-obvious literal in business logic.
- **low** — a borderline literal where a name would help but isn't critical.

## Direction examples

- "Extract `0.0825` into a named `TAX_RATE` constant."
- "Replace the `\"PENDING\"` string with a `Status` enum used across the module."
