# Check: Logging

Audit logging for observability and hygiene. Good logs make production
debuggable; bad logs leak data, hide failures, or drown signal in noise.

## Structured vs plain

- **Debug/observability logs should be structured** (JSON or key-value), so they
  can be queried and correlated — flag free-text logs in service/library code
  that bury the useful fields in a sentence (`log.info("user " + id + " did X")`
  → structured `{event, user_id}`).
- **Plain text is only for user-facing CLI output.** Flag structured-JSON noise
  printed to a human at a terminal, and flag CLI tools that emit raw JSON where a
  readable line is expected.

## Stray / debug logging

- **`print` / `console.log` / `puts` / `fmt.Println` left in** non-CLI code as
  ad-hoc debugging — should be a real log call or removed.
- **Commented-out log lines** left behind.
- **`log.debug` spam** on hot paths that will flood production.

## Levels

- **Wrong level** — errors logged at `info`, routine events logged at `error`,
  everything at one level. Flag misuse that would make alerting useless.
- **Swallowed errors** — an exception caught and logged at `debug`/not at all,
  so failures vanish silently.

## Sensitive data (high severity)

- Logging **secrets, passwords, tokens, API keys, full card numbers, PII** (raw
  emails, national IDs, auth headers, request bodies with credentials). This is
  a security/compliance issue — always `high`.

## Missing logs

- No log at an important boundary: a caught-and-handled failure, a retry, an
  external call that fails, a security-relevant action — where the absence would
  make an incident hard to diagnose.

## What is NOT worth flagging

- Deliberate user-facing CLI prints.
- Test output. Framework-managed request logging.
- A reasonable amount of structured info logging.

## Severity

- **high** — sensitive data in logs; swallowed errors that hide failures.
- **medium** — unstructured logs in service code, wrong levels, stray
  `print`/`console.log` in production paths.
- **low** — minor noise, commented-out log lines, debug spam off hot paths.

## Direction examples

- "Redact the auth token — it's being logged in the request dump (security)."
- "Convert this free-text `log.info` to structured fields (`event`, `order_id`)."
- "Remove the leftover `console.log(user)` in the checkout handler."
- "This `catch` logs at debug and continues — failures disappear; log at error."
