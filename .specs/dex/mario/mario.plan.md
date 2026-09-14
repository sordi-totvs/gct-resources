# Plano de Implementação — MARIO

## Referências

- Especificação: `mario.spec.md`
- Briefing: `mario.briefing.md`
- Questionário: `mario.refinement-questionnaire.md`
- Convenções de autoria: `AGENTS.md` (raiz)
- Catálogo e instalação: `README.md`, `CHANGELOG.md`

## Estratégia

A entrega é de conteúdo, não de código executável: uma skill (`skills/mario/`)
e um agente (`agents/mario.agent.md`), ambos consumidos em repositórios de
módulo Protheus. Não há build, suíte de testes ou lint neste repositório — a
validação de cada fase é por inspeção de arquivo com comandos de leitura e por
`git status` / `git diff --check`, e a validação funcional acontece em execução
assistida no repositório de módulo (fase final).

A ordem segue a dependência real de conteúdo:

1. Primeiro os **invariantes** que todas as fases consomem — preflight, regra de
   branch, gates, estado, tabela de artefatos e tabela de overrides. Eles vivem
   no `SKILL.md` e são o contrato que as references citam.
2. Depois uma reference por fase do MARIO, na ordem em que a fase roda.
3. O agente depois do `SKILL.md`, porque apenas o referencia.
4. Documentação do repositório e revisão de consistência ao final.

Fatos já confirmados no workspace, que as fases abaixo consomem sem
redescobrir:

| Fato | Onde foi confirmado |
| --- | --- |
| Agente é `*.agent.md` com frontmatter `name`, `description`, `argument-hint` | `.kiro/agents/browse-to-smartx-migrator.agent.md` |
| A extensão Dex sincroniza somente a pasta `skills` | `.dex/sync.json` (`"path": "skills"`), `README.md` |
| `advpl-tlpp-sdd` grava o bug track em `.specs/fixes/[bug]/` com `bug-spec.md`, `rca.md`, `context.md`, `tasks.md` | `.kiro/skills/advpl-tlpp-sdd/SKILL.md` (seção Estrutura do Projeto) |
| No bug track, o RCA entra na fase **Design**, acionando `advpl-tlpp-root-cause-analysis` | `.kiro/skills/advpl-tlpp-sdd/references/design.md` |
| `gct-tests` tem o modo literal "apenas Kanoah" e declara modo + origem ao usuário | `skills/gct-tests/SKILL.md` (passos 1.4 e 4) |
| `gct-tests` procura a origem em `.specs/fixes/...`, não em `.specs/mario/...` | `skills/gct-tests/SKILL.md` (passo 1.4) |
| Frontmatter das skills deste repositório: `name`, `description`, `license`, `metadata` | `skills/*/SKILL.md` |

Regra de conteúdo aplicada a todas as fases: nenhuma API, classe, tabela, campo
ou parâmetro Protheus é afirmado sem verificação; os textos instruem a consulta
às fontes de verdade (MCP `advpl-tlpp-mcp-docs` e documentação oficial). Nomes de
arquivo em inglês, conteúdo em português do Brasil.

## Fases

### Fase 1 — Invariantes do MARIO no `SKILL.md`

**Objetivo:** `skills/mario/SKILL.md` existe, é ativável pela `description` e
carrega tudo o que não é específico de uma fase: preflight, branch, gates,
estado, mapa das 6 fases, tabela de artefatos e tabela de overrides.

**Dependências:** nenhuma

**Alterações:**

- [ ] Confirmar nos SKILL.md instalados em `.kiro/skills/` os nomes exatos de
      fase, artefato e caminho default de cada skill delegada
      (`advpl-tlpp-sdd`, `advpl-tlpp-root-cause-analysis`, `gct-tests`,
      `gct-pr-text`, `tdn-technical-doc-writer`, `kanoah-advpr-generator`,
      `utf8-to-cp1252-conversion`, `code-review`), registrando divergências em
      relação à tabela de overrides da seção 6.8 da spec.
- [ ] Criar `skills/mario/SKILL.md` com frontmatter no padrão do repositório
      (`name: mario`, `description`, `license: MIT`, `metadata` com `domain`,
      `maintainer`, `author`, `version: 1.0.0`, `category` e `depends-on` com as
      seis skills bloqueantes) — CA-002.
- [ ] Encerrar a `description` com as frases reais de acionamento no formato
      `Use quando o usuário disser: ...`, cobrindo o acionamento por fase
      ("rodar a fase 1 da issue X") e por issue.
- [ ] Escrever a seção de preflight: verificação do MCP `advpl-tlpp-mcp-docs`
      por chamada real e barata, aviso de degradação com pergunta de
      continuidade, e verificação das seis skills bloqueantes em
      `.kiro/skills/{skill}/SKILL.md` com fallback no diretório de skills do
      usuário — REQ-001 a REQ-004, CA-003.
- [ ] Escrever a seção de branch com os quatro desfechos: criação autorizada com
      árvore limpa (`git fetch origin` + criação a partir de `origin/master` ou
      `origin/main`), impedimento por árvore suja, recusa do usuário e execução
      já em `mario/{ISSUE}` — REQ-005 a REQ-011, CA-005.
- [ ] Escrever a seção de estado e gates: template do `mario.status.md`, leitura
      na retomada, inferência declarada na ausência do arquivo, gate ao fim de
      cada fase e recusa de avançar sem aprovação registrada — REQ-012 a REQ-017.
- [ ] Escrever a tabela de artefatos reproduzindo exatamente os nomes e a árvore
      de REQ-038, e a tabela de overrides das seis skills de 6.8, declarando os
      caminhos como regra inviolável e a validação por `git status` ao fim de
      cada fase — REQ-038 a REQ-041, CA-006.
- [ ] Escrever o mapa das 6 fases com executor, artefatos, skill delegada e
      gate, declarando as fases 4 e 6 como humanas e listando o que o humano
      valida — CA-004.
- [ ] Escrever a seção da fase 5 (code review sob demanda, delegando à skill
      `code-review`, resultado apenas no chat) — REQ-037.
- [ ] Escrever a seção de proibições explícitas: não compila, não abre
      SmartClient, não executa testes, não commita, não faz push, não abre PR,
      não publica no Confluence, não escreve em `.specs/project/`,
      `.specs/codebase/` ou `.specs/HANDOFF.md` — CA-008.
- [ ] Escrever a seção que declara quando usar o MARIO e quando usar a
      `gct-sdd`, evitando artefato duplicado da mesma issue — REQ-042, REQ-043.
- [ ] Se o `SKILL.md` passar de 500 linhas, extrair o template do
      `mario.status.md` para `skills/mario/references/status-template.md` e
      referenciá-lo por caminho relativo.

**Validação:**

- [ ] `Get-Content skills/mario/SKILL.md -TotalCount 30` — frontmatter completo,
      com `name: mario` idêntico ao nome da pasta.
- [ ] `Select-String -Path skills/mario/SKILL.md -Pattern 'Use quando o usuário disser'`
      — gatilho de ativação presente na `description`.
- [ ] `Select-String -Path skills/mario/SKILL.md -Pattern 'mario\.status\.md|business-refinement\.md|bug-spec\.md|rca\.md|test-case\.md|tasks\.md|technical-doc\.md|pr-text\.md|side-findings\.md'`
      — os nove artefatos de REQ-038 citados.
- [ ] `Select-String -Path skills/mario/SKILL.md -Pattern 'advpl-tlpp-sdd|advpl-tlpp-root-cause-analysis|kanoah-advpr-generator|tdn-technical-doc-writer|gct-tests|gct-pr-text'`
      — as seis skills bloqueantes citadas.

**Critério de conclusão:** o `SKILL.md` responde, sem consultar nenhuma
reference, a quatro perguntas: quais são os pré-requisitos, em que branch
trabalhar, onde cada artefato é gravado e como cada fase termina.

---

### Fase 2 — Reference da fase 1 (refinamento de negócio)

**Objetivo:** `skills/mario/references/phase-1-business-refinement.md` conduz o
refinamento de negócio de ponta a ponta e produz `business-refinement.md`.

**Dependências:** Fase 1

**Alterações:**

- [ ] Criar a reference com o roteiro de coleta das fontes obrigatórias: issue do
      JIRA via `get-jira-issue` (com o bloco Zendesk e
      `include_zendesk_attachments` quando houver), código do repositório alvo,
      `product-docs-search`, `language-system-docs-search`,
      `legislation-docs-search` quando o comportamento esperado depender de
      norma, lei ou obrigação fiscal, e os changesets da issue quando existirem
      — REQ-020.
- [ ] Definir o registro de fonte indisponível ou sem resultado e seu reflexo na
      nota — REQ-021.
- [ ] Escrever o template do `business-refinement.md` com as quatro perguntas do
      briefing (jornada de reprodução, comportamento esperado, comportamento
      atual, respaldo documental) e a conclusão sobre ser ou não um bug, com
      evidências — REQ-018, REQ-019.
- [ ] Escrever a rubrica da nota de confiabilidade com as cinco dimensões e os
      três níveis (0, 1, 2), o cálculo do total e o registro da pontuação por
      dimensão — RN-001, REQ-022, CA-007.
- [ ] Escrever o tratamento de nota menor que 6: listar as lacunas, recomendar o
      que buscar e exigir decisão explícita antes da fase 2 — RN-002.
- [ ] Escrever o encerramento quando a issue não é bug: gravar o documento com a
      conclusão e as evidências, reportar e sugerir encaminhamentos, aguardando
      decisão explícita — RN-003.

**Validação:**

- [ ] `Select-String -Path skills/mario/references/phase-1-business-refinement.md -Pattern 'get-jira-issue|product-docs-search|language-system-docs-search|legislation-docs-search'`
      — as quatro fontes obrigatórias citadas pelo nome real da tool.
- [ ] `Select-String -Path skills/mario/references/phase-1-business-refinement.md -Pattern 'Reprodutibilidade|Comportamento atual|Respaldo|Qualidade das informações|Premissas'`
      — as cinco dimensões da rubrica presentes.
- [ ] `Select-String -Path skills/mario/SKILL.md -Pattern 'phase-1-business-refinement\.md'`
      — reference alcançável a partir do `SKILL.md`.

**Critério de conclusão:** a reference permite produzir o
`business-refinement.md` completo, com nota calculada por dimensão, e define os
dois desfechos que não seguem para a fase 2 (nota abaixo de 6 e issue que não é
bug).

---

### Fase 3 — Reference da fase 2 (refinamento técnico)

**Objetivo:** `skills/mario/references/phase-2-technical-refinement.md` conduz a
delegação que produz `bug-spec.md`, `rca.md`, `test-case.md` e o Kanoah.

**Dependências:** Fase 1

**Alterações:**

- [ ] Escrever o acionamento da `advpl-tlpp-sdd` no bug track, fase a fase
      (Specify para `bug-spec.md`, Design para `rca.md`), com o prompt de
      delegação já contendo o caminho de destino `.specs/mario/{ISSUE}/` — REQ-023,
      REQ-039.
- [ ] Declarar que a `advpl-tlpp-root-cause-analysis` não é acionada diretamente:
      ela atua por dentro do Design, e o override do seu default
      `docs/rca/RCA-<rotina>-<AAAA-MM-DD>.md` para `rca.md` é explícito no prompt
      — REQ-024.
- [ ] Proibir o Quick mode e qualquer auto-sizing que pule RCA ou tasks, com a
      justificativa e o que fazer se a skill delegada sugerir o desvio — REQ-025.
- [ ] Declarar a supressão dos gates internos da `advpl-tlpp-sdd` entre Specify,
      Design e Tasks, e o registro no próprio documento das premissas que a skill
      pediria para aprovar — RN-004.
- [ ] Escrever o acionamento da `gct-tests` no modo "apenas Kanoah", informando
      explicitamente que a origem das informações é `.specs/mario/{ISSUE}` (a
      skill procura em `.specs/fixes/...`) e que o Kanoah é gravado em
      `.specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md` — REQ-026.
- [ ] Definir o `test-case.md`: registra o cenário de regressão aprovado e
      referencia o caminho do Kanoah e o nome previsto do método AdvPR.
- [ ] Declarar que a `kanoah-advpr-generator` só é acionada quando o usuário
      pedir o XML de importação no Zephyr Scale — REQ-027.
- [ ] Escrever a checagem de fim de fase: `git status` para confirmar que nada
      foi gravado em `.specs/fixes/` ou `docs/rca/`, movendo o que estiver fora e
      avisando o usuário — REQ-040.
- [ ] Registrar o desfecho quando o caso de teste da issue já existe: respeitar a
      porta de antiduplicidade da `gct-tests`, informar e não sobrescrever.

**Validação:**

- [ ] `Select-String -Path skills/mario/references/phase-2-technical-refinement.md -Pattern '\.specs/mario/\{ISSUE\}'`
      — caminho de destino explícito nos prompts de delegação.
- [ ] `Select-String -Path skills/mario/references/phase-2-technical-refinement.md -Pattern 'Quick mode|apenas Kanoah|Specify|Design'`
      — proibição do Quick mode e modos/fases delegados nomeados como nas skills
      de origem.
- [ ] `Select-String -Path skills/mario/references/phase-2-technical-refinement.md -Pattern 'docs/rca|\.specs/fixes'`
      — defaults a sobrepor citados explicitamente.

**Critério de conclusão:** a reference nomeia, para cada artefato da fase 2, qual
skill o produz, em qual fase dela, com qual override de caminho e com qual
verificação ao final.

---

### Fase 4 — Reference da fase 3 (codificação)

**Objetivo:** `skills/mario/references/phase-3-coding.md` conduz `tasks.md`, a
codificação mínima, o script AdvPR, `technical-doc.md`, `pr-text.md` e
`side-findings.md`.

**Dependências:** Fase 1, Fase 3 (consome o `bug-spec.md`/`rca.md` descritos lá)

**Alterações:**

- [ ] Escrever o acionamento da fase Tasks da `advpl-tlpp-sdd` para produzir
      `tasks.md` em `.specs/mario/{ISSUE}/` — REQ-028.
- [ ] Escrever o acionamento da fase Execute com commit atômico desabilitado e a
      regra de alteração mínima, listando o que o Execute não cobre e permanece
      com o MARIO — REQ-029.
- [ ] Suprimir explicitamente o passo do Execute que pergunta sobre compilação, e
      declarar o alcance de "não executar": não acionar `advpl-tlpp-compile`, não
      abrir o SmartClient, não rodar testes — REQ-032.
- [ ] Tornar obrigatória a conversão de todo fonte AdvPL/TLPP tocado com
      `utf8-to-cp1252-conversion`, com a justificativa (o humano da fase 4 é quem
      compila) — REQ-031, CA-009.
- [ ] Definir o registro, no `mario.status.md` e no `pr-text.md`, de que o fonte
      não foi compilado nem executado — REQ-033.
- [ ] Escrever o acionamento da `gct-tests` para o script AdvPR em
      `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW` do repositório alvo, único
      artefato fora de `.specs/mario/{ISSUE}` — REQ-030.
- [ ] Escrever o acionamento da `tdn-technical-doc-writer` apenas até a montagem
      do conteúdo, gravando `technical-doc.md` com a indicação de que está pronto
      para publicação e qual template segue, sem publicar no Confluence — REQ-034.
- [ ] Escrever o acionamento da `gct-pr-text` com pedido explícito de gravação em
      `pr-text.md`, preservando a seção `TEXTO PARA CHECK-IN NO TFS`, e a
      apresentação do texto no chat no encerramento da fase — REQ-035.
- [ ] Avaliar se a delegação por prompt basta para a `gct-pr-text` gravar em
      arquivo; se exigir ajuste na própria skill, alterar
      `skills/gct-pr-text/SKILL.md`, subir a `version` no `metadata` e registrar
      no `CHANGELOG.md` (autorizado por REQ-035). Se a `gct-tests` também exigir
      alteração para aceitar a origem `.specs/mario/{ISSUE}`, **parar** e levar a
      decisão ao usuário: a spec não autoriza alterá-la.
- [ ] Definir o `side-findings.md`, criado apenas quando houver achados, com um
      item por problema (fonte, função, sintoma, risco de deixar sem correção,
      esforço estimado), listado no encerramento da fase e nunca corrigido sem
      aprovação explícita — REQ-036.

**Validação:**

- [ ] `Select-String -Path skills/mario/references/phase-3-coding.md -Pattern 'utf8-to-cp1252-conversion'`
      — conversão obrigatória declarada.
- [ ] `Select-String -Path skills/mario/references/phase-3-coding.md -Pattern 'advpl-tlpp-compile|SmartClient|commit'`
      — proibições de compilar, executar e commitar declaradas.
- [ ] `Select-String -Path skills/mario/references/phase-3-coding.md -Pattern 'TEXTO PARA CHECK-IN NO TFS'`
      — seção do TFS preservada na instrução de gravação.
- [ ] `git diff --stat skills/gct-pr-text/SKILL.md` — vazio, ou acompanhado de
      bump de `version` e entrada no `CHANGELOG.md`.

**Critério de conclusão:** a reference cobre os seis entregáveis da fase 3 e
declara, para cada um, quem o produz e qual regra de proibição se aplica.

---

### Fase 5 — Agente `agents/mario.agent.md`

**Objetivo:** o agente existe na nova pasta `agents/` da raiz e dá a percepção de
fluxo MARIO sem duplicar o detalhamento da skill.

**Dependências:** Fase 1 (pode ocorrer em paralelo com as fases 2, 3 e 4 — arquivo
distinto, e cita apenas o `SKILL.md`)

**Alterações:**

- [ ] Criar `agents/mario.agent.md` com frontmatter no formato observado em
      `.kiro/agents/browse-to-smartx-migrator.agent.md` (`name`, `description`,
      `argument-hint` orientando o código da issue).
- [ ] Escrever o corpo fino: identidade do MARIO, as 6 fases com executor e
      gate, os pré-requisitos bloqueantes, as proibições e a instrução de
      carregar a skill `mario` para o detalhamento — sem repetir templates nem
      rubricas.
- [ ] Declarar no agente que as fases 4 e 6 são humanas e que a fase 5 é
      acionável sob demanda.

**Validação:**

- [ ] `Get-Content agents/mario.agent.md -TotalCount 10` — frontmatter no formato
      do exemplo instalado.
- [ ] `Select-String -Path agents/mario.agent.md -Pattern 'skills/mario|skill mario'`
      — delegação de detalhamento explícita.
- [ ] `git check-ignore -v .kiro/agents .kiro/skills` — confirma que os caminhos
      de consumo seguem ignorados, e que o agente foi versionado em `agents/`
      (CA-012).

**Critério de conclusão:** `agents/mario.agent.md` está versionado, é
autossuficiente para iniciar o fluxo e não contradiz o `SKILL.md`.

---

### Fase 6 — Documentação do repositório

**Objetivo:** `README.md` e `CHANGELOG.md` refletem a nova skill, a nova pasta de
recursos e a forma de instalar cada uma.

**Dependências:** Fase 1, Fase 5

**Alterações:**

- [ ] Adicionar a linha da skill `mario` na tabela de skills do `README.md`, com
      descrição derivada da `description` real do `SKILL.md` — REQ-044.
- [ ] Incluir `agents/mario.agent.md` e `skills/mario/` na árvore de estrutura do
      `README.md`, mantendo o formato existente.
- [ ] Documentar em "Como usar" que a extensão Dex instala apenas o conteúdo de
      `skills` (confirmado em `.dex/sync.json`) e que o agente é instalado por
      cópia manual para `.kiro/agents/` do repositório alvo.
- [ ] Acrescentar em "Acionando as skills" um exemplo real de acionamento do
      MARIO, coerente com a `description`.
- [ ] Registrar em `## [Não publicado]` do `CHANGELOG.md`, em `Adicionado`, a
      skill `mario` e a pasta `agents/` como novo tipo de recurso; em
      `Modificado`, a atualização do `README.md` — REQ-045.

**Validação:**

- [ ] `Select-String -Path README.md -Pattern 'skills/mario|agents/mario'` —
      skill e agente presentes na tabela e na árvore.
- [ ] `Select-String -Path CHANGELOG.md -Pattern 'Não publicado' -Context 0,25` —
      entrada da skill `mario` e da pasta `agents/` sob a categoria correta.
- [ ] Conferir que nenhuma versão publicada do `CHANGELOG.md` foi reescrita e que
      as datas seguem o formato mensal `YYYY-MM`.

**Critério de conclusão:** um leitor que só tem o `README.md` consegue instalar a
skill e o agente e acionar o MARIO — CA-011.

---

### Fase 7 — Revisão de consistência (TE-001)

**Objetivo:** o conjunto entregue satisfaz CA-001 a CA-012, sem contradição entre
`SKILL.md`, references e agente.

**Dependências:** Fases 1 a 6

**Alterações:**

- [ ] Revisar `SKILL.md`, as três references e `agents/mario.agent.md` contra CA-001
      a CA-010, anotando e corrigindo cada desvio.
- [ ] Conferir que todo caminho de reference citado no `SKILL.md` existe e é
      relativo, e que nenhuma reference cita arquivo inexistente.
- [ ] Conferir que nenhuma API, classe, tabela, campo ou parâmetro Protheus foi
      afirmado sem verificação, e que os textos instruem a consulta às fontes de
      verdade — CA-010.
- [ ] Conferir que nada foi gravado em `.kiro/agents` ou `.kiro/skills` deste
      repositório e que `.specs/dex/` não foi tocado fora dos artefatos desta
      feature — CA-012.

**Validação:**

- [ ] `git status --short` — apenas os arquivos previstos nas fases 1 a 6.
- [ ] `git diff --check` — sem erro de espaço em branco.
- [ ] `Get-ChildItem -Recurse skills/mario, agents | Select-Object FullName` —
      árvore igual à da seção 3 da spec.

**Critério de conclusão:** revisão concluída com zero desvio aberto em CA-001 a
CA-012.

---

### Fase 8 — Validação assistida no repositório de módulo (TE-002 a TE-008)

**Objetivo:** o fluxo do MARIO se comporta como especificado em execução real.

**Dependências:** Fase 7

**Pré-condições externas:** repositório de módulo Protheus aberto no Kiro, skill
e agente instalados, MCP `advpl-tlpp-mcp-docs` disponível e uma issue de bug
real para exercitar o fluxo. Estes cenários não rodam neste repositório e
precisam de participação humana.

**Alterações:**

- [ ] Executar a fase 1 sobre uma issue real: conferir `business-refinement.md`,
      as quatro respostas, a nota com pontuação por dimensão e a parada no gate —
      TE-002.
- [ ] Executar a fase 2 na sequência: conferir `bug-spec.md`, `rca.md`,
      `test-case.md` e o Kanoah nos caminhos de REQ-038, sem artefato em
      `.specs/fixes/` ou `docs/rca/` — TE-003.
- [ ] Executar a fase 3: conferir `tasks.md`, o código alterado, o script AdvPR,
      `technical-doc.md`, `pr-text.md`, a conversão de encoding e a ausência de
      commit, compilação e publicação — TE-004.
- [ ] Exercitar o cenário de branch: com árvore limpa, autorizar a criação e
      confirmar `mario/{ISSUE}`; repetir com árvore suja e confirmar o
      impedimento sem stash nem descarte — TE-005.
- [ ] Exercitar o cenário de pré-requisito ausente: renomear temporariamente uma
      skill bloqueante e confirmar o aborto antes de qualquer artefato — TE-006.
- [ ] Exercitar a retomada em nova sessão e confirmar o reconhecimento da fase
      pelo `mario.status.md` — TE-007.
- [ ] Exercitar o cenário de issue que não é bug e confirmar o encerramento na
      fase 1 com encaminhamentos sugeridos — TE-008.
- [ ] Corrigir na skill ou no agente cada desvio encontrado, subindo a `version`
      no `metadata` e registrando no `CHANGELOG.md`.

**Validação:**

- [ ] Em cada cenário, `git status --short` no repositório de módulo mostra
      artefatos apenas em `.specs/mario/{ISSUE}/` e, na fase 3, o fonte alterado
      e o script AdvPR.
- [ ] Nenhum commit, push, PR, compilação ou publicação no Confluence ocorreu.

**Critério de conclusão:** os sete cenários executados, com desvios corrigidos ou
registrados como pendência acordada com o usuário.

## Paralelismo e ordem de execução

- A Fase 1 é bloqueante: as references citam os invariantes definidos nela.
- Fases 2, 3 e 5 podem correr em paralelo depois da Fase 1 — arquivos distintos,
  sem dependência de resultado entre si.
- A Fase 4 depende da Fase 3 porque consome os artefatos e a nomenclatura de
  delegação definidos lá.
- Fases 6, 7 e 8 são sequenciais e fecham a entrega.

## Riscos

| Risco | Efeito | Mitigação |
| --- | --- | --- |
| A `gct-tests` procura a origem em `.specs/fixes/...` e pode não aceitar `.specs/mario/{ISSUE}` só por prompt | Kanoah gerado a partir da origem errada, ou gravado fora do caminho | Tarefa de avaliação na Fase 4; se exigir alterar a `gct-tests`, parar e decidir com o usuário — a spec não autoriza essa alteração |
| A `advpl-tlpp-sdd` pode reintroduzir seus gates ou sugerir Quick mode | Fluxo para em gate não previsto ou pula RCA/tasks | REQ-025 e RN-004 declarados na Fase 3, com o desfecho explícito quando a skill sugerir o desvio |
| Skills delegadas mudarem de default de caminho em versões futuras | Artefato gravado fora de `.specs/mario/{ISSUE}` | REQ-040: verificação por `git status` ao fim de cada fase, com movimentação e aviso |
| `SKILL.md` crescer além do que a divulgação progressiva recomenda | Skill difícil de manter e de carregar | Limite e extração previstos na última tarefa da Fase 1 |

## Definição de pronto

- [ ] `skills/mario/SKILL.md` e as três references de fase existem, com nome de
      arquivo em inglês e conteúdo em português — CA-001.
- [ ] `agents/mario.agent.md` existe na nova pasta `agents/` da raiz — CA-001.
- [ ] CA-002 a CA-010 verificados na revisão da Fase 7.
- [ ] `README.md` e `CHANGELOG.md` atualizados — CA-011.
- [ ] Nada versionado em `.kiro/agents` ou `.kiro/skills` — CA-012.
- [ ] `git diff --check` sem erro e diff revisado.
- [ ] Cenários TE-002 a TE-008 executados no repositório de módulo, com desvios
      corrigidos ou acordados.
