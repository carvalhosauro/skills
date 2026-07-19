---
name: project-docs
description: >-
  Standardizes durable project memory for AI agents (Claude Code, Cursor, Codex,
  OpenCode): AGENTS.md + docs/{STATUS,ROADMAP,DECISIONS,DESIGN}.md with read
  order, session log, and decisions with reconsider-triggers. Use when the user
  asks to initialize project docs for agents, record an architecture/product
  decision, update STATUS/ROADMAP after work, or close a session documenting
  what changed. Also: "docs setup for agents", "project memory", "continuity
  between sessions", "registrar decisão", "encerrar sessão nos docs" — EN or PT.
  Not for product discovery or roadmap brainstorming without a docs/init ask.
---

# Project Docs

Padroniza a **memória durável do projeto** — o que qualquer agente precisa saber
para retomar trabalho sem re-derivar contexto. Complementa (não substitui)
README, CHANGELOG e docs de produto/arquitetura maduros.

**Leve por design:** sem hooks, sem comandos slash obrigatórios, sem diretório
oculto. Tudo em Markdown versionado no repo, legível por humanos e agentes.

## O que esta skill NÃO faz

- Não substitui `docs/architecture/` numerado (open-loops) nem `RFC/` (vigil) —
  aponta para eles quando o projeto já os tem.
- Não edita código de aplicação.
- Não impõe regras de engenharia (TDD, Clean Arch, etc.) — só documentação.

## Perfis — escolha no init

Leia `references/profiles.md` para o mapa completo. Resumo:

| Perfil | Quando | Arquivos base |
|--------|--------|---------------|
| **continuity** | Greenfield, muitos agentes/sessões, design ainda fluido | `AGENTS.md` + `docs/{STATUS,DECISIONS,DESIGN,ROADMAP}.md` |
| **shipping** | Implementação madura, checklist executável, ADRs por domínio | `AGENTS.md` (mapa operacional) + `ROADMAP.md` na raiz + `docs/architecture/` |
| **design-first** | Spec antes/durante build, contratos formais | `ROADMAP.md` + `RFC/` + opcional `TASK.md` local |

**Regra de unificação:** todo projeto ganha pelo menos `AGENTS.md` + `docs/STATUS.md`.
Os outros arquivos entram conforme o perfil. Projetos existentes: **auditar antes
de sobrescrever** — mapear o que já existe para o perfil mais próximo.

## AGENTS.md — dois modos

### Modo `continuity` (read order)

`AGENTS.md` é entrypoint com **read order** explícito, guardrails e resumo de
uma linha. Modelo: envkeep.

### Modo `shipping` / `design-first` (mapa operacional)

`AGENTS.md` é mapa de trabalho: comandos, estrutura de código, convenções,
ponteiros para docs detalhados. Modelo: open-loops. Se `CLAUDE.md` existir,
mantê-lo idêntico ou symlink → `AGENTS.md`.

Em ambos os modos: **curto** (~100 linhas). Detalhe fica em `docs/`.

## Workflows

### 1. Init — `inicializar docs do projeto`

1. **Auditar** o repo: liste `AGENTS.md`, `CLAUDE.md`, `ROADMAP.md`, `docs/**`,
   `RFC/**`, `TASK.md`. Não apague nada sem confirmar com o usuário.
2. **Perguntar o perfil** se não estiver claro pelo contexto:
   - projeto novo / design-first → `continuity` ou `design-first`
   - OSS maduro com architecture docs → `shipping`
   - já tem estrutura parecida com envkeep → `continuity`
3. **Scaffold** só arquivos ausentes, a partir dos templates em `references/`.
   Preencher placeholders com o que souber do README ou da conversa.
4. **Symlink opcional:** se o harness usa `CLAUDE.md` e não existe, sugerir
   `ln -s AGENTS.md CLAUDE.md` (não executar sem pedido).
5. **Resumir** o que foi criado, o read order, e o protocolo de sessão.

### 2. Session start — retomar projeto

1. Ler `AGENTS.md`.
2. Ler `docs/STATUS.md` (ou `TASK.md` se for o scratch local do vigil).
3. Se mudança arquitetural planejada: ler `docs/DECISIONS.md` (ou RFC
   relevante) **antes** de codar.
4. Confirmar em uma linha: fase atual + próxima ação.

### 3. Session end — encerrar sessão

Obrigatório ao encerrar qualquer sessão com mudanças relevantes:

1. **Atualizar `docs/STATUS.md`:**
   - `## Next action` — o que o próximo agente deve fazer primeiro.
   - `## Done` — mover itens concluídos nesta sessão.
   - `## Log` — append (newest last): `**YYYY-MM-DD · <o quê> · <por que importa>**`
2. **Atualizar `docs/ROADMAP.md`** se fases/itens mudaram.
3. **Registrar decisões novas** em `docs/DECISIONS.md` (formato D#) ou na RFC
   (DEC-NNN) — nunca só no chat.
4. **Não** inflar `AGENTS.md` — se algo novo é durável mas longo, vai em
   `docs/DESIGN.md` ou `docs/architecture/`.

### 4. Record decision — registrar decisão

Antes de propor mudança de design:

1. Buscar em `docs/DECISIONS.md` (grep pelo tema) ou RFCs (`DEC-` / `D#`).
2. Se conflita com decisão `ACCEPTED`: citar a entrada e o reconsider-trigger.
   Só mudar se o trigger disparou — então marcar `SUPERSEDED`/`REVISED` e
   adicionar nova entrada.
3. Nova entrada: próximo `D#` em `docs/DECISIONS.md` usando
   `references/template-decisions-entry.md`.

Para perfil `design-first`: copiar `references/template-rfc.md` ou adicionar
`DEC-NNN` na RFC existente.

### 5. Migrate — alinhar projeto existente

Para repos como open-loops ou vigil **sem apagar** o que funciona:

| Já existe | Ação |
|-----------|------|
| `ROADMAP.md` na raiz | Manter; adicionar `docs/STATUS.md` se faltar |
| `docs/architecture/` | Manter; `AGENTS.md` aponta para `00-overview.md` |
| `RFC/` | Manter; `docs/STATUS.md` resume PRs/fase atual |
| `TASK.md` (local) | Manter como scratch; opcional espelhar resumo em `docs/STATUS.md` |
| Sem `AGENTS.md` | Criar no modo adequado ao perfil |

## Convenções transversais (todos os perfis)

- **STATUS** = onde estamos *agora* + log narrativo (append-only no log).
- **ROADMAP** = o que construir, em que ordem; fases futuras com **triggers**
  explícitos (scope fence).
- **DECISIONS** = *por quê*; cada entrada com alternativas rejeitadas e
  reconsider-trigger.
- **DESIGN** = *como* funciona hoje (arquitetura, layout, state machines).
- Decisão sem registro = decisão que o próximo agente vai reverter sem saber.

## Multi-harness

| Harness | Descoberta |
|---------|------------|
| Claude Code | `CLAUDE.md` e/ou `AGENTS.md` na raiz |
| Cursor | `AGENTS.md` (rules) + skills |
| Codex | `AGENTS.md` em `~/.codex/` ou raiz do projeto |
| OpenCode | `AGENTS.md` + `.opencode/skills/` |

**Fonte canônica:** `AGENTS.md` na raiz do repo. Symlink tool-specific só
quando o harness não lê `AGENTS.md` nativamente.

## Templates

| Arquivo | Uso |
|---------|-----|
| `references/profiles.md` | Mapa de perfis e migração |
| `references/template-agents-continuity.md` | AGENTS.md modo read order |
| `references/template-agents-shipping.md` | AGENTS.md modo operacional |
| `references/template-status.md` | `docs/STATUS.md` |
| `references/template-roadmap.md` | `docs/ROADMAP.md` (fases + triggers) |
| `references/template-decisions.md` | `docs/DECISIONS.md` (cabeçalho) |
| `references/template-decisions-entry.md` | Uma entrada D# |
| `references/template-design.md` | `docs/DESIGN.md` |
| `references/template-roadmap-checklist.md` | `ROADMAP.md` estilo open-loops |
| `references/template-rfc.md` | RFC estilo vigil (simplificado) |
| `references/template-task.md` | `TASK.md` scratch local |

## Princípios

- **Progressive disclosure:** AGENTS.md aponta; docs/ explicam.
- **História é o ponto:** log e decisões superseded ficam — não apagar o porquê.
- **Mínimo viável:** na dúvida, só `AGENTS.md` + `docs/STATUS.md`.
- **Consistência > perfeição:** mesma estrutura em todos os projetos reduz
  carga cognitiva entre harnesses.
