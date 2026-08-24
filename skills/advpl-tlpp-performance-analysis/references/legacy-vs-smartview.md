# Legado x Smart View — cadeia de herança, hooks e divergências

Use na fase 1 (localizar os fontes), 2 (mapear os dois caminhos) e 5 (delta).

## Do menu ao objeto de negócio

O fonte de menu é uma casca fina. Ele resolve a versão da lib e chama um dos dois
caminhos, passando **o nome do objeto de negócio**:

```advpl
local lLibVersion := FwLibVersion() < "20240226" As Logical

If lLibVersion
    lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.billsreceivable", ...)
Else
    oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.billsreceivable")
    oSmartView:setParameters(jParams)
    lSuccess := oSmartView:executeSmartView()
    oSmartView:Destroy()
EndIf
```

O menu também revela: forçamento de parâmetros (`setParameters`/`setForceParams`),
tratamento de compartilhamento (`FWModeAccess`), e qual `pergunte` é reaproveitado
do legado (frequentemente o **mesmo grupo de perguntas** do relatório antigo —
`FINSV005` usa o grupo `FINR130`). Esse reaproveitamento é uma pista forte: os
parâmetros que ligam blocos caros são os mesmos nos dois caminhos.

## A cadeia de herança

```
totvs.framework.treports.integratedprovider.IntegratedProvider     <- Framework
   └── FinIntegratedProvider                                        <- provider do módulo
         │     backoffice.sv.fin.integratedprovider.tlpp  (Genericos/)
         │     namespace totvs.protheus.backoffice.fin.smartView.integratedProvider
         │
         └── BillsReceivableSmartViewBusinessObject                 <- objeto de negócio
               backoffice.sv.fin.billsreceivable.tlpp  (Objeto_Negocios/)
```

**Divisão de responsabilidade:**

| Camada | O que implementa | Onde mora o custo |
|---|---|---|
| Framework `IntegratedProvider` | contrato do provider integrado, transporte, schema | fora de escopo |
| Provider do módulo | parâmetros/pergunte, filtros, **o laço de extração**, paginação, montagem do `jData` | custo **estrutural**: quantas vezes o hook por linha é chamado |
| Objeto de negócio | query própria (`loadStatement`), schema, **enriquecimento por registro** | custo **por linha**: as funções de negócio chamadas |

Alguns módulos não têm provider próprio e o objeto de negócio herda direto do
`IntegratedProvider` do Framework (cadeia de dois níveis). Confirme lendo a
cláusula `from` — não presuma.

## Hooks do provider (exemplo real: `FinIntegratedProvider`)

Verificado em `backoffice.sv.fin.integratedprovider.tlpp`. Serve de mapa; confirme
os nomes no fonte do módulo em análise.

| Grupo | Hooks | Para a análise |
|---|---|---|
| Parâmetros | `setPergunte`, `setMVPAR`, `setFilter`, `loadParameters`, `loadDefaultParameters` | onde os `MV_PAR*` viram membros — é aqui que se descobre o que liga bloco caro |
| Query | `loadStatement` (atual), `getQuery` (deprecado) | a query principal; alvo do plano de execução |
| Schema | `mySetSchema`, `setLookups`, `handleSchema`, `finAddProperty` | raramente é gargalo; confirme no profiler antes de investigar |
| Ciclo de extração | `preOpenQuery`, `preWhileMyAliasToData`, **`myAliasToData`**, `postWhileMyAliasToData`, `postCloseQuery` | **o laço**; `preWhileMyAliasToData` é o ponto natural de pré-carga em lote |
| Por registro | `processAndAppend`, **`myProcessData`**, `addToData`, `completeData`, `posPositionAlias` | executados 1× por registro; multiplicam qualquer custo |

O laço, no provider (não no objeto de negócio):

```advpl
method myAliasToData() class FinIntegratedProvider
    ...
    self:preWhileMyAliasToData()
    while !(self:cAlias)->(Eof()) .and. ( nRecordCount < self:getPageSize() )
        if self:lAppendInMyAliasToData
            self:jData := JSONObject():new()
            self:processAndAppend()
        else
            self:myProcessData()        // <- implementado no objeto de negócio
        endIf
        (self:cAlias)->(DbSkip())
        nRecordCount++
    endDo
    self:setHasNext(!(self:cAlias)->(Eof()))
    self:postWhileMyAliasToData()
return
```

Três consequências que a análise precisa registrar:

1. A extração é **set-based apenas na query principal**; tudo depois é
   **row-by-row**. Se `myProcessData` chama função de negócio pesada, o custo é
   `O(N × custo_por_registro)` — o que produz "roda em 1 min com 230 títulos e
   não termina com 130 mil".
2. Há **duas rotas por registro** (`processAndAppend` ou `myProcessData`),
   escolhidas por `lAppendInMyAliasToData`. Saiba qual está ativa antes de
   procurar o hotspot no lugar errado.
3. A extração é **paginada** (`nCurrentPage`, `getPageSize`, `setHasNext`), e o
   posicionamento de página usa `dbSkip(n)`. Em página alta isso significa
   percorrer os registros anteriores — vale conferir no profiler se `DBSKIP`
   aparece com contagem muito acima do nº de registros extraídos.

## Onde procurar, dos dois lados

| Pergunta | No legado | No Smart View |
|---|---|---|
| Como lê os dados? | `TCQuery`/workarea/`FWTemporaryTable` | `loadStatement` no objeto de negócio |
| O que faz por linha? | corpo do `While` do `ReportPrint` | `myProcessData`/`processAndAppend` |
| Quem controla o laço? | o próprio fonte | o **provider** (`myAliasToData`) |
| Onde monta cache? | objetos estáticos `__o*` criados no início e destruídos no fim | `new` / `preWhileMyAliasToData` (por requisição) |
| O que liga o bloco caro? | `mv_par*` lidos no início | membros preenchidos em `setMVPAR`/`loadParameters` |

## Catálogo de divergências que explicam regressão

Verifique uma a uma na fase 5:

1. **Cache compartilhado que o legado monta e o Smart View não.** Rotinas legadas
   frequentemente pré-carregam estruturas uma vez por execução (objetos estáticos)
   e as destroem no fim. O objeto de negócio, instanciado por requisição, perde
   esse ganho e paga por linha. **Divergência mais comum.**

2. **Motor de cálculo escolhido por call stack.** Funções de núcleo trocam de
   implementação conforme quem chamou — via `FwIsInCallStack("FINR130")`,
   parâmetros de forçamento, ou parâmetros de versão financeira. O Smart View cai
   num caminho diferente do legado **para o mesmo cálculo**. Sempre inspecione o
   `if` que escolhe o motor dentro da função de núcleo.

3. **Bloco caro que o legado não executa nesse cenário.** Um `mv_par` desligado,
   uma flag, um `if` de curto-circuito. Compare os *guards* dos dois lados: o
   objeto de negócio às vezes perdeu o `if` na migração.

4. **Consulta unitária dentro do laço (N+1).** Query por registro em vez de uma
   pré-carga agrupada em `preWhileMyAliasToData`. Assinatura no profiler:
   `MPSYSOPENQUERY`/`FWEXECSTATEMENT` com contagem ≈ nº de registros.

5. **Seek em vez de RECNO.** `MsSeek`/`DbSeek` por registro quando a query
   principal poderia trazer `R_E_C_N_O_` e o código usar `DbGoTo` (O(1), sem I/O).

6. **Ordenação/agregação movida para o AdvPL.** O que o legado fazia no `ORDER BY`
   ou num `GROUP BY` passou a ser feito em memória linha a linha.

7. **Custo de paginação.** `dbSkip(n)` para posicionar a página, refeito a cada
   requisição. Em extração completa de grande volume, o reposicionamento pode
   custar mais que a leitura.

8. **Volume maior por construção.** O Smart View extrai colunas ou linhas que o
   legado não extraía (granularidade mais fina para permitir análise na
   ferramenta). Nesse caso o custo extra é intencional — negocie escopo em vez de
   "otimizar".

9. **Custo do framework de transporte.** `getSchema`, serialização JSON, REST.
   Verifique se pesa no profiler antes de suspeitar: costuma ser irrelevante
   diante do enriquecimento por linha, e o time de Framework normalmente já
   descartou essa camada.

## Em que nível corrigir

Decisão de escopo, e ela precisa estar explícita na análise:

| Nível | Alcance | Quando |
|---|---|---|
| Objeto de negócio | um relatório | **default.** O hotspot é o enriquecimento específico daquele relatório |
| Provider do módulo | **todos** os objetos de negócio que herdam (59 no FIN) | só se o defeito é do laço/paginação comum, e com justificativa de risco |
| Função de núcleo (`finxfin.prx`) | todo o módulo, todos os chamadores | evite. Mude **quando** chamar, não a função |
| Framework `IntegratedProvider` | todos os módulos | fora de escopo; é do time de Framework |

## O desfecho incômodo, e correto

Frequentemente a conclusão é: **o legado paga o mesmo custo**. Ele parecia mais
rápido porque rodava em ranges menores, ou porque tinha um cache compartilhado que
mascarava o N+1. Registre isso com clareza — significa que:

- não há solução pronta no legado para copiar;
- a correção tem de **reduzir o número de execuções** do trecho caro, não trocar a
  implementação dele;
- alterar a função de núcleo está **fora do escopo** e traz risco para todos os
  outros chamadores.

O caminho que costuma resolver, e ficar em escopo: encontrar no código da função
de núcleo a condição sob a qual ela **retorna o valor trivial** (ex.: sem
movimento no período ⇒ saldo = valor original), pré-carregar em **uma** query
quais registros satisfazem essa condição (em `preWhileMyAliasToData`), e no laço
**pular a chamada** para eles, calculando o valor trivial direto. A função de
núcleo fica intacta, o resultado é idêntico, e o ganho é proporcional à fração de
registros pulados.

Antes de propor isso, prove no código da função de núcleo qual é o valor trivial e
**reproduza-o exatamente** — incluindo acréscimos, decréscimos, conversão de moeda
e abatimentos. Errar o valor trivial é regressão de resultado, o pior desfecho
possível para uma correção de performance.
