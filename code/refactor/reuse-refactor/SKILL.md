---
name: reuse-refactor
description: Use when a feature is done and before shipping it, to remove duplication and reinvented wheels from what the branch added, or when the user asks to refactor, dedupe or clean up code (optionally naming a path) and wants it done rather than reported.
---

# Reuse Refactor

Removes code the branch added that duplicates the repo, the standard library, an installed
dependency or a mature library, and proves nothing changed. It works to the end without asking:
every candidate is either proven and committed, or reverted and listed in the report.

**Refactor means identical behavior:** the same output, error and side effect for every input the
code accepts (what its types, its validation and its callers allow), bugs included. A replacement
whose output differs for an accepted input is not a refactor, even when the new output is more
correct. Leave the code and list it under suggestions, naming the difference. Differences only for
inputs the code rejects (a `null` where the type says `string[]`) do not block the refactor; note
them in the report.

## Roles and stops

- You, the main session, run every command and every test yourself. Never delegate a test run:
  some projects crash when tests run from subagents.
- The only subagent is the read-only reviewer (step 4).
- Stop and hand over in two cases only:
  - a policy lock blocks a step (guard hook, deny rule, refused push, denied permission). Do not
    work around it;
  - the baseline is red before any change (step 1).
- Everything else is your decision. A candidate you cannot prove: revert it and move on. Never ask
  the user to choose; put the choice and its reason in the report.

## 1. Set up

1. Read the project rules (`AGENTS.md`, `CLAUDE.md`, `.claude/rules/`, `README`). Note the
   one-file test command, the full verification command, lint and typecheck, the browser check
   (screenshots) if any, test constraints, and commit conventions. Project rules win.
2. Find the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, else `main` or
   `master`). On it with a clean tree and no path named: report "nada a refatorar" and end, with no
   branch and no commit. On it otherwise: `git switch -c refactor/<topic>`.
3. If `git status --short --untracked-files=all` lists anything, it is the feature. Commit it now,
   as it is, staged by path, in Conventional Commits. Leave unstaged only files clearly from
   another task (handoff notes, drafts, scratch files); no candidate may touch them.
4. The seed: the path the user named, else the code the branch adds,
   `git diff $(git merge-base HEAD <default>)..HEAD`. Work from the added and changed lines; the
   rest of a touched file is context, not seed. Empty seed: report "nada a refatorar" and end.
5. Baseline: run the tests for the seed's area, lint and typecheck. Red: stop, name the failing
   tests.
6. Record **BASE** = `git rev-parse HEAD`. The review target, the "was it already there?" check and
   the triage of a red full verification all use it.

## 2. Find candidates

Read `references/finding-candidates.md`. Keep only candidates with a concrete replacement, biggest
net removal first, **at most 5**. Each thing you looked at and left alone goes under "Pulado" in
the report, with the reason.

## 3. Each candidate, one at a time

1. **Pin** the behavior: read `references/pinning.md`. Every new test must be seen green on the
   current code and red with that code broken on purpose. Cannot pin it: skip the candidate.
2. **Commit the new tests alone:** `test(<scope>): pin <behavior>`.
3. **Refactor** with the smallest change. Moved or merged code keeps its error handling and
   validation. Never add a dependency: a candidate that needs one is reverted and becomes a
   suggestion.
4. **Prove:** the pinned tests (unchanged), the tests next to every touched file, lint and
   typecheck. A screen: take the "after" screenshots in the same states, themes and widths and
   compare them with "before". The markup may change; what the user sees may not. Any visible
   difference is red.
5. **Red:** fix it, at most **2 attempts**. Still red: `git restore` the candidate's files, keep
   the test commit (it pins the current code), list the candidate under "Pulado".
6. **Green: commit this candidate alone,** `refactor(<scope>): <what> -> <what replaced it>`. One
   candidate per commit, so any one can be reverted by itself.

## 4. Independent review

Nobody approves their own code. Read `references/review-request.md` and dispatch a fresh subagent
with that request. Then act on CONFIRMED BLOCKER and HIGH findings only (a project reviewer with
its own format: its blocking findings, or a blocking verdict). Decide yourself whether each one
was already there: open the code at BASE (`git show <BASE>:<path>`); do not rely on the
reviewer's label.
- **A behavior change the refactor introduced** (lost validation or error handling counts):
  `git revert --no-edit <refactor sha>` and list the candidate under "Pulado". Do not argue for
  it. A revert that conflicts: revert the newer candidates that touch the same file first.
- **Another problem the refactor introduced** (a new test that would stay green, an abstraction
  over look-alikes, net growth): fix it in a new commit and prove again.
- **Already there at BASE:** write the test that reproduces it and watch it fail, then fix it. In
  that same `fix(<scope>): <bug>` commit, change exactly the pin assertion that captured the buggy
  output, and say so in the report. List it under "Bugs corrigidos".
- MEDIUM, LOW and PLAUSIBLE go in the report.

Rounds 2 and 3 review only the delta since the last reviewed commit. **At most 3 rounds.**
Anything still open after the 3rd: revert those candidates.

## 5. Full verification

Run the project's full verification command once, in the background or with a long timeout. A
timeout is not red: run it again. Red: run each failing test at BASE (`git worktree add <tmp>
<BASE>`, run it there, then `git worktree remove <tmp>`).
- Red at BASE too: it is not yours. List it under "Não verificado" and change nothing.
- Green at BASE: revert the `refactor(...)` commits newest first until it is green again; each
  reverted candidate goes under "Pulado".

## 6. Final report

In the user's language (Brazilian Portuguese by default), short, with exactly these headings:
`Refatorado` (what replaced what, net lines), `Pulado` (and why), `Sugestões` (replacements that
change output, libraries to consider, possible bugs), `Bugs corrigidos`, `Testes adicionados`
(each proven red with the code broken), `Verificação`, `Revisão` (verdict and rounds),
`Não verificado`, `Próximo passo` (`/ship` when the project has it). Never push or open a PR.

## Red flags

| Thought | Reality |
|---|---|
| "The new output is more correct" | Then it is a fix, not a refactor. Leave it; "Sugestões". |
| "These untracked files are not part of the branch" | Uncommitted work is the feature. Commit it in step 1. |
| "One commit for all the refactors is cleaner" | One per candidate, or none can be reverted alone. |
| "The new test passes, so it pins the behavior" | A test never seen red proves nothing. Break the code, watch it fail. |
| "The user should decide if these are the same rule" | Do not merge look-alikes. "Pulado", with the reason. |
| "I checked my own diff" | Dispatch the reviewer. |
| "This library would be cleaner" | Never install. "Sugestões". |
