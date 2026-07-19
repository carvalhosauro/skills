# Skills

Personal [Agent Skills](https://agentskills.io) — reusable `SKILL.md` workflows that work across **Claude Code, Cursor, Codex, OpenCode, Copilot**, and [dozens more](https://github.com/vercel-labs/skills#supported-agents).

Browse: [skills.sh/carvalhosauro/skills](https://skills.sh/carvalhosauro/skills)

## Install (recommended) — skills.sh

The [Skills CLI](https://github.com/vercel-labs/skills) discovers every `SKILL.md` in this repo and installs into the agents you have (or the ones you pass with `-a`).

```bash
# List what's in the repo
npx skills add carvalhosauro/skills --list

# Install everything to every detected agent
npx skills add carvalhosauro/skills --all

# Or pick skills / agents
npx skills add carvalhosauro/skills -g -y \
  --skill hygiene-review --skill behavior-tests \
  -a claude-code -a cursor -a codex -a opencode

# Single skill
npx skills add carvalhosauro/skills --skill viral-product-review -g -y
```

| Flag | Meaning |
|------|---------|
| `-g` | Global (`~/.…/skills/`) instead of project-local |
| `-a <agent>` | Target agent(s): `claude-code`, `cursor`, `codex`, `opencode`, `github-copilot`, … |
| `-s / --skill` | One or more skill names (`'*'` = all) |
| `--all` | All skills → all agents (non-interactive with `-y`) |
| `-y` | Skip prompts |

Update later: `npx skills update` · remove: `npx skills remove <name>`.

### Local clone (dev)

```bash
git clone git@github.com:carvalhosauro/skills.git
npx skills add ./skills --list
npx skills add ./skills -g -y --skill '*' -a claude-code -a cursor
```

## Install — Claude Code only

### Script (symlinks; tracks `git pull`)

```bash
git clone git@github.com:carvalhosauro/skills.git
cd skills && ./install.sh
```

Then `/reload-plugins` (or restart). Options: `--copy`, `--uninstall`, `--help`. Honors `$CLAUDE_CONFIG_DIR`.

### Plugin marketplace

```text
/plugin marketplace add carvalhosauro/skills
/plugin install skills@skills
```

Namespaced: `/skills:hygiene-review`, … Update: `/plugin marketplace update skills`.

## Organization

```
skills/
├── code/
│   ├── project-docs
│   ├── review/hygiene-review
│   ├── tests/behavior-tests
│   └── benchmark/compare-alternatives
├── product/
│   └── viral-product-review
├── writing/blog/
│   ├── blog-critic
│   └── blog-refiner
└── agents/          # empty — no orchestrator agents in this release
```

> **Breaking (v1.2.0):** Product OS pipeline + `product-manager` removed. Renames: `marclou-review` → `viral-product-review`, `code-hygiene-review` → `hygiene-review`, `test-coverage-and-logging` → `behavior-tests`, `disposable-scripts` → `compare-alternatives`.

### `code/` — Engineering

| Skill | What it does |
|-------|--------------|
| **project-docs** | Durable project memory for agents: `AGENTS.md` + `docs/{STATUS,ROADMAP,DECISIONS,DESIGN}.md`. |
| **hygiene-review** | Session-aftermath readability review (9 parallel check categories). Reports only. |
| **behavior-tests** | Missing tests for **flows, business rules, happy + bad paths** (+ logging audit). |
| **compare-alternatives** | Throwaway A-vs-B benchmarks; report in `docs/experimental/`. |

### `product/` — Product critique

| Skill | What it does |
|-------|--------------|
| **viral-product-review** | Landing/pricing/copy against Marc Lou's 32 Principles (audit or build). |

### `writing/` — Writing & critique

| Skill | What it does |
|-------|--------------|
| **blog-critic** | Socratic critique of a technical article (not a rewrite). |
| **blog-refiner** | Collaborative section-by-section rewrite in your voice. |

## Using a skill

- **Automatic** — describe the task; the agent matches the skill `description`.
- **Explicit** — `/hygiene-review`, `/behavior-tests`, `/viral-product-review`, …
