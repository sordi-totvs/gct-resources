# Especificação — MARIO

## 1. Visão

MARIO é um recurso de IA para resolver issues de manutenção (bugs) do TOTVS
Protheus, atuando como integrante de um time de desenvolvimento. Ele conduz as
fases de refinamento de negócio, refinamento técnico e codificação, cada uma
encerrada por aprovação humana explícita. As fases de validação, code review e
teste de aceitação permanecem com pessoas.

A entrega tem duas partes: um **agente**, que dá ao usuário a percepção de estar
dentro do fluxo do MARIO independentemente das skills e tools acionadas, e uma
**skill**, que carrega o fluxo detalhado.

## 2. Escopo

### 2.1 Dentro do escopo

- Fluxo de 6 fases documentado, com as fases 1, 2 e 3 executáveis pelo MARIO.
- Fase 5 (code review) acionável sob demanda, delegando à skill `code-review`.
- Uma issue por execução, de forma interativa, com gate humano ao fim de cada fase.
- Agnóstico de módulo Protheus; o repositório alvo é o repositório de módulo aberto
  no workspace.

### 2.2 Fora do escopo

| Item | Motivo |
| --- | --- |
| Fases 4 e 6 (validação e teste de aceitação) | responsabilidade humana; a skill apenas descreve o que validar |
| Compilar fonte, abrir SmartClient, executar testes | decidido adiar (4.4); será tratado em entrega futura |
| Commit, push e abertura de pull request | pertencem à fase 4, humana |
| Publicação do documento técnico no TDN/Confluence | decisão humana da fase 4 |
| Absorção da `gct-sdd` como modo lote | adiada para depois das fases 1 a 3 estáveis (1.6) |
| Processamento de múltiplas issues em paralelo | permanece na `gct-sdd` |
| Memória de projeto da `advpl-tlpp-sdd` (`.specs/project/`, `.specs/codebase/`, `.specs/HANDOFF.md`) | o MARIO não escreve nesses caminhos |

## 3. Entregáveis

Arquivos produzidos **neste** repositório (`gct-resources`):

```
agents/
└── mario.agent.md                          # novo tipo de recurso do repositório
skills/mario/
├── SKILL.md
└── references/
    ├── phase-1-business-refinement.md
    ├── phase-2-technical-refinement.md
    ├── phase-3-coding.md
    └── (arquivos de apoio conforme necessário)
README.md                                   # tabela de skills, árvore, instalação do agente
CHANGELOG.md                                # entrada em [Não publicado]
```

Nomes de arquivo em inglês; conteúdo em português do Brasil.

## 4. Arquitetura da entrega

| Decisão | Definição |
| --- | --- |
| Granularidade | uma única skill `skills/mario/`, com o fluxo no `SKILL.md` e um arquivo de `references/` por fase |
| Skill da fase 1 | não é skill separada: nasce como `references/phase-1-business-refinement.md` |
| Agente | `agents/mario.agent.md`, fino — identidade, fluxo das 6 fases e gates; o detalhamento vive na skill |
| Distribuição da skill | extensão Dex, que instala em `.kiro/skills` |
| Distribuição do agente | manual, por cópia para `.kiro/agents/` do repositório alvo — a extensão Dex 2.5.0 instala apenas skills |
| Relação com a `gct-sdd` | coexistência: MARIO interativo, `gct-sdd` em lote. O MARIO não delega à `gct-sdd`; ambos acionam a `advpl-tlpp-sdd` |

## 5. Fluxo

| Fase | Executor | Artefatos | Skill delegada | Encerramento |
| --- | --- | --- | --- | --- |
| 1 — Refinamento de negócio | MARIO | `business-refinement.md` | nenhuma (fluxo próprio) | gate humano |
| 2 — Refinamento técnico | MARIO | `bug-spec.md`, `rca.md`, `test-case.md`, `kanoah/{routine}/{CTxxx}.md` | `advpl-tlpp-sdd` (Specify + Design), `gct-tests` | gate humano |
| 3 — Codificação | MARIO | `tasks.md`, código, script AdvPR, `technical-doc.md`, `pr-text.md` | `advpl-tlpp-sdd` (Tasks + Execute), `gct-tests`, `tdn-technical-doc-writer`, `gct-pr-text` | gate humano |
| 4 — Validação | humano | — | — | — |
| 5 — Code review | MARIO, sob demanda | resultado no chat | `code-review` | — |
| 6 — Teste de aceitação | humano (CI/CD gera o `.ptm`) | — | — | — |

## 6. Requisitos

### 6.1 Preflight

- **REQ-001** — Antes de qualquer fase, verificar a disponibilidade do MCP
  `advpl-tlpp-mcp-docs` por uma chamada real e barata (ex.: `language-system-docs-search`
  com `limit: 1`).
- **REQ-002** — MCP indisponível não interrompe: informar o impacto na qualidade da
  análise, perguntar se deve continuar e registrar a resposta no `mario.status.md`,
  repetindo o aviso ao encerrar cada fase executada em modo degradado.
- **REQ-003** — Verificar a presença das skills bloqueantes em
  `.kiro/skills/{skill}/SKILL.md` do workspace e, como fallback, no diretório de
  skills do usuário. A lista é: `advpl-tlpp-sdd`,
  `advpl-tlpp-root-cause-analysis`, `kanoah-advpr-generator`,
  `tdn-technical-doc-writer`, `gct-tests` e `gct-pr-text`.
- **REQ-004** — Faltando qualquer skill bloqueante, abortar antes de criar qualquer
  artefato, listar as ausentes e instruir a instalação pela extensão Dex.

### 6.2 Branch e árvore de trabalho

- **REQ-005** — No início de qualquer parte do fluxo, se a branch atual não for
  `mario/{ISSUE}`, informar o usuário e perguntar se deve criar uma nova branch a
  partir da master.
- **REQ-006** — Autorizada a criação e estando a árvore limpa, executar
  `git fetch origin`, criar a branch a partir de `origin/master` (ou `origin/main`,
  conforme a base do repositório alvo), ativá-la e só então continuar a tarefa.
- **REQ-007** — Árvore suja é impedimento para criar a branch: listar os arquivos
  pendentes (`git status --short`), explicar que é preciso árvore limpa e parar, sem
  fazer stash, descartar ou commitar nada.
- **REQ-008** — Recusada a criação, seguir na branch atual — não é impedimento.
- **REQ-009** — Já estando em `mario/{ISSUE}`, a árvore suja não impede a execução:
  listar os arquivos pendentes e registrá-los como pendência no `mario.status.md`,
  porque afetam o diff descrito no `pr-text.md`.
- **REQ-010** — Nunca fazer commit, push nem abrir pull request.
- **REQ-011** — Não usar worktree; uma issue por execução, no diretório de trabalho
  atual.

### 6.3 Estado, gates e acionamento

- **REQ-012** — Manter `mario.status.md` com fase atual, data, aprovações
  registradas, decisões de degradação e pendências abertas.
- **REQ-013** — Na retomada, ler o `mario.status.md`; na ausência dele, inferir a
  fase pelos artefatos existentes e declarar a inferência ao usuário antes de agir.
- **REQ-014** — Ao concluir uma fase, apresentar no chat resumo, caminhos dos
  artefatos e pendências, encerrar o turno e aguardar aprovação explícita.
- **REQ-015** — Nunca iniciar a fase seguinte no mesmo turno, nem interpretar
  silêncio ou pedido genérico ("continua") como aprovação sem confirmar o que foi
  aprovado.
- **REQ-016** — Aceitar o acionamento de fase isolada (ex.: "rodar a fase 2 da issue
  X"), validando que os artefatos da fase anterior existem e estão aprovados no
  `mario.status.md`.
- **REQ-017** — Fase anterior não concluída ou não aprovada: avisar o que falta e
  **não** prosseguir.

### 6.4 Fase 1 — Refinamento de negócio

- **REQ-018** — Produzir `business-refinement.md` respondendo: jornada do usuário
  para reproduzir o erro, comportamento esperado, comportamento atual e quais
  documentos do TDN, padrões de mercado, normas ou leis sustentam o comportamento
  esperado.
- **REQ-019** — Determinar se a issue é realmente um bug e registrar a conclusão com
  evidências.
- **REQ-020** — Consultar obrigatoriamente: issue no JIRA via `get-jira-issue`
  (incluindo o bloco Zendesk e, quando houver, `include_zendesk_attachments`);
  código do repositório alvo; TDN e documentação de produto via
  `product-docs-search` e `language-system-docs-search`; `legislation-docs-search`
  quando o comportamento esperado depender de norma, lei ou obrigação fiscal; e os
  changesets da issue quando existirem.
- **REQ-021** — Fonte indisponível ou sem resultado deve ser registrada no documento
  e refletida na nota de confiabilidade.
- **REQ-022** — Calcular e registrar a nota de confiabilidade conforme RN-001, com a
  pontuação por dimensão.

### 6.5 Fase 2 — Refinamento técnico

- **REQ-023** — Produzir `bug-spec.md` e `rca.md` obrigatoriamente pela skill
  `advpl-tlpp-sdd`, no bug track (Specify e Design).
- **REQ-024** — Não acionar `advpl-tlpp-root-cause-analysis` diretamente: ela atua
  por dentro do Design da `advpl-tlpp-sdd`.
- **REQ-025** — Proibir Quick mode e qualquer auto-sizing que pule RCA ou tasks:
  `bug-spec.md`, `rca.md` e `tasks.md` são sempre produzidos.
- **REQ-026** — Produzir o caso de teste de regressão com a `gct-tests` no modo
  "apenas Kanoah", gerando `test-case.md` e `kanoah/{routine}/{CTxxx}.md`.
- **REQ-027** — Acionar a `kanoah-advpr-generator` apenas quando o usuário pedir o
  XML de importação no Zephyr Scale.

### 6.6 Fase 3 — Codificação

- **REQ-028** — Produzir `tasks.md` pela fase Tasks da `advpl-tlpp-sdd`.
- **REQ-029** — Executar as tasks pela fase Execute da `advpl-tlpp-sdd`, com commit
  atômico desabilitado e alteração mínima do código.
- **REQ-030** — Gerar o script AdvPR pela `gct-tests`, em
  `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW` do repositório alvo.
- **REQ-031** — Converter todo fonte AdvPL/TLPP tocado com
  `utf8-to-cp1252-conversion`.
- **REQ-032** — Não acionar `advpl-tlpp-compile`, não abrir o SmartClient e não
  executar testes; suprimir o passo do Execute que pergunta sobre compilação.
- **REQ-033** — Registrar no `mario.status.md` e no `pr-text.md` que o fonte não foi
  compilado nem executado.
- **REQ-034** — Produzir `technical-doc.md` usando a `tdn-technical-doc-writer`
  apenas até a montagem do conteúdo, indicando que está pronto para publicação e
  qual template segue. Não publicar no Confluence.
- **REQ-035** — Produzir `pr-text.md` acionando a `gct-pr-text` com pedido explícito
  de gravação, preservando a seção `TEXTO PARA CHECK-IN NO TFS`, e apresentar o
  texto também no chat ao encerrar a fase. Ajustes na própria `gct-pr-text` são
  permitidos quando necessário.
- **REQ-036** — Registrar problemas colaterais em `side-findings.md`, apenas quando
  houver achados, com um item por problema (fonte, função, sintoma, risco de deixar
  sem correção e esforço estimado), listando-os no encerramento da fase. Nenhum é
  corrigido sem aprovação explícita.

### 6.7 Fase 5 — Code review

- **REQ-037** — Quando acionada pelo usuário, delegar à skill `code-review` e
  entregar o resultado no chat, sem publicar comentários.

### 6.8 Artefatos e caminhos

- **REQ-038** — Todos os artefatos de especificação ficam em
  `.specs/mario/{ISSUE}/`, com `{ISSUE}` na forma da chave do JIRA em maiúsculas e
  sem slug. Aceitar na entrada chave em minúsculas, ID numérico ou URL do JIRA,
  normalizando para maiúsculas.

```
.specs/mario/{ISSUE}/
├── mario.status.md          # controle
├── business-refinement.md   # fase 1
├── bug-spec.md              # fase 2 — advpl-tlpp-sdd
├── rca.md                   # fase 2 — advpl-tlpp-sdd
├── context.md               # fase 2 — advpl-tlpp-sdd, só se o Discuss for acionado
├── test-case.md             # fase 2
├── kanoah/{routine}/{CTxxx}.md   # fase 2
├── tasks.md                 # fase 3 — advpl-tlpp-sdd
├── technical-doc.md         # fase 3
├── pr-text.md               # fase 3
└── side-findings.md         # fase 3, só se houver achados
```

Único artefato fora dessa árvore: o script AdvPR, em
`tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW` do repositório alvo.

- **REQ-039** — Declarar os caminhos como regra inviolável no `SKILL.md` e informar
  o caminho de destino explícito no prompt de cada delegação, sobrepondo os defaults
  das skills.
- **REQ-040** — Ao final de cada fase, validar via `git status` que nenhum artefato
  de especificação foi criado fora de `.specs/mario/{ISSUE}`, movendo o que estiver
  fora e avisando o usuário.
- **REQ-041** — Não criar nem atualizar `.specs/project/`, `.specs/codebase/` ou
  `.specs/HANDOFF.md`. Se existirem no repositório alvo, podem ser lidos como
  contexto, nunca escritos.

Defaults que precisam de override explícito:

| Skill | Default | Destino no MARIO |
| --- | --- | --- |
| `advpl-tlpp-sdd` | `.specs/fixes/[bug]/` | `.specs/mario/{ISSUE}/` |
| `advpl-tlpp-sdd` (Quick mode) | `.specs/quick/NNN-slug/TASK.md` + `SUMMARY.md` | proibido (REQ-025) |
| `advpl-tlpp-root-cause-analysis` | `docs/rca/RCA-<rotina>-<AAAA-MM-DD>.md` | `.specs/mario/{ISSUE}/rca.md` |
| `gct-tests` | `tests/kanoah/{rotina}/{CTxxx}.md` | `.specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md` |
| `gct-pr-text` | entrega apenas no chat | grava `.specs/mario/{ISSUE}/pr-text.md` |
| `tdn-technical-doc-writer` | publica página no Confluence | grava `.specs/mario/{ISSUE}/technical-doc.md` |

- **REQ-042** — Enquanto a `gct-sdd` não for absorvida, o `SKILL.md` do MARIO
  declara quando usar cada uma, para não gerar artefato duplicado da mesma issue em
  pastas e branches diferentes.
- **REQ-043** — Reservar o prefixo `kiro/` às branches da `gct-sdd`; o MARIO usa
  `mario/{ISSUE}`.

### 6.9 Documentação do repositório

- **REQ-044** — Atualizar o `README.md`: incluir a skill `mario` na tabela, a pasta
  `agents/` na árvore de estrutura e a instalação do agente (cópia manual para
  `.kiro/agents/`).
- **REQ-045** — Registrar a entrega em `## [Não publicado]` no `CHANGELOG.md`.

## 7. Regras de negócio

### RN-001 — Nota de confiabilidade da fase 1

Cinco dimensões de 0 a 2 pontos, somando 10, com a pontuação por dimensão
registrada no `business-refinement.md`.

| Dimensão | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Reprodutibilidade da jornada | passos desconhecidos | passos inferidos do código | passos completos e confirmados na issue ou no ticket |
| Comportamento atual | não localizado no código | localizado por inferência | localizado no fonte e na função exatos |
| Respaldo do comportamento esperado | nenhuma fonte | apenas a expectativa do cliente | TDN, norma, lei ou padrão de mercado citado |
| Qualidade das informações da issue | descrição insuficiente | descrição parcial | descrição, evidências e dados de ambiente |
| Premissas | decisões-chave presumidas | premissas menores em aberto | nenhuma premissa não confirmada |

### RN-002 — A nota não bloqueia automaticamente

Nota final menor que 6: listar as lacunas que a derrubaram, recomendar o que buscar
(informação com o atendimento, evidência do cliente, documento no TDN) e exigir
decisão explícita do usuário antes de iniciar a fase 2. Nota 6 ou mais: vale o gate
normal de aprovação da fase.

### RN-003 — Issue que não é bug encerra o fluxo

Concluído na fase 1 que não se trata de bug, gravar o documento com a conclusão, as
evidências e a nota, reportar ao usuário e sugerir encaminhamentos (devolver ao
atendimento, tratar como melhoria, solicitar mais informações). A fase 2 só começa
com decisão explícita do usuário.

### RN-004 — Gates do MARIO sobrepõem os da skill delegada

A `advpl-tlpp-sdd` é acionada por fase, nunca de ponta a ponta: Specify e Design na
fase 2, Tasks e Execute na fase 3. Seus gates internos entre Specify, Design e
Tasks são suprimidos; valem os gates do MARIO. Premissas que a skill pediria para
aprovar ficam registradas no próprio documento.

## 8. Tratamento de erros e exceções

| Situação | Comportamento |
| --- | --- |
| MCP `advpl-tlpp-mcp-docs` indisponível | avisa o impacto, pergunta se continua, registra a decisão e repete o aviso a cada encerramento de fase |
| Skill bloqueante ausente | aborta antes de criar artefato, lista as ausentes e instrui a instalação pela Dex |
| Issue não encontrada no JIRA | para e pede ao usuário os dados do defeito; não inventa cenário |
| Árvore suja com pedido de criar branch | não cria a branch e para (REQ-007) |
| Árvore suja já em `mario/{ISSUE}` | segue, listando os pendentes e registrando a pendência (REQ-009) |
| Fase anterior não aprovada | avisa o que falta e não prossegue (REQ-017) |
| Nota de confiabilidade menor que 6 | exige decisão explícita antes da fase 2 (RN-002) |
| Issue não é bug | encerra o fluxo (RN-003) |
| Artefato criado fora de `.specs/mario/{ISSUE}` | move para o caminho correto e avisa (REQ-040) |
| Caso de teste já existente para a issue | respeita a porta de antiduplicidade da `gct-tests`: informa e não sobrescreve |

## 9. Critérios de aceitação

- **CA-001** — `agents/mario.agent.md` e `skills/mario/SKILL.md` existem, com um
  arquivo de `references/` por fase, todos com nome de arquivo em inglês e conteúdo
  em português.
- **CA-002** — O frontmatter do `SKILL.md` segue o padrão do repositório (`name`,
  `description`, `license` e `metadata`), com `description` terminando nas frases de
  acionamento reais.
- **CA-003** — O `SKILL.md` lista as seis skills bloqueantes e descreve a
  verificação do MCP com a pergunta de continuidade.
- **CA-004** — O `SKILL.md` descreve as 6 fases, identificando executor, artefatos e
  gate de cada uma, e declara as fases 4 e 6 como humanas.
- **CA-005** — A regra de branch está descrita com os quatro desfechos: criação
  autorizada com árvore limpa, impedimento por árvore suja, recusa do usuário e
  execução já em `mario/{ISSUE}`.
- **CA-006** — A tabela de artefatos do `SKILL.md` reproduz exatamente os nomes de
  REQ-038, e a tabela de overrides cobre as seis skills de 6.8.
- **CA-007** — A rubrica da nota de confiabilidade aparece com as cinco dimensões e
  os três níveis de pontuação.
- **CA-008** — Está declarado que o MARIO não compila, não abre SmartClient, não
  executa testes, não commita, não faz push, não abre PR e não publica no Confluence.
- **CA-009** — Está declarado que a conversão para CP1252 é obrigatória em todo
  fonte tocado.
- **CA-010** — Nenhuma API, classe, tabela, campo ou parâmetro Protheus é afirmado
  sem verificação: os textos instruem a consulta às fontes de verdade.
- **CA-011** — `README.md` e `CHANGELOG.md` atualizados conforme REQ-044 e REQ-045.
- **CA-012** — Nenhum arquivo foi criado em `.kiro/agents` ou `.kiro/skills` deste
  repositório, que seguem ignorados pelo Git.

## 10. Testes esperados

Não há suíte automatizada neste repositório: a verificação é por leitura e por
execução assistida no repositório de módulo.

- **TE-001** — Revisão do `SKILL.md` e do `mario.agent.md` contra os critérios
  CA-001 a CA-010.
- **TE-002** — Execução da fase 1 sobre uma issue real de bug: confere
  `business-refinement.md`, as quatro respostas, a nota com pontuação por dimensão e
  a parada no gate.
- **TE-003** — Execução da fase 2 na sequência: confere `bug-spec.md`, `rca.md`,
  `test-case.md` e o Kanoah nos caminhos de REQ-038, sem artefato em
  `.specs/fixes/` ou `docs/rca/`.
- **TE-004** — Execução da fase 3: confere `tasks.md`, o código alterado, o script
  AdvPR, `technical-doc.md`, `pr-text.md`, a conversão de encoding e a ausência de
  commit, compilação e publicação.
- **TE-005** — Cenário de branch: partindo de `master` com árvore limpa, autoriza a
  criação e confirma a branch `mario/{ISSUE}`; repetindo com árvore suja, confirma o
  impedimento sem stash nem descarte.
- **TE-006** — Cenário de pré-requisito ausente: renomeia temporariamente uma skill
  bloqueante e confirma o aborto antes de qualquer artefato.
- **TE-007** — Cenário de retomada: apaga o contexto da sessão e confirma que o
  MARIO reconhece a fase pelo `mario.status.md`.
- **TE-008** — Cenário de issue que não é bug: confirma o encerramento na fase 1 com
  encaminhamentos sugeridos.

## 11. Premissas e lacunas

- A absorção da `gct-sdd` como modo lote do MARIO fica para uma entrega posterior.
  Esta especificação já fixa os três pontos que a tornam barata: prefixo único de
  branch, pasta única de artefatos e nomes de artefato idênticos.
- Compilação e execução entram em entrega futura; enquanto isso, o fonte é entregue
  convertido para CP1252, porém não compilado.
- A instalação do agente é manual porque a extensão Dex 2.5.0 instala somente em
  `.kiro/skills`. Se uma versão futura passar a instalar agentes, o `README.md` deve
  ser revisto.
- Não foi definido se o `pr-text.md` deve ser regenerado quando o humano alterar o
  código na fase 4; hoje o texto reflete o diff do momento em que a fase 3 encerrou.
- `gct-tests` declara `module: SIGAGCT`, enquanto o MARIO é agnóstico de módulo. Em
  módulos fora do SIGAGCT, as convenções de base congelada e de prefixo de rotina da
  `gct-tests` podem não se aplicar.

## 12. Rastreabilidade

| Item da especificação | Origem no questionário |
| --- | --- |
| Seção 3, 4 | 1.1, 1.5 |
| Seção 2.2, REQ-042, REQ-043 | 1.2, 1.6, 2.6 |
| Seção 2.1 (agnóstico de módulo) | 1.3 |
| Seção 5, REQ-037 | 1.4 |
| REQ-005 a REQ-011 | 2.5, 2.6, 2.7, 2.8 |
| REQ-012 a REQ-017 | 2.1, 2.2, 2.3 |
| REQ-018 a REQ-022, RN-001, RN-002, RN-003 | 2.4, 5.1, 5.2, 5.3 |
| REQ-023 a REQ-027, RN-004 | 4.1, 4.6, 4.7 |
| REQ-028 a REQ-036 | 4.2, 4.3, 4.4, 4.5, 4.8, 4.9 |
| REQ-038 a REQ-041 | 3.1, 3.2, 3.3, 3.4, 3.5 |
| REQ-001 a REQ-004 | 6.1, 6.2, 6.3 |
