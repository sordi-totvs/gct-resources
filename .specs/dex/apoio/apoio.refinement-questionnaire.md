# Questionário de Refinamento — apoio

## Como responder

Responda abaixo de cada pergunta, mantendo a numeração. Respostas curtas são
suficientes. Quando a sugestão estiver adequada, responda `manter sugestão`.
Itens marcados como **Essencial** afetam diretamente a implementação.

## 1. Escopo e acionamento

### 1.1 Onde este fluxo é definido? **Essencial**

O fluxo de "apoio" é uma variação do MARIO. Ele deve ser incorporado à própria
skill `mario` (nova reference de fluxo + ajustes no `SKILL.md`), ou virar uma
skill nova e independente?

Sugestão: incorporar ao MARIO como um fluxo alternativo, selecionado pelo tipo da
issue, reaproveitando preflight, branch e controle de estado. Assim evitamos
duplicar toda a mecânica.

Resposta: manter sugestão

### 1.2 Como o MARIO decide que a issue é do tipo "apoio"? **Essencial**

O MARIO passa a tratar dois fluxos (manutenção/bug e apoio). Como ele escolhe?
Pelo campo de tipo da issue no JIRA (`get-jira-issue`), por instrução explícita
do usuário, ou por ambos?

Sugestão: detectar pelo tipo/issuetype do JIRA e confirmar com o usuário no
início; se o usuário disser explicitamente "apoio", isso prevalece.

Resposta: Exclusivamente pelo issuetype do Jira. Pode ser "Apoio" ou "Apoio - Cliente".

### 1.3 "apoio" e "apoio ao cliente" são fluxos distintos ou o mesmo fluxo? **Essencial**

O briefing distingue "apoio" (dúvida/pedido do time de suporte) de "apoio ao
cliente" (atendimento direto ao cliente). Eles seguem o mesmo fluxo de duas fases
(need-for-support.md + resposta), diferindo só no destinatário e no tom da
sugestão de resposta, ou têm artefatos/estrutura diferentes?

Sugestão: mesmo fluxo e mesmos artefatos para os dois; a diferença fica no
destinatário e no ajuste de tom da "Sugestão de resposta" (para o colega de
suporte vs. para o cliente final).

Resposta: manter sugestão

## 2. Artefatos e caminhos

### 2.1 Onde ficam os artefatos deste fluxo? **Essencial**

O MARIO grava tudo em `.specs/mario/{ISSUE}/`. O fluxo de apoio deve usar a mesma
pasta por issue, apenas trocando os nomes de arquivo (`need-for-support.md` e o
arquivo da fase 2)?

Sugestão: sim, manter `.specs/mario/{ISSUE}/` e o mesmo `mario.status.md`, só
mudando os artefatos gerados neste fluxo.

Resposta: manter sugestão

### 2.2 Qual o nome dos arquivos das fases? **Essencial**

O briefing nomeia a fase 1 (`need-for-support.md`) mas não a fase 2. Quais nomes
de arquivo usar para o entendimento do pedido (fase 1) e para o parecer técnico +
sugestão de resposta (fase 2)?

Sugestão: fase 1 = `support-request.md`; fase 2 = `support-response.md`.

Resposta: fase 1 = `support-request.md`; fase 2 = `support-response.md`.

### 2.3 O fluxo de apoio usa `mario.status.md` e a mesma branch `mario/{ISSUE}`?

Deve reaproveitar o controle de estado e a branch de trabalho do MARIO, ou por
ser um fluxo sem alteração de código isso é dispensável?

Sugestão: reaproveitar o `mario.status.md` para rastreabilidade e aprovação;
dispensar a criação de branch, já que o fluxo de apoio não altera código-fonte
(criar branch só se o usuário pedir).

Resposta: manter sugestão

## 3. Fases, gates e proibições

### 3.1 O fluxo de apoio tem gate humano ao fim de cada fase? **Essencial**

O MARIO encerra cada fase num gate com aprovação humana explícita. O fluxo de
apoio mantém gate ao fim da fase 1 (antes de gerar a resposta) e ao fim da fase 2?

Sugestão: manter gate ao fim da fase 1 (o usuário responde as dúvidas e aprova o
entendimento) e ao fim da fase 2 (entrega da sugestão de resposta encerra o
fluxo).

Resposta: manter sugestão

### 3.2 As proibições do MARIO continuam valendo?

Neste fluxo, além das proibições padrão (não compilar, não commitar, não abrir
PR, não publicar no Confluence), há algo específico? Por exemplo, o MARIO pode
responder diretamente no JIRA/e-mail, ou apenas entrega a sugestão de resposta
como artefato/no chat?

Sugestão: mesmas proibições; o MARIO só entrega a "Sugestão de resposta" como
texto (artefato + chat), nunca publica resposta no JIRA nem envia e-mail.

Resposta: manter sugestão

### 3.3 O preflight do MARIO (MCP, skills, steerings) se aplica igual?

O fluxo de apoio não delega para as skills de bug (advpl-tlpp-sdd, gct-tests,
etc.). Quais verificações de preflight permanecem obrigatórias?

Sugestão: manter a verificação do MCP `advpl-tlpp-mcp-docs` (essencial para a
análise da fase 2) e o levantamento de steerings; remover a exigência das skills
de bug como bloqueantes neste fluxo.

Resposta: manter sugestão

## 4. Fase 2 — análise e resposta

### 4.1 Quais fontes de análise são obrigatórias na fase 2?

O briefing cita código do repositório, TDN, issues anteriores e "qualquer outra
fonte útil". Alguma dessas é obrigatória, ou todas são "conforme necessário para
sustentar o parecer"?

Sugestão: todas conforme necessário; o parecer deve citar as fontes efetivamente
usadas e o MARIO não afirma API/tabela/campo do Protheus por memória (confirma no
código ou no MCP).

Resposta: manter sugestão

### 4.2 O que a seção "Sugestão de resposta" deve conter além do texto?

Além do texto no estilo e-mail corporativo pouco formal e amigável, a seção deve
incluir algo como saudação/assinatura, ou é só o corpo da mensagem?

Sugestão: corpo da mensagem pronto para copiar, com saudação e fechamento
amigáveis, sem assinatura pessoal (o remetente preenche).

Resposta: manter sugestão

### 4.3 Idioma da sugestão de resposta.

A sugestão de resposta deve ser sempre em português do Brasil, ou pode variar
(por exemplo, quando "apoio ao cliente" for de mercado internacional)?

Sugestão: português do Brasil por padrão; só variar se a issue indicar
explicitamente outro idioma.

Resposta: manter sugestão
