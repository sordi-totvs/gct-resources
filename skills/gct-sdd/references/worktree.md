# Worktree: criação, retry e limpeza

Leia quando criar ou remover uma worktree, ou quando um comando git falhar. Todos os comandos são para PowerShell no Windows.

## Convenção de caminho e branch

| Item | Valor |
| --- | --- |
| Diretório da worktree | `{pai do repo}\{nome do repo}-{ISSUE_CODE}` |
| Exemplo | `C:\git\gestao-de-contratos-DTEXPRO-6805` |
| Branch | `kiro/{ISSUE_CODE}` |
| Base | `BASE_BRANCH` resolvido no preflight (normalmente `origin/master`) |

A worktree fica **fora** do repositório, como diretório irmão. Essa escolha é deliberada: worktree dentro do repo exigiria entrada no `.gitignore` e poluiria o `git status` se alguém esquecesse. Diretório irmão elimina a classe inteira de problemas — e é a convenção já usada neste repositório.

## Criar

```powershell
$issue    = "{ISSUE_CODE}"
$repoRoot = "{REPO_ROOT}"
$wtPath   = "{WORKTREE_PATH}"
$branch   = "kiro/$issue"
$baseRef  = "{BASE_BRANCH}"

# A branch ja existe em algum lugar?
$localExists  = (git -C $repoRoot rev-parse --verify --quiet "refs/heads/$branch")
$remoteExists = (git -C $repoRoot rev-parse --verify --quiet "refs/remotes/origin/$branch")

if ($localExists) {
    # Reaproveita a branch local existente
    git -C $repoRoot worktree add "$wtPath" "$branch"
}
elseif ($remoteExists) {
    # Cria local rastreando a remota
    git -C $repoRoot worktree add "$wtPath" -b "$branch" "origin/$branch"
}
else {
    # Caminho normal: branch nova a partir da base
    git -C $repoRoot worktree add "$wtPath" -b "$branch" "$baseRef"
}
```

Verifique sempre depois de criar:

```powershell
git -C "$wtPath" rev-parse --abbrev-ref HEAD   # kiro/{ISSUE_CODE}
git -C "$wtPath" status --porcelain            # vazio
```

## Retry de lock (execução paralela)

Worktrees diferentes compartilham o mesmo diretório `.git`. Com N sub-agentes rodando ao mesmo tempo, `worktree add`, `fetch` e `push` podem colidir nos locks. As falhas são transitórias — o certo é esperar e repetir, não abortar.

Trate como transitório quando a mensagem contiver:

- `index.lock`
- `packed-refs.lock`
- `cannot lock ref`
- `Unable to create ... File exists`
- `another git process seems to be running`

```powershell
$attempt = 0
$maxAttempts = 5
do {
    $attempt++
    $output = (git -C $repoRoot worktree add "$wtPath" -b "$branch" "$baseRef" 2>&1)
    $ok = ($LASTEXITCODE -eq 0)
    if (-not $ok) {
        $transient = $output -match 'lock|another git process|File exists'
        if (-not $transient) { break }          # erro real: nao insista
        Start-Sleep -Seconds (2 * $attempt)     # backoff: 2s, 4s, 6s, 8s
    }
} while (-not $ok -and $attempt -lt $maxAttempts)
```

Nunca "resolva" um lock apagando `.git\index.lock` à mão. Isso corromperia a operação de outro sub-agente que está legitimamente segurando o lock.

## Remover

Só remova com a árvore limpa e o push já confirmado.

```powershell
git -C "$wtPath" status --porcelain              # precisa estar vazio
git -C $repoRoot worktree remove "$wtPath"
git -C $repoRoot worktree prune
git -C $repoRoot worktree list                   # confirma a saida da lista
```

A branch **permanece**, local e remota. Ela é o entregável da issue. Nunca rode `git branch -d`, `git branch -D` ou `git push origin --delete` nessa branch.

## Falhas comuns

| Sintoma | Causa | O que fazer |
| --- | --- | --- |
| `fatal: '<branch>' is already used by worktree at ...` | Worktree órfã de execução anterior | `git worktree list`, confirme o path, `git worktree remove <path> --force`, `git worktree prune`, e recrie |
| `fatal: '<path>' already exists` | Diretório sobrou sem registro no git | `git worktree prune`; se o diretório persistir e estiver vazio, remova-o; se tiver conteúdo, reporte e não apague às cegas |
| `worktree remove` falha com "contains modified or untracked files" | Artefato não commitado ou lixo | Verifique o `git status`; se for artefato legítimo, commite e faça push antes de remover. Não use `--force` para descartar trabalho |
| `worktree remove` falha com arquivo em uso | Editor/processo com o diretório aberto | Não force. Reporte a worktree remanescente com o comando de limpeza manual |
| `push` rejeitado por `non-fast-forward` | Branch remota avançou desde o `fetch` | `git -C "$wtPath" pull --rebase origin "$branch"`, revalide o diff e faça push de novo |
| `push` falha por credencial | Sem credencial válida para `code.engpro.totvs.com.br` | Não tente contornar. Reporte `Failed` e deixe a worktree intacta para inspeção do usuário |

## Limpeza de órfãs (preflight do orquestrador)

```powershell
# Lista worktrees registradas e sinaliza as que sumiram do disco
git -C $repoRoot worktree list --porcelain

# Remove registros de worktrees cujo diretorio nao existe mais
git -C $repoRoot worktree prune

# Remocao explicita de orfa conhecida
git -C $repoRoot worktree remove "C:\git\gestao-de-contratos-DTEXPRO-6805" --force
git -C $repoRoot worktree prune
```

Só remova com `--force` worktrees de issues **da execução atual** ou que você tenha confirmado serem restos de execuções anteriores da própria `gct-sdd`. Worktrees de outras finalidades (ex.: `gestao-de-contratos-w2`) não são da sua alçada — deixe intactas.
