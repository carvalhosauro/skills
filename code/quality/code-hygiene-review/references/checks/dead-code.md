# Check: Dead Code

Find code that no longer runs or is never referenced. Dead code makes files
longer, hides intent, and tricks the next reader into maintaining something that
doesn't matter.

## What to flag

- **Unused symbols** — functions, methods, classes, variables, or constants that
  are defined but never referenced within the scope (and not exported/public as
  part of an API).
- **Unused imports / requires** — imported but never used.
- **Unreachable code** — statements after a `return`/`throw`/`break`, branches
  that can never be true, code behind `if (false)` or a constant condition.
- **Commented-out code** — blocks of real code left as comments "just in case".
  Version control already remembers it.
- **Dead parameters** — function params that are never read.
- **Redundant branches** — `else` after a guard that already returned, duplicated
  conditions, `if x: return true else: return false`.

## Be careful (lower confidence → mark `low`, note the doubt)

- Symbols that are **exported / public** may be used outside the reviewed scope.
  When scope is "session" or a single path, you can't see the whole repo — say
  "possibly unused; verify across the codebase" instead of asserting it's dead.
- Reflection, dynamic dispatch, dependency-injection registration, framework
  hooks, and string-based lookups can use code that looks unreferenced.
- Public API surface, plugin entry points, and test helpers.

## Severity

- **high** — unreachable code or a clearly dead private function/branch.
- **medium** — unused imports/variables/params with no dynamic-use risk.
- **low** — possibly-unused public symbols, or anything you can't confirm in
  the given scope.

## Direction examples

- "Remove the unreachable block after the early `return`."
- "Drop the unused `legacyFormat` import."
- "`buildLabel` looks unreferenced in this scope — confirm repo-wide, then remove."
