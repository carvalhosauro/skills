# Check: Secrets and Config

Find secrets, credentials, and environment-specific config embedded in source
where they don't belong — or config values treated as magic in business logic.

## What to flag

- **Hardcoded secrets** — API keys, tokens, passwords, private keys, webhook
  secrets, connection strings with credentials in source or committed samples.
- **Secrets in logs / errors** — printing Authorization headers, cookies, or
  full connection URLs that include passwords.
- **Environment URLs / hosts inline** — production/staging hosts, account ids,
  or region names hardcoded in business logic instead of config/env.
- **Config buried in logic** — feature flags, limits, and toggles scattered as
  literals deep in functions rather than named config near the boundary.
- **Committed `.env` or credential files** in the changed scope (when clearly
  not an example/`*.example`).

## What is NOT worth flagging

- Public client ids / publishable keys that the platform documents as public
  (still prefer config over scattering).
- Test fixtures that use obvious fake secrets (`test-key`, `sk_test_…` in test
  dirs) when clearly fake.
- Literals already loaded once from `os.Getenv` / config at the edge and passed
  in — flag the *hardcode*, not legitimate injection.

## Severity

- **high** — real-looking credentials or private keys in source; secrets in logs
  on a hot path.
- **medium** — production hostnames or account ids hardcoded; config literals
  deep in domain logic.
- **low** — mild config scattering that doesn't risk exposure.

## Direction examples

- "Move the API key to env/secret manager; reference it at the composition root."
- "Redact Authorization before logging the outbound request."
- "Pull the base URL from config instead of hardcoding `https://api.prod…`."
