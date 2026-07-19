# Check: N+1 Queries

Find places that issue one query per item in a loop instead of one batched
query. N+1s are invisible in small datasets and quietly destroy performance in
production.

## Applicability — check this FIRST

This category only applies to code that talks to a database or ORM. If the file
has no DB/ORM access, return a single note that N+1 is **not applicable** to it
rather than forcing findings.

Recognize the stack, e.g.:
- **Rails / ActiveRecord** — `.each` then accessing an association; missing
  `includes` / `preload` / `eager_load`.
- **Django ORM** — looping a queryset and touching related objects without
  `select_related` / `prefetch_related`.
- **SQLAlchemy** — lazy-loaded relationships accessed in a loop; missing
  `joinedload` / `selectinload`.
- **Prisma / TypeORM / Sequelize / Eloquent** — querying inside `map`/`for`
  instead of `include` / eager loading / `whereIn`.
- **Raw SQL** — a query executed inside a loop keyed on the loop variable.

## What to flag

- A query (or association access that triggers a query) **inside a loop** over a
  prior result set.
- `await`-ing a per-item DB call inside `for`/`map`/`forEach`.
- Counting/summing per parent in a loop instead of an aggregate query.
- A serializer/view that lazily loads relations for each record in a collection.

## What is NOT an N+1

- A loop over an in-memory collection with no DB call inside.
- A single batched query (already uses eager loading / `IN (...)`).
- A deliberate, bounded single fetch (one record, not a per-item loop).

## Severity

- **high** — N+1 over an unbounded/user-controlled collection on a hot path.
- **medium** — N+1 over a small or bounded collection, or off a hot path.
- **low** — suspected N+1 you can't fully confirm from the code alone (note it).

## Direction examples

- "Add `includes(:author)` before the `.each` to avoid a query per post."
- "Replace the per-item `findUser` inside `map` with a single `whereIn` batch."
