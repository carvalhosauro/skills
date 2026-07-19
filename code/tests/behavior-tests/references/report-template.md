# Report template

Write to `docs/audit/test-logging-YYYY-MM-DD_HH-MM.md` using this structure.
Prose in the user's language (default pt-BR). Keep it tight and actionable.

```markdown
# Testes, cobertura e logs — <YYYY-MM-DD HH:MM>

**Escopo:** <session | repo | path>  ·  **Framework:** <ex.: pytest>
**Comando:** `<comando único de teste>`

## Suíte

- Resultado: <X passaram, Y falharam, Z skip>
- <se houver falhas: liste as principais com arquivo:teste>

## Cobertura

| Métrica            | Antes  | Depois |
| ------------------ | ------ | ------ |
| Linhas (geral)     | <a>%   | <b>%   |
| Escopo analisado   | <a>%   | <b>%   |

> "Depois" só aparece se testes foram adicionados nesta execução.

## Testes adicionados

- `caminho/do/teste_x.py` — cobre `Modulo.funcao` (caminho de erro).
- `...`

(Se nada foi escrito: "Nenhum teste adicionado — apenas análise.")

## Lacunas de cobertura priorizadas (não escritas)

- **[ALTA]** `arquivo:funcao` — sem teste; deveria validar <o quê>.
- **[MÉDIA]** `arquivo:funcao` — branch de erro não coberto.

## Achados — qualidade de testes

- **[ALTA] <título>** — `arquivo:linha`
  Por quê: <...>. Direção: <...>.

## Achados — logging

- **[ALTA] <título>** — `arquivo:linha`
  Por quê: <...>. Direção: <...>.

## Não aplicável / nada encontrado

- <categorias sem achados>.

---
_Esta skill só cria/edita arquivos de teste. Nenhum código de produção foi alterado._
```

Rules:
- Order findings high → low within each section.
- The "Testes adicionados" section lists only what was actually written and
  verified green.
- Gaps that were proposed but NOT written go under "Lacunas priorizadas".
- Never claim a source file was changed — this skill doesn't touch source.
