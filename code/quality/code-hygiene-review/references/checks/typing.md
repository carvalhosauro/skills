# Check: Typing

Find missing or evasive type information. Explicit types document intent, catch
errors early, and let the reader understand a function without running it.

## Applicability

Adjust to the language. For dynamically typed languages without an adopted type
system, flag only where the project clearly uses types elsewhere (don't demand
type hints in a codebase that has none). If the language has no meaningful type
story for a file, say so rather than inventing findings.

Per-language signals:
- **TypeScript** — `any` (explicit or implicit), missing return types on
  exported functions, `as any` casts, untyped function params, `object`/`{}`
  where a real shape exists, untyped `catch` used as `any`.
- **Python** — functions without type hints (params and return) in a codebase
  that otherwise uses them; bare `dict`/`list`/`Dict`/`List` where a concrete
  shape or `TypedDict`/`dataclass`/`pydantic` model fits; `Any` as an escape hatch.
- **Ruby** — when Sorbet/RBS is in use: missing `sig`s on public methods,
  `T.untyped`. If no type system is adopted, skip.
- **Go / Rust / Java / C#** — `interface{}`/`any`/`object`/`dynamic` where a
  concrete type is known; unnecessary type erasure.

## What to flag

- Explicit `any` / `Dict` / `interface{}` used to dodge typing.
- Public/exported functions missing parameter or return types.
- Implicit `any` from absent annotations where the tooling would otherwise infer
  nothing useful.
- A typed value passed through an untyped boundary that loses its shape.

## What is NOT worth flagging

- Genuinely dynamic data at a true boundary (e.g. raw JSON before validation) —
  flag only if it's never narrowed afterward.
- Local variables where inference is clear and correct.
- Test scaffolding, unless the project types its tests.

## Severity

- **high** — `any`/untyped on a public API or on data that flows widely.
- **medium** — missing types on internal functions in a typed codebase.
- **low** — local or borderline cases.

## Direction examples

- "Give `parseEvent` an explicit return type instead of inferring `any`."
- "Replace `data: dict` with a `TypedDict` describing the expected keys."
