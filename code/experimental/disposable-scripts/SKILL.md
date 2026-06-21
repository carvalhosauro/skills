---
name: disposable-scripts
description: >-
  Use when you need to answer a quick technical question by running something — does this
  route/endpoint work, which of two approaches is faster, does this change actually have an
  effect, what does this API really return — and the answer matters but the code does not.
  Triggers: probing an API route with curl, benchmarking two implementations, a one-off
  sanity check or spike, "let me quickly test", "which is faster", "is the endpoint up",
  throwaway / scratch / experimental script. NOT for code that ships or gets reused.
---

# Disposable Scripts

## Overview

The deliverable is the **answer, not the code**. When a question can be settled by running something ("does this route 200?", "is approach A faster than B?"), write the cheapest script that produces a trustworthy answer, run it, record the answer, and throw the script away. The script is scaffolding; the report is the artifact.

**Optimize for time-to-answer, not for quality of code.** Polishing a script you will run once and delete is wasted work.

## When to use

- One-off API probes: hit a route with curl, see the status/body/headers.
- Micro-benchmarks: compare two implementations / queries / configs.
- Spikes: "does this even work?" before committing to a real implementation.
- Any throwaway check where the output is the point.

**When NOT to use:** anything that ships, gets imported, runs in CI, or that someone else will read and reuse. That's real code — write it properly elsewhere.

## Workflow

1. **State the question in one line.** The script exists to answer exactly this and nothing more.
2. **Put it in `experimental/`.** Create the dir and ensure it's gitignored (see Disposability). All scripts live here.
3. **Write the smallest script that answers it.** Hardcode everything. Pick the fastest tool for the job: `bash`+`curl`/`jq` for routes, `python` or `hyperfine` for benchmarks.
4. **Run it and capture the raw output.**
5. **Make the *answer* trustworthy — not the code pretty.** If the result is noisy or ambiguous, fix the measurement (warm up, more reps, isolate variables), not the style.
6. **Write the report** to `docs/experimental/<topic>.md` (template below).
7. **Leave the script in `experimental/`** (gitignored) for re-runs. The report is what survives.

## Disposability (the discipline)

Your instinct will be to make it clean. Resist it. For a single-use script:

- **Hardcode everything** — URLs, payloads, paths, counts. No args, no flags, no config, no env parsing.
- **No abstractions** — no functions/classes unless they genuinely cut total effort. No error handling beyond what you need to trust the result.
- **One file.** No project, no deps file, no README.
- **Don't generalize.** "I might reuse this" → you won't; if you do, rewrite it as real code then.

The one thing you may NOT cut: **result integrity.** A fast wrong number is worse than no number. Benchmarks get a warmup + multiple reps + reported variance; probes print the actual status and body.

**Gitignore the scripts.** On first use in a project, add `experimental/` to `.gitignore` (keep `docs/experimental/` tracked). Scripts are throwaway; reports are history.

## Safety

- **Read-only runs freely** (GET, local benchmarks).
- **Confirm before anything that mutates** — POST/PUT/DELETE, writes, or anything pointed at a shared/prod target. State the target and effect, get a yes, then run.

## Report template

`docs/experimental/<topic>.md`:

```markdown
# <Question being answered>

- **Date:** <YYYY-MM-DD>
- **Question:** <the one-line question>

## How
<what the script did, in 1-3 lines + the command to reproduce>

## Result
\`\`\`
<raw output: status codes, timings, numbers>
\`\`\`

## Conclusion
<the answer, stated plainly. e.g. "Approach B is ~3x faster (12ms vs 38ms, n=50)."
 Include caveats: sample size, environment, what wasn't tested.>
```

## Examples

**Probe a route (bash):**
```bash
# experimental/probe-orders.sh — does the orders endpoint work?
curl -s -o /dev/null -w "%{http_code} %{time_total}s\n" \
  http://localhost:3000/api/orders/42
```

**Benchmark two approaches (bash + hyperfine):**
```bash
# experimental/bench-count.sh — which line-count is faster on big.log?
hyperfine --warmup 3 'wc -l big.log' 'grep -c "" big.log'
```

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Polishing the script (functions, flags, error handling) | It runs once. Hardcode and move on. |
| No report — answer lives only in terminal scrollback | The report is the deliverable. Always write it. |
| Benchmark with one run, no warmup | Warm up + repeat + report variance, or the number is a lie. |
| Committing the scripts | Gitignore `experimental/`; commit only the report. |
| Turning it into a "small reusable tool" | If it's worth reusing, rewrite it as real code. This isn't that. |
