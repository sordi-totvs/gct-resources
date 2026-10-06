# Fluxo de apoio

Fluxo alternativo do MARIO para issues de **apoio**, distinto do fluxo de
manutenção (bug) das 6 fases. Issues de apoio não pedem correção de defeito:
registram um pedido ou uma dúvida que o time de desenvolvimento precisa ajudar a
responder.

Carregue esta reference **em vez das** references de fase do bug quando o fluxo
selecionado for o de apoio. A seleção do fluxo é feita no preflight — ver o
`SKILL.md`.

## Quando este fluxo é usado

A seleção é **exclusiva pelo issuetype do JIRA** obtido no `get-jira-issue`:

| Issuetype | Quem é o solicitante | Destinatário da resposta |
| --- | --- | --- |
| `Apoio` | time de suporte/atendimento | colega de suporte |
| `Apoio - Cliente` | cliente que usa o sistema | cliente final |

Os dois issuetypes seguem **o mesmo fluxo e os mesmos artefatos**. A diferença
aparece só no destinatário e no ajuste de tom da "Sugestão de resposta" na fase 2.

Não infira o tipo de apoio por instrução do usuário nem por heurística de texto: a
origem é o issuetype. Qualquer outro issuetype segue o fluxo de bug das 6 fases.

## As duas fases

| Fase | Executor | Artefato | Encerramento |
| --- | --- | --- | --- |
| 1 — Refinamento de negócio | MARIO | `support-request.md` | gate humano |
| 2 — Resposta ao apoio | MARIO | `support-response.md` | gate humano |

Não há fase 3 nem fases subsequentes: a entrega da sugestão de resposta encerra o
fluxo. Ambos os artefatos vivem em `.specs/mario/{ISSUE}/`.

Este fluxo **não delega** para as skills de bug (`advpl-tlpp-sdd`, `gct-tests`,
`tdn-technical-doc-writer`, `gct-pr-text`, `kanoah-advpr-generator`,
`advpl-tlpp-root-cause-analysis`). O MARIO produz os dois artefatos diretamente.

---

## Fase 1 — Refinamento de negócio (`support-request.md`)

**Objetivo:** entender o pedido ou a dúvida da issue de apoio e registrar o que
ficou claro, o que ficou obscuro e o que precisa ser esclarecido com o usuário.

**Entrega:** `.specs/mario/{ISSUE}/support-request.md`.

**Encerramento:** gate humano. A fase 2 não começa no mesmo turno.

Esta fase é análise, não codificação. Nenhum fonte é alterado aqui.

### 1. Coleta de informação

Levante o contexto do pedido antes de concluir o que entendeu. As fontes:

- **A issue no JIRA** — `get-jira-issue` com a chave da issue. Leia a descrição,
  os `comments` e, quando houver, o bloco `zendesk_ticket` (o pedido do cliente
  costuma estar mais completo no `subject` e nos comentários do ticket que no
  resumo da issue). Havendo indício de evidência anexada, repita com
  `include_zendesk_attachments: true`. Aproveite `technical_scope` (módulo,
  rotina, ambiente, país) e `affected_versions` para saber onde investigar.
  Issue não encontrada ou sem acesso: **pare** e peça ao usuário os dados do
  pedido. Não invente o teor do apoio.
- **O código do repositório alvo** — localize a rotina e a função ligadas ao
  pedido e leia o que for necessário para entender o comportamento envolvido.
  `code-search`, `called-functions-by-programs-search` e
  `program-parameters-search` ajudam quando a origem não está óbvia.
- **A documentação do produto e do framework** — `product-docs-search` e
  `language-system-docs-search` para o comportamento documentado do módulo, da
  rotina, dos parâmetros, dos pontos de entrada e do framework citado.
- **Issues anteriores e demais fontes** — quando ajudarem a entender o pedido.

Nada é afirmado por memória: classe, método, função, tabela, campo, parâmetro e
ponto de entrada do Protheus são confirmados no código do repositório alvo ou nas
fontes de verdade (MCP `advpl-tlpp-mcp-docs`, documentação oficial) antes de
entrar no documento.

### 2. Estrutura do `support-request.md`

O documento mostra três coisas — o que foi entendido, o que não foi entendido e as
dúvidas ao usuário — e, **somente quando necessário**, uma seção de testes a serem
feitos no sistema.

A seção de testes só existe quando a leitura do código-fonte **não** permitir
identificar algum comportamento relevante para atender ao pedido. Cada teste
listado aponta o comportamento que não pôde ser determinado pelo código e descreve
o cenário a ser executado no sistema para esclarecê-lo. O teste no sistema é o
último recurso: primeiro esgote o código-fonte. Quando o código for suficiente
para identificar todos os comportamentos, **omita** a seção inteira.

```markdown
# Refinamento de negócio (apoio) — {ISSUE}

- **Issue:** {ISSUE} — {título}
- **Link:** https://jiraproducao.totvs.com.br/browse/{ISSUE}
- **Issuetype:** Apoio | Apoio - Cliente
- **Ticket Zendesk:** {ids} — {organização} | não há
- **Módulo / rotina:** {módulo} / {rotina}
- **Versões afetadas:** {affected_versions}
- **Data:** {AAAA-MM-DD}

## 1. O que foi entendido

O pedido ou a dúvida do apoio, com o que o embasa (fonte do JIRA, ticket, código
ou documentação).

## 2. O que não foi entendido

Pontos obscuros ou ambíguos que ainda impedem uma resposta completa.

## 3. Dúvidas para o usuário

Perguntas objetivas a serem respondidas pelo usuário para esclarecer a
necessidade do solicitante. `Não há.` quando o pedido está claro.

## 4. Testes a serem feitos no sistema

Somente quando a leitura do código-fonte não identificar algum comportamento.
Cada item liga o comportamento não determinado pelo código ao cenário a executar
no sistema. Omita esta seção inteira quando o código for suficiente.

## 5. Fontes consultadas

| Fonte | Resultado |
| --- | --- |
| `get-jira-issue` | ... |
| Código do repositório | ... |
| `product-docs-search` | ... |
| `language-system-docs-search` | ... |
| Issues anteriores | ... | não há |
```

Seção sem conteúdo recebe `Não há.` — não desaparece do documento. A exceção é a
seção de testes no sistema, que é **omitida** quando o código-fonte basta.

### 3. Encerramento da fase 1

Grave o documento, atualize o `mario.status.md` e apresente no gate:

- o caminho do `support-request.md`;
- o que foi entendido, em uma linha;
- os pontos que ficaram obscuros;
- as dúvidas para o usuário, se houver;
- se aplicável, os testes no sistema pendentes de execução;
- o aviso de modo degradado, se houver.

Encerre o turno. A fase 2 depende de aprovação explícita e das respostas às
dúvidas em aberto.

---

## Fase 2 — Resposta ao apoio (`support-response.md`)

**Objetivo:** produzir um parecer técnico embasado e uma sugestão de resposta
pronta para o solicitante.

**Entrega:** `.specs/mario/{ISSUE}/support-response.md`.

**Encerramento:** gate humano. A entrega encerra o fluxo.

### Pré-condição

`support-request.md` existe e a fase 1 está aprovada no `mario.status.md`, com as
dúvidas em aberto respondidas pelo usuário. Se não estiver, avise o que falta e
**não prossiga** — não há confirmação que dispense a fase 1.

### 1. Análise

Aprofunde a análise com base nas fontes que forem necessárias para sustentar o
parecer: código do produto no repositório, documentação do TDN
(`product-docs-search`, `language-system-docs-search`,
`legislation-docs-search` quando houver norma ou obrigação fiscal), issues
anteriores e qualquer outra fonte útil. Se a fase 1 registrou testes a serem
feitos no sistema, incorpore o resultado informado pelo usuário à análise.

Continua valendo: nada por memória. Cada afirmação sobre o Protheus é confirmada
no código ou nas fontes de verdade.

### 2. Estrutura do `support-response.md`

```markdown
# Resposta ao apoio — {ISSUE}

- **Issue:** {ISSUE} — {título}
- **Issuetype:** Apoio | Apoio - Cliente
- **Módulo / rotina:** {módulo} / {rotina}
- **Data:** {AAAA-MM-DD}

## 1. Parecer técnico

Análise que responde ao pedido, com o encadeamento até a conclusão. Aponta fonte,
função e comportamento quando o parecer depender do código.

## 2. Fontes consultadas

| Fonte | O que sustentou |
| --- | --- |

## Sugestão de resposta

{corpo da mensagem pronto para copiar, no estilo e-mail corporativo pouco formal e
amigável, com saudação e fechamento amigáveis, sem assinatura pessoal}
```

O parecer **cita as fontes efetivamente usadas** na análise.

A seção final chama-se exatamente **"Sugestão de resposta"** e traz o corpo da
mensagem pronto para copiar:

- estilo "e-mail corporativo pouco formal e amigável", com saudação e fechamento
  amigáveis, sem assinatura pessoal (o remetente preenche);
- destinatário conforme o issuetype: colega de suporte no `Apoio`, cliente final
  no `Apoio - Cliente`;
- em português do Brasil por padrão, variando o idioma somente quando a issue
  indicar explicitamente outro idioma.

O MARIO **entrega a sugestão apenas como texto** (o artefato e o resumo no chat).
Não publica a resposta no JIRA e não envia e-mail.

### 3. Encerramento da fase 2

Grave o documento, atualize o `mario.status.md` e apresente no gate:

- o caminho do `support-response.md`;
- o parecer técnico em uma linha, com as fontes que o sustentam;
- a sugestão de resposta;
- pendências e aviso de modo degradado, se houver.

Encerre o turno. Este é o fim do fluxo de apoio — não há fase seguinte.

---

## Validação de fim de fase

Em ambas as fases, antes do gate:

```
git status --short
```

Confirme que os artefatos nasceram em `.specs/mario/{ISSUE}/` e que **nenhum
fonte** AdvPL/TLPP foi alterado — o fluxo de apoio não escreve código. Nenhum
commit, push, PR, compilação, execução ou publicação acontece, e a resposta não é
publicada no JIRA nem enviada por e-mail.
