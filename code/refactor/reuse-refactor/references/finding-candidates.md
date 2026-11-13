# Finding candidates

The seed is what the branch added; the search space is the whole repo. For each new function,
component, hook, query, validation, formatter or repeated block in the seed, walk this ladder and
stop at the first rung with a concrete replacement:

1. **Already in the repo:** a helper, component, hook, service, query, constant or validation.
2. **Duplicated inside the seed** itself.
3. **Standard library or platform** feature.
4. **An installed dependency** (`package.json`, `composer.json`, `pyproject.toml` or
   `requirements*.txt`, `go.mod`).
5. **A mature library that is not installed:** never install it. It goes under "Sugestões".

## Search moves

- **Names:** grep the verb and noun and their synonyms (`format`, `fmt`, `toMoney`; `unique`,
  `dedupe`, `distinct`).
- **Distinctive literals:** format options, regexes, magic numbers, date formats, endpoint paths,
  table and column names, error messages.
- **Shape:** same parameters and return type, same sequence of calls, same JSX tree and props.
- **Where shared code lives:**

| Stack | Look in | Platform first |
|---|---|---|
| TS / React | `packages/ui`, `components/`, `hooks/use*`, `lib/`, `utils/`, the project's `cx`/`clsx` | `Intl`, `URL`, `structuredClone`, `Set`/`Map`, array methods, `Object.groupBy`, Web APIs |
| PHP | `Helpers/`, `Services/`, traits, base classes, model scopes | framework helpers (Laravel `Str`, `Arr`, `collect`, Carbon), `array_*`, `str_*`, `filter_var`, `DateTimeImmutable` |
| Python | `utils/`, `common/`, `core/` | `itertools`, `functools`, `collections`, `pathlib`, `dataclasses`, `zoneinfo` |
| Go | `internal/`, `pkg/` | `slices`, `maps`, `strings`, `strconv`, `time`, `errors` |

## Not a candidate

- **Look-alikes with a different business meaning:** two fees with different values, two statuses
  that happen to share a rule. They evolve apart; merging couples them. A shared literal (the same
  threshold) is not proof of a shared rule.
- **A replacement whose output differs for an input the code accepts:** formatting, rounding, time zones and
  daylight saving, ordering, duplicates, error type or message, null handling. It goes under
  "Sugestões" with the difference named.
- Framework boilerplate, generated code, migrations, test setup.
- A replacement that needs a new dependency.
- Files from another task.

## Ranking

Net lines removed from the seed (removed minus added), biggest first. Ties: fewer callers first.
Keep at most 5.
