# Orquestrador

Leia este arquivo antes de despachar qualquer sub-agente. Ele cobre normalização da lista, preflight, o template do prompt de despacho, batching e o relatório consolidado.

## 1. Normalizar a lista de issues

Extraia todas as chaves do prompt do usuário e produza uma lista limpa.

```
Regex de chave:  [A-Za-z][A-Za-z0-9_]+-\d+
Regex de URL:    /browse/([A-Za-z][A-Za-z0-9_]+-\d+)
```

Depois de extrair:

1. Converta para **maiúsculas** (`dtexpro-6805` → `DTEXPRO-6805`).
2. **Deduplique** preservando a ordem de aparição.
3. Remova qualquer slug ou texto agregado (`DTEXPRO-6805-reajuste` → `DTEXPRO-6805`).

Confirme a lista normalizada ao usuário em uma linha antes de despachar, sem pedir aprovação — é informativo, não um gate:

```
Processando 3 issues em paralelo: DTEXPRO-6805, DTEXPRO-6866, DTEXPRO-6901
```

Se nenhuma chave for identificável, pergunte a lista. É a única pergunta permitida no fluxo.

## 2. Preflight (repositório principal)

Rode do diretório principal do repositório. Objetivo: garantir que os sub-agentes partam de um estado previsível e que não haja lixo de execuções anteriores.

```powershell
# Raiz do repositório e nome do projeto
$repoRoot = (git rev-parse --show-toplevel)
$repoName = Split-Path $repoRoot -Leaf

# Branch base — resolvida, nunca assumida
$baseRef = (git symbolic-ref --quiet refs/remotes/origin/HEAD)
if (-not $baseRef) { $baseRef = "refs/remotes/origin/master" }
$baseBranch = $baseRef -replace '^refs/remotes/', ''   # ex.: origin/master

# Atualizar refs uma unica vez (evita N fetches concorrentes nos sub-agentes)
git fetch origin --prune

# Estado da arvore principal
git status --porcelain

# Worktrees registradas
git worktree list
```

Checagens e reações:

| Checagem | Reação |
| --- | --- |
| `git status --porcelain` retorna linhas | Não bloqueia: os sub-agentes trabalham em worktrees próprias. Apenas registre no relatório final que a árvore principal tinha alterações pendentes. |
| `git worktree list` mostra worktree órfã de uma issue da lista atual | Limpe antes de despachar: `git worktree remove <path> --force; git worktree prune` |
| `git fetch` falha (rede/credencial) | Aborte tudo e reporte ao usuário. Sem `fetch` os sub-agentes partiriam de base desatualizada. |

Passe `repoRoot`, `repoName` e `baseBranch` resolvidos para cada sub-agente no prompt — não deixe cada um redescobrir, para não divergirem.

## 3. Despachar os sub-agentes

Use `invoke_sub_agent` com `name: "general-task-execution"`. **Todas as chamadas do lote no mesmo bloco de ferramentas**, para que rodem de fato em paralelo.

- **Lote padrão: 5 concorrentes.** Com mais que isso a contenção nos locks do `.git` compartilhado e o custo de contexto passam a doer.
- Issues além do lote entram em fila e são despachadas quando um slot libera.
- Nunca despache duas vezes a mesma issue no mesmo lote.

### Template do prompt (preencha os placeholders)

```
Voce e um agente autonomo processando UMA issue do JIRA no repositorio Gestao de Contratos.

ISSUE: {ISSUE_CODE}
REPO_ROOT: {REPO_ROOT}
REPO_NAME: {REPO_NAME}
BASE_BRANCH: {BASE_BRANCH}
WORKTREE_PATH: {WORKTREE_PATH}
BRANCH: kiro/{ISSUE_CODE}

PRIMEIRO PASSO OBRIGATORIO: leia o protocolo completo e siga-o a risca:
  {REPO_ROOT}\.kiro\skills\gct-sdd\references\issue-agent.md

Referencias que voce vai precisar (caminhos absolutos do workspace principal —
a worktree NAO tem .kiro/skills porque esta no .gitignore):
  {REPO_ROOT}\.kiro\skills\gct-sdd\references\worktree.md
  {REPO_ROOT}\.kiro\skills\advpl-tlpp-sdd\SKILL.md
  {REPO_ROOT}\.kiro\skills\advpl-tlpp-sdd\references\bug-spec.md
  {REPO_ROOT}\.kiro\skills\advpl-tlpp-sdd\references\design.md
  {REPO_ROOT}\.kiro\skills\advpl-tlpp-root-cause-analysis\SKILL.md
  {REPO_ROOT}\.kiro\skills\advpl-tlpp-root-cause-analysis\references\rca-template.md
  {REPO_ROOT}\.kiro\skills\advpl-tlpp-root-cause-analysis\references\defect-patterns.md

RESTRICOES ABSOLUTAS:
- Modo autonomo total: NUNCA pergunte, NUNCA aguarde aprovacao. Gates de aprovacao
  das skills viram premissas registradas na secao "Premissas e lacunas" do documento.
- Produza exatamente: .specs/fixes/{ISSUE_CODE}/bug-spec.md e .specs/fixes/{ISSUE_CODE}/rca.md
  (ou .specs/features/{ISSUE_CODE}/spec.md se a issue nao for Bug).
- NUNCA crie tasks.md, TASK.md, SUMMARY.md, design.md nem nada em .specs/quick/.
- NUNCA altere, crie ou remova arquivo .prw/.prx/.prg/.tlpp/.ch/.aph. Fonte e somente leitura.
- NUNCA compile e NUNCA abra o SmartClient.
- Trabalhe SOMENTE dentro de WORKTREE_PATH. Nunca escreva em REPO_ROOT.
- Ao final, remova a worktree mas PRESERVE a branch local e remota.

RETORNE o relatorio estruturado exatamente no formato definido no passo 8 do protocolo.
```

`WORKTREE_PATH` = `{pai de REPO_ROOT}\{REPO_NAME}-{ISSUE_CODE}` — ex.: `C:\git\gestao-de-contratos-DTEXPRO-6805`. Diretório irmão, fora do repositório, portanto imune a problemas de `.gitignore`.

## 4. Consolidar

Enquanto os sub-agentes rodam, não produza relatórios parciais. Um progresso curto é aceitável; o relatório completo sai só quando todos terminarem (incluindo a fila).

### Relatório consolidado

```markdown
## GCT-SDD — Resultado

| Issue | Tipo | Branch | bug-spec | rca | Push | Worktree | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DTEXPRO-6805 | Bug | kiro/DTEXPRO-6805 | OK | OK | OK | removida | Completed |
| DTEXPRO-6866 | Bug | kiro/DTEXPRO-6866 | OK | OK | OK | removida | Completed |
| DTEXPRO-6901 | Story | kiro/DTEXPRO-6901 | n/a (spec.md) | n/a | OK | removida | Completed (feature track) |

**Totais:** 3 issues - 3 Completed - 0 Blocked - 0 Failed

### Detalhes por issue

**DTEXPRO-6805** — [resumo de 1 linha da causa raiz provada]
- Causa raiz: `arquivo:funcao:linha` — [evidência resumida]
- Premissas registradas: [N] (ver seção "Premissas e lacunas" do rca.md)
- Commit: `<sha curto>`

**DTEXPRO-6866** — ...

### Pendências para o usuário
- [Issues Blocked/Failed com o motivo e o que fazer]
- [Worktrees que não puderam ser removidas, com o comando de limpeza manual]
```

Regras do relatório:

- Uma linha por issue na tabela, sempre — inclusive as que falharam.
- Status possíveis: `Completed`, `Completed (feature track)`, `Blocked`, `Failed`.
- `Blocked` = não conseguiu começar (issue inexistente, sem acesso ao JIRA, branch travada). `Failed` = começou e quebrou no meio.
- Para `Blocked`/`Failed`, informe o passo em que parou e o comando de limpeza manual, se houver worktree remanescente.
- Nunca declare sucesso sem que o sub-agente tenha confirmado a existência dos arquivos e o push. Relato de agente sem evidência não conta.
