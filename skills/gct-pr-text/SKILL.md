---
name: gct-pr-text
description: >-
  Redige o texto completo do Pull Request a partir das alterações da branch
  atual em relação à master, seguindo padrões de mercado (título imperativo,
  contexto, causa raiz, correção, alterações, testes). Antes de analisar,
  verifica se existem alterações pendentes de commit e, se existirem, para e
  pergunta ao usuário se devem ser consideradas. Entrega o texto no chat em
  markdown pronto para copiar e colar, encerrando com a seção TEXTO PARA
  CHECK-IN NO TFS — resumo curto em texto puro, sem crase, dentro de bloco de
  código, seguido do ID da task no formato {sub-tarefa de codificação}\{issue
  principal}, resolvido via JIRA quando possível. Use quando o usuário disser:
  redige o texto do PR, texto do PR, escreve o PR, descrição do PR, monta o
  pull request, gct-pr-text, texto de check-in, comentário de check-in do TFS,
  resumo para commit no TFS.
license: MIT
metadata:
  domain: Protheus
  module: SIGAGCT - Gestão de Contratos
  maintainer: Engenharia Protheus - Gestão de Contratos
  version: 1.1.0
  category: Documentation / Delivery
---

# GCT PR Text — Texto do Pull Request e do check-in no TFS

Transforma o diff da branch atual em dois entregáveis de entrega: o **texto do PR** (markdown, pronto para colar no formulário do Pull Request) e o **texto de check-in no TFS** (texto puro, curto, com o ID da task).

```
┌────────────────────┐   ┌──────────────────┐   ┌─────────────────┐   ┌──────────────┐   ┌──────────────────┐
│ 1. PENDÊNCIAS GIT  │ → │ 2. DIFF vs MASTER│ → │ 3. IDs NO JIRA  │ → │ 4. TEXTO PR  │ → │ 5. CHECK-IN TFS  │
└────────────────────┘   └──────────────────┘   └─────────────────┘   └──────────────┘   └──────────────────┘
   para e pergunta         commits + arquivos     issue + sub-tarefa    markdown no chat    texto puro, sem crase
```

## Entrada e saída

| | |
|---|---|
| **Entrada** | Nenhuma obrigatória. A skill trabalha sobre a branch atual do workspace. Opcionalmente o usuário informa o código da issue. |
| **Saída** | Um único bloco de texto no **chat**, em markdown, contendo o texto do PR e, no final, a seção `TEXTO PARA CHECK-IN NO TFS`. |
| **Não faz** | Não faz commit, não faz push, não abre o PR. Não cria arquivo `.md` no repositório, salvo pedido explícito de gravação. |

Regra de ouro: **a entrega é conversacional**. Nunca gravar o texto do PR em arquivo, a não ser que o usuário peça explicitamente.

Havendo pedido explícito, grave no caminho que o usuário informar, preserve a seção `TEXTO PARA CHECK-IN NO TFS` no arquivo e **apresente o texto no chat também** — o arquivo é adicional à entrega conversacional, não substituto dela.

---

## Passo 1 — Verificar alterações pendentes de commit (parada obrigatória)

Antes de qualquer análise, inspecione o estado da árvore de trabalho:

```
git status --short
```

Classifique o que aparecer:

| Indicador | Significado |
|---|---|
| `M`, `A`, `D`, `R` na 1ª coluna | alteração **staged**, ainda não commitada |
| `M`, `D` na 2ª coluna | alteração no working tree, não staged |
| `??` | arquivo **untracked** |

### 1.1 Se a saída estiver vazia

Nenhuma pendência. Informe em uma linha que a árvore está limpa e siga para o passo 2.

### 1.2 Se houver qualquer pendência — PARE

Esta é uma **parada obrigatória**. Não analise o diff, não redija nada e não presuma a resposta.

Apresente ao usuário a lista dos arquivos pendentes, agrupados por situação, e pergunte:

> Encontrei alterações pendentes de commit nesta branch:
>
> **Não commitadas (staged/working tree)**
> - `src/CNTA300R.PRW`
>
> **Não rastreadas (untracked)**
> - `tests/kanoah/CNTA300R/CT283.md`
>
> Devo considerar esses arquivos na análise do PR?

Aguarde a resposta e só então prossiga:

| Resposta | Comportamento |
|---|---|
| **Sim** / considerar | Inclui os arquivos pendentes na análise (passo 2.3) e registra no texto do PR, na seção de alterações, que existem itens ainda não commitados. |
| **Não** / ignorar | Analisa somente o que está commitado. Ao final, avisa o usuário que os arquivos pendentes ficaram fora do texto e que o PR não os conterá enquanto não forem commitados. |
| Resposta ambígua | Pergunte novamente, listando as duas opções de forma explícita. |

Não use a resposta de uma execução anterior. A pergunta se repete a cada execução da skill.

---

## Passo 2 — Analisar as alterações da branch em relação à master

### 2.1 Identificar branch atual e branch base

```
git branch --show-current
```

A base padrão é `master`. Se `master` não existir localmente, use `origin/master`. Se nenhuma das duas existir, pergunte ao usuário qual é a branch base antes de continuar.

Localize o ponto de divergência para não capturar commits da própria base:

```
git merge-base master HEAD
```

### 2.2 Coletar o conjunto de alterações commitadas

Execute, nesta ordem:

```
git log --oneline master..HEAD
git diff --stat master...HEAD
git diff master...HEAD -- <arquivo>
```

Use a notação de três pontos (`master...HEAD`) no `diff` — ela compara a partir do merge-base e evita mostrar como remoção o que evoluiu na master.

Leia o diff **de cada arquivo de código alterado**. Não redija o PR apenas a partir do `--stat` nem das mensagens de commit: o texto precisa descrever o comportamento que mudou, e isso só sai do diff.

### 2.3 Incluir pendências, quando autorizado no passo 1

```
git diff HEAD -- <arquivo>          # alterações commitáveis em arquivo rastreado
```

Para arquivos untracked, leia o conteúdo diretamente com a ferramenta de leitura de arquivos.

### 2.4 Entender o domínio antes de escrever

Interprete a alteração no contexto do produto, não só do código:

- Identifique a **rotina impactada** pelo nome do fonte (`CNTA300R`, `CNTA311`, `CNTSV121`).
- Identifique as **funções/métodos alterados** e o que cada mudança provoca em runtime.
- Identifique **tabelas e campos** envolvidos (`CND_REVISA`, `CN9_NUMERO`) e **parâmetros** (`MV_CNREVMD`).
- Quando o diff não bastar para explicar a causa raiz, procure artefatos de apoio na branch: `.specs/**`, `others/**/*.md`, RCA, spec ou documento técnico adicionados nos mesmos commits.
- Valide APIs e comportamento de framework nos MCPs (`language-system-docs-search`, `product-docs-search`, `code-search`) antes de afirmar como algo funciona. Não descreva comportamento de framework por suposição.

Distinga os tipos de arquivo para classificar a entrega corretamente:

| Caminho | Natureza |
|---|---|
| `src/**` | correção ou evolução de produto |
| `tests/Scripts AdvPR/Cases/**` | script de teste AdvPR |
| `tests/kanoah/**` | documentação de caso de teste de regressão |
| `others/**` | customização, spike, RCA ou material de apoio — **não** é entrega de produto |
| `.kiro/**`, `AGENTS.md`, `*.instructions.md` | configuração de agente e convenções |

---

## Passo 3 — Resolver o ID da issue principal e da sub-tarefa de codificação

O ID alimenta a seção de check-in. Resolva na seguinte ordem, parando no primeiro passo que der certeza.

### 3.1 Issue principal

1. **Informada pelo usuário** na conversa — usar diretamente.
2. **Contexto da sessão** — issue já identificada em passos anteriores da mesma conversa.
3. **Nome da branch** — assuma o nome da branch como candidato à chave da issue (`DTEXPRO-7123`, `kiro/DTEXPRO-7123` → `DTEXPRO-7123`) e **confirme no JIRA** com `get-jira-issue`.
4. **Commits da branch** — procure a chave nas mensagens de `git log master..HEAD`.

Regras de decisão:

- Se o `get-jira-issue` retornar a issue e o `summary` for coerente com o diff analisado, considere identificada.
- Se a issue retornada for uma **sub-tarefa** (`is_subtask`), a issue principal é o `parent` dela.
- Se o JIRA não responder, não encontrar a chave, ou o `summary` não tiver relação com o diff, **confirme com o usuário** antes de usar.
- Nunca invente chave, nem deduza a partir de numeração de issues vizinhas.

### 3.2 Sub-tarefa de codificação

Com a issue principal identificada, consulte `get-jira-issue` e examine `subtasks`:

- Selecione a sub-tarefa cujo `summary`/`issue_type` caracterize **codificação** (termos como codificação, desenvolvimento, implementação, correção de fonte).
- Havendo mais de uma candidata, prefira a atribuída ao desenvolvedor da branch (`people.developer` ou `assignee`) e a que esteja concluída ou em andamento; se ainda restar ambiguidade, **liste as candidatas e pergunte** ao usuário.
- Se não houver nenhuma sub-tarefa de codificação, não force uma sub-tarefa de outra natureza (teste, documentação, revisão).

### 3.3 Formato e fallback

O ID da task usa o padrão de nota de check-in do TFVC:

```
{sub-tarefa de codificação}\{issue principal}
```

Use os identificadores exatamente como registrados no JIRA (mesmo tipo — chave ou ID numérico — nos dois lados da barra), mantendo a barra invertida como separador, sem espaços.

Se ao final do passo 3 algum dos dois não for identificado com certeza, preencha **apenas o que faltou** com `Não identificado`:

```
ID da task: Não identificado\DTEXPRO-7123
ID da task: Não identificado
```

Não deixe placeholder, campo vazio ou texto inventado.

---

## Passo 4 — Redigir o texto do PR

Escreva em **português do Brasil**, com acentuação e ortografia corretas. Identificadores de código (fontes, funções, campos, parâmetros) permanecem na forma original.

### 4.1 Título

```
{CHAVE-DA-ISSUE} - {ROTINA} - {verbo no imperativo}{o que muda}
```

- Verbo no imperativo: Corrige, Adiciona, Altera, Remove, Refatora, Otimiza, Documenta.
- Até ~72 caracteres. O detalhe vai no corpo, não no título.
- Sem ponto final.
- Omita a chave da issue se ela não tiver sido identificada.

Exemplo: `DTEXPRO-7123 - CNTA300R - Corrige exclusão indevida de medições ao desfazer revisão`

### 4.2 Seções do corpo

Inclua apenas as seções que a alteração justifica. Um PR de correção normalmente usa todas; um PR só de teste ou documentação dispensa Causa raiz.

| Seção | Conteúdo |
|---|---|
| **Contexto** | O comportamento esperado, o comportamento observado e o caminho de execução envolvido (`CN300DesRv` → `CnDrProces` → `CNA300RvMd`). Fecha com a rastreabilidade: issue, ticket Zendesk, versão. |
| **Causa raiz** | A razão técnica do defeito, no fonte e na função exatos. Uma explicação, não a narrativa da investigação. |
| **Correção** / **Implementação** | O que mudou no comportamento, em itens curtos. Cite a condição/regra introduzida. Registre o que **não** mudou quando isso evita leitura equivocada (por exemplo: o comportamento com `MV_CNREVMD` habilitado permanece). |
| **Alterações** | Lista de arquivos com o papel de cada um, agrupando por natureza (produto, teste, documentação, apoio). Marque explicitamente o que não é entrega de produto. |
| **Testes** | Caso de teste criado ou executado, com identificação (`CN300R_283` / `CT283`), massa utilizada e pontos de verificação. Se não houve teste automatizado, descreva a validação manual. |
| **Observações** | Limitações, pendências, itens não compilados/não executados, arquivos ainda não commitados, dependências de pacote ou dicionário. Omita a seção se não houver nada relevante. |

### 4.3 Boas práticas de redação

- Comece pelo fato: o que o PR resolve. Sem preâmbulo.
- Descreva comportamento, não a cronologia do trabalho.
- Não use emoji.
- Não invente número de ticket, versão, parâmetro ou nome de campo.
- Não afirme que algo foi testado, compilado ou validado sem evidência no diff ou na conversa.
- Frases curtas. Cada item deve acrescentar informação.

---

## Passo 5 — Seção TEXTO PARA CHECK-IN NO TFS

Última seção do texto do PR, sempre presente, com o título exato:

```
## TEXTO PARA CHECK-IN NO TFS
```

Dentro dela, um **bloco de código** contendo, nesta ordem:

1. Resumo curto do que foi alterado — 1 a 3 frases, em **texto puro**.
2. Linha em branco.
3. A linha do ID da task.

Restrições do bloco, sem exceção:

- **Nenhum caractere crase** no conteúdo.
- Nenhuma marcação markdown: sem `**`, sem `#`, sem `-`, sem lista.
- Sem emoji.
- Referências a código aparecem como texto simples: `nRecCndAnt maior que zero`, não a expressão entre crases.
- O bloco existe para facilitar o copiar e colar: nada de comentário ou instrução dentro dele.

Modelo:

~~~
Corrige a função CNA300RvMd (src/CNTA300R.PRW), que ao desfazer uma revisão excluía indevidamente medições existentes apenas na revisão desfeita. O estorno da medição anterior passa a ocorrer somente quando há registro CND correspondente (nRecCndAnt maior que zero); caso contrário, a medição é apenas devolvida à revisão anterior. Adiciona o caso de teste AdvPR CN300R_283 (CT283).

ID da task: 123456\123450
~~~

---

## Formato da resposta no chat

Entregue o texto do PR em um único bloco de código markdown, delimitado por **quatro crases**, para que os blocos internos de código sejam preservados ao copiar.

Estrutura da resposta:

1. Uma linha declarando o que foi analisado: branch, branch base, quantidade de commits e de arquivos, e se pendências foram incluídas ou ignoradas.
2. O bloco com o texto completo do PR, encerrado pela seção `TEXTO PARA CHECK-IN NO TFS`.
3. Se aplicável, uma linha final com as pendências que o usuário precisa resolver (arquivo não commitado, ID não identificado, fonte não compilado).

Nada além disso. Sem repetir o conteúdo do PR em prosa fora do bloco.

---

## Checklist antes de responder

- [ ] `git status --short` foi executado **antes** da análise.
- [ ] Havendo pendências, o usuário foi consultado e a resposta dele foi respeitada.
- [ ] O diff foi comparado com `master...HEAD` a partir do merge-base.
- [ ] O diff de cada arquivo de código foi efetivamente lido.
- [ ] Arquivos de `others/**` não foram apresentados como entrega de produto.
- [ ] Título no imperativo, com a rotina e até ~72 caracteres.
- [ ] Nenhuma afirmação de teste, compilação ou validação sem evidência.
- [ ] A seção `TEXTO PARA CHECK-IN NO TFS` está presente, em bloco de código, sem crase e sem markdown.
- [ ] O ID da task está no formato `{sub-tarefa}\{issue principal}`, com `Não identificado` no que não foi resolvido.
- [ ] Nenhum arquivo foi criado no repositório — exceto quando houve pedido explícito de gravação, caso em que o arquivo está no caminho pedido e o texto também foi apresentado no chat.
