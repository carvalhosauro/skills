# Check: Boundaries (I/O, HTTP, DB)

Find missing or weak guards where the process talks to the outside world —
HTTP clients/servers, DB, queues, filesystem, third-party SDKs.

## What to flag

- **No timeouts** — outbound HTTP/DB/RPC calls without an explicit timeout (or
  using an unbounded default).
- **Unbounded retries** — retries without backoff, jitter, or a max attempt
  count; retrying non-idempotent writes blindly.
- **Unvalidated input at the edge** — request bodies, query params, webhook
  payloads, or file uploads used before schema/type validation.
- **Trusting external shape** — indexing into JSON/`map` from an external
  response without checking required fields or handling partial payloads.
- **Missing idempotency / duplicate guards** on write endpoints that can be
  retried by clients or brokers.
- **Leaky boundaries** — raw driver/ORM errors or internal models returned
  straight to HTTP clients without mapping.

## What is NOT worth flagging

- Internal in-process calls that are not network I/O.
- Framework middleware that already enforces timeouts/validation for the route
  (note "covered by framework" rather than inventing a finding).
- Scripts under `experimental/` or one-off migrations the user marked throwaway.

## Severity

- **high** — production request path with no timeout; unvalidated input that
  reaches auth, money, or destructive writes.
- **medium** — missing validation on less critical endpoints; retries without
  backoff on reads.
- **low** — missing timeout on a rare admin tool; minor mapping inconsistency.

## Direction examples

- "Set an explicit client timeout (e.g. 5s) on this outbound HTTP call."
- "Validate the webhook body against a schema before touching the DB."
- "Cap retries (e.g. 3) with exponential backoff; don't retry non-idempotent POSTs."
