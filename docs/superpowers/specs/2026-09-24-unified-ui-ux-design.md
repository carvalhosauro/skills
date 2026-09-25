# Unified UI/UX skill — design

**Date:** 2026-09-24
**Status:** approved in conversation, pending written-spec review
**Sub-project:** 2 of 3 (1 = foundation ✅, 2 = unified UI/UX skill, 3 = skills adapted from akitaonrails/my-skills)
**Builds on:** `docs/superpowers/specs/2026-09-24-repo-foundation-design.md` (vendoring convention, `UPSTREAM.md`, `install.sh`, `scripts/upstream-diff.sh`)

## Goal

Replace the 8 UI/UX skills that today compete for triggering — `impeccable`, `animate`,
`animation-vocabulary`, `emil-design-eng`, `find-animation-opportunities`,
`improve-animations`, `review-animations`, `web-design-guidelines` — with **one** versioned
skill, `impeccable`, that routes to all of their material, for **Web + React Native/Expo**.

Success criteria:

1. Claude Code and Cursor list exactly one UI/UX skill (`impeccable`); none of the 8 old
   entries remain in `~/.claude/skills`, `~/.agents/skills`, or `~/.cursor/skills`.
2. A request like "improve this screen", "animate this modal", "review this animation",
   "what's this effect called", or "check this UI against the web guidelines" triggers that
   one skill, which loads the right reference.
3. Every vendored part records its upstream and local changes, and
   `scripts/upstream-diff.sh <dir>` shows only real edits (renames do not show as whole-file
   add/delete).
4. Native iOS/Android can be added later as new references without restructuring.

## Decisions

| Decision | Choice | Why |
|---|---|---|
| Platforms | Web + React Native/Expo now; native later | User's current work. impeccable's native references (`ios.md`, `android.md`, `*.native.md`) are vendored anyway; Emil's `write-swift`/`apple-design` can be added as references later. |
| Shape | Approach A: impeccable is the single entry point; Emil + Vercel material become references inside it | One description → no trigger competition; impeccable's scripts/detector/live keep working because its name and layout are unchanged. |
| impeccable variant | Upstream `.claude/skills/impeccable` (v4.4.0) | Variants differ only in fallback path prefixes (`.claude/` vs `.cursor/`), used only when the harness reports no base dir; Claude variant serves both via `~/.claude/skills`. |
| Emil skills included | animate, animate-expo, animation-vocabulary, emil-design-eng, find-animation-opportunities, improve-animations, review-animations | The 6 in use + `animate-expo` for React Native. Others (mobile-native, apple-design, pick-ui-library, prototype, ask-sonner, write-swift) left out — YAGNI; addable later as references. |
| web-design-guidelines | Rewritten as own `reference/guidelines.md`, "inspired by" vercel-labs/agent-skills | The Vercel skill is 39 lines of instructions that fetch MIT rules from `vercel-labs/web-interface-guidelines`; no verified LICENSE on `vercel-labs/agent-skills`, so no copy. |
| Name | Keep `impeccable` | Its SKILL.md, references and launcher refer to `impeccable` throughout; renaming would be a large, fragile local diff. |

## 1. Structure

```
design/impeccable/                         ← vendored pbakaus/impeccable (Apache-2.0)
├── SKILL.md                               ← local edits (section 3)
├── UPSTREAM.md                            ← Source: https://github.com/pbakaus/impeccable · Path: /.claude/skills/impeccable
├── LICENSE, NOTICE.md                     ← copied from upstream repo root (Apache-2.0 requires keeping NOTICE)
├── agents/ reference/ scripts/            ← upstream, unchanged
├── reference/guidelines.md                ← own file (section 3)
└── reference/motion/                      ← vendored emilkowalski/skills (MIT)
    ├── LICENSE                            ← copied from emilkowalski/skills root
    ├── animate/                 animate.md, RECIPES.md, UPSTREAM.md
    ├── animate-expo/            animate-expo.md, RECIPES.md, UPSTREAM.md
    ├── animation-vocabulary/    animation-vocabulary.md, UPSTREAM.md
    ├── emil-design-eng/         emil-design-eng.md, UPSTREAM.md
    ├── find-animation-opportunities/  find-animation-opportunities.md, UPSTREAM.md
    ├── improve-animations/      improve-animations.md, AUDIT.md, PLAN-TEMPLATE.md, UPSTREAM.md
    └── review-animations/       review-animations.md, STANDARDS.md, UPSTREAM.md
```

Pins observed during design (implementation re-reads upstream HEAD and records the real SHA):
impeccable `9d715cc4f5564a990ca8345abfdd5df6dc9b41c8` (SKILL.md `version: 4.4.0`), emilkowalski/skills
`d16ebe60d09a5ba2afcb7054ede9d0a10c9f6128`.

The only `SKILL.md` under `design/` is `design/impeccable/SKILL.md`. No nested `SKILL.md`
anywhere, so neither `install.sh` nor Cursor's recursive walk sees extra skills.

impeccable's launcher (`scripts/impeccable`) downloads a platform binary from
`github.com/pbakaus/impeccable/releases` on first run, verifies it against a `.sha256`
sidecar, and caches it in `~/.impeccable/` — outside the repo. No binary is committed.

## 2. Rename-aware upstream-diff

Each Emil skill's upstream `SKILL.md` is stored as `<name>.md` so it is not a skill. Its
`UPSTREAM.md` declares that:

```md
Source: https://github.com/emilkowalski/skills
Path: /skills/animate
License: MIT
Pinned: <sha> (2026-09-24)
Rename: SKILL.md -> animate.md

## Local changes
- …
```

`scripts/upstream-diff.sh` change:

- New optional, repeatable field `Rename: <upstream-relpath> -> <local-relpath>` (paths
  relative to `Path` upstream and to the skill dir locally).
- After cloning, before diffing, the script copies the upstream `Path` subtree into a
  temp staging dir and applies each rename there (`mkdir -p` the destination's parent,
  then `mv`). A rename whose source does not exist upstream prints
  `rename source missing upstream: <path>` to stderr and exits 1.
- Diff then runs staging (left) vs local (right), still excluding `.git` and `UPSTREAM.md`.
- Everything else in the script is unchanged (read-only, `trap` cleanup, exit codes).

Tests (TDD, `tests/upstream-diff.test.sh`): a fixture upstream with `skills/demo/SKILL.md`,
local `demo.md` with one edited line and `Rename: SKILL.md -> demo.md` → output shows only the
edited line (no `Only in` for `SKILL.md`/`demo.md`), exit 0; a rename with a missing source →
exit 1 with the message above.

For `design/impeccable` itself, the local-only `reference/motion/` and
`reference/guidelines.md` show up as `Only in …` lines — that is expected and informative.

## 3. Routing (local changes)

**`design/impeccable/SKILL.md`** — the complete list of edits; each becomes one bullet in
`design/impeccable/UPSTREAM.md` → `## Local changes`:

1. `description:` — append one sentence: *"Also covers motion craft from Emil Kowalski's
   skills — building web and React Native/Expo animations, reviewing and auditing motion code,
   finding animation opportunities, naming motion effects — and Web Interface Guidelines
   compliance reviews."*
2. `argument-hint:` — add `motion-review|motion-audit|motion-find|motion-vocab · guidelines`.
3. Commands table — add rows:

   | Command | Category | Description | Reference |
   |---|---|---|---|
   | `motion-review [target]` | Evaluate | Review animation/motion code against a strict craft bar | `reference/motion/review-animations/review-animations.md` |
   | `motion-audit [target]` | Evaluate | Audit a codebase's motion and write prioritized fix plans | `reference/motion/improve-animations/improve-animations.md` |
   | `motion-find [target]` | Evaluate | Find places that should animate, reject the rest | `reference/motion/find-animation-opportunities/find-animation-opportunities.md` |
   | `motion-vocab [description]` | Iterate | Name a motion effect from a vague description | `reference/motion/animation-vocabulary/animation-vocabulary.md` |
   | `guidelines [files]` | Evaluate | Web Interface Guidelines compliance review | `reference/guidelines.md` |

4. `animate` row — keep `reference/animate.md`; append to its Reference cell:
   `· build detail: reference/motion/animate/animate.md (web) · reference/motion/animate-expo/animate-expo.md (React Native/Expo)`.
5. One line after the Commands table: *"Motion commands (`animate`, `motion-*`) also load
   `reference/motion/emil-design-eng/emil-design-eng.md` for the underlying philosophy."*

Deliberately not edited: `reference/routing.md` (context menu) and
`scripts/command-metadata.json` (launcher/pin). New commands exist only in SKILL.md routing;
`pin` does not know them. Keeps the per-update reapply small.

**Emil files** — local changes per skill, each listed in its `UPSTREAM.md`:

- Cross-references to sibling skills by name become the equivalent impeccable command:
  `animate` → `animate`, `review-animations` → `motion-review`, `improve-animations` →
  `motion-audit`, `find-animation-opportunities` → `motion-find`, `animation-vocabulary` →
  `motion-vocab`, `animate-expo` → `animate` (React Native/Expo). References to Emil skills
  not vendored here (e.g. `apple-design`, `mobile-native`) are left as-is.
- Frontmatter kept as-is (harmless in a non-`SKILL.md` file; keeps the diff small).
- Relative links between files inside one skill dir (e.g. `RECIPES.md`, `STANDARDS.md`) keep
  working because each skill keeps its own directory.

**`reference/guidelines.md`** — own file, credited in README as inspired by
vercel-labs/agent-skills `web-design-guidelines`: fetch
`https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md` fresh
before each review, read the target files (ask if none given), apply every rule, and report in
the fetched document's `file:line` format. No `UPSTREAM.md` (not a copy).

## 4. Repo, tests, migration

Repo:

- New category `design/`.
- `skills.sh.json`: group `{"title": "Design", "description": "design/ — impeccable (vendored) with Emil Kowalski's motion craft and Web Interface Guidelines.", "skills": ["impeccable"]}`.
- README: Layout tree adds `design/impeccable`; Catalog row
  `impeccable | design | vendored: pbakaus/impeccable + emilkowalski/skills; guidelines inspired by vercel-labs | UI/UX design, critique, polish, motion (web + RN), guidelines review`;
  External components rows for impeccable and emilkowalski/skills (update via
  `scripts/upstream-diff.sh design/impeccable` and `… design/impeccable/reference/motion/<name>`,
  merge by hand, bump `Pinned:`), and a row for the impeccable engine binary (cached in
  `~/.impeccable/`, updated when `scripts/VERSION` changes after a re-vendor).

Verification:

- `bash tests/install.test.sh` and `bash tests/upstream-diff.test.sh` pass.
- `find design -name SKILL.md` → exactly `design/impeccable/SKILL.md`.
- `install.sh` on a temp HOME links `impeccable` once, no collisions.
- `scripts/upstream-diff.sh design/impeccable/reference/motion/<name>` for each of the 7 shows
  only the cross-reference edits; for `design/impeccable` shows only the SKILL.md edits plus
  `Only in` lines for `reference/motion` and `reference/guidelines.md`.

Migration (this machine, after merge):

1. Back up `~/.claude/skills`, `~/.agents/skills`, `~/.agents/.skill-lock.json`,
   `~/.cursor/skills`.
2. Remove: `~/.claude/skills/impeccable` (dir); the 7 links `~/.claude/skills/{animate,
   animation-vocabulary,emil-design-eng,find-animation-opportunities,improve-animations,
   review-animations,web-design-guidelines}`; `~/.agents/skills/{impeccable, animate,
   animation-vocabulary, emil-design-eng, find-animation-opportunities, improve-animations,
   review-animations, web-design-guidelines}` and their entries in `~/.agents/.skill-lock.json`;
   `~/.cursor/skills/impeccable`.
3. `./install.sh --prune`.
4. Verify: `impeccable` is the only UI/UX entry across the three dirs Cursor reads; Claude
   Code lists it once. GUI confirmation in Cursor is the user's.

## Error handling summary

- `upstream-diff.sh`: missing rename source → exit 1 with message; otherwise unchanged.
- Migration: backup first; removes only the listed paths.

## Out of scope

- Native iOS/Android skills (later: add `write-swift`/`apple-design` as references).
- Editing impeccable's `routing.md` or `command-metadata.json`.
- Sub-project 3.
