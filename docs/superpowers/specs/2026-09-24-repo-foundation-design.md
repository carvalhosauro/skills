# Repo foundation — design

**Date:** 2026-09-24
**Status:** approved in conversation, pending written-spec review
**Sub-project:** 1 of 3 (1 = foundation, 2 = unified UI/UX skill, 3 = skills adapted from akitaonrails/my-skills)

## Goal

Turn `carvalhosauro/skills` into the single versioned source of every skill I use — my own
and third-party ones with light local changes — consumable by **Claude Code and Cursor** at
minimum, following the shape of [akitaonrails/my-skills](https://github.com/akitaonrails/my-skills).

Success criteria:

1. Every skill I use daily that is not plugin-provided lives in this repo.
2. One `./install.sh` run makes all of them available in Claude Code **and** Cursor, with no
   duplicates in Cursor's skill list.
3. Each vendored skill records where it came from, the pinned version, and my local changes,
   and I can see upstream drift with one command.
4. The README documents what is here, what is deliberately elsewhere, and how every external
   component is updated.

## Decisions

| Decision | Choice | Why |
|---|---|---|
| Language | English (README + SKILL.md) | Matches current repo; skills.sh audience; EN descriptions trigger fine on PT prompts. |
| Layout | Keep categories (`code/`, `writing/`, `product/`, later `design/`) | Already in place; `skills.sh.json` groupings mirror it; install and skills.sh discover `SKILL.md` recursively. |
| Install paths | `install.sh` (my daily use) + skills.sh (others) | Drop the Claude plugin marketplace: it duplicates skills when combined with symlinks and needs a hand-maintained path list. |
| Link target | `~/.claude/skills` only, by default | Cursor reads `~/.claude/skills` as a compatibility dir, plus `~/.cursor/skills` and `~/.agents/skills`. One link covers both harnesses; more links = duplicates in Cursor. |
| Third-party code | Vendor (copy, strip `.git`, keep LICENSE) + `UPSTREAM.md` | Versioned alongside my changes; upstream drift reviewed manually, like Akita does. |
| Skills with no license | Rewrite "inspired by", credit in README, no copy | Akita's repo has no LICENSE and asks not to reuse verbatim. Applies to sub-project 3. |

## 1. Structure and inventory

```
skills/
├── code/
│   ├── git/committing-changes        ← moved in (today a loose dir in ~/.claude/skills)
│   ├── review/hygiene-review
│   ├── tests/behavior-tests
│   └── benchmark/compare-alternatives
├── writing/
│   ├── humanizer                     ← vendored from blader/humanizer (MIT)
│   └── blog/{blog-critic,blog-refiner}
├── product/viral-product-review
├── scripts/upstream-diff.sh          ← new
├── tests/install.test.sh             ← new
├── install.sh
├── skills.sh.json
└── README.md
```

Changes:

- **committing-changes** — move `~/.claude/skills/committing-changes/SKILL.md` into
  `code/git/committing-changes/`. Light edit: description says "in this repository"; make it
  repository-agnostic. No other behavior change.
- **humanizer** — vendor fresh from upstream at the latest release (local copy is 2.11.2,
  upstream is 3.0.0), not from the local copy. Keep upstream's `LICENSE`. Drop upstream
  files that are not part of the skill package only if they break discovery (e.g. a nested
  `SKILL.md`); otherwise copy the package as-is.
- **Remove** `agents/` (empty, only `.gitkeep`) and agent handling from `install.sh`.
- **Remove** `.claude-plugin/` (marketplace + plugin manifest) and its README section.
- **Remove** `code/project-docs` (already staged in the working tree from the cleanup; it is
  committed as part of this work).
- `skills.sh.json` groupings updated: add `committing-changes` under a "Git" group and
  `humanizer` under "Writing".

Out of scope here: `design/` (sub-project 2), Akita-derived skills (sub-project 3).

## 2. Third-party convention

Each vendored skill directory contains an `UPSTREAM.md`:

```md
Source: https://github.com/blader/humanizer
Path: /
License: MIT
Pinned: v3.0.0 @ <full commit sha> (2026-09-24)

## Local changes
- none
```

Fields are line-oriented `Key: value` so the script can parse them with `sed`/`grep`.
`Path:` is the skill's directory inside the upstream repo (`/` = repo root).
"Local changes" is a human-maintained bullet list; every edit I make to vendored files adds a
bullet.

`scripts/upstream-diff.sh <skill-dir>`:

1. Reads `Source:` and `Path:` from `<skill-dir>/UPSTREAM.md`; errors if missing.
2. Shallow-clones the upstream default branch into a temp dir (`mktemp -d`, removed on exit).
3. Prints the upstream HEAD commit, then `diff -ru` between upstream `Path` and the local
   dir, excluding `.git` and `UPSTREAM.md`.
4. Exit 0 always when the diff runs (a diff is information, not failure); non-zero only on
   missing file, bad fields, or clone failure.

It never writes to the repo. Merging upstream changes is manual.

Skills merely *inspired by* another project (no copied text) get a credit line in the README
catalog and no `UPSTREAM.md`.

## 3. install.sh

Behavior:

- **Default target:** `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`.
- **`--target DIR`** (repeatable): link into extra dirs (e.g. `~/.codex/skills`). When a target
  resolves to `~/.agents/skills` or `~/.cursor/skills`, print a warning that Cursor already
  reads `~/.claude/skills` and will show duplicates.
- **Discovery:** every directory containing `SKILL.md`, excluding `.git`, **skipping any
  `SKILL.md` whose ancestor directory (below repo root) also contains a `SKILL.md`** — nested
  sub-skills of a vendored package are not installed separately.
- **Name collision:** if two discovered skills share a basename, print both paths and exit 1
  before touching any target.
- **Per skill** (unchanged semantics): link if absent; `ok` if already our link; `skip` with
  a message if the path exists and is not our link. Never clobbers.
- **`--prune`:** after the install pass of the same invocation, remove symlinks in each
  target whose link text points inside this repo but whose destination no longer exists.
  Never touches anything else. Ignored with `--uninstall`.
- **Kept:** `--copy`, `--uninstall`, `--help`.
- Summary line per target: found / linked / skipped / pruned.

Testing — `tests/install.test.sh`, plain bash, no dependencies:

- Each case runs `install.sh` against a fixture repo in `mktemp -d` with `HOME` and
  `CLAUDE_CONFIG_DIR` pointed at temp dirs, so the real config is never touched.
- Cases: fresh install links all skills; re-run is a no-op (`ok`); nested `SKILL.md` not
  linked; name collision exits 1 and creates nothing; foreign existing dir is skipped, not
  overwritten; `--prune` removes a dangling repo link and leaves a foreign dangling link;
  `--uninstall` removes only our links; `--target` links into the extra dir and warns for
  `~/.agents/skills`.
- Written first (TDD), must fail against the current script, then pass.
- Script prints `PASS`/`FAIL` per case and exits non-zero on any failure.

Local migration (my machine, after merge):

1. `rm -rf ~/.claude/skills/committing-changes` (content now in repo), then `./install.sh`.
2. `rm -rf ~/.agents/skills/humanizer`, drop its entry from `~/.agents/.skill-lock.json`,
   remove `~/.claude/skills/humanizer` link, then `./install.sh`.
3. `./install.sh --prune` (also clears any leftover dangling links into the repo).
4. Verify: Claude Code lists `committing-changes` and `humanizer` once; Cursor lists them once
   (this also answers whether Cursor follows symlinks — fallback is `--copy` for Cursor via
   `--target ~/.cursor/skills --copy`, documented if needed).

## 4. README

English, Akita-style sections, in this order:

1. **Title + disclaimer** — personal skills tailored to my machines and workflow; published
   for reference; ask your own LLM to adapt rather than reuse verbatim.
2. **Layout** — the tree from section 1.
3. **Catalog** — table: skill · category · origin (*own* / *vendored: upstream* /
   *inspired by: X*) · one-line purpose.
4. **Install** — `./install.sh` (flags table) for me; `npx skills add carvalhosauro/skills`
   for others.
5. **Consumers** — table: Claude Code → `~/.claude/skills` (per-skill symlinks); Cursor →
   reads `~/.claude/skills` (no extra link); others → `--target`.
6. **Deliberately NOT in this repo** — `run-on-device` (lives in the pigz mobile repo, linked
   from there); work skills (private); plugin-provided skills (superpowers, caveman, figma);
   claude.ai synced skills (`~/.claude/skills/synced/`).
7. **External components** — table: component · source · where it lives · update procedure.
   Rows: humanizer (`scripts/upstream-diff.sh`); Claude plugins superpowers, caveman, figma,
   github, gopls-lsp, php-lsp (`claude plugin update <name>`); ai-memory (`ai-memory upgrade`);
   rtk. Footer: "Last checked YYYY-MM-DD".
8. **Rules** — public repo; `.gitignore` blocks credential-shaped files (`.env`, `.env.*`,
   `*.key`, `*.pem`, `*secret*`, `*credentials*`) in addition to current entries. No
   `*token*` pattern: "design tokens" is a legitimate UI term (sub-project 2).
9. **Adding a skill** — create dir + `SKILL.md` under a category, add to `skills.sh.json`,
   run `./install.sh`, restart the agent. For vendored: copy, strip `.git`, add `UPSTREAM.md`.

## Error handling summary

- `install.sh`: collisions abort before any write; never overwrites foreign paths; prune
  only touches dangling links into the repo.
- `upstream-diff.sh`: read-only; temp dir cleaned via `trap`.

## Out of scope

- Unified UI/UX skill (sub-project 2).
- Akita-derived skills (sub-project 3).
- Automated upstream sync or CI.
