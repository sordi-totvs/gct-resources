# Template — `perf-analysis.md`

Grave em `.specs/fixes/<ISSUE>/perf-analysis.md`. Este documento **não propõe
código final** — ele quantifica o gargalo e entrega a direção provada para o RCA.

Omita seções que não se aplicam. Não invente número: sem artefato, a linha vira
❓ Hipótese e entra em **Limitações**.

---

```markdown
# Análise de Performance — <ROTINA SV> (<OBJETO DE NEGÓCIO>) x <FONTE LEGADO>

| Campo | Valor |
|---|---|
| **Issue** | [<ISSUE>](<url>) · Ticket <n> |
| **Data** | <AAAA-MM-DD> |
| **Fonte de menu** | `<FINSV005>.prw` · caminho ativo: callSmartView / callTReports |
| **Objeto de negócio** | `<backoffice.sv.fin.billsreceivable>.tlpp` (classe `<...SmartViewBusinessObject>`) |
| **Provider do módulo** | `<backoffice.sv.fin.integratedprovider>.tlpp` (`<FinIntegratedProvider>`) |
| **Base do Framework** | `totvs.framework.treports.integratedprovider.IntegratedProvider` |
| **Fonte legado** | `<FINR130>.PRX` |
| **Módulo / versões** | SIGA<XXX> · <12.1.2410, 12.1.2510> |
| **Artefatos** | profiler legado ✅/❌ · profiler SV ✅/❌ · plano de execução ✅/❌ |

> **Escopo:** análise e direção de correção. **Nenhum fonte alterado.**
> Causa raiz formal e correção vão para `rca.md` (fase Design).

## 1. Sumário executivo

<3-6 linhas: onde está o tempo, por que o legado não sofria, e qual a direção da
correção mínima de resultado idêntico. Diga também o que **não** é o problema.>

## 2. Cenário medido

| | Legado | Smart View |
|---|---|---|
| Fonte / objeto de negócio | | |
| Volume (registros) | | |
| Raiz medida no profiler | | |
| Tempo da raiz | | |
| ms / registro | | |
| Parâmetros relevantes | | |
| Mesmo range? | sim / não — se não, comparar só % relativo |

## 3. Arquitetura dos dois caminhos

**Legado:** <como lê os dados, o que faz por linha, que caches monta>

**Smart View:** <query principal set-based no objeto de negócio; laço em
`myAliasToData` no provider do módulo; o que `myProcessData` faz por registro;
rota ativa — `processAndAppend` ou `myProcessData`>

<Trecho curto do laço de extração (provider), com fonte e linhas.>

## 4. Hotspots medidos (LogProfiler)

**Profile Smart View — `<arquivo>` · <N> registros · raiz `<FUNC>` = <T> s (100%)**

| Função | Chamadas | T (s) | % da raiz | ms/chamada | Callee dominante (T) |
|---|---:|---:|---:|---:|---|
| | | | | | |

**Profile legado — `<arquivo>` · <N> registros · raiz `<FUNC>` = <T> s (100%)**

| Função | Chamadas | T (s) | % da raiz | ms/chamada | Callee dominante (T) |
|---|---:|---:|---:|---:|---|
| | | | | | |

**Leitura da evidência:**
1. <quem domina, e quanto somam os dominantes>
2. <núcleo do custo de cada dominante — callee que aparece 1x por registro>
3. <o que parecia achado e é irrelevante (< 5%) — dizer explicitamente>
4. <custo por registro; linearidade; extrapolação para o volume de produção>

## 5. Plano de execução da query principal

**Query:** <loadStatement / getQuery — tabelas, JOINs, filtros>
**Plano:** <real | estimado> · SGBD <...> · base <volume>

| Achado | Evidência | Peso |
|---|---|---|
| | | |

**Índices consultados (SIX):** <ordem, chave, a query usa?>

**Conclusão:** a query principal ✅ é / ❌ não é o gargalo — <por que>.

## 6. Delta legado x Smart View

| Hotspot SV | O legado chama? | Frequência no legado | O que é diferente | Consequência |
|---|---|---|---|---|
| | | | | |

**Divergências identificadas** (ver catálogo em `legacy-vs-smartview.md`):
- <cache compartilhado / motor por call stack / guard perdido / N+1 / seek x RECNO / ...>

**Achado central:** <o legado tem solução a copiar? Ou paga o mesmo custo e a
correção tem de reduzir o número de execuções?>

## 7. Priorização

| # | Hotspot | % do tempo | Correção candidata | Em escopo? | Resultado idêntico? | Esforço | Risco |
|---|---|---:|---|---|---|---|---|
| 1 | | | | | | | |
| 2 | | | | | | | |

**Recomendação:** atacar #<n> — <justificativa em % de tempo, escopo e risco>.
**Descartados:** <hotspots < 5% e por que corrigi-los não resolve.>

## 8. Direção da correção (para o RCA)

**Alvo:** <o que se pretende reduzir — nº de execuções de X, round-trips, etc.>

**Fundamento provado no código:** <a condição sob a qual a função de núcleo
retorna o valor trivial, com fonte e linhas>

**Ideia:** <pré-carga em lote + curto-circuito no laço, em 2-3 passos>

**Nível da correção:** objeto de negócio / provider do módulo / (justificar se
subir de nível — o provider é herdado por todos os objetos de negócio do módulo)

**Por que é segura e em escopo:** <função de núcleo intacta; só o objeto de
negócio muda; valor idêntico para os registros pulados>

**Cuidados de validação:** <reproduzir o valor trivial exatamente: acréscimo,
decréscimo, moeda, abatimento; provar igualdade de dataset nos dois grupos>

**Alternativa se não bastar:** <pré-agregação total em lote — maior esforço e
risco de regressão de valor>

**Fora do escopo atual:** <materializar em staging, paginar/assíncrono, índice novo>

## 9. Metas e validação

| Critério | Meta | Como medir |
|---|---|---|
| Tempo de extração | <meta / baseline do legado> | reexecução no volume de produção |
| Chamadas do hotspot | cai de N para <...> | contador / profiler pós-correção |
| Pré-carga | **1** query, não N | sensor de N+1 |
| Resultado | **idêntico** ao atual | comparação de dataset (AdvPR) |

**Baseline:** <tempo do legado no mesmo volume — ou "em aberto", se não houver>

## 10. Limitações e confiança

| Afirmação | Confiança | Base |
|---|---|---|
| | ✅ / ⚠ / ❓ | profiler / plano / código / issue |

<Artefatos ausentes e o que ficou sem prova.>

## 11. Prevenção

- <causa sistêmica: enriquecimento row-by-row com round-trip por linha>
- <sensor de N+1 como teste permanente>
- <outros objetos de negócio que herdam do mesmo provider e repetem o padrão>

---

### Rastreabilidade

- Bug spec: `.specs/fixes/<ISSUE>/bug-spec.md`
- RCA: `.specs/fixes/<ISSUE>/rca.md`
- Profilers: `profiles/<...>` · Plano: `plans/<...>`
- **Nenhum código-fonte foi alterado nesta análise.**
```

---

## Como fechar

Apresente as seções 1, 4, 6, 7 e 8 no chat (o resto fica no arquivo) e
**confirme a direção com o engenheiro antes de gerar qualquer código** — regra 5
de `tlpp-master-rules.md`. Depois acione `advpl-tlpp-root-cause-analysis` para o
`rca.md`, que referencia esta análise em vez de repetir os números.
