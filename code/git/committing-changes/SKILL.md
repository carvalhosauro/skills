---
name: committing-changes
description: "Use when staging and committing changes to git in the current repository — at a logical checkpoint, after finishing a unit of work, or whenever the user asks to commit/commitar/salvar. Covers commit authorization, Conventional Commits format, the co-author trailer, and lean domain-separated commits."
triggers:
  - commit
  - commitar
  - fazer commit
  - faz o commit
  - git commit
  - /commit
  - stage and commit
  - salva isso
user-invocable: true
model: haiku
effort: medium
---

# Committing Changes

## Overview
You ARE authorized to create local git commits in the current repository, following the rules below — you do NOT need to ask permission for each commit. Commit at logical checkpoints (a unit of work done + verified) or when asked.

**Local commits only.** Pushing (`git push`) and opening PRs are outward-facing and still require an explicit user request.

## Two non-negotiable rules

1. **Conventional Commits** — every subject is `type(scope): summary` (imperative, lowercase, no trailing period, ≤ ~50 chars; hard cap 72).
2. **Co-author trailer** — every commit message ends with a blank line then the
   attribution line your harness provides (e.g. a system reminder). If none is given, use
   `Co-Authored-By: <your model name> <noreply@anthropic.com>`.
   (The committer stays the human git user; the model is credited as co-author.)

## Lean + domain-separated (the core discipline)

**One commit = one logical concern in one domain.** Do not bundle.

- Split changes that touch different domains / bounded contexts (e.g. `money`, `channel`, `golden`, `domain`, `config`) into **separate commits**, even when made in the same session.
- Don't mix a refactor + a feature + an unrelated test-fixup in one commit. Separate them.
- Stage selectively (`git add <paths>` or `git add -p`) to keep each commit focused — never blindly `git add -A` when the working tree spans domains.
- Keep the diff reviewable: a reader should grasp one commit's intent without untangling unrelated edits.
- Match the repo's existing scope vocabulary (look at `git log` for prior scopes before inventing new ones).

## Quick reference — types

| type | use for |
|------|---------|
| `feat` | new behavior/capability |
| `fix` | bug fix |
| `refactor` | behavior-preserving restructure |
| `perf` | performance, no behavior change |
| `test` | tests only (golden, specs, fixtures) |
| `docs` | docs/specs/plans/comments only |
| `build` | build system, tsconfig, deps |
| `ci` | CI config |
| `chore` | misc maintenance |
| `style` | formatting only, no logic |
| `revert` | reverts a prior commit |

Scope = the domain touched: `feat(domain)`, `refactor(money)`, `test(golden)`, `docs`, `build(tsconfig)`.

## Body & footer

- **Subject** only is fine when the change is obvious.
- **Body** (wrap ~72 cols) when the *why* isn't obvious: what changed, why, verification result. State "what behavior is preserved" for refactors.
- **Footer**: `BREAKING CHANGE: ...` when applicable; then the co-author trailer.

## Workflow

1. Run `git status` / `git diff` — see everything that changed.
2. Group changes by domain. If the tree spans domains, plan N commits.
3. For each group: stage only its paths → write a Conventional-Commits message (+ body if non-obvious) → end with the co-author trailer → commit.
4. Verify with `git log --oneline -n` that the history reads cleanly.

## Example (one session, three domains → three commits)

```
refactor(money): delegate duplicate helpers to the Money VO

Replace formatMoney/parseMoney bodies with delegations to the shared Money VO.
Behavior preserved byte-for-byte (golden + §9 invariants green, 0 drift).

Co-Authored-By: <model name> <noreply@anthropic.com>
```
```
test(golden): lock the structured-credit card scenario

Co-Authored-By: <model name> <noreply@anthropic.com>
```
```
docs: add Fase 1 P1 plan

Co-Authored-By: <model name> <noreply@anthropic.com>
```

## Common mistakes

- **One fat commit for a multi-domain session.** Split by domain instead.
- **`git add -A` then commit.** Stage selectively; unrelated edits leak in.
- **Vague subject** (`update code`, `fixes`). Name the type, scope, and concrete change.
- **Missing co-author trailer.** Every commit, no exceptions.
- **Pushing without being asked.** Local commit is authorized; push/PR is not.
- **Inventing a new scope** when the repo already uses one for that domain. Check `git log` first.
