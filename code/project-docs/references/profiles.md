# Perfis de documentação de projeto

Três perfis extraídos dos repos do autor. A skill unifica o **mínimo comum**
(`AGENTS.md` + `docs/STATUS.md`) e deixa extensões opcionais.

## continuity (envkeep)

**Sinais:** projeto greenfield ou em design ativo; muitas sessões com agentes
diferentes; decisões ainda sendo tomadas; escopo com fences explícitos.

```
AGENTS.md                 # read order + guardrails
docs/
  STATUS.md               # fase, done, next, log
  DECISIONS.md            # D# + reconsider-triggers
  DESIGN.md               # arquitetura / como funciona
  ROADMAP.md              # fases + triggers de escopo
README.md                 # humanos
```

**AGENTS.md:** modo read order — agente lê STATUS antes de qualquer coisa.

## shipping (open-loops)

**Sinais:** implementação madura; roadmap é checklist executável; arquitetura
documentada por domínio; ADRs absorvidos nos docs de architecture.

```
AGENTS.md                 # mapa operacional (comandos, estrutura, convenções)
CLAUDE.md                 # = AGENTS.md (symlink)
ROADMAP.md                # checklist com dependências e links
docs/
  architecture/           # 00-overview, 01-discovery, …
  features.md
  configuration.md
  STATUS.md               # ← adicionar se faltar (skill preenche lacuna)
```

**AGENTS.md:** aponta para `docs/architecture/00-overview.md`, não read order
de estado. Estado vivo pode ir em `docs/STATUS.md` sem duplicar o ROADMAP.

## design-first (vigil)

**Sinais:** contratos formais antes do código; RFCs numeradas; roadmap
Now/Next/Later; trabalho de sessão em arquivo local.

```
ROADMAP.md                # Now / Next / Later + non-goals
RFC/
  RFC-0000-….md
  RFC-XXXX-Template.md
TASK.md                   # scratch local (recomendado .gitignore)
AGENTS.md                 # criar se faltar — aponta ROADMAP + RFC index
docs/
  STATUS.md               # resumo versionado do que TASK.md espelha
```

**TASK.md:** não versionar se contém status de PRs em fluxo; espelhar marcos
em `docs/STATUS.md` para agentes que não veem o arquivo local.

## Escolha rápida

| Pergunta | Perfil |
|----------|--------|
| "Acabei de começar, agentes vão rodar o show" | continuity |
| "Já tenho architecture/ e ROADMAP com checkboxes" | shipping |
| "Tudo está em RFCs" | design-first |

## Migração entre perfis

Projetos evoluem. Transições comuns:

- **continuity → shipping:** quando `DESIGN.md` crescer demais, fatiar em
  `docs/architecture/`; mover checklist de `ROADMAP.md` para raiz; AGENTS.md
  vira mapa operacional.
- **design-first → shipping:** RFCs aceitas viram `docs/architecture/`; RFC/
  fica histórico; ROADMAP na raiz vira checklist.
- **qualquer → + STATUS:** sempre seguro adicionar `docs/STATUS.md` sem
  quebrar o resto.
