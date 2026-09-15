---
name: advpl-tlpp-performance-analysis
description: >-
  Análise de performance de relatórios Protheus que migraram de fonte legado
  (AdvPL/TLPP, FINR*/CTBR*/MATR*) para Smart View / TReports (objeto de negócio
  sobre integrated provider), comparando os dois caminhos para provar o gargalo
  e propor a correção mínima. Estende a skill advpl-tlpp-sdd (bug track) com uma
  fase de Análise Comparativa Legado x Smart View, alimentada por dois
  LogProfiler (legado e Smart View) e pelo plano de execução da query principal
  do objeto de negócio. Recebe código da issue, nome do fonte legado e nome do
  fonte de menu do Smart View (de onde extrai o objeto de negócio na chamada
  callSmartView / callTReports). Use quando: relatório Smart View lento,
  extração demorada, "Servidor não respondendo" no TReports, regressão de
  performance após migrar para Smart View, analisar LogProfiler, comparar legado
  com Smart View, analisar plano de execução, encontrar hotspot, gargalo, N+1 em
  objeto de negócio, performance de integrated provider, otimizar relatório.
license: MIT
metadata:
  domain: Protheus
  maintainer: Engenharia Protheus - SIGAFIN
  author: Fabio H. Andrade
  version: 1.1.0
  category: Performance Analysis
---

# Análise de Performance — Legado x Smart View

Prova **onde** um relatório Smart View perdeu performance em relação ao fonte
legado que ele substituiu, e propõe a **correção mínima de resultado idêntico**.

O diferencial desta skill não é "otimizar código": é usar o **legado como base de
negócio** — ele produz o mesmo resultado, logo tudo o que o Smart View faz e o
legado não faz é candidato a custo desnecessário. Essa comparação, ancorada em
dois LogProfiler e no plano de execução, transforma palpite em evidência.

## Vocabulário — use estes termos com precisão

Três camadas distintas, e confundi-las atrapalha a análise:

| Termo | O que é | Exemplo |
|---|---|---|
| **Fonte de menu** | casca que chama o Smart View passando o nome do objeto de negócio | `FINSV005.prw` |
| **Objeto de negócio** | a classe do relatório: query própria, schema e enriquecimento por linha | `backoffice.sv.fin.billsreceivable.tlpp` → `BillsReceivableSmartViewBusinessObject` |
| **Provider** | a **superclasse do módulo** que todos os objetos de negócio implementam; concentra o laço de extração | `backoffice.sv.fin.integratedprovider.tlpp` → `FinIntegratedProvider` |
| **IntegratedProvider** | classe base disponibilizada pelo **Framework**, da qual o provider do módulo herda | `totvs.framework.treports.integratedprovider.IntegratedProvider` |

Cadeia real de herança no financeiro:

```
totvs.framework.treports.integratedprovider.IntegratedProvider   (Framework)
   └── FinIntegratedProvider                     (provider do módulo — Genericos/)
         └── BillsReceivableSmartViewBusinessObject  (objeto de negócio — Objeto_Negocios/)
```

O que o usuário informa é o **fonte de menu**; dele se extrai o **objeto de
negócio**; do objeto de negócio se chega ao **provider** pela cláusula `from`.
Alguns módulos não têm provider próprio e o objeto de negócio herda direto do
`IntegratedProvider` do Framework — nesse caso a cadeia tem dois níveis.

**O laço de extração quase sempre está no provider, não no objeto de negócio.**
É por isso que ler apenas o objeto de negócio não explica o custo por linha.

## Base: advpl-tlpp-sdd

Esta skill **não substitui** o bug track do `advpl-tlpp-sdd` — ela se encaixa
nele, inserindo uma fase entre o Specify e o Design:

```
Specify          Análise Comparativa      Design            Tasks        Execute
bug-spec.md  →   perf-analysis.md     →   rca.md        →   tasks.md  →  código
(SDD)            (ESTA SKILL)             (skill RCA)       (SDD)        (SDD)
```

Delegue cada fase a quem é dona dela:

| Fase | Dono | Artefato |
|---|---|---|
| Specify | `advpl-tlpp-sdd` → `references/bug-spec.md` | `bug-spec.md` |
| **Análise Comparativa** | **esta skill** | **`perf-analysis.md`** |
| Design / causa raiz | `advpl-tlpp-root-cause-analysis` | `rca.md` |
| Tasks | `advpl-tlpp-sdd` → `references/tasks.md` | `tasks.md` |
| Execute | `advpl-tlpp-sdd` → `references/implement.md` | fontes + testes |
| Encoding / compilação | `utf8-to-cp1252-conversion` + `advpl-tlpp-compile` | — |

A `perf-analysis.md` **alimenta** o RCA: ela entrega o hotspot quantificado e o
delta legado x Smart View; o RCA formaliza a causa e a correção. Não duplique
conteúdo — o RCA referencia a análise.

**As regras técnicas obrigatórias estão em `references/tlpp-master-rules.md`.
Leia esse arquivo antes de propor qualquer alteração de código** — ele contém as
regras de análise de performance (curto-circuito antes de otimização técnica,
nunca confundir ponto de chamada com ponto de custo, nunca duplicar lógica de
framework no chamador) e o padrão de entrega. Se conflitar com o `AGENTS.md` do
workspace, o `AGENTS.md` prevalece.

## Entradas obrigatórias

Peça as três, nesta forma, e não siga sem elas:

| # | Entrada | Exemplo | Para que serve |
|---|---|---|---|
| 1 | **Código da issue** | `DSFIN-20529` | nomeia a pasta, busca o contexto via MCP `get-jira-issue` |
| 2 | **Nome do fonte legado** | `FINR130` | base de negócio da comparação |
| 3 | **Nome do fonte de menu do Smart View** | `FINSV005` | de onde se extrai o objeto de negócio |

O objeto de negócio **não** é informado pelo usuário: ele é extraído do fonte de
menu. Abra o fonte de menu e leia a string da chamada:

```advpl
// caminho TReports (lib antiga)
lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.billsreceivable", ...)

// caminho Smart View (lib >= 20240226)
oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.billsreceivable")
```

A string é o **nome do objeto de negócio**, e o fonte dele é essa string +
`.tlpp`. Se o fonte de menu tiver os dois caminhos, registre qual está ativo no
ambiente medido — `FwLibVersion()` decide, e o caminho ativo muda qual código de
framework entra no profiler.

## Pré-requisitos (gate — sem eles a análise não começa)

| # | Artefato | Sem ele |
|---|---|---|
| 1 | **LogProfiler do relatório legado** | não há base de comparação; a análise vira palpite |
| 2 | **LogProfiler do Smart View** (objeto de negócio) | não há hotspot quantificado; a priorização vira palpite |
| 3 | **Plano de execução da query principal do objeto de negócio** | não se sabe se o gargalo é a query ou o enriquecimento linha a linha |

Se algum faltar, **pare e peça**, explicando como capturar
(`references/prerequisites.md` tem o passo a passo do `LogProfiler=1` e da
extração do plano por SGBD). Não invente números e não "estime" hotspot por
leitura de código — a skill inteira existe para evitar exatamente isso.

Exceção única: se o usuário declarar explicitamente que um artefato não existe e
pedir para seguir, registre a lacuna em **Limitações** na `perf-analysis.md` e
rebaixe as conclusões afetadas de ✅ Confirmado para ⚠ Inferência.

Idealmente os dois LogProfiler cobrem **o mesmo range/volume**. Quando não
cobrem, compare **percentual relativo**, nunca segundos absolutos.

## Estrutura de artefatos

```
.specs/fixes/<ISSUE>/
├── bug-spec.md              # Specify (SDD)
├── perf-analysis.md         # ESTA SKILL
├── rca.md                   # Design (skill RCA)
├── tasks.md                 # Tasks (SDD)
├── profiles/
│   ├── legado_<...>.log     # LogProfiler do fonte legado
│   ├── smartview_<...>.log  # LogProfiler do objeto de negócio
│   └── posfix_<...>.log     # (Execute) reexecução após a correção
└── plans/
    └── mainquery-execplan.<sqlplan|txt|json>
```

Fontes para **edição** são copiados para `fontes/` na workspace do dev — nunca
edite no projeto de origem. A **leitura** é feita direto no workspace.

## Pipeline

```
- [ ] 0. Intake: 3 entradas + 3 pré-requisitos + issue via MCP
- [ ] 1. Localizar os fontes: menu -> objeto de negócio -> provider
- [ ] 2. Mapear os dois caminhos (legado x Smart View) no código
- [ ] 3. Quantificar: parsear os dois LogProfiler -> tabela de hotspots
- [ ] 4. Analisar o plano de execução da query principal
- [ ] 5. Delta legado x Smart View: o que o Smart View faz que o legado não faz
- [ ] 6. Priorizar hotspots e escrever perf-analysis.md
- [ ] 7. Handoff: RCA (Design) -> tasks -> Execute -> reprofile
```

### 0. Intake

Busque a issue (`get-jira-issue`) e as correlatas citadas. Confirme as 3
entradas, localize os 3 artefatos, mova-os para `profiles/` e `plans/`.
Registre o volume medido em cada profiler (nº de registros/títulos) — sem
volume, `ms/registro` não existe e a extrapolação para produção é impossível.

### 1. Localizar os fontes no workspace

**Os fontes estão no workspace. Localize por busca de arquivo — não use o MCP
`get-code-chunks` para isso.** O MCP é fallback (fonte ausente no workspace ou
dúvida sobre outra versão), não a primeira opção: o fonte local é o que vai ser
compilado e pode divergir do indexado.

Layout do financeiro (`Fontes\Adm\SmartView\FIN\`), que serve de modelo:

| Pasta | Conteúdo |
|---|---|
| `Menu\` | fontes de menu — `FINSV001.prw` … `FINSV0NN.prw` |
| `Objeto_Negocios\` | objetos de negócio — `backoffice.sv.fin.*.tlpp` (59 no FIN) |
| `Genericos\` | **provider** `backoffice.sv.fin.integratedprovider.tlpp` + utilitários (`utils`, `classutil`, `localization.bra`) |

Outros módulos repetem o padrão com nomes de pasta variando (`SmartView`,
`Smart View`, `Smartview`, `smart_view`; `Genericos`, `utils`). Estratégia
robusta, na ordem:

1. objeto de negócio: buscar pelo nome exato extraído do menu, `+ .tlpp`;
2. provider: ler a cláusula `from` do objeto de negócio e buscar
   `*integratedprovider*.tlpp` no módulo — o nome do arquivo raramente coincide
   com o nome da classe (`FinIntegratedProvider` vive em
   `backoffice.sv.fin.integratedprovider.tlpp`);
3. subir a cadeia até chegar ao `IntegratedProvider` do Framework, que é onde a
   leitura para — essa camada é do Framework e está fora do escopo.

Atenção a **variantes de localização**: pode existir um objeto de negócio
homônimo em pasta de localização (ex.: `Adm\Localizacoes\Smartview\Objeto_negocios\`)
que sobrescreve ou complementa o padrão. Confirme qual está efetivamente no RPO
do ambiente medido antes de analisar o fonte errado. As definições de relatório
(`treports\<modulo>\Visao_Dados`, `Tabelas_Dinamicas`) não são código de
extração — não gaste tempo nelas.

O `.ch` de includes do objeto de negócio pode não estar na mesma pasta; só o
busque se precisar resolver um `#define`.

Ao ler, identifique os **hooks de extração** implementados em cada nível —
são os pontos onde o custo por linha nasce. Ver `references/legacy-vs-smartview.md`
para o mapa de hooks do provider e do objeto de negócio.

### 2. Mapear os dois caminhos

Leia o legado até o `Return`, e o objeto de negócio + o provider até o
`endclass`. Não pare no primeiro `while` que pareça caro. O que você precisa
saber, dos dois lados:

- **Como os dados são lidos**: uma query set-based? workarea + seek? tabela temporária?
- **O que é feito por linha**: quais funções de negócio são chamadas dentro do laço.
- **Quais condições controlam os blocos caros**: parâmetro (`MV_PAR*`), flag,
  saldo zero, data. Um bloco caro que não precisa executar é a melhor otimização.
- **Que caches o legado monta e o Smart View não**: o legado costuma pré-carregar
  estruturas compartilhadas uma vez por execução (objetos estáticos `__o*`); o
  objeto de negócio, instanciado por requisição, frequentemente perde esse ganho.

### 3. Quantificar os LogProfiler

Use o script — os logs têm centenas de milhares de linhas e não cabem no contexto:

```powershell
# hotspots do Smart View, ancorados na raiz da extração
& "<skill>/scripts/Parse-FwLogProfiler.ps1" `
    -Path .specs/fixes/<ISSUE>/profiles/smartview_x.log `
    -Root MYPROCESSDATA -Subtree -Top 25

# onde uma função específica gasta o tempo dela (callees) e quem a chama (callers)
& "<skill>/scripts/Parse-FwLogProfiler.ps1" -Path ...smartview_x.log -Function SALDOTIT

# legado x Smart View lado a lado, com percentual normalizado por raiz
& "<skill>/scripts/Parse-FwLogProfiler.ps1" `
    -Path ...profiles/legado_x.log   -Root REPORTPRINT `
    -Compare ...profiles/smartview_x.log -CompareRoot GETDATA -Subtree
```

Leia `references/profiler-analysis.md` antes de interpretar a saída — a
semântica de `C`/`T`/`M` e das linhas `-- FROM` é contraintuitiva e erra-se
fácil (o erro mais comum é tratar `T` como tempo exclusivo).

Entregue uma tabela por profiler: função, chamadas, T, % da raiz, ms/chamada,
callee dominante. E confirme a distribuição em **dois volumes diferentes** quando
houver — distribuição estável em volumes distintos é o que torna a conclusão robusta.

### 4. Plano de execução

Confirme se a query principal é ou não o gargalo. Se o profiler mostra a query
principal com T pequeno e o enriquecimento por linha dominando, o plano serve
para **descartar** a query — e isso é um achado, não um desperdício.
Ver `references/execution-plan-analysis.md`.

### 5. Delta legado x Smart View

O núcleo da skill. Para cada hotspot do Smart View, responda:

1. O legado chama a mesma função? Com que frequência?
2. Se chama e é rápido no legado, **o que é diferente**? (cache compartilhado,
   parâmetro que desliga o bloco, motor de cálculo diferente, ordem de leitura)
3. Se não chama, o Smart View precisa mesmo chamar para produzir o mesmo resultado?
4. Existe condição barata que decidiria **não** executar o bloco caro?

Um resultado comum e desconfortável: **o legado paga o mesmo custo**. Registre
isso — significa que não há solução para copiar, e a correção tem de vir de
reduzir o **número de execuções**, não de trocar a implementação. Foi exatamente
o desfecho da DSFIN-20529.

Decida também **em que nível a correção cabe**: no objeto de negócio (afeta um
relatório) ou no provider do módulo (afeta todos os objetos de negócio que
herdam dele). Mexer no provider tem alcance muito maior e exige justificar o
risco — trate como decisão de escopo, não como detalhe de implementação.

### 6. Priorizar e escrever

Ordene por `% do tempo medido`, não por elegância da correção. Descarte hotspots
< 5% do tempo, exceto quando a mesma correção os resolve de brinde. Um achado
"estrutural" bonito que vale 1% do tempo **não é a correção** — diga isso
explicitamente para não desperdiçar a implementação.

Escreva `perf-analysis.md` a partir de `references/perf-analysis-template.md`.

### 7. Handoff

Apresente a análise e **confirme com o engenheiro antes de gerar código**.
Depois: RCA (Design) → `tasks.md` → Execute com encoding CP-1252 + compilação →
**reprofile** para provar que o hotspot deixou de dominar.

## Gotchas

Erros que esta análise comete sem aviso:

- **Ler só o objeto de negócio e concluir.** O laço de extração está no provider
  do módulo. Sem ele você vê as funções chamadas por linha, mas não vê que são
  chamadas uma vez por registro.
- **Buscar fonte no MCP quando ele está no workspace.** Analise o fonte local —
  é o que será compilado. MCP é fallback.
- **`T` é tempo inclusivo.** Uma função orquestradora com T alto não é o
  problema — o custo está nos callees dela. Somar T de níveis diferentes passa
  de 100%.
- **`T.Timer` do cabeçalho não é o total da rotina.** Inclui o tempo ocioso com
  o usuário parado no wizard. Ancore os percentuais na raiz da extração
  (`REPORTPRINT`, `GETDATA`, `MYALIASTODATA`), nunca em `T.Timer`.
- **Ignore os wrappers reentrantes**: `EVAL`, `#CODEBLOCK#`, `MSDIALOG:ACTIVATE`,
  `TREPORT:PRINT`, `FWDIALOGMODAL:ACTIVATE`. Aparecem com Pct > 100% porque são
  ancestrais/reentrantes, não hotspots.
- **`ms/chamada` baixo com contagem alta é o padrão N+1**, e é o achado mais
  provável aqui. `DBSKIP` com 141 mil chamadas a 0,96 ms = 135 s.
- **Comparar segundos absolutos entre profilers de volumes diferentes é errado.**
  Compare percentual relativo à raiz de cada log.
- **A correção não pode mudar o resultado.** Relatório otimizado que muda um
  centavo é regressão, não otimização. A prova de igualdade de dataset é critério
  de aceite obrigatório, não opcional.
- **Não altere função de núcleo do módulo** (`SaldoTit`, `SomaAbat`, `FValAcess`
  em `finxfin.prx` e afins) para resolver performance de um relatório. Mude
  **quando** o objeto de negócio a chama; a função fica intacta. Isso mantém a
  correção em escopo e evita risco em todos os outros chamadores.
- **Alterar o provider do módulo afeta dezenas de relatórios.** No FIN são 59
  objetos de negócio herdando do mesmo provider. Prefira corrigir no objeto de
  negócio; só suba para o provider se o defeito for realmente do laço comum.
- **Não duplique lógica de framework no objeto de negócio.** Pré-carga em lote é
  legítima quando reproduz um critério **provado no código** (ex.: "sem movimento
  até a data ⇒ saldo = valor original"); recriar a regra de negócio inteira em
  paralelo não é.
- **Objeto de negócio é instanciado por requisição.** Cache em membro de
  instância vale para uma extração; não assuma persistência entre requisições.
- **Fontes `.tlpp`/`.prw` são CP-1252 + CRLF.** Todo arquivo que o agente grava
  sai em UTF-8 — converter antes de compilar é obrigatório.

## Arquivos de referência

Carregue sob demanda, não todos de uma vez:

- **`references/tlpp-master-rules.md`** — regras técnicas obrigatórias
  (AdvPL/TLPP, MCP como fonte de verdade, regras de análise de performance,
  checklist de revisão, formato de entrega). **Leia antes de propor código.**
- **`references/prerequisites.md`** — como capturar os 3 pré-requisitos:
  `LogProfiler=1`, plano de execução por SGBD, medição de volume. Leia quando
  algum artefato faltar ou o usuário perguntar como gerar.
- **`references/profiler-analysis.md`** — formato do log, semântica de C/T/M e
  `-- FROM`, uso do script, como montar a tabela de hotspots. Leia antes de
  interpretar qualquer profiler.
- **`references/execution-plan-analysis.md`** — como capturar e ler o plano por
  SGBD e o que caracteriza gargalo de query em base Protheus.
- **`references/legacy-vs-smartview.md`** — cadeia de herança e hooks de
  extração (provider x objeto de negócio), e o catálogo de divergências legado x
  Smart View que explicam regressão. Leia nas fases 1, 2 e 5.
- **`references/perf-analysis-template.md`** — template da `perf-analysis.md`.
  Leia na fase 6.

## Script

- **`scripts/Parse-FwLogProfiler.ps1`** — agrega o LogProfiler em rankings,
  callers/callees por função, suspeitos de N+1 e comparação entre dois logs.
  Use sempre; nunca leia o `.log` inteiro para o contexto.
