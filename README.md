# skills

> **These are Gustavo Carvalho's personal skills** — tailored to my machines,
> subscriptions, and workflow. They are published for reference. Treat them as
> examples, then ask your own LLM to adapt them to your needs instead of reusing
> them verbatim: they carry my assumptions and paths.

Single versioned source for the [Agent Skills](https://agentskills.io) I use —
my own and third-party ones with light local changes. Each harness's skills
directory holds per-skill symlinks into this repo, so one edit here reaches all
of them and `git pull` updates everything.

## Layout

Categories, one directory per skill, each with a `SKILL.md`.

```
skills/
├── code/
│   ├── git/committing-changes
│   ├── review/hygiene-review
│   ├── tests/behavior-tests
│   └── benchmark/compare-alternatives
├── writing/
│   ├── humanizer            (vendored — see UPSTREAM.md)
│   └── blog/{blog-critic,blog-refiner}
├── product/viral-product-review
├── scripts/upstream-diff.sh
├── tests/
├── install.sh
├── skills.sh.json
└── README.md
```

## Catalog

| Skill | Category | Origin | What it does |
|---|---|---|---|
| committing-changes | code/git | own | Lean, domain-separated Conventional Commits with a co-author trailer. |
| hygiene-review | code/review | own | Post-session readability and hygiene review via parallel subagents. Reports only. |
| behavior-tests | code/tests | own | Behavior coverage: flows, business rules, happy and bad paths. |
| compare-alternatives | code/benchmark | own | Throwaway A-vs-B code with a measured verdict. |
| humanizer | writing | vendored: [blader/humanizer](https://github.com/blader/humanizer) | Rewrites AI-sounding prose so it reads naturally. |
| blog-critic | writing/blog | own | Socratic critique of technical posts (PT or EN). |
| blog-refiner | writing/blog | own | Section-by-section rewrite that keeps the author's voice. |
| viral-product-review | product | own, from Marc Lou's 32 principles | Audits landing page, pricing, and positioning. |

## Install

### Me — install.sh (symlinks)

```bash
git clone git@github.com:carvalhosauro/skills.git
cd skills && ./install.sh --prune
```

| Flag | Meaning |
|---|---|
| *(none)* | Link every skill into `${CLAUDE_CONFIG_DIR:-~/.claude}/skills`. |
| `--target DIR` | Also link into `DIR` (repeatable), e.g. `~/.codex/skills`. |
| `--prune` | After installing, remove dangling links into this repo. |
| `--copy` | Copy instead of symlink (snapshot; won't track `git pull`). |
| `--uninstall` | Remove every link into this repo from each target. |
| `--help` | Print usage. |

It never overwrites or deletes anything that is not a symlink into this repo.
Restart the agent afterwards.

### Others — skills.sh

```bash
npx skills add carvalhosauro/skills --list
npx skills add carvalhosauro/skills --skill humanizer -g -y -a claude-code -a cursor
```

## Consumers

| Harness | Skills directory | How it links |
|---|---|---|
| Claude Code | `~/.claude/skills` | per-skill symlinks (default target) |
| Cursor | reads `~/.claude/skills` as a compatibility dir | nothing extra — linking into `~/.cursor/skills` or `~/.agents/skills` would show duplicates |
| Others (Codex, …) | e.g. `~/.codex/skills` | `./install.sh --target <dir>` |

Per-skill symlinks rather than one directory symlink: the harness directories
also hold entries that must not live here (below).

## Deliberately NOT in this repo

- **run-on-device** — lives in the pigz mobile repo (`tools/run-on-device`) and is
  linked from there; it only makes sense inside that project.
- **Work skills** — private; not published in a public repo.
- **Plugin-provided skills** — superpowers, caveman, figma: installed and updated as
  Claude Code plugins.
- **claude.ai synced skills** — `~/.claude/skills/synced/`, managed by account sync.

## External components

None of these auto-update; re-check occasionally.

| Component | Source | Where it lives | Update procedure |
|---|---|---|---|
| humanizer | [blader/humanizer](https://github.com/blader/humanizer) | vendored in `writing/humanizer/` | `scripts/upstream-diff.sh writing/humanizer`, merge by hand, bump `Pinned:` and `Local changes` in `UPSTREAM.md` |
| superpowers, figma, github, gopls-lsp, php-lsp | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Claude Code plugins | `claude plugin update <name>` |
| caveman | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Claude Code plugin | `claude plugin update caveman` |
| intelephense | npm `intelephense` | global npm (needed by php-lsp) | `npm i -g intelephense@latest` |
| ai-memory | [akitaonrails/ai-memory](https://github.com/akitaonrails/ai-memory) | Docker container `ai-memory` + hooks/MCP in Claude Code and Cursor | `ai-memory upgrade` |
| rtk | [rtk-ai/rtk](https://github.com/rtk-ai/rtk) | `~/.local/bin/rtk` + Claude Code Bash hook | re-run the upstream installer |
| statusline | this machine | `~/.claude/statusline.py` | edit in place |

Last checked 2026-09-24 — humanizer 3.0.0, superpowers 6.4.1,
figma 2.2.120, ai-memory 2.4.0, rtk 0.34.2.

## Rules

This repo is public. `.gitignore` blocks credential-shaped files (`.env`,
`.env.*`, `*.key`, `*.pem`, `*secret*`, `*credentials*`). Never commit anything
resembling a key, token, or private work material.

Vendored skills keep their upstream `LICENSE`, have `.git` stripped, and carry an
`UPSTREAM.md` (`Source:`, `Path:`, `License:`, `Pinned:`, `## Local changes`).
Skills only *inspired by* another project get a credit in the Catalog and no copy.

## Adding a skill

1. Create `<category>/<name>/SKILL.md`.
2. Add it to a group in `skills.sh.json` and a row in the Catalog.
3. `./install.sh`, then restart the agent.

Vendoring instead: clone upstream, copy the skill directory, `rm -rf .git`, add
`UPSTREAM.md`, and confirm `scripts/upstream-diff.sh <dir>` shows no diff.

## Tests

```bash
bash tests/install.test.sh
bash tests/upstream-diff.test.sh
```
