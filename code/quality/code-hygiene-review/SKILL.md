---
name: code-hygiene-review
description: >-
  Runs a readability-focused hygiene review of recently written code by
  dispatching parallel subagents, one per category: magic values, dead code,
  duplication, N+1 queries, missing typing, and general readability (function
  and file size, naming, SRP, early returns, exception messages, comments).
  It only REPORTS — it never edits code. Use this skill after a long coding
  session, after the agent made many modifications, before opening a PR, or
  whenever the user asks to "review", "audit", "clean up", "check the code",
  "find code smells", or "go over what we just wrote". Trigger it even when the
  user does not say the word "skill" — any request to inspect recently changed
  code for shallow quality problems should use this.
---

# Code Hygiene Review

Produce a structured, actionable report of shallow code-quality problems in a
chosen scope. The single goal is **readability**: surfacing the smells that
accumulate during long agent sessions so a human can decide what to fix.

This skill **only reports**. It must never edit, format, or rewrite any file.
Findings include a one-line suggested direction, not a patch.

## Workflow

### 1. Resolve the scope

The user must tell you *what* to analyze. If they already said it in the
request, use that. Otherwise, ask them to pick one:

- **Session** — code changed in the current working session. Resolve this from
  git: tracked changes (`git diff --name-only HEAD`) plus untracked files
  (`git ls-files --others --exclude-standard`). If not a git repo, ask the user
  to name the files or a path instead.
- **Whole repo** — all source files, respecting `.gitignore`. Skip vendored
  dependencies, build artifacts, lockfiles, and generated code.
- **Domain / path** — a specific directory, module, or glob the user names
  (e.g. `src/billing/`, `app/models/**`).

Resolve the chosen scope to a concrete list of source files before going on.
Exclude non-source files (binaries, assets, generated code, migrations unless
asked). If the list is large (> ~40 files), tell the user the count and confirm
before launching the review.

### 2. Dispatch the subagents in parallel

Launch **six** subagents in a single turn using the Task tool. Each one owns one
category and works independently. Give every subagent the same scaffold,
swapping in its category and checklist file:

```
You are reviewing code for ONE category: <CATEGORY>.

Files to review:
<the resolved file list>

Read your checklist first: references/checks/<CHECK_FILE>
Follow it exactly. For each file, detect the language before applying any
heuristic — rules differ per language, and some categories do not apply to
some languages (say so explicitly when that happens).

This is REPORT-ONLY. Do not edit, format, or rewrite any file. Do not run
fixers. Only read and report.

Return your findings as a JSON array. Each finding:
{ "file": "...", "line": <int or null>, "severity": "high|medium|low",
  "title": "short label", "why": "why it hurts readability",
  "direction": "one-line suggested direction (no code patch)" }
Return [] if you find nothing. Do not include anything except the JSON array.
```

The six categories and their checklists:

| Category            | Checklist file                          |
| ------------------- | --------------------------------------- |
| Magic values        | `references/checks/magic-values.md`     |
| Dead code           | `references/checks/dead-code.md`        |
| Duplication         | `references/checks/duplication.md`      |
| N+1 queries         | `references/checks/n-plus-one.md`       |
| Typing              | `references/checks/typing.md`           |
| General readability | `references/checks/readability.md`      |

Run them concurrently — they don't depend on each other. Don't analyze the code
yourself in the main thread; that's the subagents' job.

### 3. Consolidate into the report

Collect every subagent's JSON. Then:

1. **Merge & dedupe** — if two categories flag the same `file:line` for the same
   underlying issue, keep one entry and note both categories.
2. **Group by file**, files ordered by total severity weight (high=3, medium=2,
   low=1) so the worst files surface first.
3. Within a file, order findings high → low severity.
4. Write the report to `docs/audit/review-YYYY-MM-DD_HH-MM.md` (create the
   `docs/audit/` directory if needed; use the current local date and time).
   Follow `references/report-template.md` exactly.
5. Print a **short** summary in chat: total findings, counts per severity, the
   3 files with the most issues, and the report path. Do not paste the whole
   report into chat.

Write the report in the user's language (default **Portuguese / pt-BR** for this
user; switch if they write in another language).

## Principles

- **Report, never fix.** The value is a human-reviewable map of problems. A
  patch the user didn't ask for is noise and risks breaking working code.
- **Readability is the lens.** Every finding answers "why does this make the
  code harder to read or maintain?" If a finding can't answer that, drop it.
- **Language-aware, not language-blind.** N+1 only applies where there's an
  ORM/DB; typing rules differ between TypeScript, Python, Ruby, Go, etc. A
  subagent that says "not applicable here" is doing its job correctly.
- **Signal over volume.** A short report of real problems beats an exhaustive
  list of nitpicks. Prefer high-confidence findings; mark uncertain ones `low`.

## Scope notes

This skill deliberately stays on shallow, readability-level smells. It does
**not** cover tests, dependency injection, project structure, or logging — those
belong to a separate, heavier review skill.
