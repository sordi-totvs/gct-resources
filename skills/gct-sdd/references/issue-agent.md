# Protocolo do sub-agente (uma issue)

Você processa **uma** issue do JIRA, do início ao fim, sem interação humana. Execute os 8 passos em ordem. Não pule passos, não invente passos.

## Regras que valem em todos os passos

1. **Modo autônomo.** Nunca pergunte nada, nunca aguarde aprovação. Quando uma skill encadeada pedir input ou aprovação, resolva com a melhor inferência disponível e registre a decisão na seção `Premissas e lacunas` do documento que estiver escrevendo. Uma premissa registrada é aceitável; uma pergunta ao usuário não é.
2. **Fonte é somente leitura.** Nenhum `.prw`, `.prx`, `.prg`, `.tlpp`, `.ch`, `.aph` criado, alterado ou removido. Você investiga o código; não o corrige.
3. **Nada de compilar** e nada de abrir SmartClient/WebApp.
4. **Nada de `tasks.md`.** Nem `TASK.md`, `SUMMARY.md`, `design.md` ou `.specs/quick/**`.
5. **Escreva só dentro da worktree.** Nunca grave em `REPO_ROOT`.
6. **Skills são copiadas para a worktree.** No passo 2, as skills do workspace principal são copiadas para `{WORKTREE_PATH}\.kiro\skills\`. Use preferencialmente o caminho da worktree para ler referências de skill. Se por algum motivo a cópia falhar, use o caminho absoluto em `REPO_ROOT\.kiro\skills\...` como fallback.
7. **Evidência antes de afirmação.** Não reporte "arquivo criado" ou "push feito" sem ter conferido com um comando.

---

## Passo 1 — Buscar a issue no JIRA

Chame `get-jira-issue` com **apenas** `issue_key`. Esse MCP não aceita `fields` nem `expand`; qualquer parâmetro extra falha.

```
get-jira-issue(issue_key = "{ISSUE_CODE}")
```

Extraia e guarde: `summary`, `description`, `issuetype`, `status`, `priority`, `components`, `labels`, comentários relevantes.

**Decida a trilha:**

| `issuetype` | Trilha | Artefatos |
| --- | --- | --- |
| Bug / Defect | Bug track | `bug-spec.md` + `rca.md` |
| Story / Task / Improvement descrevendo comportamento errado | Bug track (o sintoma manda) | `bug-spec.md` + `rca.md` |
| Story / Task / Improvement descrevendo funcionalidade nova | Feature track | `spec.md` apenas |

**Se a issue não existir, o MCP falhar ou a descrição estiver vazia a ponto de não permitir caracterizar nada:** pare aqui, **não crie worktree**, e reporte `Blocked` no passo 8 com o motivo. Abortar antes de criar worktree evita lixo no repositório.

## Passo 2 — Criar a worktree e a branch

Consulte `REPO_ROOT\.kiro\skills\gct-sdd\references\worktree.md` para os comandos, o retry de lock e o tratamento de branch preexistente.

Resultado esperado: worktree em `WORKTREE_PATH`, na branch `kiro/{ISSUE_CODE}`, criada a partir de `BASE_BRANCH`.

Confirme antes de seguir:

```powershell
git -C "{WORKTREE_PATH}" rev-parse --abbrev-ref HEAD   # deve imprimir kiro/{ISSUE_CODE}
git -C "{WORKTREE_PATH}" status --porcelain            # deve estar vazio
```

### Copiar skills para a worktree

`.kiro/skills` está no `.gitignore`, então a worktree nasce sem elas. Copie imediatamente após criar:

```powershell
$skillsSrc  = Join-Path "{REPO_ROOT}" ".kiro" "skills"
$skillsDest = Join-Path "{WORKTREE_PATH}" ".kiro" "skills"

if (Test-Path $skillsSrc) {
    New-Item -ItemType Directory -Path (Join-Path "{WORKTREE_PATH}" ".kiro") -Force | Out-Null
    Copy-Item -Path $skillsSrc -Destination $skillsDest -Recurse -Force
}

# Confirme
Test-Path $skillsDest   # True
```

Com isso, referências de skill podem usar caminhos relativos à worktree (`{WORKTREE_PATH}\.kiro\skills\...`). A pasta copiada é ignorada pelo git e não aparecerá no diff.

Se a worktree não puder ser criada após os retries, reporte `Blocked`.

## Passo 3 — Specify: gerar a bug spec

Leia `REPO_ROOT\.kiro\skills\advpl-tlpp-sdd\references\bug-spec.md` e siga o template dele.

Grave em: `{WORKTREE_PATH}\.specs\fixes\{ISSUE_CODE}\bug-spec.md`

Preencha a partir da issue do JIRA:

| Seção da bug spec | Origem |
| --- | --- |
| Título e resumo do defeito | `summary` + `description` |
| Severidade | `priority` |
| Módulo/Rotina | `components` + rotinas citadas na descrição |
| Comportamento atual vs. esperado | descrição e comentários, no formato WHEN/THEN/SHALL |
| Passos de reprodução | descrição; se ausentes, derive dos dados disponíveis e marque como inferidos |
| Escopo e restrições | inferido do impacto; liste explicitamente o que não tocar |
| Critérios de aceite | derivados do comportamento esperado, incluindo não-regressão |
| Rastreabilidade | IDs `BUG-{ISSUE_CODE}-NN` |

Adicione ao final do documento:

```markdown
## Rastreabilidade JIRA

- **Issue:** {ISSUE_CODE}
- **Link:** https://jira.totvs.com.br/browse/{ISSUE_CODE}
- **Tipo:** {issuetype} - **Status:** {status} - **Prioridade:** {priority}

## Premissas e lacunas

> Documento gerado em modo autonomo pela skill `gct-sdd`. Onde a issue nao trazia
> informacao suficiente, a premissa abaixo foi adotada e precisa de validacao humana.

| # | Lacuna | Premissa adotada | Precisa validar |
| --- | --- | --- | --- |
| 1 | (o que faltava) | (o que foi assumido) | Sim |
```

Nunca deixe placeholder entre colchetes no documento final: ou preencha com informação real, ou registre a lacuna na tabela de premissas e escreva "Não informado na issue" no campo.

**Feature track:** grave `{WORKTREE_PATH}\.specs\features\{ISSUE_CODE}\spec.md` seguindo `advpl-tlpp-sdd\references\specify.md`, com as mesmas seções de rastreabilidade JIRA e premissas, e pule o passo 4.

## Passo 4 — Design: gerar a RCA

Leia `REPO_ROOT\.kiro\skills\advpl-tlpp-root-cause-analysis\SKILL.md` e conduza as 6 fases da metodologia. Use o template em `references\rca-template.md` e, quando útil para classificar o defeito, `references\defect-patterns.md`.

Grave em: `{WORKTREE_PATH}\.specs\fixes\{ISSUE_CODE}\rca.md`

**Este caminho sobrepõe o default da skill** (`docs/rca/RCA-<rotina>-<data>.md`), por exigência das regras de artefato do workspace. Não crie `docs/rca/`.

Pontos de atenção:

- **Investigue o código real da worktree**, não o do diretório principal. Ao usar ferramentas de leitura e busca, aponte para `WORKTREE_PATH`.
- **LSP primeiro, MCP depois.** Navegue definições e referências no código; valide semântica de API e dicionário nos MCPs (`language-system-docs-search`, `product-docs-search`, `code-search`, `execute-sql`). Nunca conclua por memória.
- **A causa raiz precisa de evidência.** Arquivo + função + branch + linha, mais o que prova. Se após investigação honesta a causa não puder ser provada, escreva isso explicitamente no `rca.md`: hipóteses levantadas, o que foi descartado e com qual evidência, e o que falta para provar. Um RCA inconcluso e honesto é entregável; um RCA com causa inventada não é.
- **A correção é proposta, não aplicada.** Snippet no documento, zero edição no fonte.
- Se a causa raiz cair fora do escopo declarado na bug spec, não renegocie com o usuário: registre o conflito na seção `Premissas e lacunas` do `rca.md` e siga.

**Pare aqui.** Não gere `tasks.md`, não planeje execução, não implemente.

## Passo 5 — Validar antes de commitar

```powershell
# Artefatos existem e nao estao vazios
Get-Item "{WORKTREE_PATH}\.specs\fixes\{ISSUE_CODE}\bug-spec.md" | Select-Object Name, Length
Get-Item "{WORKTREE_PATH}\.specs\fixes\{ISSUE_CODE}\rca.md"      | Select-Object Name, Length

# Diff contem SOMENTE os artefatos da issue
git -C "{WORKTREE_PATH}" status --porcelain
```

Checklist bloqueante:

- [ ] `bug-spec.md` e `rca.md` existem e têm conteúdo (`Length > 0`).
- [ ] Nenhum arquivo fora de `.specs/fixes/{ISSUE_CODE}/` aparece no `git status`.
- [ ] Nenhum `.prw/.prx/.prg/.tlpp/.ch/.aph` no diff. **Se aparecer, reverta**: `git -C "{WORKTREE_PATH}" checkout -- <arquivo>` e reporte a violação.
- [ ] Nenhum `tasks.md` foi criado.
- [ ] Nenhum placeholder entre colchetes sobrou nos documentos.

Se o checklist falhar e não for corrigível, não commite: reporte `Failed`.

## Passo 6 — Commit e push

Adicione **caminhos específicos**, nunca `git add .` ou `-A`:

```powershell
git -C "{WORKTREE_PATH}" add ".specs/fixes/{ISSUE_CODE}/bug-spec.md" ".specs/fixes/{ISSUE_CODE}/rca.md"
```

Mensagem em pt-BR, imperativa, assunto até 72 caracteres, corpo referenciando a issue:

```
Documenta causa raiz do bug {ISSUE_CODE}

Adiciona bug spec com comportamento atual versus esperado, passos de
reproducao, escopo e criterios de aceite, alem da analise de causa raiz
com evidencias e proposta de correcao minima.

Issue: {ISSUE_CODE}
Nenhum fonte AdvPL/TLPP foi alterado.
```

Para feature track, o assunto vira `Documenta especificacao da issue {ISSUE_CODE}`.

```powershell
git -C "{WORKTREE_PATH}" commit -F <arquivo-de-mensagem>
git -C "{WORKTREE_PATH}" push -u origin "kiro/{ISSUE_CODE}"
git -C "{WORKTREE_PATH}" rev-parse --short HEAD
```

Não use `--no-verify`. Se um hook de pre-commit alterar arquivos, re-adicione e faça um **novo** commit — nunca `--amend`. Falha de push por rede: tente novamente até 3 vezes com espera crescente; se persistir, reporte `Failed` deixando a worktree intacta para inspeção.

## Passo 7 — Remover a worktree

Só remova com a árvore limpa e o push confirmado.

```powershell
git -C "{WORKTREE_PATH}" status --porcelain     # precisa estar vazio
git -C "{REPO_ROOT}" worktree remove "{WORKTREE_PATH}"
git -C "{REPO_ROOT}" worktree prune
git -C "{REPO_ROOT}" worktree list              # confirma que saiu da lista
```

**Nunca** delete a branch — nem local (`branch -d/-D`), nem remota. Ela é o entregável.

Se a remoção falhar (arquivo em uso, processo com lock), não force às cegas: reporte a worktree remanescente no passo 8 com o comando de limpeza manual `git worktree remove "<path>" --force`.

## Passo 8 — Reportar

Retorne exatamente neste formato. É o que o orquestrador consome.

```markdown
### {ISSUE_CODE} — Completed | Completed (feature track) | Blocked | Failed

- **Tipo da issue:** {issuetype}
- **Trilha:** bug track | feature track
- **Branch:** kiro/{ISSUE_CODE} (push: OK | falhou)
- **Commit:** {sha curto}
- **Artefatos:**
  - `.specs/fixes/{ISSUE_CODE}/bug-spec.md` ({N} bytes)
  - `.specs/fixes/{ISSUE_CODE}/rca.md` ({N} bytes)
- **Causa raiz:** `{arquivo}:{funcao}:{linha}` — uma linha | Nao provada: o que falta
- **Premissas registradas:** {N}
- **Worktree:** removida | remanescente em `{path}` (limpar com: `git worktree remove "{path}" --force`)
- **Fontes alterados:** nenhum
- **Problemas:** nenhum | descricao
```

Para `Blocked`/`Failed`, informe o passo em que parou e a causa. Seja factual: se algo não foi verificado, diga que não foi verificado.
