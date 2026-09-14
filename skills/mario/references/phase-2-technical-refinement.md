# Fase 2 — Refinamento técnico

**Objetivo:** provar a causa raiz do defeito e fixar o cenário de regressão que
comprovará a correção.

**Entregas em `.specs/mario/{ISSUE}/`:**

| Artefato | Quem produz |
| --- | --- |
| `bug-spec.md` | `advpl-tlpp-sdd` — fase Specify (bug track) |
| `rca.md` | `advpl-tlpp-sdd` — fase Design (aciona a skill de RCA por dentro) |
| `context.md` | `advpl-tlpp-sdd` — só quando o Discuss for acionado |
| `test-case.md` | MARIO |
| `kanoah/{routine}/{CTxxx}.md` | `gct-tests` — modo "apenas Kanoah" |

**Encerramento:** gate humano. A fase 3 não começa no mesmo turno.

## Pré-condição

`business-refinement.md` existe e a fase 1 está aprovada no `mario.status.md`. Se
não estiver, avise o que falta e **não prossiga** — não há confirmação que
dispense a fase 1.

Quando a nota de confiabilidade ficou abaixo de 6, é preciso também a decisão
explícita do usuário registrada no `mario.status.md`.

---

## 1. `bug-spec.md` — Specify da `advpl-tlpp-sdd`

Acione a `advpl-tlpp-sdd` **por fase**, nunca de ponta a ponta. Aqui, apenas o
Specify do bug track.

O `business-refinement.md` é a entrada: ele já respondeu esperado, atual, jornada e
respaldo. O Specify não redescobre isso — formaliza em bug spec com escopo,
restrições e critérios de aceite.

Modelo de delegação:

```
Skill: advpl-tlpp-sdd — bug track, fase Specify apenas.

Issue: {ISSUE}
Contexto de negócio já aprovado: .specs/mario/{ISSUE}/business-refinement.md

Grave a bug spec em .specs/mario/{ISSUE}/bug-spec.md.
NÃO use .specs/fixes/ — o caminho da pasta é imposto pelo MARIO.

Não acione Quick mode. Não pule a fase Design nem a fase Tasks por
auto-dimensionamento: bug-spec.md, rca.md e tasks.md são sempre produzidos.

Não abra gate de aprovação ao final do Specify: siga direto para o Design.
Premissas que você pediria para aprovar ficam registradas na própria bug spec,
em uma seção de premissas.
```

## 2. `rca.md` — Design da `advpl-tlpp-sdd`

No bug track, a causa raiz é estabelecida na fase **Design**, que aciona a skill
`advpl-tlpp-root-cause-analysis` por dentro.

O MARIO **não** chama a skill de RCA diretamente.

O default dela é `docs/rca/RCA-<rotina>-<AAAA-MM-DD>.md` na raiz do workspace, e
ela só usa outro caminho se ele for informado. Informe.

```
Skill: advpl-tlpp-sdd — bug track, fase Design.

Issue: {ISSUE}
Bug spec: .specs/mario/{ISSUE}/bug-spec.md

Grave o RCA em .specs/mario/{ISSUE}/rca.md.
NÃO use docs/rca/RCA-<rotina>-<data>.md.

O RCA prova a causa e propõe a correção mínima, sem aplicá-la: nenhum fonte é
alterado nesta fase.

Não abra gate ao final do Design. O gate é do MARIO, ao fim da fase 2.
```

O RCA precisa apontar fonte, função e linha, com as evidências que sustentam a
causa. Causa raiz descrita como sintoma ("o campo vem vazio") não fecha a fase:
peça o encadeamento até a origem.

### Quick mode é proibido

O Quick mode grava `TASK.md` + `SUMMARY.md` em `.specs/quick/NNN-slug/` e dispensa
RCA e tasks. Ele não é usado pelo MARIO em nenhuma hipótese, mesmo quando a causa
parece óbvia — o fluxo entrega os três artefatos.

Se a skill delegada sugerir Quick mode ou auto-dimensionamento que pule Design ou
Tasks, recuse e siga o bug track completo. Registre a tentativa como decisão no
`mario.status.md`.

---

## 3. `test-case.md` e o Kanoah — `gct-tests`

Acione a `gct-tests` no modo **"apenas Kanoah"**. O script AdvPR é da fase 3.

Dois ajustes de rota são obrigatórios no prompt:

1. **Origem.** A skill procura a especificação em `.specs/fixes/...`. Informe que
   a origem é `.specs/mario/{ISSUE}/`, com `bug-spec.md` e `rca.md`.
2. **Destino.** O default dela é `tests/kanoah/{rotina}/{CTxxx}.md`. No MARIO o
   Kanoah fica em `.specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md`.

```
Skill: gct-tests — modo "apenas Kanoah".

Issue: {ISSUE}
Origem das informações: .specs/mario/{ISSUE}/ (bug-spec.md e rca.md).
NÃO procure em .specs/fixes/.

Grave o Kanoah em .specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md.
NÃO use tests/kanoah/{rotina}/{CTxxx}.md.

O script AdvPR será criado na fase 3 deste mesmo fluxo. Quando perguntar sobre
criar o script agora, a resposta é não — e, por isso, NÃO marque o caso de teste
como Test Type: Manual, porque a automação está prevista.
```

3. **Regras do repositório que prevalecem.** Antes de montar o prompt, releia a
   seção "Steerings aplicáveis" do `mario.status.md` e selecione as regras que
   afetam o caso de teste (numeração, nomenclatura, estrutura). Inclua no prompt um
   bloco final, montado **dinamicamente** a partir do que o preflight levantou — não
   crave a regra aqui:

```
Regras do repositório que PREVALECEM sobre os defaults desta skill
(extraídas das steerings em .kiro/steering/, ver mario.status.md):
- {regra concreta 1} (fonte: {arquivo da steering})
- {regra concreta 2} (fonte: {arquivo da steering})
Onde estas regras conflitarem com o comportamento padrão da skill, siga as regras acima.
```

Atenção ao momento: uma regra de numeração/nomenclatura de teste costuma morar numa
steering `fileMatch` que só casaria com o script AdvPR na fase 3. Mas o código do CT
é decidido **agora**, na fase 2, no `test-case.md` e no Kanoah. **É obrigação da
fase 2** aplicar essa regra já ao definir o código do CT, sob pena de o CT nascer
com numeração incompatível e só ser corrigido depois.

Respeite a porta de antiduplicidade da skill. Se já existe Kanoah para o CT, para
o método do script ou citando a issue, informe o usuário e **não sobrescreva** —
decida com ele entre reaproveitar o caso existente ou criar um novo cenário.

### `test-case.md`

Documento do MARIO. Registra o cenário de regressão aprovado e amarra as pontas:

```markdown
# Caso de teste de regressão — {ISSUE}

- **Rotina:** {rotina}
- **Código CT:** {CTxxx}
- **Kanoah:** `.specs/mario/{ISSUE}/kanoah/{routine}/{CTxxx}.md`
- **Método AdvPR previsto:** `{Rotina}TestCase.PRW` → `{nome do método}` (fase 3)

## Cenário

Passos, massa e pontos de verificação que provam a correção.

## Por que este cenário prova a correção

Ligação explícita com a causa raiz do `rca.md`.

## Fora do cenário

O que este caso de teste não cobre.
```

O nome do método é **previsão**, confirmada na fase 3 quando o script é escrito.

### XML do Zephyr Scale

A `kanoah-advpr-generator` só é acionada quando o usuário pedir explicitamente o
XML de importação no Zephyr. Não gere XML por iniciativa própria.

---

## 4. Validação de fim de fase

```
git status --short
```

Confirme que nada de especificação nasceu fora de `.specs/mario/{ISSUE}/`. Desvios
prováveis nesta fase:

| Caminho | Origem do desvio |
| --- | --- |
| `.specs/fixes/{ISSUE}/` | default da `advpl-tlpp-sdd` |
| `.specs/quick/NNN-slug/` | Quick mode acionado por engano |
| `docs/rca/RCA-*.md` | default da `advpl-tlpp-root-cause-analysis` |
| `tests/kanoah/{rotina}/` | default da `gct-tests` |

Encontrando artefato fora, mova para o caminho correto, remova a pasta vazia que
sobrou e avise o usuário. Confirme também que **nenhum fonte** AdvPL/TLPP foi
alterado: a fase 2 não escreve código.

Confirme ainda que a numeração e a nomenclatura do CT criado obedecem às steerings
aplicáveis registradas no `mario.status.md`. Encontrando divergência, corrija o
código do CT no `test-case.md` e no Kanoah antes do gate.

---

## 5. Encerramento

Atualize o `mario.status.md` e apresente no gate:

- caminhos de `bug-spec.md`, `rca.md`, `test-case.md` e do Kanoah;
- a causa raiz em uma linha, com fonte e função;
- a correção mínima proposta pelo RCA, ainda não aplicada;
- o cenário de regressão em uma linha;
- premissas registradas nos documentos, que a fase 3 vai assumir;
- pendências e aviso de modo degradado, se houver.

Encerre o turno. A fase 3 depende de aprovação explícita.
