# Check: Duplication

Find repeated logic that should be extracted into a shared function, method, or
module. Duplication means a future change has to be made in several places, and
readers can't tell whether the copies are meant to be identical.

## What to flag

- **Copy-pasted blocks** — the same (or near-same) sequence of statements in two
  or more places, differing only in a value or two that could be a parameter.
- **Parallel structures** — functions/classes that are structurally identical
  with minor variations (e.g. one per type/status that could be data-driven).
- **Repeated literals-as-logic** — the same conditional or transformation
  expressed repeatedly (`x.strip().lower()` everywhere, the same validation
  inline in many handlers).
- **Duplicated knowledge** — the same business rule encoded in more than one
  spot (a discount calculation, a date format, a regex) that will drift apart.

## What is NOT worth flagging

- Coincidental similarity — two short blocks that look alike but represent
  genuinely different concepts that should evolve independently. Premature
  extraction couples things that shouldn't be coupled.
- Boilerplate the framework requires.
- Test setup that's clearer when explicit.

Apply the rule of three loosely: two copies *plus a clear shared intent* is
worth noting; near-identical large blocks are worth noting even at two.

## Severity

- **high** — large duplicated blocks, or a business rule duplicated across files
  (high drift risk).
- **medium** — a repeated mid-size block within a file or module.
- **low** — small repetitions where extraction is a judgment call.

## Reporting

When you flag duplication, list **all** locations involved (`file:line`) in the
`why` field so the reader sees the full set, even though the finding's primary
`file`/`line` points at the first occurrence.

## Direction examples

- "Three handlers repeat the same auth check — extract a `requireAdmin` guard."
- "`formatMoney` logic is inlined in 4 places; extract one helper."
