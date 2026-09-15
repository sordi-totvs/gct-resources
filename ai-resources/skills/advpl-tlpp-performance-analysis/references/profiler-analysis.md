# Análise do LogProfiler (FWLogProfiler)

Leia este arquivo **antes** de interpretar qualquer profiler. A semântica do
formato é contraintuitiva e o erro de leitura invalida a análise inteira.

## Formato do arquivo

Um log do FWLogProfiler tem um cabeçalho curto e, depois, apenas dois tipos de
linha úteis:

```
/* ========================================
Request Profiler Log
DateTime ..: 20260521 14:47:24
Service ...: SERVICO
Method ....: METODO
Thread ....: 56104
T.Timer ..:               52951.759 s.

CALL    REPORTPRINT(FINR550.PRX)                     C     1 T   259.717 M   259.717
-- FROM #CODEBLOCK# (FINR550.PRX) (100)              C     1 T   259.717 M   259.717

CALL    MSSEEK(APLIB070.PRW)                         C 28924 T    85.045 M     0.025
-- FROM REPORTPRINT (FINR550.PRX) (1567)             C 28739 T    84.655 M     0.025
-- FROM F550CALSLD (FINR550.PRX) (2210)              C   185 T     0.390 M     0.011
```

| Campo | Significado |
|---|---|
| `CALL <FUNC>(<FONTE>)` | função/método medido e o fonte onde está declarado |
| `C` | número de chamadas |
| `T` | **tempo total INCLUSIVO** em segundos (a função + tudo que ela chamou) |
| `M` | duração da **maior** chamada individual |
| `-- FROM <CHAMADOR> (<FONTE>) (<linha>)` | um *call site*: quem chamou, de qual fonte e linha |

`(Internal)` como fonte = função nativa do AppServer (`DBSKIP`, `DBSEEK`, `EVAL`).

## As duas leituras do grafo — a parte que engana

As linhas `-- FROM` dentro do bloco `CALL F` decompõem o `T` de **F** por call
site. Disso derivam duas visões diferentes:

- **CALLERS de F** — as linhas `-- FROM x` **dentro** do bloco `CALL F`.
  Responde: *quem chama F, quantas vezes, e de qual linha*.
- **CALLEES de F** — as linhas `-- FROM F` espalhadas por **todos os outros**
  blocos `CALL`. Responde: *onde F gasta o tempo dela*.

A visão de callees é a que prova a causa raiz. Foi assim que se estabeleceu, na
DSFIN-20529, que 88% do tempo de `SaldoTit` estava em `SLDTITFK`.

O script faz as duas: `-Function SALDOTIT` imprime callers e callees com
percentual sobre o T da função.

## Regras de interpretação

1. **`T` é inclusivo.** Nunca some `T` de funções de níveis diferentes — passa de
   100%. Para achar o custo próprio, compare o `T` da função com a soma dos `T`
   dos callees dela: a diferença é o custo local.

2. **`T.Timer` do cabeçalho não é o total da rotina.** É o tempo de vida da
   thread, incluindo o usuário parado no wizard. Num log real, `T.Timer` =
   52.951 s enquanto a rotina medida (`REPORTPRINT`) = 259 s. Ancore os
   percentuais na **raiz da extração**:

   | Caminho | Raiz típica |
   |---|---|
   | Relatório legado TReport | `REPORTPRINT`, `<FONTE>` |
   | Smart View — entrada | `GETDATA`, `GETSCHEMA` |
   | Smart View — laço do provider do módulo | `MYALIASTODATA` |
   | Smart View — hook por registro do objeto de negócio | `MYPROCESSDATA`, `PROCESSANDAPPEND`, `PROCESSDATA` |

   Para isolar o enriquecimento por linha, ancore em `MYPROCESSDATA`; para medir a
   extração inteira (query + laço + transporte), ancore em `GETDATA`.

3. **Ignore os wrappers reentrantes.** `EVAL`, `#CODEBLOCK#`, `MSDIALOG:ACTIVATE`,
   `TREPORT:PRINT`, `FWDIALOGMODAL:ACTIVATE`, `FWMSGRUN` aparecem com Pct > 100%
   porque são ancestrais ou reentram no grafo. Não são hotspot.

4. **`ms/chamada` baixo + contagem altíssima = N+1.** É o achado mais comum aqui.
   Exemplos reais: `DBSKIP` 141.112 chamadas × 0,96 ms = 135 s;
   `MSSEEK` 28.924 × 2,94 ms = 85 s; `SLDTITFK` 130.035 chamadas = 893 s.
   Corrigir N+1 é reduzir **N**, não o custo unitário.

5. **`M` muito maior que a média** indica custo concentrado (uma query pesada, um
   lock, um flush). Investigue separado do padrão N+1 — a correção é outra.

6. **Distribuição estável em dois volumes = conclusão robusta.** Quando houver
   dois profilers do mesmo caminho em volumes diferentes, compare os percentuais.
   Se a distribuição se mantém, a causa é estrutural e escala linearmente.
   Registre `ms/registro` nos dois e extrapole para o volume de produção.

7. **Não há tempo de SQL puro no profiler AdvPL.** O custo de banco aparece
   dentro de `MPSYSOPENQUERY`, `TCQUERY`, `FWEXECSTATEMENT:OPENALIAS`,
   `MPSYSEXECSCALAR`, `DBUSEAREA`. Contagem alta nessas funções é a assinatura de
   round-trip por linha; o **plano de execução** é que diz se cada round-trip
   também é caro.

## Uso do script

`scripts/Parse-FwLogProfiler.ps1`. Nunca leia o `.log` inteiro para o contexto —
são 700 KB a 2 MB, dezenas de milhares de linhas.

```powershell
$s = "$HOME\.kiro\skills\advpl-tlpp-performance-analysis\scripts\Parse-FwLogProfiler.ps1"

# 1) hotspots, ancorados na raiz da extração, sem ruído de UI/login
& $s -Path .\profiles\smartview.log -Root MYPROCESSDATA -Subtree -Top 25

# 2) callers + callees de um hotspot (prova onde o tempo dele vai)
& $s -Path .\profiles\smartview.log -Function SALDOTIT

# 3) legado x Smart View, percentual normalizado por raiz de cada log
& $s -Path .\profiles\legado.log -Root REPORTPRINT `
     -Compare .\profiles\smartview.log -CompareRoot GETDATA -Subtree -Top 30

# 4) antes x depois da correção (mesmo volume => Delta em segundos vale)
& $s -Path .\profiles\smartview.log -Compare .\profiles\posfix.log `
     -Root MYPROCESSDATA -CompareRoot MYPROCESSDATA -Subtree

# 5) exportar tudo para planilha
& $s -Path .\profiles\smartview.log -Csv .\profiles\smartview-hotspots.csv
```

| Parâmetro | Para que |
|---|---|
| `-Root` | função que vale 100% do ranking. **Sempre informe.** |
| `-Subtree` | restringe aos descendentes do root; remove login/UI/env do ranking |
| `-Function` | foco: callers + callees da função (aceita nome parcial) |
| `-Compare` / `-CompareRoot` | segundo log e a raiz dele (as raízes diferem entre legado e Smart View) |
| `-MinSeconds` | corta ruído; default 0,1 s |
| `-Top` | tamanho dos rankings; default 25 |
| `-Csv` | grava o ranking completo |

Se o script reclamar que não reconheceu linhas `CALL`, confira se o arquivo é o
`.log` e não o `.logpreProcess1` ou o `.log_err` (que vem vazio).

## Tabela de hotspots — o entregável

Para cada profiler, produza:

```markdown
**Profile <A|B> — `<arquivo>` · <N> registros · raiz `<FUNC>` = <T> s (100%)**

| Função | Chamadas | T (s) | % da raiz | ms/chamada | Callee dominante (T) |
|---|---:|---:|---:|---:|---|
| `SaldoTit` | 130.035 | 1.009,30 | 54,7% | 7,76 | `SLDTITFK` 893,72 s |
| `FValAcess` | 130.035 | 521,69 | 28,3% | 4,01 | `MsSeek` 321,62 s |
| `SomaAbat` | 16.647 | 88,40 | 4,8% | 5,31 | `__ExecSQL` 77,24 s |
| `buscaUltimaBaixa` | 6.253 | 11,53 | 0,6% | 1,84 | — |
```

Feche com a **leitura da evidência** em frases numeradas: quem domina, qual o
núcleo do custo de cada dominante, e — igualmente importante — **o que parecia
achado e é irrelevante**. Dizer "o N+1 que priorizamos vale 1% e não resolve" é
o resultado mais valioso que um profiler entrega, porque impede implementação
desperdiçada.
