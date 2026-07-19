# Check: Error Handling

Find places where failures are swallowed, stripped of context, or reported in a
way that makes debugging or recovery harder.

## What to flag

- **Swallowed errors** — empty `catch`/`except`/`rescue`, or a catch that only
  logs nothing / returns a default with no signal that something failed.
- **Lost context** — rethrow/wrap that drops the original cause, stack, or
  identifying ids (order id, user id, request id).
- **Vague messages** — `"something went wrong"`, `"error"`, `"failed"` with no
  what/where/why; messages that won't help the next reader or operator.
- **Wrong level** — catching too broadly (`catch (Exception)` / `except Exception`)
  around logic that should let programming errors bubble; or catching a narrow
  type and then ignoring it.
- **Silent fallbacks** — falling back to a default value on error without
  logging or surfacing the failure when the caller needed to know.
- **Inconsistent patterns** — mixed return-error vs throw vs Result types in the
  same module without a clear boundary.

## What is NOT worth flagging

- Intentional ignore of a known-benign error with a one-line comment explaining
  why (e.g. best-effort cache invalidate).
- Framework-required catch blocks that rethrow or map to a typed domain error.
- User-facing copy that is intentionally short *if* the structured log/error
  object still carries detail.

## Severity

- **high** — swallowed errors on money/auth/data-loss paths; lost cause on
  production failure paths.
- **medium** — vague messages or broad catches in non-critical paths.
- **low** — stylistic inconsistency where behavior is still clear.

## Direction examples

- "Don't empty-catch here — log with order id and rethrow or return a typed error."
- "Wrap with `cause=` / `%w` so the original stack isn't lost."
- "Replace `'error'` with a message that names the operation and the entity id."
