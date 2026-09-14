# Questionário de Refinamento — Mario

## Como responder

Responda abaixo de cada pergunta, mantendo a numeração. Respostas curtas são
suficientes. Quando a sugestão estiver adequada, responda `manter sugestão`.
Itens marcados como **Essencial** afetam diretamente a implementação.

## 1. Escopo e arquitetura da entrega

### 1.1 O MARIO deve ser entregue como uma única skill orquestradora ou como um conjunto de skills, uma por fase? — **Essencial**

Este repositório versiona skills (`skills/<nome>/SKILL.md`). O briefing chama o
MARIO de "agente" e ainda menciona a criação de "uma skill" para a fase 1, o que
deixa a granularidade da entrega em aberto. `.kiro/agents` é ignorado pelo Git,
então um custom agent não pode ser versionado aqui.

**Sugestão:** uma única skill `skills/mario/`, com o fluxo das fases no `SKILL.md`
e um arquivo em `references/` por fase (`phase-1-business-refinement.md`,
`phase-2-technical-refinement.md`, `phase-3-coding.md`, além de arquivos de
apoio). A "skill de análise de fontes" citada na fase 1 nasce como
`references/phase-1-business-refinement.md` do próprio MARIO, não como skill
separada.

Resposta: Uma única skill `skills/mario/`, com o fluxo das fases no SKILL.md e um arquivo em references/ por fase (phase-1-business-refinement.md, phase-2-technical-refinement.md, phase-3-coding.md). A skill de análise de fontes citada na fase 1 nasce como references/phase-1-business-refinement.md do próprio MARIO, não como skill separada.
O nosso objetivo é entregar um agente, além da skill. O usuário, ao usar esse agente, saberá que está trabalhando justamente dentro desse fluxo independentemente de quais skills ou tools venham a ser usadas.
O nosso objetivo é entregar um agente, além da skill. O usuário, ao usar esse agente, saberá que está trabalhando justamente dentro desse fluxo independentemente de quais skills ou tools venham a ser usadas.

### 1.2 Qual é a relação do MARIO com a skill `gct-sdd`, que já produz `bug-spec.md` e `rca.md` por issue? — **Essencial**

A `gct-sdd` orquestra várias issues em paralelo, em worktrees isoladas, sem
interação humana, gravando em `.specs/fixes/{ISSUE}/`. O MARIO cobre o mesmo
terreno da fase 2, mas de forma interativa e com gate humano.

**Sugestão:** o MARIO é interativo, trata uma issue por execução e é independente
da `gct-sdd`, que permanece para o processamento em lote. O MARIO não delega à
`gct-sdd`; aciona a mesma skill base (`advpl-tlpp-sdd`) e reaproveita no seu
`references/` os overrides de caminho e de modo já validados na `gct-sdd`,
trocando o modo autônomo pelos gates de aprovação humana.

Resposta: manter sugestão

### 1.3 O MARIO é específico do módulo Gestão de Contratos (SIGAGCT) ou agnóstico de módulo Protheus? — **Essencial**

As skills deste repositório variam: `gct-tests` e `gct-pr-text` declaram
`module: SIGAGCT`, enquanto `advpl-tlpp-performance-analysis` é agnóstica.

**Sugestão:** agnóstico de módulo Protheus. O repositório alvo é o repositório de
módulo aberto no workspace, e convenções específicas de módulo (base congelada,
prefixos de rotina) continuam residindo nas skills delegadas.

Resposta: manter sugestão

### 1.4 As fases 4, 5 e 6 fazem parte do escopo executável do MARIO? — **Essencial**

O briefing atribui as fases 4 a 6 a humanos, mas na fase 5 o humano pede ao
agente que faça o code review.

**Sugestão:** as fases 1 a 3 são executáveis pelo MARIO. A fase 5 é acionável sob
demanda e delega à skill `code-review`, entregando o resultado no chat sem
publicar comentários. As fases 4 e 6 ficam fora do escopo: o `SKILL.md` apenas as
descreve como responsabilidade humana e lista o que o humano precisa validar.

Resposta: manter sugestão

### 1.5 Como o agente do MARIO será versionado e distribuído, dado que `/.kiro/agents` está no `.gitignore` deste repositório? — **Essencial**

A resposta da 1.1 acrescentou a entrega de um agente, além da skill. Verificado
neste workspace: agentes são arquivos `*.agent.md` em `.kiro/agents/` (exemplo
instalado: `browse-to-smartx-migrator.agent.md`), e o `.gitignore` ignora
`/.kiro/agents` e `/.kiro/skills`. Ou seja, o agente não pode ser versionado no
caminho em que é consumido.

Sobre a distribuição, verifiquei a extensão Dex instalada (`sordi.dex-2.5.0`): ela
instala apenas em `.kiro/skills` (ou `.agents/skills` no VS Code) e não trata
agentes. Então a instalação do agente é manual nesta versão, por cópia para
`.kiro/agents/` do repositório alvo.

**Sugestão:** versionar a definição em `agents/mario.agent.md` na raiz do
repositório e documentar no `README.md` a instalação por cópia para
`.kiro/agents/` do repositório alvo. O agente permanece fino — identidade, fluxo
das 6 fases e gates —, delegando o detalhamento à skill `mario`.

Resposta: Este projeto cria recursos de IA para serem usados em outros projetos. Hoje o único tipo de recurso é skill, na pasta `skills` da raiz. O agente é um novo tipo de recurso, então ele deve ficar em uma nova pasta chamada `agents`.

### 1.6 A incorporação da `gct-sdd` ao ecossistema do MARIO entra nesta entrega ou fica para depois? — **Essencial**

A 1.2 decidiu coexistência (MARIO interativo, `gct-sdd` em lote), mas a intenção
declarada é absorver a `gct-sdd` no MARIO em algum momento. Dois fatos pesam na
decisão: os modelos de autonomia são opostos — a `gct-sdd` tem "nunca pergunta"
como regra inviolável e o MARIO para em gate a cada fase — e a `gct-sdd` cobre
apenas a fase 2, sem a fase 1, que é a parte inédita do MARIO.

**Sugestão:** depois, em duas etapas. Nesta entrega, o MARIO nasce interativo e a
`gct-sdd` continua como está. Quando as fases 1 a 3 estiverem estáveis, a
`gct-sdd` é absorvida como modo lote do MARIO (`references/modo-lote.md`),
herdando o despacho paralelo, o worktree e o retry de lock já provados nas suas
três references. Para a absorção sair barata, três pontos já ficam decididos
agora: prefixo único de branch (2.6), pasta única de artefatos — o lote passa a
gravar em `.specs/mario/{ISSUE}` — e nomes de artefato idênticos (3.1, que já
coincidem). Enquanto a absorção não acontecer, o `SKILL.md` do MARIO declara
quando usar cada uma, para não gerar artefato duplicado da mesma issue em pastas e
branches diferentes.

Resposta: manter sugestão

## 2. Fluxo, estado e aprovação

### 2.1 Como o gate de aprovação ao final de cada fase deve funcionar? — **Essencial**

**Sugestão:** ao concluir uma fase, o MARIO apresenta no chat um resumo, os
caminhos dos artefatos gerados e as pendências, encerra o turno e aguarda
aprovação explícita do usuário. Nunca inicia a fase seguinte no mesmo turno, nem
interpreta silêncio ou pedido genérico ("continua") como aprovação da fase
anterior sem confirmar o que foi aprovado.

Resposta: manter sugestão

### 2.2 Como o MARIO reconhece em que fase uma issue está ao ser retomado em outra sessão? — **Essencial**

**Sugestão:** manter `.specs/mario/{ISSUE}/mario.status.md` com fase atual, data,
aprovações registradas, decisões de degradação (MCP ausente, por exemplo) e
pendências abertas. Na retomada, ler esse arquivo; na ausência dele, inferir a
fase pelos artefatos existentes e declarar a inferência ao usuário antes de agir.

Resposta: manter sugestão

### 2.3 O usuário pode acionar uma fase isolada, sem passar pelas anteriores? — **Essencial**

**Sugestão:** sim. Aceitar pedidos como "rodar a fase 2 da issue X". Antes de
executar, validar que os artefatos da fase anterior existem e estão aprovados no
`mario.status.md`; se não estiverem, avisar o que está faltando e pedir
confirmação explícita para prosseguir mesmo assim, registrando a decisão.

Resposta: Sim. Aceitar pedidos como "rodar a fase 2 da issue X", validando antes que os artefatos da fase anterior existem e estão aprovados no mario.status.md; se não estiverem, avisar o que falta e não prosseguir.

### 2.4 O que acontece quando a fase 1 concluir que a issue não é um bug? — **Essencial**

**Sugestão:** o fluxo para. O documento da fase 1 é gravado com a conclusão, as
evidências e a nota de confiabilidade, e o MARIO reporta ao usuário sugerindo os
encaminhamentos possíveis (devolver ao atendimento, tratar como melhoria,
solicitar mais informações). A fase 2 só começa com decisão explícita do usuário.

Resposta: manter sugestão

### 2.5 O MARIO deve criar branch e/ou worktree para a issue? — **Essencial**

**Sugestão:** uma issue por execução, no diretório de trabalho atual, sem
worktree. No início de qualquer fase, se a branch atual não for a branch da issue,
o MARIO informa e pergunta se deve criar uma nova branch a partir da base do
repositório (`origin/master` ou `origin/main`), precedida de `git fetch origin`.
Confirmado, cria e ativa a branch antes de seguir; negado, continua na branch
atual. Nunca faz commit, push nem abre pull request — isso pertence à fase 4, que
é humana. Paralelismo entre issues continua sendo papel da `gct-sdd`.

Resposta: Uma issue por execução, no diretório de trabalho atual, sem worktree. No início de qualquer parte do fluxo, se a branch atual não for `mario/{ISSUE}`, informar o usuário e perguntar se ele quer criar uma nova branch baseada na master. Se confirmar, criar a branch, ativá-la e só então continuar a tarefa. Se negar, seguir na branch atual — não é impedimento.
Nunca fazer commit, push ou abrir PR (fase 4, humana). Paralelismo entre issues continua sendo papel da gct-sdd.
Nunca fazer commit, push ou abrir PR (fase 4, humana). Paralelismo entre issues continua sendo papel da gct-sdd.

### 2.6 Qual é o nome definitivo da branch: `kiro/{ISSUE}` ou `mario/{issue}`? — **Essencial**

A resposta da 2.5 traz os dois nomes: manteve `kiro/{ISSUE}` da sugestão e
acrescentou `mario/{issue}` para o caso de partida da master/main. Como é o mesmo
propósito, precisa de um nome único.

**Sugestão:** usar `mario/{ISSUE}`, com a chave em maiúsculas igual à da pasta de
artefatos (3.2), reservando o prefixo `kiro/` para as branches da `gct-sdd` e
evitando colisão entre as duas skills na mesma issue.

Resposta: Usar `mario/{ISSUE}`, com a chave em maiúsculas igual à da pasta de artefatos (3.2).

### 2.7 Como tratar a árvore de trabalho suja no momento de criar a branch? — **Essencial**

Alterações não commitadas mudam o comportamento do Git: `git switch -c
mario/{ISSUE} origin/master` levaria as alterações pendentes para a nova branch
quando não há conflito com o checkout, e falharia quando há. Por isso a criação
precisa de uma regra explícita.

**Sugestão:** com a árvore suja, não criar a branch e tratar como impedimento — o
MARIO lista os arquivos pendentes (`git status --short`), explica que precisa de
árvore limpa para criar a branch a partir da base e para, sem fazer stash,
descartar ou commitar nada. Com a árvore limpa, criar a partir de `origin/master`
(ou `origin/main`) após `git fetch origin`, ativar a branch e seguir.

Resposta: Quando a árvore estiver suja, a nova branch `mario/{ISSUE}` não deve ser criada — isso é um impeditivo no fluxo. Se a árvore estiver limpa, a nova branch pode ser criada.

### 2.8 O impedimento da árvore suja vale também quando o usuário já está na branch `mario/{ISSUE}`? — **Essencial**

Nesse caso não há branch a criar, então o motivo do impedimento da 2.7 não se
aplica. Uma leitura estrita, porém, travaria a retomada da fase 3 com alterações
em andamento, que é situação normal de trabalho.

**Sugestão:** não. O impedimento pertence ao caminho de criação de branch. Já
estando em `mario/{ISSUE}`, a fase segue normalmente, com os arquivos pendentes
listados ao usuário e registrados como pendência no `mario.status.md`, porque
afetam o diff que a fase 3 vai descrever no `pr-text.md`.

Resposta: manter sugestão

## 3. Artefatos e caminhos

### 3.1 Quais são os nomes exatos dos artefatos em `.specs/mario/{issue}`? — **Essencial**

Verificado em `.kiro/skills/advpl-tlpp-sdd`: no bug track a skill grava em
`.specs/fixes/[bug]/` os arquivos `bug-spec.md` (Specify), `rca.md` (Design) e
`tasks.md` (Tasks) — os três nomes já coincidem com a sugestão abaixo, então só a
pasta muda. Dois defaults, porém, não coincidem e precisam de override explícito
(ver 3.3): a skill `advpl-tlpp-root-cause-analysis`, acionada por dentro do
Design, grava em `docs/rca/RCA-<rotina>-<AAAA-MM-DD>.md`, e o Quick mode grava
`TASK.md` + `SUMMARY.md` em `.specs/quick/NNN-slug/` (proibido pela 4.1).

**Sugestão:** nomes em inglês em todos os artefatos, preservando exatamente os
nomes que a `advpl-tlpp-sdd` já usa e traduzindo os que são do MARIO.

| Quem cria | Fase | Arquivo | Condição |
| --- | --- | --- | --- |
| `advpl-tlpp-sdd` | 2 | `bug-spec.md` | sempre |
| `advpl-tlpp-sdd` | 2 | `rca.md` | sempre |
| `advpl-tlpp-sdd` | 2 | `context.md` | só quando o Discuss for acionado |
| `advpl-tlpp-sdd` | 3 | `tasks.md` | sempre |
| MARIO | controle | `mario.status.md` | sempre |
| MARIO | 1 | `business-refinement.md` | sempre |
| MARIO | 2 | `test-case.md` | sempre |
| MARIO | 2 | `kanoah/{routine}/{CTxxx}.md` | sempre (caminho da resposta da 3.4) |
| MARIO | 3 | `technical-doc.md` | sempre |
| MARIO | 3 | `pr-text.md` | sempre |
| MARIO | 3 | `side-findings.md` | só quando houver achados (ver 4.5) |

Nota sobre `side-findings.md`: é o relatório de problemas colaterais. Evitei
`side-issues.md` porque "issue" já significa a issue do JIRA em todo o projeto, e
o duplo sentido atrapalharia a leitura dos caminhos.

Resposta: manter sugestão

### 3.2 Qual é o formato de `{issue}` no caminho? — **Essencial**

**Sugestão:** a chave do JIRA em maiúsculas, sem slug descritivo:
`.specs/mario/DTEXPRO-6805/`. Aceitar na entrada chave em minúsculas, ID numérico
ou URL do JIRA, normalizando para a chave em maiúsculas.

Resposta: manter sugestão

### 3.3 Como garantir que as skills delegadas gravem em `.specs/mario/{issue}` em vez de seus caminhos padrão? — **Essencial**

As skills delegadas têm defaults próprios (`.specs/fixes/{ISSUE}/`,
`.specs/features/`, `.specs/quick/`, `docs/rca/RCA-<rotina>-<data>.md`,
`tests/kanoah/...`).

**Sugestão:** o `SKILL.md` do MARIO declara os caminhos como regra inviolável e
informa o caminho de destino explícito no prompt de cada delegação, sobrepondo o
default. Ao final de cada fase, validar via `git status` que nenhum artefato de
especificação foi criado fora de `.specs/mario/{ISSUE}` e mover o que estiver
fora, avisando o usuário.

Resposta: manter sugestão

### 3.4 O caso de teste (Kanoah) e o script AdvPR também ficam em `.specs/mario/{issue}`? — **Essencial**

A regra do briefing fala de "arquivos de especificação". O Kanoah e o script
AdvPR são artefatos de teste com caminhos já estabelecidos pela `gct-tests`.

**Sugestão:** o Kanoah permanece em `tests/kanoah/{rotina}/{CTxxx}.md` e o script
em `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW`, conforme a `gct-tests`. O
arquivo `test-case.md` da fase 2, em `.specs/mario/{ISSUE}`, registra o
cenário de regressão aprovado e referencia o caminho real do Kanoah e o nome do
método AdvPR.

Resposta: O kanoah fica em .specs/mario/{issue}/kanoah/{rotina}/{CTxxx}.md e o script em tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW

### 3.5 O que fazer com a memória de projeto da `advpl-tlpp-sdd`? — **Essencial**

Além da pasta da feature, a skill mantém arquivos compartilhados, não vinculados
a uma issue: `.specs/project/STATE.md` (decisões, bloqueios, lições, todos),
`.specs/project/PROJECT.md`, `.specs/project/ROADMAP.md`, os sete documentos de
`.specs/codebase/` (`STACK.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`,
`STRUCTURE.md`, `TESTING.md`, `INTEGRATIONS.md`, `CONCERNS.md`) e
`.specs/HANDOFF.md`, que é sobrescrito a cada handoff de sessão.

**Sugestão:** o MARIO não usa a memória de projeto da skill — nenhum arquivo em
`.specs/project/`, `.specs/codebase/` ou `.specs/HANDOFF.md` é criado ou
atualizado. Decisões, bloqueios e pendências ficam no `mario.status.md` da issue,
único registro de estado. Se esses arquivos já existirem no repositório alvo,
podem ser lidos como contexto, nunca escritos.

Resposta: manter sugestão

## 4. Delegação às skills existentes

### 4.1 Qual skill produz `bug-spec.md`, `rca.md` e `tasks.md`? — **Essencial**

Decisão já tomada pelo usuário: obrigatoriamente a `advpl-tlpp-sdd`. A
`advpl-tlpp-root-cause-analysis` continua sendo usada, mas por dentro do bug
track da `advpl-tlpp-sdd`, não em chamada direta do MARIO.

**Sugestão:** o MARIO aciona a `advpl-tlpp-sdd` no bug track para os três
artefatos e proíbe o Quick mode e qualquer auto-sizing que pule RCA ou tasks —
`bug-spec.md`, `rca.md` e `tasks.md` são sempre produzidos.

Resposta: obrigatoriamente com a skill `advpl-tlpp-sdd`.

### 4.2 O documento técnico deve ser publicado no TDN/Confluence ou apenas gravado como `.md`? — **Essencial**

A skill `tdn-technical-doc-writer` monta o payload e publica a página no
Confluence após aprovação. O briefing pede um arquivo `.md`.

**Sugestão:** usar a `tdn-technical-doc-writer` somente até a montagem do
conteúdo e gravar `technical-doc.md` em `.specs/mario/{ISSUE}`. Não publicar
no Confluence: a publicação é decisão humana da fase 4. O documento deve deixar
claro que está pronto para publicação e qual template ele segue.

Resposta: manter sugestão

### 4.3 Como resolver o conflito com a `gct-pr-text`, que proíbe gravar o texto do PR em arquivo? — **Essencial**

A `gct-pr-text` entrega o texto apenas no chat, salvo pedido explícito. O
briefing exige o texto do PR em arquivo `.md`.

**Sugestão:** o MARIO aciona a `gct-pr-text` com o pedido explícito de gravação e
salva o resultado em `.specs/mario/{ISSUE}/pr-text.md`, preservando a seção
`TEXTO PARA CHECK-IN NO TFS`. O texto também é apresentado no chat no
encerramento da fase 3.

Resposta: Acionar a gct-pr-text com o pedido explícito de gravação e salvar o resultado em .specs/mario/{ISSUE}/pr-text.md, preservando a seção TEXTO PARA CHECK-IN NO TFS. O texto também é apresentado no chat no encerramento da fase 3. Ajustes podem ser feitos na skill gct-pr-text se necessário.

### 4.4 Na fase 3, o MARIO deve converter encoding e compilar os fontes alterados? — **Essencial**

**Sugestão:** alterar o mínimo necessário para corrigir o defeito; converter todo
fonte tocado com `utf8-to-cp1252-conversion`; oferecer a compilação via
`advpl-tlpp-compile` e executá-la somente após confirmação do usuário, corrigindo
até zero erros. Sem compilação confirmada, registrar isso como pendência no
`pr-text.md` e no `mario.status.md`.

Resposta: Por enquanto, o MARIO não vai compilar ou executar. Vamos implementar isso em outro momento.

### 4.5 Onde registrar os problemas colaterais encontrados durante a fase 3?

**Sugestão:** criar `.specs/mario/{ISSUE}/side-findings.md` apenas quando
houver achados, com um item por problema (fonte, função, sintoma, risco de deixar
sem correção e esforço estimado), e listá-los no resumo de encerramento da fase 3
para decisão do usuário. Nenhum deles é corrigido sem aprovação explícita.

Resposta: manter sugestão

### 4.6 Qual skill produz o documento de caso de teste de regressão da fase 2? — **Essencial**

Este item saiu da 4.1, que agora trata apenas de `bug-spec.md`, `rca.md` e
`tasks.md`. O briefing lista `kanoah-advpr-generator` como pré-requisito, mas
neste repositório a `gct-tests` é a skill que produz o Kanoah em markdown e o
script AdvPR; a `kanoah-advpr-generator` produz o XML de importação no Zephyr
Scale.

**Sugestão:** `gct-tests` no modo "apenas Kanoah" para o caso de teste da fase 2 e
para o script AdvPR da fase 3. A `kanoah-advpr-generator` é acionada apenas quando
o usuário pedir o XML de importação no Zephyr.

Resposta: manter sugestão

### 4.7 Como as fases do MARIO se mapeiam nas fases da `advpl-tlpp-sdd` e onde ficam os gates? — **Essencial**

A `advpl-tlpp-sdd` tem quatro fases próprias (Specify, Design, Tasks, Execute) e
seus próprios pontos de aprovação. O MARIO tem gates apenas ao final das suas
fases 1, 2 e 3.

**Sugestão:** acionar a `advpl-tlpp-sdd` por fase, nunca de ponta a ponta —
Specify e Design na fase 2 do MARIO (`bug-spec.md` + `rca.md`), Tasks no início da
fase 3 (`tasks.md`). Os gates internos da `advpl-tlpp-sdd` entre Specify, Design e
Tasks são suprimidos: valem os gates do MARIO. Premissas que a skill pediria para
aprovar ficam registradas no próprio documento, no padrão que a `gct-sdd` já usa.

Resposta: manter sugestão

### 4.8 A fase Execute da `advpl-tlpp-sdd` conduz a codificação da fase 3? — **Essencial**

A decisão do usuário cobre explicitamente `bug-spec.md`, `rca.md` e `tasks.md`. A
implementação em si pode seguir pelo Execute da mesma skill ou ser conduzida pelo
próprio MARIO a partir do `tasks.md`.

**Sugestão:** sim, usar o Execute da `advpl-tlpp-sdd` para executar as tasks,
mantendo commit atômico desabilitado (o MARIO não commita) e a regra de alteração
mínima. O MARIO permanece responsável pelos artefatos que o Execute não cobre:
script AdvPR, `technical-doc.md`, `pr-text.md` e `side-findings.md`.

Resposta: manter sugestão

### 4.9 Sem compilar nem executar (4.4), a conversão para CP1252 continua na fase 3? — **Essencial**

A `advpl-tlpp-sdd` declara como regra que todo fonte AdvPL/TLPP gerado por IA nasce
em UTF-8 e que o compilador RDMake/AppServer exige CP-1252. O MARIO escreve código
na fase 3 mas não compila, então quem compila é o humano na fase 4 — e receberia o
fonte em UTF-8, com risco de acentuação corrompida.

Vale fixar também o alcance de "não executar": a 4.8 manteve a fase Execute da
`advpl-tlpp-sdd`, cujos passos convertem encoding e perguntam sobre compilar.

**Sugestão:** manter a conversão. Todo fonte tocado na fase 3 é convertido com
`utf8-to-cp1252-conversion`. "Não executar" significa não acionar
`advpl-tlpp-compile`, não abrir o SmartClient e não rodar testes — o passo do
Execute que pergunta sobre compilação é suprimido, e a fase Execute em si
permanece, conforme a 4.8. O MARIO registra no `mario.status.md` e no `pr-text.md`
que o fonte não foi compilado nem executado.

Resposta: manter sugestão

## 5. Nota de confiabilidade da fase 1

### 5.1 Quais são os critérios da nota de 0 a 10? — **Essencial**

O briefing deixa essa definição explicitamente aberta.

**Sugestão:** cinco dimensões de 0 a 2 pontos cada, somando 10, com a pontuação
por dimensão registrada no documento:

| Dimensão | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Reprodutibilidade da jornada | passos desconhecidos | passos inferidos do código | passos completos e confirmados na issue/ticket |
| Comportamento atual | não localizado no código | localizado por inferência | localizado no fonte e na função exatos |
| Respaldo do comportamento esperado | nenhuma fonte | apenas a expectativa do cliente | TDN, norma, lei ou padrão de mercado citado |
| Qualidade das informações da issue | descrição insuficiente | descrição parcial | descrição, evidências e dados de ambiente |
| Premissas | decisões-chave presumidas | premissas menores em aberto | nenhuma premissa não confirmada |

Resposta: manter sugestão

### 5.2 A nota funciona como gate para a fase 2? — **Essencial**

**Sugestão:** a nota não bloqueia automaticamente. Com nota final menor que 6, o
MARIO lista as lacunas que a derrubaram, recomenda o que buscar (informação com o
atendimento, evidência do cliente, documento no TDN) e exige decisão explícita do
usuário antes de iniciar a fase 2. Com nota 6 ou mais, vale o gate normal de
aprovação da fase.

Resposta: manter sugestão

### 5.3 Quais fontes de informação a fase 1 deve consultar obrigatoriamente? — **Essencial**

**Sugestão:** issue do JIRA via `get-jira-issue` (incluindo o bloco Zendesk e,
quando houver, `include_zendesk_attachments`); código do repositório alvo; TDN e
documentação de produto via `product-docs-search` e
`language-system-docs-search`; `legislation-docs-search` quando o comportamento
esperado depender de norma, lei ou obrigação fiscal; changesets da issue quando
existirem. Fonte indisponível ou sem resultado deve ser registrada no documento e
refletida na nota.

Resposta: manter sugestão

## 6. Pré-requisitos e degradação

### 6.1 Como verificar se o MCP `advpl-tlpp-mcp-docs` está disponível? — **Essencial**

**Sugestão:** no preflight, executar uma chamada real e barata ao MCP (por
exemplo `language-system-docs-search` com `limit: 1`). Se a tool não existir ou a
chamada falhar, exibir o aviso de impacto na qualidade da análise, perguntar se
deve continuar e registrar a resposta no `mario.status.md`, repetindo o aviso no
encerramento de cada fase executada em modo degradado.

Resposta: manter sugestão

### 6.2 Como verificar a presença das skills pré-requisito? — **Essencial**

**Sugestão:** verificar a existência de `.kiro/skills/{skill}/SKILL.md` no
workspace e, como fallback, no diretório de skills do usuário. Faltando qualquer
uma das quatro skills bloqueantes, abortar antes de criar qualquer artefato,
listar as ausentes e instruir a instalação pela extensão Dex.

Resposta: manter sugestão

### 6.3 A `gct-tests` e a `gct-pr-text` entram na lista de pré-requisitos bloqueantes? — **Essencial**

As respostas 4.1 e 4.3 as colocam no fluxo, mas o briefing lista apenas quatro
skills bloqueantes.

**Sugestão:** tratá-las como pré-requisitos não bloqueantes. Na ausência da
`gct-tests`, o MARIO usa `advpr-test-generator` e `kanoah-advpr-generator` e
avisa a degradação; na ausência da `gct-pr-text`, redige o texto do PR pelo
próprio fluxo, mantendo a seção de check-in do TFS. A lista bloqueante permanece
com as quatro skills do briefing.

Resposta: Sim, entram na lista de pré-requisitos bloqueantes.
