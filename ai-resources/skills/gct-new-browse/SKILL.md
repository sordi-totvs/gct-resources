---
name: gct-new-browse
description: >-
  Implementa ou revisa, de forma minuciosa, a adoção do novo browse do Protheus
  (visualização de dados Smart X) em rotinas legadas que abrem a tela com a
  função mBrowse (SetSmartX) ou com a classe FWMBrowse (oBrowse:SetSmartX),
  sempre protegida por hasSmartX. No modo implementação, exige que o usuário
  informe a rotina e não prossegue sem ela; identifica o tipo de browse, ativa o
  Smart X com índice e ordenação iniciais e ajusta legendas (cColorPoUi e
  de-para de cores), filtros (cFilterDefault no mBrowse, AddFilterSmartX no
  FWMBrowse, DbSetFilter), MenuDef (pageAction, Imprimir com operação 8,
  Pesquisa e Legenda), usos do objeto após a ativação (isSmartX) e métodos sem
  suporte no Smart X. No modo code review, compara por padrão a branch atual com
  a branch principal do git e emite um relatório por regra com severidade,
  evidência (arquivo e linha) e correção sugerida. Nunca compila, nunca commita e
  nunca abre pull request. Use quando o usuário disser: novo browse, browse
  Smart X, browse SmartX no mBrowse, browse SmartX no FWMBrowse, implementar o
  novo browse, converter mBrowse para Smart X, converter FWMBrowse para Smart X,
  setSmartX, hasSmartX, AddFilterSmartX, ativar Smart X na rotina, revisar o
  novo browse, code review do novo browse, revisar setSmartX, gct-new-browse.
license: MIT
metadata:
  domain: Protheus
  maintainer: Engenharia Protheus - Gestão de Contratos / Gestão de Receitas
  author: guilherme.sordi@totvs.com.br
  version: 1.1.0
  category: Development / Code Review
---

# GCT New Browse — Novo browse Smart X em rotinas legadas

Aplica ou revisa a ativação da visualização de dados Smart X em rotinas legadas que
abrem a tela com a função `mBrowse` ou com a classe `FWMBrowse`. Cada tipo tem sua
própria reference, transcrita da documentação do TDN:

| Tipo de browse | Ativação | Reference |
|---|---|---|
| Função `mBrowse` | Função `SetSmartX(nIndex, lOrderAsc)` na mesma função do `mBrowse`, antes da chamada | [references/mbrowse-smartx.md](references/mbrowse-smartx.md) |
| Classe `FWMBrowse` | Método `oBrowse:setSmartX(nIndex, lOrderAsc)` antes do `oBrowse:Activate()` | [references/fwmbrowse-smartx.md](references/fwmbrowse-smartx.md) |

Antes de qualquer ação, **leia inteira a reference do tipo de browse em questão** (ou as
duas, se a rotina ou o diff tiver os dois tipos). Elas são a regra de negócio desta
skill. A seção "Diferenças em relação à página do mBrowse", no fim da reference do
`FWMBrowse`, resume o que é igual e o que muda entre os dois tipos. Não presuma
comportamento que não esteja nas references; quando elas não bastarem, consulte o MCP
`advpl-tlpp-mcp-docs` (`smartx-docs-search`, `language-system-docs-search`,
`code-search`) antes de afirmar como uma função ou método se comporta. Se o MCP trouxer
versão diferente da reference, prevalece a reference, que foi transcrita da página
atual; registre a divergência ao usuário.

## Escopo

| | |
|---|---|
| **Cobre** | Rotinas que abrem a tela com a função `mBrowse` ou com a classe `FWMBrowse`. |
| **Não cobre** | `MarkBrowse`, `FWMarkBrowse`, `AxCadastro`, `FWFormBrowse` ou migração para Smart X nativo (`totvs.framework.structure`). Se a rotina usar um desses, informe que as references cobrem apenas `mBrowse` e `FWMBrowse` e pergunte ao usuário como seguir — para migração nativa existe a skill `browse-to-smartx-migration`. |
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

### Passo 2 — Localizar o fonte e identificar o tipo de browse

1. Localize o fonte da rotina no repositório de módulo (ex.: `src/**/CNTA100.PRW`). Se
   houver mais de um candidato, liste e pergunte.
2. Leia o fonte **inteiro**. Não trabalhe só com trechos.
3. Localize as chamadas de `mBrowse(` e as instâncias de `FWMBrowse():New()`, com a
   função que contém cada uma. Para `FWMBrowse`, acompanhe a variável do objeto até o
   `Activate()`, inclusive quando a configuração passa por funções auxiliares.
4. Classifique cada ocorrência como **mBrowse** ou **FWMBrowse** e carregue a reference
   correspondente.
5. Se não houver nenhum dos dois, aplique a regra de escopo acima.
6. Se houver mais de um browse no fonte, liste-os e pergunte quais devem ser
   convertidos.

### Passo 3 — Levantamento antes de alterar

Para cada browse a converter, levante e registre:

**Comuns aos dois tipos**

| Item | O que verificar |
|---|---|
| Ordenação | Índice em uso no browse legado (`DbSetOrder` antes do `mBrowse`, ordem configurada no `FWMBrowse`), para definir `nIndex`. Confirme no SIX (skill `data-dictionary-lookup`) que o índice existe — índice inexistente gera exceção. `0` ordena pelo `RECNO`. |
| Legendas | Cor de cada legenda (array do `mBrowse` ou chamadas de `AddLegend`) contra o de-para `caption-tag-NN` e `color-01`..`color-12`; presença de ícones/imagens. |
| Filtros | Uso de `DbSetFilter` no alias (ignorado no Smart X) e filtros AdvPL. |
| Objeto após a ativação | Métodos executados sobre o objeto do browse depois do `Activate()` / da abertura do `mBrowse`. |
| MenuDef | Condicionais, operação do Imprimir, ações que precisam de `pageAction`, opções de Pesquisa e de Legenda (ambas ignoradas no Smart X). |
| Personalização visual | Cor de fonte, estilo, cor de linha aplicados ao browse ou ao papel de trabalho. |

**Específicos do mBrowse**

| Item | O que verificar |
|---|---|
| Filtro | `cFilterDefault` existente e se é SQL; filtro AdvPL passado ao `mBrowse`. |
| Objeto do browse | Usos de `GetMBrowse()`. |

**Específicos do FWMBrowse**

| Item | O que verificar |
|---|---|
| Métodos usados | Todo método chamado sobre o objeto, comparado com a tabela "Métodos da classe FWMBrowse" da reference. Destaque os ausentes da lista e os "Em desenvolvimento" (`SetFieldFilter`, `SetUseFilter`). |
| Filtro | Filtros configurados no objeto e se a regra precisa ser levada para `AddFilterSmartX` com SQL iniciado por `@`. |

Apresente o levantamento ao usuário com as decisões que dependem dele (índice inicial e
ordem, cores PO-UI, quais ações viram `pageAction`, como tratar filtros e métodos sem
suporte) e só altere o código depois da resposta.

### Passo 4 — Aplicar a implementação

**Ativação** — proteja com `hasSmartX()` e informe `nIndex` e `lOrderAsc`, no padrão
do exemplo da reference do tipo:

- `mBrowse`: `SetSmartX(nIndex, lOrderAsc)` dentro da **mesma função** que chama o
  `mBrowse`, antes da chamada. Em outra função ou outro fonte, há exceção.
- `FWMBrowse`: `oBrowse:setSmartX(nIndex, lOrderAsc)` no mesmo objeto, antes do
  `oBrowse:Activate()`.

Declare as variáveis locais conforme o estilo do fonte.

**Legendas** — para cor fora do de-para e fora de `color-01`..`color-12`, informe
`cColorPoUi` com uma cor `caption-tag-NN`: 6ª posição do item do array no `mBrowse`, 6º
parâmetro do `AddLegend` no `FWMBrowse`. Sem isso, há exceção. Ícones não são aceitos.

**Filtros** — o browse convertido ignora `DbSetFilter`. Quando a regra for necessária
ao negócio no Smart X, converta-a para SQL:

- `mBrowse`: parâmetro `cFilterDefault` (expressões AdvPL não são consideradas).
- `FWMBrowse`: `oBrowse:AddFilterSmartX(cExp)`, com a expressão SQL iniciada por `@`.

Mantenha os filtros legados para o browse sem Smart X.

**Objeto após a ativação** — envolva com `if !oBrw:isSmartX()` os métodos executados
sobre o objeto depois da ativação (no `mBrowse`, o objeto vem de `GetMBrowse()`; no
`FWMBrowse`, é o próprio `oBrowse`).

**Métodos sem suporte (FWMBrowse)** — não remova métodos ausentes da lista de
suportados; informe o impacto ao usuário. Se a remoção ou a condição for pedida, aplique
sem alterar o comportamento do browse legado.

**MenuDef** — sem condicionais. Imprimir com operação `8` (`OP_IMPRIMIR` se o fonte
usar `fwmvcdef.ch`). Ações extras como `pageAction` via 10ª posição do array ou
`PAGEACTION` no comando `ADD OPTION` (este último depende dos `.ch` atualizados). Não
remova Pesquisa nem Legenda do legado sem pedido do usuário; apenas informe que deixam
de aparecer no Smart X.

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

1. Rotina, funções alteradas e tipo de cada browse convertido.
2. Decisões tomadas (índice, ordem, cores, filtros, `pageAction`).
3. Impactos que o usuário precisa conhecer (filtros não considerados, métodos sem
   suporte, personalização visual perdida, Pesquisa e Legenda fora do menu,
   pré-requisito de release 12.1.2610 / RPO D-1).
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
2. Para cada fonte que toque `mBrowse`, `FWMBrowse`, `hasSmartX`, `SetSmartX`,
   `AddFilterSmartX`, `isSmartX`, legendas, `MenuDef` ou `GetMBrowse`, leia também o
   **fonte inteiro** na versão da branch: várias regras dependem de código fora do diff
   (mesma função do `mBrowse`, configuração do objeto `FWMBrowse` até o `Activate()`,
   `DbSetFilter` anterior, `MenuDef`).
3. Classifique cada browse convertido como mBrowse ou FWMBrowse e aplique as regras
   comuns e as do seu tipo.
4. Fontes do diff com browse sem Smart X ativado não são falha por si só — registre
   apenas se o objetivo declarado da mudança incluía essa rotina.

### Passo 3 — Checklist

Avalie cada regra por browse convertido. Status: ✅ conforme, ❌ não conforme, ⚠️
atenção/decisão do usuário, N/A não se aplica.

**Regras comuns (NB)**

| ID | Regra | Severidade se falhar |
|---|---|---|
| NB-01 | Ativação protegida por `hasSmartX()`. | Alta |
| NB-02 | `nIndex` corresponde a um índice existente da tabela (SIX) ou é `0` (RECNO), e é coerente com a ordenação legada. | Alta (exceção) |
| NB-03 | `lOrderAsc` é lógico e coerente com a ordenação esperada; variáveis declaradas e usadas com o mesmo nome. | Média |
| NB-04 | Toda cor de legenda está no de-para `caption-tag-NN`, em `color-01`..`color-12`, ou tem `cColorPoUi` válido (`caption-tag-01`..`35`) na 6ª posição/parâmetro. | Alta (exceção) |
| NB-05 | Nenhuma legenda usa ícone/imagem. | Alta |
| NB-06 | Estrutura da legenda respeita a ordem `xCondition`, `cColor`, `cTitle`, `cID`, `lFilter`, `cColorPoUi`. | Média |
| NB-07 | `DbSetFilter` no alias: a regra não é perdida silenciosamente no Smart X (convertida para o filtro SQL do tipo ou impacto aceito pelo usuário). | Alta |
| NB-08 | Métodos executados sobre o objeto do browse após a ativação estão protegidos por `isSmartX()`. | Alta |
| NB-09 | `MenuDef` sem condicionais (inclusive as introduzidas para o Smart X). | Alta |
| NB-10 | Imprimir padrão usa operação `8` / `OP_IMPRIMIR` (este exige `fwmvcdef.ch`). | Média |
| NB-11 | `pageAction` adicional usa a 10ª posição do array ou `PAGEACTION` no comando; uso do comando sinalizado como dependente dos `.ch` atualizados. | Baixa |
| NB-12 | Impactos identificados: Pesquisa e Legenda fora do menu Smart X (remoção no legado só se pedida) e personalização visual que deixa de valer. | Baixa |
| NB-13 | Comportamento sem Smart X (`hasSmartX()` falso) permanece idêntico ao legado. | Alta |
| NB-14 | Alteração mínima: sem refatoração ou reformatação fora do escopo; encoding Windows-1252 preservado. | Média |
| NB-15 | Includes necessários presentes para as funções/defines usados. Confirme no MCP antes de apontar include faltante. | Média |

**Regras do mBrowse (MB)**

| ID | Regra | Severidade se falhar |
|---|---|---|
| MB-01 | `SetSmartX` está no **mesmo fonte e mesma função** que chama o `mBrowse`, antes da chamada. | Alta (exceção) |
| MB-02 | `cFilterDefault`, quando usado, é expressão SQL; filtros AdvPL não são considerados no Smart X. | Alta |
| MB-03 | O objeto usado nas verificações de `isSmartX()` é obtido com `GetMBrowse()`. | Média |

**Regras do FWMBrowse (FB)**

| ID | Regra | Severidade se falhar |
|---|---|---|
| FB-01 | `setSmartX(nIndex, lOrderAsc)` é chamado no mesmo objeto `FWMBrowse` e antes do `Activate()`. | Alta |
| FB-02 | Filtros necessários ao negócio no Smart X estão em `AddFilterSmartX`, com expressão SQL iniciada por `@`. | Alta |
| FB-03 | Métodos chamados sobre o objeto fora da lista de suportados, ou "Em desenvolvimento" (`SetFieldFilter`, `SetUseFilter`), estão identificados com o impacto. | Média |

Regras de evidência:

- Todo ❌ e ⚠️ cita **arquivo e linha** e traz a **correção sugerida** em código.
- Não aponte falha sem ter lido o trecho. Não invente função, método, parâmetro, índice
  ou cor.
- Para validar índice, use `data-dictionary-lookup`; para comportamento de API, o MCP.

### Passo 4 — Relatório

Entregue no chat (grave em arquivo apenas se o usuário pedir):

1. Uma linha com o que foi comparado: base, branch, commits, arquivos e se pendências
   foram incluídas.
2. Veredito: **Aprovado**, **Aprovado com ressalvas** (só ⚠️ ou falhas Baixa) ou
   **Reprovado** (qualquer ❌ Alta ou Média).
3. Tabela por rotina e por browse (com o tipo), com as regras aplicáveis, status e
   evidência.
4. Detalhamento de cada ❌/⚠️: problema, evidência, impacto e correção sugerida.
5. Impactos funcionais para o usuário final (filtros, menu, métodos sem suporte,
   personalização).

Não altere código no modo code review. Se o usuário pedir a correção depois, siga o
modo implementação a partir do passo 3, com a rotina já identificada.

---

## Checklist antes de responder

- [ ] A reference de cada tipo de browse envolvido foi lida inteira.
- [ ] Modo implementação: a rotina foi informada pelo usuário; sem ela, nada foi feito.
- [ ] Modo code review: sem indicação, a comparação foi branch atual × branch principal
      a partir do merge-base.
- [ ] O fonte inteiro foi lido, não apenas o diff.
- [ ] Regras específicas de um tipo de browse não foram aplicadas ao outro.
- [ ] Nenhuma afirmação sobre API, índice ou cor sem evidência na reference, no MCP ou
      no dicionário.
- [ ] Nada foi compilado, commitado ou publicado.
