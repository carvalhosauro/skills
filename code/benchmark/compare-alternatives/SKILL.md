---
name: compare-alternatives
description: >-
  Compares two (or more) distinct technical alternatives with throwaway code and
  reports which wins on an explicit criterion (latency, correctness, allocations,
  output quality, …). Use when the user asks "which is faster", "A vs B",
  "benchmark these two approaches", "compare implementations", or needs a
  measured decision between alternatives — and the answer matters but the script
  does not. NOT for one-off API probes without an A/B hypothesis, not for code
  that ships or gets reused.
---

# Compare Alternatives

## Overview

The deliverable is a **measured decision**, not the code. When the question is
"is A better than B on criterion X?", write the cheapest disposable script that
compares them fairly, run it, record the winner (and the numbers), and leave the
script throwaway. The script is scaffolding; the report is the artifact.

**Optimize for trustworthy comparison, not for quality of code.** Polishing a
script you will run once and delete is wasted work — but a fast wrong number is
worse than no number.

## When to use

- Micro-benchmarks: two implementations, queries, configs, or algorithms.
- Correctness bake-offs: same inputs, compare outputs or error rates.
- Resource trade-offs: latency vs allocations, throughput vs CPU.
- Any **A vs B (vs C…)** question where a criterion of victory can be stated.

**When NOT to use:**

- Single-side probes ("does this route return 200?") with no alternative to
  compare — just curl it or use an ad-hoc check; this skill needs A vs B.
- Spikes with no hypothesis ("does this even work?") unless framed as alternative
  approaches to evaluate.
- Anything that ships, gets imported, runs in CI, or that someone else will read
  and reuse — write that as real code elsewhere.

## Workflow

1. **State the hypotheses and the win criterion in one line each.**
   Example: "A = hash index scan; B = btree range. Win = lower p50 latency on
   this dataset, n≥30 after warmup."
2. **Put the script in `experimental/`.** Create the dir and ensure it's
   gitignored (see Disposability).
3. **Write the smallest script that compares them fairly.** Hardcode everything.
   Same inputs, same environment, isolate the variable under test. Prefer
   `hyperfine`, `python`, or `bash` — whatever is fastest to a fair answer.
4. **Warm up + multiple reps + report variance.** Don't crown a winner on one run.
5. **Capture raw output** (timings, counts, diffs).
6. **Write the report** to `docs/experimental/<topic>.md` (template below).
7. **Leave the script in `experimental/`** (gitignored) for re-runs. The report
   is what survives.

## Disposability (the discipline)

Your instinct will be to make it clean. Resist it. For a single-use script:

- **Hardcode everything** — paths, payloads, counts, labels for A/B. No args,
  no flags, no config, no env parsing.
- **No abstractions** — no functions/classes unless they cut total effort. No
  error handling beyond what you need to trust the result.
- **One file.** No project, no deps file, no README.
- **Don't generalize.** "I might reuse this" → you won't; if you do, rewrite it
  as real code then.

The one thing you may NOT cut: **result integrity.** Warmup + reps + variance
(or an equivalent correctness check) are mandatory.

**Gitignore the scripts.** On first use in a project, add `experimental/` to
`.gitignore` (keep `docs/experimental/` tracked). Scripts are throwaway; reports
are history.

## Safety

- **Read-only runs freely** (local benches, GET-only comparisons).
- **Confirm before anything that mutates** — POST/PUT/DELETE, writes, or
  anything pointed at a shared/prod target. State the target and effect, get a
  yes, then run.

## Report template

`docs/experimental/<topic>.md`:

```markdown
# <A vs B question>

- **Date:** <YYYY-MM-DD>
- **Alternatives:** A = … · B = …
- **Win criterion:** <latency p50 / correctness / …>

## How
<what the script did, in 1-3 lines + the command to reproduce>
Warmup: <n> · Reps: <n> · Env: <brief>

## Result
\`\`\`
<raw output: timings, variance, diffs>
\`\`\`

## Conclusion
<Winner stated plainly. e.g. "B wins: ~3x faster (12ms vs 38ms p50, n=50)."
 Include caveats: sample size, environment, what wasn't tested.>
```

## Examples

**Benchmark two approaches (bash + hyperfine):**
```bash
# experimental/bench-count.sh — A=wc vs B=grep -c on big.log
hyperfine --warmup 3 --runs 20 'wc -l big.log' 'grep -c "" big.log'
```

**Compare two query plans (python sketch):**
```python
# experimental/bench-queries.py — same DB, A vs B SQL, print p50/p95
# hardcode DSN, SQL_A, SQL_B, N, warmup; print table; no argparse
```

## Common mistakes

| Mistake | Fix |
|---------|-----|
| No A vs B — only probing one side | Reframe with two alternatives or don't use this skill |
| Polishing the script (functions, flags) | It runs once. Hardcode and move on |
| No report — answer only in scrollback | The report is the deliverable |
| One run, no warmup | Warm up + repeat + variance, or the number is a lie |
| Unfair comparison (different inputs/env) | Same inputs; change one variable |
| Committing the scripts | Gitignore `experimental/`; commit only the report |
| Turning it into a reusable tool | If worth reusing, rewrite as real code |
