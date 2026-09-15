# Análise do plano de execução da query principal

O objetivo aqui é binário: **a query principal é ou não é o gargalo?** Responder
"não é" também é um achado — descarta uma frente de trabalho e concentra o esforço
no enriquecimento linha a linha, que é onde o problema costuma estar em objeto de
negócio de Smart View.

## Como decidir com o profiler na mão

Cruze o plano com o profiler antes de mergulhar no plano:

| Sintoma no profiler | Leitura | Onde atacar |
|---|---|---|
| `MPSYSOPENQUERY`/`FWEXECSTATEMENT:OPENALIAS` com **1-2 chamadas** e T alto | a query principal é o gargalo | plano de execução, índices, predicados |
| Mesmas funções com **milhares** de chamadas e T alto | round-trip por linha (N+1) | reduzir o número de execuções, não a query |
| Query principal com T baixo e `myProcessData`/laço dominando | a query está ok | enriquecimento por linha |
| `M` (maior chamada) próximo do `T` total | custo concentrado em uma execução | plano dessa query específica |

Uma query principal de 1 execução com T de poucos segundos, num relatório que
leva 9 horas, **não é o problema** — não gaste a análise nela.

## O que procurar no plano

Em ordem de frequência em base Protheus:

1. **Scan onde deveria haver seek.** `Table Scan`/`Clustered Index Scan` em SE1,
   SE2, SE5, FK1... Confirme se existe índice útil no dicionário (SIX via
   `execute-sql`) e se os predicados o alcançam.

2. **Predicado não-sargável.** O padrão mais comum é a função aplicada na coluna,
   que anula o índice:

   ```sql
   -- anula índice
   WHERE SUBSTRING(E1_EMISSAO,1,6) = '202601'
   WHERE RTRIM(E1_CLIENTE) = '000001'
   -- sargável
   WHERE E1_EMISSAO BETWEEN '20260101' AND '20260131'
   WHERE E1_CLIENTE = '000001'
   ```

3. **Divergência estimado x real** (só no plano real). Estimado 100 linhas,
   real 2 milhões: estatística desatualizada ou predicado que o otimizador não
   consegue estimar. Consequência típica: escolha de Nested Loops onde Hash Join
   seria correto.

4. **Ordem de JOIN e tipo de JOIN.** Nested Loops com a tabela grande no lado
   interno é desastre em volume. Hash/Merge Join costuma ser o correto para
   agregação de grande volume.

5. **Sort/Spool custoso.** Vem quase sempre de `ORDER BY` que não acompanha
   nenhum índice. Verifique se a ordenação é realmente necessária — no Smart View
   a ordenação final é frequentemente feita pela ferramenta.

6. **Spill para disco / tempdb.** Sort ou hash que estourou a memória concedida.
   Sinaliza volume acima do previsto pelo otimizador (ver item 3).

7. **Key Lookup / acesso à tabela por rowid em volume.** Índice não cobre as
   colunas do SELECT. Avalie se as colunas realmente precisam vir da query.

## Filtros obrigatórios — verificar sempre

Independente de performance, confira na query do objeto de negócio:

- `D_E_L_E_T_ = ' '` em **todas** as tabelas do FROM/JOIN;
- filtro de filial via `xFilial()`/`FWxFilial()` conforme compartilhamento (SX2);
- `%NoLock%` / `ChangeQuery()` para portabilidade e para não bloquear;
- parâmetros via `FWExecStatement` (anti-injection), não concatenação.

A ausência de `D_E_L_E_T_` ou de filial é simultaneamente bug de resultado e
problema de performance — reporte como achado próprio.

## Sobre criar índice

Criar índice é decisão de Design/RCA, não de análise. Antes de propor:

- confirme os índices existentes no dicionário (`SIX` via `execute-sql`);
- verifique se um índice existente atende com uma pequena mudança de predicado —
  ajustar a query é mais seguro que criar índice;
- lembre que índice novo custa em gravação e exige atualização de dicionário, o
  que normalmente está **fora do escopo** de uma correção de performance de
  relatório.

Registre no `perf-analysis.md`: índices existentes consultados, se a query os
usa, e a conclusão (query é/não é gargalo). Classifique a confiança:
✅ Confirmado (plano real na base com volume) · ⚠ Inferência (plano estimado ou
base pequena) · ❓ Hipótese (sem plano).
