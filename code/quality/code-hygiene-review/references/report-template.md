# Report template

Write the report to `docs/audit/review-YYYY-MM-DD_HH-MM.md` using this exact
structure. Write the prose in the user's language (default pt-BR). Keep it tight
— it's a map for a human to act on, not an essay.

```markdown
# Revisão de higiene de código — <YYYY-MM-DD HH:MM>

**Escopo:** <session | repo inteiro | path>  ·  **Arquivos analisados:** <N>

## Resumo

| Severidade | Qtd |
| ---------- | --- |
| Alta       | <n> |
| Média      | <n> |
| Baixa      | <n> |
| **Total**  | <n> |

Por categoria: Magic values <n> · Código morto <n> · Duplicação <n> ·
N+1 <n> · Tipagem <n> · Legibilidade <n>

> Top 3 arquivos com mais problemas: `a.rb` (n) · `b.ts` (n) · `c.py` (n)

## Achados por arquivo

### `caminho/do/arquivo.ext`  — <peso de severidade>

- **[ALTA] <título>** — `linha 42` · _Categoria: <categoria>_
  Por quê: <impacto na legibilidade/manutenção>.
  Direção: <sugestão de uma linha, sem patch>.

- **[MÉDIA] <título>** — `linha 88` · _Categoria: <categoria>_
  Por quê: <...>.
  Direção: <...>.

### `outro/arquivo.ext`  — <peso>

- **[BAIXA] <título>** — `linha 12` · _Categoria: <categoria>_
  Por quê: <...>.
  Direção: <...>.

## Não aplicável

- N+1: <linguagens/arquivos onde não se aplica>.
- Tipagem: <onde não há sistema de tipos adotado>.

---
_Relatório somente informativo — nenhum arquivo foi modificado._
```

Rules for filling it in:
- Order files by total severity weight (high=3, medium=2, low=1), worst first.
- Within a file, order findings high → low.
- If a finding was flagged by two categories for the same line, merge it and list
  both categories.
- If a whole category found nothing, omit it from per-file findings but say so in
  a one-line "Nada encontrado em: <categorias>" note under the summary.
- Never include code patches. The `Direção` line is a pointer, not a fix.
