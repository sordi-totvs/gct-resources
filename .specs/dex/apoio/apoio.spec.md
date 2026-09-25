# Especificação — Fluxo de apoio no MARIO

## 1. Objetivo e contexto

Adicionar ao MARIO um segundo fluxo de trabalho, para issues do tipo **apoio**,
distinto do fluxo de manutenção (bug) que ele já executa. Issues de apoio não
pedem correção de defeito: elas registram um pedido ou uma dúvida — do time de
suporte/atendimento, ou de um cliente que usa o sistema — que o time de
desenvolvimento precisa ajudar a responder.

O fluxo de apoio tem **duas fases**, ambas executadas pelo MARIO, cada uma
encerrada por um gate humano:

1. **Fase 1 — Refinamento de negócio:** entender o pedido de apoio e registrar o
   entendimento, o que ficou obscuro e as dúvidas para o usuário.
2. **Fase 2 — Resposta ao apoio:** produzir um parecer técnico embasado e uma
   sugestão de resposta pronta para o solicitante.

Não há fase 3 nem fases subsequentes: a entrega da sugestão de resposta encerra o
fluxo.

## 2. Referências

- Briefing: `.specs/dex/apoio/apoio.briefing.md`
- Questionário: `.specs/dex/apoio/apoio.refinement-questionnaire.md`
- Skill base: `ai-resources/skills/mario/SKILL.md` (fluxo de 6 fases para bug)
- Preflight, branch, estado e proibições reaproveitados do `mario/SKILL.md`

## 3. Escopo

### Incluído

- Um fluxo de apoio de duas fases dentro da skill `mario`, selecionado pelo tipo
  da issue.
- Geração dos artefatos `support-request.md` (fase 1) e `support-response.md`
  (fase 2) em `.specs/mario/{ISSUE}/`.
- Reaproveitamento do `mario.status.md`, do preflight e das proibições do MARIO,
  com os ajustes descritos nesta especificação.

### Excluído

- Qualquer alteração de código-fonte Protheus, teste, RCA, documento técnico ou
  texto de PR — artefatos exclusivos do fluxo de bug.
- Publicação da resposta no JIRA, envio de e-mail ou qualquer entrega automática
  ao solicitante.
- Criação de uma skill nova e independente: o fluxo de apoio vive dentro do
  MARIO.

## 4. Requisitos funcionais

### 4.1 Seleção do fluxo

- O MARIO **deve** identificar o fluxo de apoio **exclusivamente** pelo issuetype
  do JIRA, obtido via `get-jira-issue`.
- Os issuetypes que ativam o fluxo de apoio são **"Apoio"** e **"Apoio -
  Cliente"**.
- Issuetype "Apoio" indica apoio ao time de suporte/atendimento; "Apoio -
  Cliente" indica atendimento direto a um cliente que usa o sistema.
- O MARIO **não deve** inferir o tipo de apoio por instrução do usuário nem por
  heurística de texto: a origem é o issuetype.
- Issues que não sejam desses dois issuetypes seguem o fluxo de bug já existente
  e estão fora desta especificação.

### 4.2 Fluxo único para os dois issuetypes

- "Apoio" e "Apoio - Cliente" **devem** seguir o mesmo fluxo de duas fases e
  gerar os mesmos artefatos.
- A diferença entre eles **deve** se refletir apenas no destinatário e no ajuste
  de tom da seção "Sugestão de resposta": para o colega de suporte no caso
  "Apoio", para o cliente final no caso "Apoio - Cliente".

### 4.3 Fase 1 — Refinamento de negócio (`support-request.md`)

- A fase 1 **deve** produzir o artefato `support-request.md` em
  `.specs/mario/{ISSUE}/`.
- O artefato **deve** conter, no mínimo:
  - o que o agente entendeu do pedido/dúvida da issue;
  - o que o agente não entendeu (pontos obscuros ou ambíguos);
  - quando necessário, uma lista de dúvidas a serem respondidas pelo usuário para
    esclarecer a necessidade do solicitante.
- O artefato **deve** conter, **somente quando necessário**, uma seção de testes
  a serem feitos no sistema. Essa seção só é incluída quando a leitura do
  código-fonte não permitir identificar algum comportamento relevante para
  atender ao pedido: cada teste listado aponta o comportamento que não pôde ser
  determinado pelo código e descreve o cenário a ser executado no sistema para
  esclarecê-lo. Quando o código-fonte for suficiente para identificar todos os
  comportamentos, a seção é omitida.
- A fase 1 **deve** encerrar em gate humano: o usuário responde as dúvidas e
  aprova o entendimento antes da fase 2.

### 4.4 Fase 2 — Resposta ao apoio (`support-response.md`)

- A fase 2 **deve** produzir o artefato `support-response.md` em
  `.specs/mario/{ISSUE}/`.
- A resposta **deve** se basear em análise aprofundada, usando as fontes que
  forem necessárias para sustentar o parecer: código do produto no repositório,
  documentação do TDN, issues anteriores e qualquer outra fonte útil.
- O artefato **deve** conter um parecer técnico da IA e, ao final, uma seção
  intitulada **"Sugestão de resposta"**.
- A seção "Sugestão de resposta" **deve** conter o corpo da mensagem pronto para
  copiar, no estilo "e-mail corporativo pouco formal e amigável", com saudação e
  fechamento amigáveis e **sem** assinatura pessoal (o remetente preenche).
- A entrega da fase 2 encerra o fluxo; **não deve** haver fase subsequente.
- A fase 2 **deve** encerrar em gate humano.

## 5. Regras de negócio

- O parecer técnico **deve** citar as fontes efetivamente utilizadas na análise.
- O MARIO **não deve** afirmar classe, método, função, tabela, campo, parâmetro
  ou ponto de entrada do Protheus por memória: cada afirmação é confirmada no
  código do repositório alvo ou nas fontes de verdade (MCP `advpl-tlpp-mcp-docs`,
  documentação oficial).
- A sugestão de resposta **deve** ser em português do Brasil por padrão, variando
  o idioma somente quando a issue indicar explicitamente outro idioma.
- Os artefatos do fluxo de apoio **devem** viver em `.specs/mario/{ISSUE}/`,
  reaproveitando o `mario.status.md` para rastreabilidade e registro de
  aprovações.
- O fluxo de apoio **não deve** criar branch de trabalho por padrão, por não
  alterar código-fonte; a branch `mario/{ISSUE}` só é criada se o usuário pedir.

## 6. Preflight e proibições

- O preflight **deve** manter a verificação do MCP `advpl-tlpp-mcp-docs`
  (essencial para a análise da fase 2) e o levantamento de steerings aplicáveis.
- As skills de bug (`advpl-tlpp-sdd`, `advpl-tlpp-root-cause-analysis`,
  `gct-tests`, `tdn-technical-doc-writer`, `gct-pr-text`,
  `kanoah-advpr-generator`) **não devem** ser bloqueantes neste fluxo, por não
  serem delegadas.
- As proibições do MARIO permanecem: **não** compilar, **não** executar, **não**
  commitar, **não** abrir PR, **não** publicar no Confluence, **não** mexer em
  alterações pendentes do usuário.
- O MARIO **deve** entregar a "Sugestão de resposta" apenas como texto (artefato
  `support-response.md` + chat); **não deve** publicar a resposta no JIRA nem
  enviar e-mail.

## 7. Gates e estado

- Cada fase **deve** encerrar em gate humano, no padrão do MARIO: apresentar o
  que foi produzido, as conclusões a conferir e as pendências, e então encerrar o
  turno aguardando aprovação explícita.
- O MARIO **deve** registrar fase atual, decisões, pendências e aprovações no
  `mario.status.md`, reaproveitando o mesmo controle de estado do fluxo de bug.
- A fase 2 só **deve** iniciar após a aprovação da fase 1 registrada no
  `mario.status.md`.

## 8. Critérios de aceitação

- **CA-01:** Dada uma issue de issuetype "Apoio" ou "Apoio - Cliente", o MARIO
  seleciona o fluxo de apoio de duas fases; dado qualquer outro issuetype, segue
  o fluxo de bug.
- **CA-02:** A fase 1 gera `.specs/mario/{ISSUE}/support-request.md` contendo o
  que foi entendido, o que não foi entendido e, quando aplicável, a lista de
  dúvidas ao usuário.
- **CA-03:** Quando a leitura do código-fonte não identifica algum comportamento
  relevante, o `support-request.md` inclui uma seção de testes a serem feitos no
  sistema, cada teste ligado ao comportamento não determinado pelo código; quando
  o código é suficiente, a seção é omitida.
- **CA-04:** A fase 1 encerra em gate humano, sem iniciar a fase 2 no mesmo turno.
- **CA-05:** A fase 2 gera `.specs/mario/{ISSUE}/support-response.md` com parecer
  técnico embasado em fontes citadas e uma seção final "Sugestão de resposta".
- **CA-06:** A seção "Sugestão de resposta" traz o corpo da mensagem pronto para
  copiar, em tom de e-mail corporativo pouco formal e amigável, com saudação e
  fechamento, sem assinatura pessoal, em português do Brasil por padrão.
- **CA-07:** O tom/destinatário da sugestão de resposta corresponde ao issuetype
  (colega de suporte para "Apoio"; cliente final para "Apoio - Cliente"), mantido
  o mesmo fluxo e os mesmos artefatos para ambos.
- **CA-08:** O fluxo encerra após a fase 2; nenhuma fase adicional é oferecida.
- **CA-09:** Nenhum commit, push, PR, compilação, execução ou publicação ocorre;
  a resposta não é publicada no JIRA nem enviada por e-mail.
- **CA-10:** O `mario.status.md` registra as duas fases, decisões, pendências e
  aprovações; por padrão, nenhuma branch é criada.

## 9. Testes esperados

- Verificar, em uma issue de cada issuetype ("Apoio" e "Apoio - Cliente"), que o
  fluxo de apoio é acionado e que os artefatos nascem com os nomes e no caminho
  corretos.
- Verificar que uma issue de bug continua acionando o fluxo de 6 fases sem
  regressão.
- Conferir que a fase 1 lista dúvidas quando o pedido é ambíguo e que o gate
  encerra o turno.
- Conferir que a fase 1 inclui a seção de testes no sistema quando o código-fonte
  não determina algum comportamento, e que essa seção é omitida quando o código é
  suficiente para identificar todos os comportamentos.
- Conferir que a fase 2 cita as fontes usadas e que a seção "Sugestão de
  resposta" segue o tom e o formato especificados, com destinatário coerente com
  o issuetype.
- Conferir que nenhuma proibição do MARIO é violada e que o fluxo encerra na
  fase 2.

## 10. Decisões técnicas

- O fluxo de apoio é incorporado à skill `mario` como fluxo alternativo
  (provável nova reference de fase + ajustes no `SKILL.md` e na tabela de
  fluxo/artefatos), em vez de uma skill independente, reaproveitando preflight,
  estado e proibições. O desenho detalhado da implementação (arquivos e edições)
  pertence ao plano (`dex-spec-plan`), não a esta especificação.
- Nomes de artefato: `support-request.md` (fase 1) e `support-response.md`
  (fase 2), formando um par consistente e alinhado ao estilo de nomes por
  conteúdo já usado pelo MARIO.
