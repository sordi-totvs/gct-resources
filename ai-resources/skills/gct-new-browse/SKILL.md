---
name: gct-new-browse
description: >-
  Implementa ou revisa, de forma minuciosa, a adoção do novo browse do Protheus
  (visualização de dados Smart X ativada no mBrowse via hasSmartX/SetSmartX) em
  rotinas legadas. No modo implementação, exige que o usuário informe a rotina e
  não prossegue sem ela; localiza a chamada do mBrowse, ativa o Smart X na mesma
  função, ajusta legendas (cColorPoUi e de-para de cores), filtros
  (cFilterDefault em SQL, DbSetFilter), MenuDef (pageAction, Imprimir com
  operação 8, opções Pesquisa e Legenda) e usos do objeto do browse após a
  ativação (GetMBrowse com isSmartX). No modo code review, compara por padrão a
  branch atual com a branch principal do git e emite um relatório por regra com
  severidade, evidência (arquivo e linha) e correção sugerida. Nunca compila,
  nunca commita e nunca abre pull request. Use quando o usuário disser: novo
  browse, browse Smart X, browse SmartX no mBrowse, implementar o novo browse,
  converter mBrowse para Smart X, setSmartX, hasSmartX, ativar Smart X na
  rotina, revisar o novo browse, code review do novo browse, revisar setSmartX,
  gct-new-browse.
license: MIT
metadata:
  domain: Protheus
  maintainer: Engenharia Protheus - Gestão de Contratos / Gestão de Receitas
  author: guilherme.sordi@totvs.com.br
  version: 1.0.0
  category: Development / Code Review
---

# GCT New Browse — Novo browse Smart X em rotinas legadas

Aplica ou revisa a ativação da visualização de dados Smart X na função `mBrowse` de
rotinas legadas, conforme a documentação do TDN transcrita em
[references/mbrowse-smartx.md](references/mbrowse-smartx.md).

Antes de qualquer ação, **leia a reference inteira**. Ela é a regra de negócio desta
skill: pré-requisitos, sintaxe de `SetSmartX`, comportamento do menu, estrutura do array
de legendas, de-para de cores e restrições de filtro. Não presuma comportamento que não
esteja nela; quando a reference não bastar, consulte o MCP `advpl-tlpp-mcp-docs`
(`smartx-docs-search`, `language-system-docs-search`, `code-search`) antes de afirmar
como uma função se comporta.

## Escopo

| | |
|---|---|
| **Cobre** | Rotinas que abrem a tela com a função `mBrowse`. |
| **Não cobre** | `FWMBrowse`, `MarkBrowse`, `AxCadastro` ou migração para Smart X nativo (`totvs.framework.structure`). Se a rotina usar um desses, informe que a reference cobre apenas `mBrowse` e pergunte ao usuário como seguir — para migração nativa existe a skill `browse-to-smartx-migration`. |
| **Não faz** | Não compila, não commita, não faz push, não abre PR. |

## Seleção do modo

| O usuário pediu | Modo |
|---|---|
| Implementar, aplicar, converter, ativar o novo browse | **Implementação** |
| Revisar, code review, validar, conferir a implementação | **Code review** |
| Ambíguo | Pergunte qual dos dois modos antes de continuar. |

---

## Modo implementação

### Passo 1 — Rotina obrigatória (parada)

A rotina (nome do fonte ou da função, por exemplo `CNTA100`) é **obrigatória**.

Se o usuário não informou a rotina, **pare**. Peça que ele informe e encerre o turno.
Não deduza a rotina pela branch, por arquivos abertos no editor, por commits ou pelo
histórico da conversa, e não comece nenhuma leitura ou alteração antes da resposta.

> Para implementar o novo browse, preciso saber qual rotina deve ser alterada. Informe o
> fonte ou a função (ex.: `CNTA100`).

### Passo 2 — Localizar o fonte e a chamada do mBrowse

1. Localize o fonte da rotina no repositório de módulo (ex.: `src/**/CNTA100.PRW`). Se
   houver mais de um candidato, liste e pergunte.
2. Leia o fonte **inteiro**. Não trabalhe só com trechos.
3. Localize todas as chamadas de `mBrowse` e a função que contém cada uma.
4. Se não houver `mBrowse`, verifique se a rotina usa outro tipo de browse e aplique a
   regra de escopo acima.
5. Se houver mais de uma chamada de `mBrowse`, liste-as e pergunte quais devem ser
   convertidas.

### Passo 3 — Levantamento antes de alterar

Para cada `mBrowse` a converter, levante e registre:

| Item | O que verificar |
|---|---|
| Ordenação | `DbSetOrder`/índice em uso antes do `mBrowse`, para definir `nIndex`. Confirme no SIX (skill `data-dictionary-lookup`) que o índice existe — índice inexistente gera exceção. |
| Legendas | Array passado ao `mBrowse` (ou montado por função auxiliar): cor de cada item contra a tabela de de-para; presença de ícones/imagens. |
| Filtro | Uso de `DbSetFilter`, filtro AdvPL passado ao `mBrowse` ou `cFilterDefault` existente e se é SQL. |
| MenuDef | Condicionais, opção de Pesquisa, opção de Legenda, operação do Imprimir, ações que precisam de `pageAction`. |
| Objeto do browse | Usos de `GetMBrowse()` e chamadas de métodos sobre o objeto após a ativação. |
| Personalização visual | Cor de fonte, estilo, cor de linha aplicados ao browse. |

Apresente o levantamento ao usuário com as decisões que dependem dele (índice inicial,
ordem ASC/DESC, cores PO-UI, quais ações viram `pageAction`, como tratar o filtro AdvPL)
e só altere o código depois da resposta.

### Passo 4 — Aplicar a implementação

Siga a reference. Em resumo:

1. **Ativação:** dentro da **mesma função** que chama o `mBrowse`, antes da chamada,
   proteja com `hasSmartX()` e chame `SetSmartX(nIndex, lOrderAsc)`, no padrão do
   exemplo da reference. Declare as variáveis locais conforme o estilo do fonte.
2. **Legendas:** para cor fora da tabela de de-para (e fora de `color-01`..`color-12`),
   preencha `cColorPoUi` na 6ª posição com uma cor `caption-tag-NN`. Sem isso, há
   exceção. Ícones não são aceitos.
3. **Filtro:** o browse convertido ignora `DbSetFilter` e expressões AdvPL; apenas
   `cFilterDefault` em SQL é considerado. Converta a regra para SQL quando ela for
   necessária ao negócio, mantendo o comportamento legado inalterado quando
   `hasSmartX()` for falso.
4. **MenuDef:** sem condicionais. Imprimir com operação `8` (`OP_IMPRIMIR` se o fonte
   usar `fwmvcdef.ch`). Ações extras como `pageAction` via 10ª posição do array ou
   `PAGEACTION` no comando `ADD OPTION` (este último depende dos `.ch` atualizados).
   Pesquisa e Legenda deixam de aparecer no Smart X — não as remova do legado sem
   pedido do usuário; apenas informe.
5. **Objeto do browse:** envolva com `if !oBrw:isSmartX()` os métodos executados sobre
   o objeto retornado por `GetMBrowse()` após a ativação.

Regras de alteração:

- Mudança mínima: não refatore nem reformate código não relacionado.
- O comportamento em ambientes sem Smart X deve permanecer idêntico.
- Preserve o encoding original do fonte (Windows-1252). Se o arquivo terminar em UTF-8
  após a edição, converta com a skill `utf8-to-cp1252-conversion`, quando disponível.
- Siga as convenções e steerings do repositório de módulo (`AGENTS.md`,
  `.kiro/steering/*.md`).

### Passo 5 — Autorrevisão e entrega

Execute o checklist do modo code review sobre o fonte alterado e corrija o que falhar.
Entregue no chat:

1. Rotina e funções alteradas.
2. Decisões tomadas (índice, ordem, cores, filtro, pageAction).
3. Impactos que o usuário precisa conhecer (filtros não considerados, personalização
   visual perdida, Pesquisa/Legenda fora do menu, pré-requisito de release).
4. Pendências: o fonte não foi compilado nem testado. Sugira a skill
   `advpl-tlpp-compile` para compilar.

---

## Modo code review

### Passo 1 — Definir o que comparar

- Se o usuário informou o que comparar (branches, commits, arquivos, PR), use isso.
- Se **não** informou, compare a **branch atual** com a **branch principal** do git:
  1. `git branch --show-current`
  2. Branch principal: `git symbolic-ref --short refs/remotes/origin/HEAD`; se falhar,
     use a primeira que existir entre `main`, `master`, `origin/main`,
     `origin/master`. Se nenhuma existir, pergunte.
  3. `git log --oneline <base>..HEAD` e `git diff --stat <base>...HEAD` (três pontos,
     a partir do merge-base).
- Rode `git status --short`. Havendo alterações não commitadas, informe e pergunte se
  devem entrar na revisão.
- Se a branch atual for a própria branch principal e nada for informado, pergunte o
  que revisar.

### Passo 2 — Ler o diff e o contexto completo

1. Leia o diff de cada fonte alterado (`git diff <base>...HEAD -- <arquivo>`).
2. Para cada fonte que toque `mBrowse`, `hasSmartX`, `SetSmartX`, legendas, `MenuDef`
   ou `GetMBrowse`, leia também o **fonte inteiro** na versão da branch: várias regras
   dependem de código fora do diff (mesma função do `mBrowse`, `DbSetFilter` anterior,
   `MenuDef`, usos de `GetMBrowse`).
3. Fontes do diff que chamam `mBrowse` sem ativar o Smart X não são falha por si só —
   registre apenas se o objetivo declarado da mudança incluía essa rotina.

### Passo 3 — Checklist

Avalie cada regra por chamada de `mBrowse` convertida. Status: ✅ conforme, ❌ não
conforme, ⚠️ atenção/decisão do usuário, N/A não se aplica.

| ID | Regra | Severidade se falhar |
|---|---|---|
| NB-01 | `SetSmartX` está no **mesmo fonte e mesma função** que chama o `mBrowse`, antes da chamada. | Alta (exceção) |
| NB-02 | `SetSmartX` protegido por `hasSmartX()`. | Alta |
| NB-03 | `nIndex` corresponde a um índice existente da tabela (SIX) ou é `0` (RECNO), e é coerente com a ordenação legada. | Alta (exceção) |
| NB-04 | `lOrderAsc` é lógico e coerente com a ordenação esperada; variáveis declaradas e usadas com o mesmo nome. | Média |
| NB-05 | Toda cor de legenda está no de-para, em `color-01`..`color-12`, ou tem `cColorPoUi` válido (`caption-tag-01`..`35`) na 6ª posição. | Alta (exceção) |
| NB-06 | Nenhuma legenda usa ícone/imagem fora do de-para. | Alta |
| NB-07 | Estrutura do array de legendas respeita as posições (`xCondition`, `cColor`, `cTitle`, `cID`, `lFilter`, `cColorPoUi`). | Média |
| NB-08 | `DbSetFilter` no alias: a regra não é perdida silenciosamente no Smart X (convertida para `cFilterDefault` SQL ou impacto aceito pelo usuário). | Alta |
| NB-09 | `cFilterDefault`, quando usado, é expressão SQL; filtros AdvPL não são considerados no Smart X. | Alta |
| NB-10 | Métodos executados sobre o objeto de `GetMBrowse()` após a ativação estão protegidos por `isSmartX()`. | Alta |
| NB-11 | `MenuDef` sem condicionais (inclusive as introduzidas para o Smart X). | Alta |
| NB-12 | Imprimir padrão usa operação `8` / `OP_IMPRIMIR` (este exige `fwmvcdef.ch`). | Média |
| NB-13 | `pageAction` adicional usa a 10ª posição do array ou `PAGEACTION` no comando; uso do comando sinalizado como dependente dos `.ch` atualizados. | Baixa |
| NB-14 | Impacto da perda de Pesquisa e Legenda no menu Smart X está identificado; remoção no legado só se pedida. | Baixa |
| NB-15 | Personalização visual (cor/estilo de fonte, cor de linha) que deixa de valer está identificada. | Baixa |
| NB-16 | Comportamento sem Smart X (`hasSmartX()` falso) permanece idêntico ao legado. | Alta |
| NB-17 | Alteração mínima: sem refatoração ou reformatação fora do escopo; encoding Windows-1252 preservado. | Média |
| NB-18 | Includes necessários presentes para as funções/defines usados. Confirme no MCP antes de apontar include faltante. | Média |

Regras de evidência:

- Todo ❌ e ⚠️ cita **arquivo e linha** e traz a **correção sugerida** em código.
- Não aponte falha sem ter lido o trecho. Não invente função, parâmetro, índice ou cor.
- Para validar índice, use `data-dictionary-lookup`; para comportamento de API, o MCP.

### Passo 4 — Relatório

Entregue no chat (grave em arquivo apenas se o usuário pedir):

1. Uma linha com o que foi comparado: base, branch, commits, arquivos e se pendências
   foram incluídas.
2. Veredito: **Aprovado**, **Aprovado com ressalvas** (só ⚠️ ou falhas Baixa) ou
   **Reprovado** (qualquer ❌ Alta ou Média).
3. Tabela por rotina com as regras NB-01..NB-18, status e evidência.
4. Detalhamento de cada ❌/⚠️: problema, evidência, impacto e correção sugerida.
5. Impactos funcionais para o usuário final (filtros, menu, personalização).

Não altere código no modo code review. Se o usuário pedir a correção depois, siga o
modo implementação a partir do passo 3, com a rotina já identificada.

---

## Checklist antes de responder

- [ ] A reference `references/mbrowse-smartx.md` foi lida inteira.
- [ ] Modo implementação: a rotina foi informada pelo usuário; sem ela, nada foi feito.
- [ ] Modo code review: sem indicação, a comparação foi branch atual × branch principal
      a partir do merge-base.
- [ ] O fonte inteiro foi lido, não apenas o diff.
- [ ] Nenhuma afirmação sobre API, índice ou cor sem evidência na reference, no MCP ou
      no dicionário.
- [ ] Nada foi compilado, commitado ou publicado.
