# MARIO — Arquivos criados por fase e por skill

Este documento lista os arquivos que o agente **MARIO** e suas skills delegadas
criam ao tratar uma issue de manutenção do TOTVS Protheus, indicando a **fase** em
que cada arquivo nasce e a **skill** responsável por criá-lo.

Fonte: `skills/mario/SKILL.md` e as references de fase
(`skills/mario/references/phase-1-business-refinement.md`,
`phase-2-technical-refinement.md`, `phase-3-coding.md`).

## Onde os arquivos ficam

Todo artefato de especificação do MARIO vive em `.specs/mario/{ISSUE}/`, onde
`{ISSUE}` é a chave do JIRA em maiúsculas, sem slug descritivo. Nas referências da
skill, essa pasta aparece grafada como `mario/{ISSUE}`.

> `mario/{ISSUE}` é também o nome da **branch** de trabalho (chave em maiúsculas).
> A pasta de artefatos é `.specs/mario/{ISSUE}/`.

Único artefato fora dessa árvore: o **script AdvPR**, gravado no repositório alvo em
`tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW`.

## Tabela de arquivos

| Arquivo | Caminho | Fase | Skill que cria | Observação |
| --- | --- | --- | --- | --- |
| `mario.status.md` | `.specs/mario/{ISSUE}/` | 1 (criado na primeira fase executada) | MARIO | Único registro de estado; atualizado ao final de cada fase |
| `business-refinement.md` | `.specs/mario/{ISSUE}/` | 1 — Refinamento de negócio | MARIO | Nenhuma skill delegada nesta fase |
| `bug-spec.md` | `.specs/mario/{ISSUE}/` | 2 — Refinamento técnico | `advpl-tlpp-sdd` (fase Specify, bug track) | — |
| `rca.md` | `.specs/mario/{ISSUE}/` | 2 — Refinamento técnico | `advpl-tlpp-sdd` (fase Design, aciona `advpl-tlpp-root-cause-analysis` por dentro) | Override do default `docs/rca/RCA-<rotina>-<data>.md` |
| `context.md` | `.specs/mario/{ISSUE}/` | 2 — Refinamento técnico | `advpl-tlpp-sdd` | Só quando o Discuss for acionado |
| `test-case.md` | `.specs/mario/{ISSUE}/` | 2 — Refinamento técnico | MARIO | Cenário de regressão aprovado |
| `kanoah/{routine}/{CTxxx}.md` | `.specs/mario/{ISSUE}/` | 2 — Refinamento técnico | `gct-tests` (modo "apenas Kanoah") | Override do default `tests/kanoah/{rotina}/{CTxxx}.md` |
| `tasks.md` | `.specs/mario/{ISSUE}/` | 3 — Codificação | `advpl-tlpp-sdd` (fase Tasks) | — |
| Fonte corrigido | repositório alvo | 3 — Codificação | `advpl-tlpp-sdd` (fase Execute) | Convertido para CP-1252 com `utf8-to-cp1252-conversion` |
| `{Rotina}TestCase.PRW` (script AdvPR) | `tests/Scripts AdvPR/Cases/` (repositório alvo) | 3 — Codificação | `gct-tests` | Único artefato fora de `.specs/mario/{ISSUE}/` |
| `technical-doc.md` | `.specs/mario/{ISSUE}/` | 3 — Codificação | `tdn-technical-doc-writer` (sem publicar no Confluence) | Override do default de publicação em página do Confluence |
| `pr-text.md` | `.specs/mario/{ISSUE}/` | 3 — Codificação | `gct-pr-text` (com gravação em arquivo) | A skill normalmente só entrega no chat; aqui grava por pedido explícito |
| `side-findings.md` | `.specs/mario/{ISSUE}/` | 3 — Codificação | MARIO | Criado **apenas quando houver achados** colaterais |

## Notas

- **Fases 4, 5 e 6 não criam arquivos na pasta da issue.** A fase 4 (validação) e a
  fase 6 (teste de aceitação) são humanas; a fase 5 (code review) é acionada sob
  demanda pela skill `code-review` e entrega o resultado apenas no chat.
- **Arquivos condicionais:** `context.md` (só com Discuss) e `side-findings.md` (só
  com achados) podem não existir em uma execução.
- **Overrides de caminho:** `advpl-tlpp-sdd`, `advpl-tlpp-root-cause-analysis`,
  `gct-tests`, `tdn-technical-doc-writer` e `gct-pr-text` têm caminhos default
  próprios; o MARIO impõe o destino em `.specs/mario/{ISSUE}/` no prompt de cada
  delegação.
