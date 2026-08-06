---
name: gct-sdd
description: >-
  Orquestra em paralelo a documentacao de multiplas issues do JIRA no repositorio
  Gestao de Contratos. Recebe uma lista de codigos de issue (ex.: DTEXPRO-6805,
  DTEXPRO-6866) e dispara um sub-agente autonomo por issue: cada um cria uma
  worktree isolada com a branch kiro/{ISSUE}, executa a skill advpl-tlpp-sdd no
  bug track ate produzir bug-spec.md e rca.md, faz commit e push, remove a
  worktree e reporta status. Nunca pergunta, nunca cria tasks.md, nunca altera
  fonte AdvPL/TLPP e nunca compila. Use quando o usuario disser: rodar gct-sdd,
  processar essas issues, documentar essas issues em paralelo, gerar RCA para
  varias issues, lista de issues do JIRA, batch de issues, spec e rca das issues,
  process these Jira issues in parallel.
license: MIT
metadata:
  domain: Protheus - Gestao de Contratos (GRR)
  maintainer: Squad Gestao de Contratos
  author: guilherme.sordi@totvs.com.br
  version: '1.0.0'
  category: Spec-Driven Development / Orchestration
  depends-on: advpl-tlpp-sdd, advpl-tlpp-root-cause-analysis
---

# GCT-SDD — Documentação paralela de issues do JIRA

Transforma uma lista de issues do JIRA em artefatos de especificação versionados, uma branch por issue, tudo em paralelo e sem interação humana durante a execução.

```
                        ┌──────────────────────────────┐
Usuário: lista de       │  ORQUESTRADOR (agente main)  │
issues do JIRA  ──────► │  parse → preflight → dispatch│
                        └──────────────┬───────────────┘
                                       │ 1 sub-agente por issue (paralelo)
        ┌──────────────────────────────┼──────────────────────────────┐
        ▼                              ▼                              ▼
┌───────────────────┐        ┌───────────────────┐        ┌───────────────────┐
│ ISSUE-A           │        │ ISSUE-B           │        │ ISSUE-C           │
│ worktree isolada  │        │ worktree isolada  │        │ worktree isolada  │
│ branch kiro/A     │        │ branch kiro/B     │        │ branch kiro/C     │
│ bug-spec → rca    │        │ bug-spec → rca    │        │ bug-spec → rca    │
│ commit + push     │        │ commit + push     │        │ commit + push     │
│ remove worktree   │        │ remove worktree   │        │ remove worktree   │
└─────────┬─────────┘        └─────────┬─────────┘        └─────────┬─────────┘
          └────────────────────────────┼────────────────────────────┘
                                       ▼
                        ┌───────────────────────────────┐
                        │ Relatório consolidado ao user │
                        └───────────────────────────────┘
```

## Entrada

Qualquer forma de lista de issues é aceita. Normalize antes de despachar:

| Forma no prompt | Exemplo | Código normalizado |
| --- | --- | --- |
| Chave padrão | `DTEXPRO-6805` | `DTEXPRO-6805` |
| Lista separada por vírgula/espaço/linha | `DTEXPRO-6805, DTEXPRO-6866` | dois códigos |
| URL do JIRA | `https://jira.totvs.com.br/browse/DTEXPRO-6805` | extrai a chave |
| Chave em minúsculas | `dtexpro-6805` | força maiúsculas |

Regras de normalização: sempre maiúsculas, sem prefixo/sufixo descritivo, deduplicar. Se nenhuma chave for identificável, pergunte a lista ao usuário — esta é a **única** pergunta permitida em todo o fluxo, e ela acontece antes do despacho.

## Fluxo do orquestrador

1. **Normalizar** a lista de issues.
2. **Preflight** no repositório principal: `git fetch origin`, confirmar árvore limpa, resolver a branch base (`origin/master`), limpar worktrees órfãs. Ver [orchestrator.md](references/orchestrator.md).
3. **Despachar um sub-agente por issue**, em paralelo, no mesmo bloco de chamadas de ferramenta. Agente: `general-task-execution`. Lote padrão: **5 concorrentes**; o excedente entra em fila e é despachado quando um slot libera.
4. **Consolidar** os relatórios e apresentar o resultado final ao usuário — uma única vez, ao término de todos.

O orquestrador **não** lê a issue no JIRA, **não** cria worktrees e **não** escreve artefatos. Isso mantém o contexto principal enxuto e evita contenção. Cada sub-agente é autossuficiente.

## Fluxo de cada sub-agente (resumo)

O protocolo autoritativo está em [issue-agent.md](references/issue-agent.md) — o sub-agente lê esse arquivo e o segue passo a passo.

| # | Passo | Resultado |
| --- | --- | --- |
| 1 | Buscar a issue via `get-jira-issue` | contexto de negócio; falha aqui aborta antes de criar worktree |
| 2 | Criar worktree + branch `kiro/{ISSUE}` | ambiente isolado a partir de `origin/master` |
| 3 | Specify do bug track (`advpl-tlpp-sdd`) | `.specs/fixes/{ISSUE}/bug-spec.md` |
| 4 | Design do bug track (`advpl-tlpp-root-cause-analysis`) | `.specs/fixes/{ISSUE}/rca.md` |
| 5 | Validar artefatos e o diff | só `.specs/fixes/{ISSUE}/**` alterado |
| 6 | Commit (pt-BR, imperativo) + `push -u` | branch remota `kiro/{ISSUE}` |
| 7 | Remover a worktree (branch preservada) | repositório principal limpo |
| 8 | Reportar status estruturado | consumido pelo orquestrador |

**Parada obrigatória após o passo 4.** O `rca.md` é a linha de chegada: nada de `tasks.md`, nada de Execute, nada de código.

## Regras invioláveis

Estas regras existem porque as skills encadeadas foram desenhadas para uso interativo e, sem override explícito, elas param para pedir aprovação ou desviam do objetivo.

1. **Modo autônomo.** Todo gate de aprovação de `advpl-tlpp-sdd` ("aguardar aprovação do usuário", "aprovar antes de investigar") é substituído por: registrar a premissa no próprio documento, na seção `Premissas e lacunas`, e prosseguir. Nenhum sub-agente pergunta nada.
2. **Sempre bug track completo.** O auto-sizing do `advpl-tlpp-sdd` desceria bugs de causa conhecida para Quick mode e pularia a RCA. Aqui isso é proibido: `bug-spec.md` **e** `rca.md` são sempre produzidos. Quick mode nunca é usado.
3. **Nunca criar `tasks.md`.** Também não crie `TASK.md`, `SUMMARY.md`, `design.md` nem `.specs/quick/**`. Os únicos arquivos permitidos são `bug-spec.md` e `rca.md` dentro de `.specs/fixes/{ISSUE}/`.
4. **Fonte é somente leitura.** Nenhum `.prw`, `.prx`, `.prg`, `.tlpp`, `.ch` ou `.aph` pode ser criado ou alterado. A skill de RCA já é read-only por contrato — mantenha assim.
5. **Nunca compilar, nunca abrir o SmartClient.** O passo 4d do `implement.md` (perguntar sobre compilação) não se aplica: não há fase Execute.
6. **Caminhos ditados pelas regras do workspace.** `.specs/fixes/{ISSUE-CODE}/bug-spec.md` e `.specs/fixes/{ISSUE-CODE}/rca.md`, com o código da issue em maiúsculas e sem slug. Isso **sobrepõe** o default `docs/rca/RCA-<rotina>-<data>.md` da skill de RCA.
7. **Uma issue, uma worktree, uma branch.** Sub-agentes nunca trabalham no diretório principal do repositório nem na worktree de outra issue.
8. **A branch sobrevive, a worktree não.** Remover a worktree ao final; jamais deletar a branch local ou remota.

## Issues que não são Bug

`rca.md` só faz sentido no bug track. Para issues cujo `issuetype` não é Bug (Story, Task, Improvement):

- Gere `.specs/features/{ISSUE-CODE}/spec.md` seguindo o Specify de features do `advpl-tlpp-sdd`.
- **Não** gere `rca.md` (não há defeito a provar) nem `tasks.md`.
- Faça commit e push normalmente e reporte status `Completed (feature track)`, deixando explícito no relatório que `rca.md` não se aplica.

Se o tipo da issue for ambíguo (ex.: Task descrevendo um comportamento errado), trate como Bug — o sintoma manda, não o rótulo do tracker.

## Gotchas

- **`.kiro/skills` está no `.gitignore`.** A worktree nasce sem as skills, mas o passo 2 do sub-agente copia a pasta inteira do workspace principal para a worktree (ver `worktree.md`, seção "Copiar skills para a worktree"). Após a cópia, referências de skill usam caminhos da worktree. Se a cópia falhar, o fallback é usar o caminho absoluto do workspace principal (`REPO_ROOT\.kiro\skills\...`).
- **`get-jira-issue` aceita só `issue_key`.** O `advpl-tlpp-sdd` menciona `fields` e `expand`; esses parâmetros não existem neste MCP. Passar qualquer outro argumento falha.
- **`git worktree add` em paralelo pode colidir** nos locks do `.git` compartilhado. Trate `index.lock`/`packed-refs.lock`/`cannot lock ref` como transitório e aplique o retry descrito em [worktree.md](references/worktree.md).
- **`.specs/` ainda não existe no repositório.** O primeiro sub-agente a rodar cria a árvore. Como cada um escreve em worktree própria e em subpasta própria, não há conflito de merge.
- **Worktree órfã trava a próxima execução.** Se um sub-agente falhar antes do passo 7, a pasta e o registro permanecem. O preflight do orquestrador detecta e limpa worktrees órfãs de execuções anteriores.
- **Branch `kiro/{ISSUE}` pode já existir** (reexecução). Reaproveite: crie a worktree apontando para a branch existente em vez de falhar, e faça um novo commit em cima.
- **Não confunda com o `engpro-spec-driven`.** Esta skill delega ao `advpl-tlpp-sdd`; nunca ao `engpro-spec-driven`.

## Relatório final

Consolide os retornos dos sub-agentes numa única tabela mais os detalhes por issue. Formato em [orchestrator.md](references/orchestrator.md). Nada de relatórios parciais no meio do processo: um status curto de progresso é aceitável, o relatório completo sai só no fim.

## Arquivos de referência

Carregue sob demanda:

- **[orchestrator.md](references/orchestrator.md)** — leia antes de despachar: normalização da lista, preflight, template do prompt do sub-agente, batching e relatório consolidado.
- **[issue-agent.md](references/issue-agent.md)** — o protocolo de 8 passos. É o arquivo que **cada sub-agente** lê ao iniciar; o orquestrador não precisa dele.
- **[worktree.md](references/worktree.md)** — leia quando criar/remover worktree ou quando um comando git falhar: comandos PowerShell, retry de lock, recuperação de falhas e limpeza de órfãs.
