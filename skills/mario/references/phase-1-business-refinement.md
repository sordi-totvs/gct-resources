# Fase 1 — Refinamento de negócio

**Objetivo:** decidir se a issue é realmente um bug e definir, com evidência, qual
é o comportamento esperado, qual é o comportamento atual e como reproduzi-lo.

**Entrega:** `.specs/mario/{ISSUE}/business-refinement.md`.

**Encerramento:** gate humano. A fase 2 não começa no mesmo turno.

Esta fase é análise, não codificação. Nenhum fonte é alterado aqui.

---

## 1. Coleta de informação

As fontes abaixo são **obrigatórias**. Fonte que não responde, não existe ou volta
vazia não é ignorada: fica registrada no documento e derruba a nota.

### 1.1 A issue no JIRA

`get-jira-issue` com a chave da issue.

- O bloco `zendesk_ticket` vem sem custo extra quando a issue está ligada a um
  ticket. Leia o `subject` original, a organização, o status e o
  `last_comment_by` — a descrição do cliente costuma estar mais completa ali que
  no resumo da issue.
- Havendo indício de evidência anexada (print, log, vídeo), repita a chamada com
  `include_zendesk_attachments: true` e leia os anexos do ticket. Eles são
  distintos dos anexos da própria issue, que já vêm em `attachments`.
- Leia os `comments`: a jornada de reprodução quase sempre aparece na conversa com
  o atendimento, não no campo de descrição.
- Aproveite `technical_scope` (módulo, rotina, ambiente, país) e
  `affected_versions` para saber onde procurar no código.

Issue não encontrada ou sem acesso: **pare** e peça ao usuário os dados do
defeito. Não invente cenário.

### 1.2 Changesets, quando existirem

Se a issue já tem código associado, `include_changesets: true` no
`get-jira-issue` traz o resumo. Para os fontes tocados use
`get-jira-issue-changesets` e, quando precisar ver o que mudou,
`get-changeset-diffs`.

Isso importa em dois casos: a issue é uma regressão de entrega anterior, ou já
houve tentativa de correção. Ambos mudam a leitura do comportamento atual.

### 1.3 O código do repositório alvo

Localize a rotina e a função que produzem o comportamento atual. Leia a função
inteira — não conclua a partir de nome de variável, comentário ou resumo.

Complementos úteis, quando a origem não está óbvia: `code-search` para busca
semântica no código do Protheus, `called-functions-by-programs-search` para a
árvore de chamadas do programa e `program-parameters-search` para os parâmetros
que a rotina consome.

Se você não conseguir apontar fonte e função, diga isso no documento. Essa lacuna
tem peso na nota.

### 1.4 A documentação do produto e do framework

- `product-docs-search` — comportamento documentado do módulo, da rotina, dos
  parâmetros e dos pontos de entrada.
- `language-system-docs-search` — comportamento de classe, método ou função de
  framework citado na análise.

Documentação que descreve exatamente o comportamento reclamado é o que separa bug
de funcionamento esperado. Procure antes de concluir.

### 1.5 Norma, lei ou obrigação fiscal

Quando o comportamento esperado depender de legislação, obrigação acessória,
cálculo tributário ou layout de arquivo legal, consulte
`legislation-docs-search`. Sem essa consulta, "o cliente diz que o valor está
errado" não sustenta comportamento esperado.

---

## 2. As quatro perguntas

O documento responde exatamente estas quatro, nesta ordem:

| Pergunta | O que a resposta precisa ter |
| --- | --- |
| Qual é a jornada do usuário para reproduzir o erro? | Módulo, rotina, dados de entrada e a sequência de passos. Cada passo verificável por quem nunca viu a issue |
| Qual seria o comportamento esperado? | O resultado correto, com a fonte que o sustenta |
| Qual é o comportamento atual? | O que acontece hoje, apontando fonte e função onde acontece |
| O que respalda o esperado? | Documento do TDN, padrão de mercado, norma ou lei — com link, número ou identificação. "Expectativa do cliente" é resposta válida, e vale 1 ponto na rubrica, não 2 |

Cada resposta cita a origem da informação: caminho do fonte com a função, URL do
TDN, identificação do documento legal ou o campo da issue de onde saiu.

---

## 3. É bug?

Decisão explícita, com justificativa. Sinais de que **não** é bug:

| Situação | Encaminhamento |
| --- | --- |
| O comportamento reclamado está documentado como esperado | não é bug — devolver ao atendimento com o documento |
| A reclamação pede comportamento que nunca existiu | melhoria, não manutenção |
| O resultado muda com parametrização (`SX6`) ou dicionário | erro de configuração de ambiente |
| O uso descrito não é o previsto para a rotina | orientação de uso |
| O comportamento vem de customização do cliente | fora do produto padrão |
| Falta informação para reproduzir e não há evidência | devolver pedindo dados, sem concluir |

Concluindo que não é bug, o fluxo **para** — ver a seção 6.

---

## 4. Nota de confiabilidade

Cinco dimensões, de 0 a 2 pontos cada, somando no máximo 10. Registre a pontuação
**por dimensão**, com uma linha de justificativa cada. Não arredonde para cima e
não invente meio ponto.

| Dimensão | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Reprodutibilidade da jornada | passos desconhecidos | passos inferidos do código | passos completos e confirmados na issue ou no ticket |
| Comportamento atual | não localizado no código | localizado por inferência | localizado no fonte e na função exatos |
| Respaldo do comportamento esperado | nenhuma fonte | apenas a expectativa do cliente | TDN, norma, lei ou padrão de mercado citado |
| Qualidade das informações da issue | descrição insuficiente | descrição parcial | descrição, evidências e dados de ambiente |
| Premissas | decisões-chave presumidas | premissas menores em aberto | nenhuma premissa não confirmada |

Fonte obrigatória indisponível reduz a dimensão correspondente. MCP indisponível
(modo degradado) costuma afetar respaldo e comportamento atual — registre isso na
justificativa em vez de manter a pontuação cheia.

### Nota menor que 6

A nota **não** bloqueia por si só. Com total abaixo de 6:

1. liste as dimensões que derrubaram a nota;
2. recomende o que buscar — informação com o atendimento, evidência com o
   cliente, documento no TDN, acesso a ambiente;
3. exija decisão explícita do usuário antes de iniciar a fase 2 e registre essa
   decisão no `mario.status.md`.

Com 6 ou mais, vale o gate normal de aprovação da fase.

---

## 5. Template do `business-refinement.md`

```markdown
# Refinamento de negócio — {ISSUE}

- **Issue:** {ISSUE} — {título}
- **Link:** https://jiraproducao.totvs.com.br/browse/{ISSUE}
- **Ticket Zendesk:** {ids} — {organização} | não há
- **Módulo / rotina:** {módulo} / {rotina}
- **Versões afetadas:** {affected_versions}
- **Data:** {AAAA-MM-DD}
- **Conclusão:** é bug | não é bug
- **Nota de confiabilidade:** {n}/10

## 1. Jornada do usuário para reproduzir

1. ...
2. ...

**Massa / pré-condições:** ...

## 2. Comportamento esperado

...

## 3. Comportamento atual

... — ocorre em `{caminho/do/fonte}`, função `{Função}`.

## 4. Respaldo do comportamento esperado

| Fonte | Identificação | O que sustenta |
| --- | --- | --- |

## 5. É bug?

**Conclusão:** ...

**Justificativa:** ...

## 6. Nota de confiabilidade

| Dimensão | Pontos | Justificativa |
| --- | --- | --- |
| Reprodutibilidade da jornada | /2 | |
| Comportamento atual | /2 | |
| Respaldo do comportamento esperado | /2 | |
| Qualidade das informações da issue | /2 | |
| Premissas | /2 | |
| **Total** | **/10** | |

## 7. Fontes consultadas

| Fonte | Resultado |
| --- | --- |
| `get-jira-issue` | ... |
| Código do repositório | ... |
| `product-docs-search` | ... |
| `language-system-docs-search` | ... |
| `legislation-docs-search` | consultada | não aplicável |
| Changesets | ... | não há |

## 8. Premissas e lacunas

- ...

## 9. Encaminhamento

...
```

Seção sem conteúdo recebe `Não há.` — não desaparece do documento.

---

## 6. Encerramento

### Quando é bug

Grave o documento, atualize o `mario.status.md` e apresente no gate:

- o caminho do `business-refinement.md`;
- a jornada de reprodução em uma linha;
- esperado versus atual em uma linha cada;
- a nota, com as dimensões que perderam ponto;
- as premissas em aberto;
- o aviso de modo degradado, se houver.

Encerre o turno. A fase 2 depende de aprovação explícita, e de decisão adicional
do usuário quando a nota ficou abaixo de 6.

### Quando não é bug

Grave o documento com a conclusão, as evidências e a nota — ele é a resposta ao
atendimento, e não deixa de existir por a issue não seguir adiante. Reporte ao
usuário e ofereça os encaminhamentos:

- devolver ao atendimento com o documento que sustenta o comportamento atual;
- tratar como melhoria, fora do fluxo de manutenção;
- solicitar mais informações ou evidência ao cliente;
- seguir para a fase 2 mesmo assim, se o usuário discordar da conclusão.

A fase 2 só começa com decisão explícita. Registre a decisão no
`mario.status.md`.
