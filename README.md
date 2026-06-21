# Skills

A personal collection of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) **skills** and **agents**. Each skill is a self-contained `SKILL.md` that teaches Claude a repeatable workflow — invoked automatically when your request matches, or explicitly with `/<skill-name>`. Agents are subagent personas (under `agents/`) that drive several skills toward a larger goal.

> **Skills are cross-tool.** `SKILL.md` follows the [Agent Skills](https://code.claude.com/docs/en/skills) spec, so the same files work in Claude Code (`~/.claude/skills/`), [Codex CLI](https://developers.openai.com/codex/skills) (`~/.codex/skills/`), and [OpenCode](https://opencode.ai/docs/skills/) (`.opencode/skills/`) — only the install location differs. Agents and the plugin marketplace below are Claude Code-specific.

## Install

Two ways to install — a local script (short skill names, auto-updates with `git pull`) or the plugin marketplace (namespaced, shareable). Pick one.

### Option A — Script (recommended)

Clones the repo and **symlinks** every skill into `~/.claude/skills/` and every agent into `~/.claude/agents/`. Because they're symlinks, a later `git pull` updates everything you installed at once.

```bash
git clone git@github.com:carvalhosauro/skills.git
cd skills
./install.sh
```

Then run `/reload-plugins` in Claude Code (or restart). Skills get short names: `/market-research`, `/code-hygiene-review`, … and the `product-manager` agent becomes available.

```bash
./install.sh            # symlink all skills + agents (default)
./install.sh --copy     # copy instead of symlink (snapshot, won't track git)
./install.sh --uninstall  # remove the symlinks this repo created
./install.sh --help
```

The script auto-discovers every `SKILL.md` and `agents/*.md`, is idempotent (safe to re-run), never clobbers files it didn't create, and honors `$CLAUDE_CONFIG_DIR` (defaults to `~/.claude`).

**Other tools:** for Codex or OpenCode, copy the skill directories into that tool's skills folder (`~/.codex/skills/`, `.opencode/skills/`) — e.g. `cp -r product/* ~/.codex/skills/`. The `install.sh` script and the marketplace below target Claude Code only.

### Option B — Plugin marketplace

Install through Claude Code's plugin system. Run these **inside Claude Code** (they're slash commands):

```text
/plugin marketplace add carvalhosauro/skills
/plugin install skills@skills
```

- `carvalhosauro/skills` is the **GitHub repo** (the marketplace source).
- `skills@skills` is `<plugin-name>@<marketplace-name>` as declared in `.claude-plugin/marketplace.json`.
- Plugin skills are **namespaced**: `/skills:market-research`, `/skills:code-hygiene-review`, …
- The `product-manager` agent ships with the plugin too.
- Update later with `/plugin marketplace update skills`.

### Option C — A single skill, manually

Symlink (or copy) just the one you want:

```bash
ln -s "$PWD/product/market-research" ~/.claude/skills/market-research
```

## Organization

Skills are grouped by domain. Each lives in its own directory holding a `SKILL.md` (and any supporting files).

```
skills/
├── code/        Engineering quality workflows
│   ├── quality/code-hygiene-review
│   └── tests/test-coverage-and-logging
├── product/     The "Product OS" — an idea-to-MVP pipeline
│   ├── market-research
│   ├── competitive-benchmark
│   ├── discovery-interviews
│   ├── problem-formulation
│   ├── prioritization
│   └── mvp-definition
├── agents/      Subagent personas that drive the skills
│   └── product-manager.md
└── writing/     (reserved — no skills yet)
```

---

## `code/` — Engineering quality

Standalone skills you run during or after a coding session. They are independent of each other.

| Skill | What it does |
|-------|--------------|
| **code-hygiene-review** | Readability-focused review of recently written code. Dispatches one subagent per category (magic values, dead code, duplication, N+1 queries, missing typing, general readability). **Reports only — never edits.** Run it after a long session or before opening a PR. |
| **test-coverage-and-logging** | Runs the test suite, measures coverage, audits test quality and logging, then **writes the missing tests** it finds — following the project's own framework and conventions. The testing counterpart to a hygiene review. |

---

## `product/` — The Product OS

Six skills that chain into one pipeline: **market → wedge → real pain → sharp problem → what comes first → MVP.** Each skill consumes the previous skill's output and feeds the next. Run them in order for a product from scratch; jump in mid-pipeline if earlier stages are already validated.

```
market-research → competitive-benchmark → discovery-interviews
        → problem-formulation → prioritization → mvp-definition
```

| # | Skill | What it does | Requires |
|---|-------|--------------|----------|
| 1 | **market-research** | Frames the scope in a brainstorm, then delivers a **Market Map** (who buys, how much they pay, what alternatives exist, opportunity size) saved as a `.md`. | nothing — the entry point |
| 2 | **competitive-benchmark** | Compares competitors in a matrix, analyzes gaps, and recommends a **wedge** (the specific entry point). | Market Map (#1) |
| 3 | **discovery-interviews** | Two modes: **prepare** an anti-bias question guide (Mom Test style), and **synthesize** notes/transcripts into problem, frequency, impact, who suffers, current workaround. | wedge / Benchmark (#2) |
| 4 | **problem-formulation** | Turns the evidence into a **sharp, singular problem** in two formats side by side — causal and job-to-be-done. Rejects solutions disguised as problems. | wedge (#2); interviews (#3) optional |
| 5 | **prioritization** | Ranks problems/features to answer "if I solve only one thing, which is worth most?". Auto-picks the framework (Opportunity Scoring / ICE / RICE) and shows the reasoning. | a list of problems/opportunities |
| 6 | **mvp-definition** | Defines the **smallest thing that delivers value** — isolates the value moment, produces scope (IN), cut list (OUT), build approach (manual / no-code / code), and the success signal. | formulated problem + prioritization (also runs standalone) |

### Where to start

Building a product from scratch? **Start at #1 (`market-research`)** — it produces the Market Map every later skill builds on. Skip a step only when you already own that input (e.g. a known market → jump to #2 or #4); skipping otherwise just forces the next skill to guess the missing data.

---

## `agents/` — Subagent personas

Agents are Claude Code subagents (markdown + frontmatter) that wrap a goal and the skills that serve it. Unlike a skill (one workflow), an agent decides *which* skill to run *when*.

| Agent | What it does |
|-------|--------------|
| **product-manager** | A senior PM/PO that drives the whole Product OS pipeline. It locates where you are (which artifacts already exist), runs the next right `product/` skill via the Skill tool, respects the human-in-the-loop gates (interviews, the cut, prioritization), and never fakes evidence or marks a hypothesis as validated. Use it to take an idea from zero toward a defined MVP without orchestrating the six skills by hand. |

Invoke it by delegating to the `product-manager` agent (e.g. "ask the product-manager agent to start discovery for …"). It runs on Opus.

---

## Using a skill

- **Automatic** — describe your task in plain language; Claude invokes the matching skill when the request fits the skill's trigger description.
- **Explicit** — call it by name: `/market-research`, `/code-hygiene-review`, etc.
