---
name: mario
description: >-
  Conduz a resolução de uma issue de manutenção (bug) do TOTVS Protheus em um
  fluxo de 6 fases, executando as três primeiras — refinamento de negócio,
  refinamento técnico e codificação — e encerrando cada uma em aprovação humana
  explícita. Trata uma issue por execução, grava todos os artefatos em
  `.specs/mario/{ISSUE}` e delega às skills advpl-tlpp-sdd, gct-tests,
  tdn-technical-doc-writer e gct-pr-text sobrepondo os caminhos default delas.
  Nunca compila, nunca executa, nunca commita, nunca abre pull request e nunca
  publica no Confluence. Agnóstico de módulo Protheus.
  Use quando o usuário disser: rodar o mario, mario da issue, refinar a issue,
  refinamento de negócio da issue, isso é bug mesmo, refinamento técnico da
  issue, rodar a fase 1 da issue, rodar a fase 2 da issue, rodar a fase 3 da
  issue, corrigir essa issue, resolver esse bug do começo ao fim, retomar a
  issue no mario, code review da issue.
license: MIT
metadata:
  domain: Protheus
  maintainer: Engenharia Protheus - Gestão de Contratos / Gestão de Receitas
  author: guilherme.sordi@totvs.com.br
  version: 1.1.0
  category: Maintenance / Spec-Driven Development
  depends-on: advpl-tlpp-sdd, advpl-tlpp-root-cause-analysis, kanoah-advpr-generator, tdn-technical-doc-writer, gct-tests, gct-pr-text
---

# MARIO — Resolução de issues de manutenção do Protheus

MARIO trata **uma issue por execução**, de forma interativa, dentro do repositório
de módulo aberto no workspace. Ele conduz o refinamento de negócio, o refinamento
técnico e a codificação; validação, merge e teste de aceitação permanecem com
pessoas.

O trabalho é organizado em 6 fases. Ao final de cada fase executada pelo MARIO
existe um **gate**: o turno encerra e nada avança sem aprovação explícita do
usuário.

## Fluxo das 6 fases

| Fase | Executor | Artefatos | Skills delegadas | Encerramento |
| --- | --- | --- | --- | --- |
| 1 — Refinamento de negócio | MARIO | `business-refinement.md` | nenhuma | gate humano |
| 2 — Refinamento técnico | MARIO | `bug-spec.md`, `rca.md`, `test-case.md`, `kanoah/{routine}/{CTxxx}.md` | `advpl-tlpp-sdd` (Specify + Design), `gct-tests` | gate humano |
| 3 — Codificação | MARIO | `tasks.md`, fonte alterado, script AdvPR, `technical-doc.md`, `pr-text.md`, `side-findings.md` | `advpl-tlpp-sdd` (Tasks + Execute), `gct-tests`, `tdn-technical-doc-writer`, `gct-pr-text` | gate humano |
| 4 — Validação | humano | — | — | — |
| 5 — Code review | MARIO, sob demanda | resultado no chat | `code-review` | — |
| 6 — Teste de aceitação | humano (CI/CD gera o `.ptm`) | — | — | — |

Detalhamento de cada fase executável:

- [phase-1-business-refinement.md](references/phase-1-business-refinement.md)
- [phase-2-technical-refinement.md](references/phase-2-technical-refinement.md)
- [phase-3-coding.md](references/phase-3-coding.md)

Carregue a reference da fase que vai executar. Não carregue as três de uma vez.

---

## Preflight

Executar **antes de qualquer fase**, inclusive quando o usuário aciona uma fase
isolada. O preflight não produz artefato.

### 1. MCP `advpl-tlpp-mcp-docs`

Faça uma chamada real e barata para provar que o MCP responde — por exemplo
`language-system-docs-search` com `limit: 1`. Presença de tool na lista não é
prova; a chamada é.

Se a tool não existir ou a chamada falhar, **não interrompa**. Informe:

> O MCP `advpl-tlpp-mcp-docs` não está respondendo. Sem ele eu perco o acesso à
> documentação oficial, ao dicionário de dados e à busca semântica no código do
> Protheus, então a análise fica mais fraca e mais dependente de inferência.
> Quer continuar mesmo assim?

Registre a resposta no `mario.status.md` e **repita o aviso no encerramento de
cada fase** executada em modo degradado.

### 2. Skills bloqueantes

Verifique a existência de `SKILL.md` para cada uma das seis skills abaixo, em
`.kiro/skills/{skill}/SKILL.md` do workspace e, como alternativa, no diretório de
skills do usuário (em VS Code o caminho instalado é `.agents/skills/{skill}/`):

| Skill | Para quê |
| --- | --- |
| `advpl-tlpp-sdd` | `bug-spec.md`, `rca.md`, `tasks.md` e a execução das tasks |
| `advpl-tlpp-root-cause-analysis` | RCA, acionada por dentro do Design da `advpl-tlpp-sdd` |
| `gct-tests` | Kanoah e script AdvPR |
| `tdn-technical-doc-writer` | conteúdo do documento técnico |
| `gct-pr-text` | texto do PR e resumo de check-in do TFS |
| `kanoah-advpr-generator` | XML de importação no Zephyr Scale, quando pedido |

Faltando **qualquer uma**, aborte antes de criar qualquer artefato — inclusive
antes de criar a pasta `.specs/mario/{ISSUE}/`. Liste as ausentes e instrua a
instalação pela extensão Dex.

Skills usadas mas **não** bloqueantes: `utf8-to-cp1252-conversion` (fase 3),
`code-review` (fase 5) e `tdn-technical-doc-review` (auditoria interna da
`tdn-technical-doc-writer`). Na ausência delas, avise a degradação e siga.

### 3. Steerings aplicáveis

As skills delegadas operam pelos defaults genéricos delas. As regras específicas
do repositório alvo vivem em `.kiro/steering/*.md`, e é o MARIO quem precisa
levá-las até cada delegação — as skills não as enxergam sozinhas. Levante-as aqui,
no preflight, para não descobri-las tarde demais.

1. **Liste** os arquivos de `.kiro/steering/` do repositório alvo. Se o diretório
   não existir ou a leitura falhar, **não é erro e não aborta**: registre "sem
   steerings" no `mario.status.md`, avise que a aderência a convenções específicas
   do projeto não pôde ser garantida automaticamente, e siga.
2. **Classifique** cada steering pelo `inclusion` do front matter:
   - `inclusion: auto` ou `inclusion: always` → sempre aplicável;
   - `inclusion: fileMatch` com `fileMatchPattern` → aplicável quando o fluxo do
     MARIO tocar arquivos que casam com o padrão. **Identifique-a já aqui**, mesmo
     que o arquivo-alvo só vá ser tocado numa fase posterior;
   - `inclusion: manual` → só quando explicitamente acionada; não repasse por
     padrão.
3. **Extraia** de cada steering aplicável as regras concretas que afetam os
   artefatos do MARIO e mapeie a **fase e a delegação** em que cada uma morde.
   O que procurar (exemplos genéricos, não lista fechada):
   - **numeração/nomenclatura de casos de teste** → fase 2 (`test-case.md` e
     Kanoah) e fase 3 (script AdvPR);
   - **convenção de DT/TDN** (página pai/`ancestor_id`, release/rótulos de versão,
     autoria, texto proibido) → fase 3 (`technical-doc.md`);
   - **tipagem, encoding, includes, padrões de código** → fase 3 (Execute);
   - **mensagem de commit / texto de PR** → fase 3 (`pr-text.md`).
4. **Registre** o resultado na seção "Steerings aplicáveis" do `mario.status.md`
   (ver "Estado e gates"), para o mapeamento sobreviver à retomada em outra sessão
   e alimentar os prompts de delegação de cada fase.

O objetivo é **antecipar**: uma regra de steering `fileMatch` precisa ser conhecida
na fase em que o artefato é **decidido**, não só na fase em que o arquivo é
**escrito**. Exemplo do mecanismo: a regra de faixa de numeração de teste unitário
mora numa steering `fileMatch` que só casaria com o script AdvPR na fase 3, mas o
código do CT é decidido na fase 2 — então a regra tem de estar levantada antes.

O MARIO **não copia a steering inteira** para o status nem para os prompts: extrai
as regras concretas e cita a steering de origem pelo nome do arquivo, para
rastreabilidade.

---

## Branch de trabalho

A branch do MARIO é `mario/{ISSUE}`, com a chave em maiúsculas — a mesma forma da
pasta de artefatos. O prefixo `kiro/` pertence à `gct-sdd`; nunca use.

No início de qualquer parte do fluxo, confira a branch atual (`git branch --show-current`).
Se não for `mario/{ISSUE}`, informe o usuário e pergunte se deve criar a branch a
partir da master. Os quatro desfechos:

| Situação | Comportamento |
| --- | --- |
| Criação autorizada, árvore limpa | `git fetch origin`, criar a partir de `origin/master` (ou `origin/main`, conforme a base do repositório alvo), ativar a branch e só então continuar |
| Criação autorizada, árvore suja | **Impedimento.** Liste os pendentes (`git status --short`), explique que a criação exige árvore limpa e pare |
| Criação recusada pelo usuário | Siga na branch atual. Não é impedimento |
| Já está em `mario/{ISSUE}` | Siga, mesmo com árvore suja. Liste os pendentes e registre a pendência no `mario.status.md`, porque eles afetam o diff que a fase 3 descreve no `pr-text.md` |

No impedimento por árvore suja, **não** faça stash, não descarte e não commite
nada. A árvore é do usuário.

---

## Estado e gates

### `mario.status.md`

Único registro de estado do MARIO. Criado na primeira fase executada e atualizado
ao final de cada uma.

```markdown
# MARIO — {ISSUE}

- **Issue:** {ISSUE} — {título}
- **Link:** https://jiraproducao.totvs.com.br/browse/{ISSUE}
- **Branch:** {branch atual}
- **Fase atual:** {n} — {nome} | aguardando aprovação | aprovada
- **Modo degradado:** não | sim ({motivo}, autorizado em {data})

## Aprovações

| Fase | Data | Aprovada por | Observação |
| --- | --- | --- | --- |

## Decisões

| Data | Decisão | Motivo |
| --- | --- | --- |

## Pendências

| Item | Impacto | Aberta desde |
| --- | --- | --- |

## Steerings aplicáveis

Preenchida no preflight e relida na retomada; cada linha vira insumo dos prompts
de delegação da fase correspondente.

| Steering | Inclusão | Regra concreta | Fase / delegação onde se aplica |
| --- | --- | --- | --- |
```

Na retomada, leia este arquivo antes de agir. Na ausência dele, infira a fase
pelos artefatos existentes na pasta da issue e **declare a inferência ao usuário**
antes de executar qualquer coisa.

### Gate de fim de fase

Ao concluir uma fase, apresente no chat:

1. o que foi produzido, em uma linha por artefato, com o caminho;
2. as conclusões que o usuário precisa conferir (nota de confiabilidade, causa
   raiz, tasks, achados colaterais);
3. as pendências abertas;
4. o aviso de modo degradado, se aplicável.

Depois **encerre o turno**. Regras do gate:

- Nunca inicie a fase seguinte no mesmo turno em que encerrou a anterior.
- Silêncio não é aprovação.
- Pedido genérico ("continua", "segue") não é aprovação: confirme qual fase está
  sendo aprovada antes de avançar.
- Registre a aprovação no `mario.status.md` com data.

### Acionamento de fase isolada

O usuário pode pedir "rodar a fase 2 da issue X". Antes de executar, valide que os
artefatos da fase anterior existem **e** que a fase está aprovada no
`mario.status.md`.

Se não estiverem, avise exatamente o que falta e **não prossiga**. Não existe
confirmação que dispense a fase anterior.

---

## Artefatos e caminhos

**Regra inviolável:** todo artefato de especificação do MARIO vive em
`.specs/mario/{ISSUE}/`. `{ISSUE}` é a chave do JIRA em maiúsculas, sem slug
descritivo. Aceite na entrada chave em minúsculas, ID numérico ou URL do JIRA, e
normalize para a chave em maiúsculas.

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

O MARIO **não** cria nem atualiza `.specs/project/`, `.specs/codebase/` ou
`.specs/HANDOFF.md`. Se existirem no repositório alvo, podem ser lidos como
contexto, nunca escritos.

### Overrides das skills delegadas

Cada skill delegada tem caminho default próprio. Informe o destino explícito no
prompt de cada delegação — o default nunca prevalece.

Quando uma regra de steering do repositório (levantada no preflight) diverge do
comportamento padrão da skill delegada, vale esta ordem de precedência:

1. Steering específica do repositório (`.kiro/steering/*.md`) — prevalece.
2. Regra do próprio MARIO (`SKILL.md` e references).
3. Default da skill delegada.

Onde uma steering declarar explicitamente que "prevalece sobre a skill X", o MARIO
honra isso no prompt de delegação, repassando a regra e dizendo que ela ganha do
default da skill.

| Skill | Default dela | Destino no MARIO |
| --- | --- | --- |
| `advpl-tlpp-sdd` | `.specs/fixes/[bug]/` | `.specs/mario/{ISSUE}/` |
| `advpl-tlpp-sdd` (Quick mode) | `.specs/quick/NNN-slug/TASK.md` + `SUMMARY.md` | proibido — ver fase 2 |
| `advpl-tlpp-root-cause-analysis` | `docs/rca/RCA-<rotina>-<AAAA-MM-DD>.md` | `.specs/mario/{ISSUE}/rca.md` |
| `gct-tests` | `tests/kanoah/{rotina}/{CTxxx}.md` | `.specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md` |
| `gct-pr-text` | entrega apenas no chat | grava `.specs/mario/{ISSUE}/pr-text.md` |
| `tdn-technical-doc-writer` | publica página no Confluence | grava `.specs/mario/{ISSUE}/technical-doc.md` |

### Validação de fim de fase

Antes de apresentar o gate, rode `git status --short` e confirme que nenhum
artefato de especificação nasceu fora de `.specs/mario/{ISSUE}/`. Os desvios mais
prováveis são `.specs/fixes/`, `.specs/quick/`, `docs/rca/` e `tests/kanoah/`.
Encontrando artefato fora, mova para o caminho correto e avise o usuário.

---

## Fase 4 — Validação (humana)

Fora do escopo executável. No gate da fase 3, diga ao usuário o que ele precisa
validar antes de seguir com o PR:

- o `business-refinement.md` descreve o defeito que o cliente relatou;
- a causa raiz do `rca.md` se sustenta no fonte apontado;
- a alteração é mínima e não carrega mudança oportunista;
- o fonte compila (o MARIO não compilou) e o cenário do `test-case.md` passa;
- `technical-doc.md` está pronto para publicação no TDN;
- `pr-text.md` descreve o diff que será submetido;
- os itens do `side-findings.md` foram decididos.

Commit, push, abertura do PR e publicação da DT são desta fase, e são do humano.

## Fase 5 — Code review (sob demanda)

Quando o usuário pedir o code review, delegue à skill `code-review` e entregue o
resultado **no chat**. Não publique comentário em PR, não crie arquivo de review e
não altere código para atender ao próprio review sem pedido explícito.

## Fase 6 — Teste de aceitação (humana)

Fora do escopo. As esteiras de CI/CD geram o pacote `.ptm` e a última validação
antes da entrega ao cliente é humana.

---

## Proibições

Valem em todas as fases, sem exceção e sem "só desta vez":

- não compilar (não acionar `advpl-tlpp-compile`), não abrir o SmartClient, não
  executar testes;
- não fazer commit, não fazer push, não abrir pull request;
- não publicar página no Confluence;
- não fazer stash, não descartar e não commitar alteração pendente do usuário;
- não corrigir problema colateral sem aprovação explícita;
- não gravar artefato de especificação fora de `.specs/mario/{ISSUE}/`;
- não escrever em `.specs/project/`, `.specs/codebase/` ou `.specs/HANDOFF.md`;
- não avançar de fase sem aprovação registrada.

Duas obrigações que a proibição de compilar não dispensa:

- **Encoding.** Todo fonte AdvPL/TLPP tocado na fase 3 é convertido para CP-1252
  com a skill `utf8-to-cp1252-conversion`. Quem compila é o humano da fase 4, e
  fonte em UTF-8 chega nele com acentuação corrompida.
- **Rastreabilidade.** Fonte não compilado e teste não executado ficam registrados
  no `mario.status.md` e no `pr-text.md`, não apenas ditos no chat.

Sobre conteúdo técnico: nenhuma classe, método, função, tabela, campo, parâmetro
ou ponto de entrada do Protheus é afirmado por memória. Confirme no código do
repositório alvo ou nas fontes de verdade (MCP `advpl-tlpp-mcp-docs`, documentação
oficial) antes de escrever a afirmação em qualquer artefato.

---

## MARIO ou `gct-sdd`?

As duas cobrem o refinamento técnico e não devem tratar a mesma issue.

| Use | Quando |
| --- | --- |
| MARIO | uma issue, de forma interativa, com aprovação humana por fase, incluindo refinamento de negócio e codificação |
| `gct-sdd` | várias issues em lote, sem interação, apenas `bug-spec.md` e `rca.md`, em worktrees e branches `kiro/{ISSUE}` |

Se a issue já tem artefatos em `.specs/fixes/{ISSUE}/` produzidos pela `gct-sdd`,
avise o usuário antes de começar: seguir com o MARIO cria a mesma documentação em
outra pasta e outra branch. Decida com ele entre aproveitar o que existe (movendo
para `.specs/mario/{ISSUE}/`) ou recomeçar.

---

## Checklist de encerramento de fase

- [ ] Preflight executado; modo degradado e steerings aplicáveis registrados, se houver.
- [ ] Branch conferida e o desfecho aplicado.
- [ ] Regras das steerings aplicáveis a esta fase foram repassadas às delegações e conferidas nos artefatos produzidos.
- [ ] Todos os artefatos da fase existem em `.specs/mario/{ISSUE}/`.
- [ ] `git status --short` sem artefato de especificação fora da pasta da issue.
- [ ] Nenhum commit, push, PR, compilação, execução ou publicação aconteceu.
- [ ] `mario.status.md` atualizado com fase, decisões e pendências.
- [ ] Resumo, caminhos e pendências apresentados no chat.
- [ ] Turno encerrado aguardando aprovação explícita.
