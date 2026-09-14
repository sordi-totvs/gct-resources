# Fase 3 — Codificação

**Objetivo:** aplicar a correção mínima que resolve o defeito provado no `rca.md`,
com a documentação e a automação que acompanham a entrega.

**Entregas:**

| Artefato | Caminho | Quem produz |
| --- | --- | --- |
| `tasks.md` | `.specs/mario/{ISSUE}/` | `advpl-tlpp-sdd` — fase Tasks |
| Fonte corrigido | repositório alvo | `advpl-tlpp-sdd` — fase Execute |
| Script AdvPR | `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW` | `gct-tests` |
| `technical-doc.md` | `.specs/mario/{ISSUE}/` | `tdn-technical-doc-writer` (sem publicar) |
| `pr-text.md` | `.specs/mario/{ISSUE}/` | `gct-pr-text` (com gravação) |
| `side-findings.md` | `.specs/mario/{ISSUE}/` | MARIO, só se houver achados |

**Encerramento:** gate humano. A fase 4 é do humano.

## Pré-condição

`bug-spec.md`, `rca.md` e `test-case.md` existem e a fase 2 está aprovada no
`mario.status.md`. Se não estiverem, avise o que falta e **não prossiga**.

---

## 1. `tasks.md` — Tasks da `advpl-tlpp-sdd`

```
Skill: advpl-tlpp-sdd — fase Tasks.

Issue: {ISSUE}
Entradas: .specs/mario/{ISSUE}/bug-spec.md e .specs/mario/{ISSUE}/rca.md

Grave as tasks em .specs/mario/{ISSUE}/tasks.md.
NÃO use .specs/fixes/.

As tasks cobrem a correção mínima, o teste de regressão e a prevenção apontada
pelo RCA. Não abra gate ao final: o gate é do MARIO, ao fim da fase 3.

Regras do repositório que PREVALECEM sobre os defaults desta skill
(extraídas das steerings em .kiro/steering/, ver mario.status.md):
- {regra concreta 1} (fonte: {arquivo da steering})
- {regra concreta 2} (fonte: {arquivo da steering})
Onde estas regras conflitarem com o comportamento padrão da skill, siga as regras acima.
```

Antes de montar o prompt, releia a seção "Steerings aplicáveis" do
`mario.status.md` e selecione as regras que afetam o código (tipagem, encoding,
includes, padrões AdvPL/TLPP, proibições). Monte o bloco **dinamicamente** — não
crave a regra aqui. Sem regra de código aplicável, omita o bloco.

## 2. Execute da `advpl-tlpp-sdd`

O Execute conduz a implementação, uma task por vez. Duas etapas do ciclo dele são
**suprimidas** pelo MARIO:

| Etapa do Execute | O que o MARIO faz |
| --- | --- |
| Compilação e a pergunta sobre compilar | suprimida — ver seção 3 |
| Commit Git atômico ao final de cada task | suprimido — o MARIO nunca commita |

Todo o resto do ciclo permanece: escolher a task, verificar dependências,
implementar, rodar o gate de qualidade (complexidade, regras de SonarQube críticas)
e marcar a task como concluída no `tasks.md`.

Regras que valem acima de qualquer sugestão da skill delegada:

- **Alteração mínima.** Só o necessário para o defeito descrito na bug spec.
  Refatoração, renomeação, reordenação de código e "melhoria enquanto estou aqui"
  ficam fora — vão para `side-findings.md`.
- **Sem mudança oportunista de dicionário, parâmetro ou ponto de entrada** sem que
  a bug spec ou o RCA a exijam.
- Nenhuma API, classe, método, tabela, campo ou parâmetro do Protheus é usado por
  memória. Confirme no código do repositório alvo ou nas fontes de verdade (MCP
  `advpl-tlpp-mcp-docs`, documentação oficial) antes de escrever a linha.
- **Regras de código do repositório prevalecem.** As regras de tipagem, encoding,
  includes e padrões AdvPL/TLPP levantadas no preflight (seção "Steerings
  aplicáveis" do `mario.status.md`) ganham do default da skill. Repasse-as no
  prompt do Execute, citando a steering de origem, e siga-as onde divergirem do
  comportamento padrão da skill.

Artefatos que o Execute não cobre e permanecem com o MARIO: script AdvPR,
`technical-doc.md`, `pr-text.md` e `side-findings.md`.

## 3. Encoding — obrigatório

Fonte AdvPL/TLPP gerado ou editado por IA nasce em UTF-8, e o compilador exige
CP-1252. Como o MARIO não compila, quem compila é o humano na fase 4 — e receberia
acentuação corrompida.

Converta **todo fonte tocado** com a skill `utf8-to-cp1252-conversion`. Ela resolve
o script pelo sistema operacional: `scripts/convert-encoding.bat` no Windows,
`scripts/convert-encoding.sh` em Linux e macOS.

Converta apenas os fontes que a fase 3 alterou. Não rode em modo recursivo sobre
pastas do repositório.

### O que "não executar" significa

- não acionar `advpl-tlpp-compile`;
- não abrir o SmartClient;
- não rodar teste, nem AdvPR, nem TIR.

Registre no `mario.status.md` e na seção de observações do `pr-text.md` que **o
fonte não foi compilado nem executado**.

## 4. Script AdvPR — `gct-tests`

```
Skill: gct-tests — apenas o script AdvPR. O Kanoah já existe.

Issue: {ISSUE}
Kanoah: .specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md
Cenário aprovado: .specs/mario/{ISSUE}/test-case.md

Implemente o método em tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW do
repositório alvo — este é o único artefato desta fase fora de .specs/mario/.

Não compile e não execute o teste.

Regras do repositório que PREVALECEM sobre os defaults desta skill
(extraídas das steerings em .kiro/steering/, ver mario.status.md):
- {regra concreta 1} (fonte: {arquivo da steering})
- {regra concreta 2} (fonte: {arquivo da steering})
Onde estas regras conflitarem com o comportamento padrão da skill, siga as regras acima.
```

Antes de montar o prompt, releia a seção "Steerings aplicáveis" do
`mario.status.md` e selecione as regras de numeração/nomenclatura de teste (a mesma
steering `fileMatch` que orientou o CT na fase 2). Monte o bloco
**dinamicamente**, garantindo que o método criado seja coerente com o código do CT
já definido na fase 2.

Confirme, no `test-case.md`, o nome real do método criado — na fase 2 ele era
previsão.

## 5. `technical-doc.md` — `tdn-technical-doc-writer`

A skill monta o conteúdo da DT campo a campo e, no fluxo dela, publicaria a página
no Confluence. **Aqui ela para antes da publicação.**

```
Skill: tdn-technical-doc-writer — montar o conteúdo apenas.

Issue: {ISSUE}

NÃO chame confluence-create-requirement-doc. NÃO pergunte se pode publicar.
A publicação é decisão humana da fase 4.

Entregue o conteúdo campo a campo, como seria publicado, para gravação em
.specs/mario/{ISSUE}/technical-doc.md.

Regras do repositório que PREVALECEM sobre os defaults desta skill
(extraídas das steerings em .kiro/steering/, ver mario.status.md):
- {convenção de DT concreta 1} (fonte: {arquivo da steering})
- {convenção de DT concreta 2} (fonte: {arquivo da steering})
Onde estas regras conflitarem com o comportamento padrão da skill, siga as regras acima.
```

Antes de montar o prompt, releia a seção "Steerings aplicáveis" do
`mario.status.md` e selecione as convenções de DT do projeto que se aplicam ao caso
(página pai/`ancestor_id` por projeto e tipo de issue, release e rótulos de versão,
autoria, texto proibido). Monte o bloco **dinamicamente**, citando a steering de
origem — não crave o valor aqui.

**Consequência.** Quando a convenção do projeto **determina** o `ancestor_id` e a
release, o `technical-doc.md` **não** registra essas informações como pendência a
perguntar ao usuário: traz o valor já resolvido pela convenção. Só vira pendência a
perguntar aquilo que a própria steering mandar perguntar. Onde a steering declarar
que prevalece sobre a `tdn-technical-doc-writer`, honre isso no prompt.

Sobre a auditoria: a `tdn-technical-doc-writer` audita o conteúdo com a
`tdn-technical-doc-review` em modo pré-publicação antes de apresentá-lo. Mantenha
esse passo quando a skill de review estiver instalada — corrigir agora é mais
barato que corrigir página publicada. Ela não é pré-requisito bloqueante do MARIO:
ausente, siga e avise a degradação.

O `technical-doc.md` declara no topo:

- qual template segue (`Documento Técnico (New)`, salvo indicação diferente da
  própria skill);
- que está **pronto para publicação** e que a publicação não foi feita;
- o `ancestor_id` da página pai: quando uma steering aplicável fixa o valor por
  projeto e tipo de issue, o documento traz o `ancestor_id` **já resolvido pela
  convenção**, citando a steering de origem; só quando **nenhuma** steering resolve
  o valor é que o documento o marca como pendência a perguntar ao usuário. O mesmo
  vale para a release/rótulos de versão fixados por convenção — resolvidos não são
  lacuna.

Como os changesets ainda não existem (nada foi commitado), o documento descreve a
correção a partir do `rca.md`, do `tasks.md` e do diff local.

## 6. `pr-text.md` — `gct-pr-text`

A regra da `gct-pr-text` é entregar apenas no chat e nunca gravar arquivo, **salvo
pedido explícito**. O MARIO pede explicitamente.

A skill também para no início quando encontra alterações não commitadas e pergunta
se deve considerá-las. Na fase 3 isso é permanente — o MARIO nunca commita —, então
a resposta vai antecipada no prompt.

```
Skill: gct-pr-text.

Issue: {ISSUE}

Pedido explícito de gravação: grave o texto em .specs/mario/{ISSUE}/pr-text.md,
preservando a seção TEXTO PARA CHECK-IN NO TFS.

Sobre as alterações pendentes de commit: SIM, considere todas. O MARIO não
commita por regra, então o diff da entrega está inteiro no working tree.

Na seção de observações, registre que o fonte não foi compilado nem executado.
```

Apresente o texto **também no chat** no encerramento da fase, no formato que a
skill define. Não faça commit, não faça push e não abra o PR.

## 7. `side-findings.md`

Criado **apenas quando houver achados**. Sem achados, o arquivo não existe — não
crie um documento vazio dizendo que não há nada.

Um item por problema:

```markdown
# Achados colaterais — {ISSUE}

## 1. {título curto}

- **Fonte / função:** `{caminho}` → `{Função}`
- **Sintoma:** o que acontece de errado
- **Risco de deixar sem correção:** impacto e probabilidade
- **Esforço estimado:** ordem de grandeza
- **Relação com esta issue:** independente | agrava o defeito | mesmo trecho de código
```

Nenhum achado é corrigido sem aprovação explícita do usuário, mesmo que a correção
seja de uma linha e o código esteja aberto na sua frente. Liste-os no gate.

---

## 8. Validação de fim de fase

```
git status --short
```

Confirme:

- artefatos de especificação apenas em `.specs/mario/{ISSUE}/`;
- fora de lá, somente o fonte corrigido e o `{Rotina}TestCase.PRW`;
- nenhum arquivo em `.specs/fixes/`, `.specs/quick/`, `docs/rca/` ou
  `tests/kanoah/`;
- nenhum commit criado (`git log --oneline -3` no mesmo ponto de antes);
- todo fonte AdvPL/TLPP tocado foi convertido para CP-1252;
- o `technical-doc.md`, o `pr-text.md` e o fonte respeitam as steerings aplicáveis
  registradas no `mario.status.md` — em especial, o `technical-doc.md` traz o
  `ancestor_id` e a release resolvidos pela convenção quando ela existir, sem
  marcá-los como pendência.

---

## 9. Encerramento

Atualize o `mario.status.md` e apresente no gate:

- caminhos de `tasks.md`, `technical-doc.md`, `pr-text.md`, do fonte alterado e do
  script AdvPR;
- o que mudou no comportamento, em uma linha;
- os arquivos alterados, com o papel de cada um;
- o texto do PR no chat;
- os itens do `side-findings.md`, quando houver, para decisão;
- as pendências explícitas: fonte não compilado, teste não executado, DT não
  publicada, nada commitado;
- aviso de modo degradado, se houver.

Depois liste o que a fase 4 exige do humano — a lista está no `SKILL.md`, seção
"Fase 4 — Validação (humana)".

Encerre o turno.
