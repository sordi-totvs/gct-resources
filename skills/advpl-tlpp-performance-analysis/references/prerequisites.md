# Pré-requisitos — como capturar os 3 artefatos

Leia quando um artefato faltar ou o usuário perguntar como gerar. Repasse as
instruções; o agente não captura nada disso sozinho, depende do ambiente.

## 1 e 2. LogProfiler (legado e Smart View)

Fonte: [LogProfiler - Como executar](https://tdn.totvs.com/display/framework/LogProfiler+-+Como+executar)
e [LogProfiler - Profiler de execução de programas AdvPL](https://tdn.totvs.com/pages/viewpage.action?pageId=6065063).
*Conteúdo reescrito para atender restrições de licenciamento.*

Use um AppServer **dedicado e exclusivo** — nenhum outro usuário conectado e
nenhum Job rodando. Concorrência contamina os tempos e invalida a comparação.

Configuração no `appserver.ini`:

```ini
[General]
ConsoleLog=1

[Environment]        ; a seção do ambiente que será medido
LogProfiler=1
```

- `ConsoleLog=1` na seção `[General]` só passa a valer na **inicialização** do
  AppServer (serviço ou console).
- `LogProfiler=1` é por ambiente e pode ser inserida com o serviço em execução:
  passa a valer para novos JOBs e novas conexões de SmartClient iniciadas depois.

Procedimento por captura:

1. Pare o AppServer; ajuste o `.ini`; renomeie o `console.log` existente.
2. Reinicie o AppServer.
3. Acesse **somente** a rotina medida — nada mais.
4. Feche o SmartClient (o arquivo do profiler é fechado no fim da thread).
5. Recolha os arquivos `fwlogprofiler_<timestamp>_<thread>.log` gerados.

Ignore os arquivos irmãos `.logpreProcess1` e `.log_err` — o script usa o `.log`.

**Duas capturas, mesmo cenário.** Rode o legado e o Smart View com os **mesmos
parâmetros e o mesmo range**. Se não for possível (o legado não aguenta o range,
ou vice-versa), capture o que der e registre os volumes: a comparação passa a ser
por **percentual relativo**, nunca por segundos absolutos.

**Registre o volume de cada captura** (nº de títulos/registros processados). Sem
isso não existe `ms/registro` e não há como extrapolar para produção. Se o
relatório não informa a contagem, obtenha por `execute-sql` com os mesmos filtros.

Caso específico de Smart View/TReports: quando a extração roda via serviço REST,
o profiler por INI mistura todas as requisições da working thread. Nesse caso use
o profiler por requisição (`restprofiler`, gravado em pasta um nível abaixo do
rootpath) ou meça em execução via SmartClient, que isola a thread.

## 3. Plano de execução da query principal do objeto de negócio

Precisa ser **a query principal** — a do `loadStatement`/`getQuery`/`execQuery`
do objeto de negócio, com os **mesmos parâmetros** da execução lenta e na **base
com volume** (plano em base pequena não reproduz o problema).

Como obter a query real:

1. Leia o objeto de negócio (fonte no workspace) e monte a query com os valores
   dos parâmetros efetivos.
2. Ou capture do log do banco / do console com o SQL logging do TOPCONN habilitado.
3. Substitua os `?` do `FWExecStatement` pelos valores reais antes de pedir o plano.

Por SGBD:

| SGBD | Plano estimado | Plano real (preferido) |
|---|---|---|
| SQL Server | `SET SHOWPLAN_ALL ON` ou Ctrl+L no SSMS | **Include Actual Execution Plan** (Ctrl+M) → salvar `.sqlplan` |
| Oracle | `EXPLAIN PLAN FOR <query>` + `DBMS_XPLAN.DISPLAY` | `DBMS_XPLAN.DISPLAY_CURSOR(..., 'ALLSTATS LAST')` (com `/*+ GATHER_PLAN_STATISTICS */`) |
| PostgreSQL | `EXPLAIN <query>` | `EXPLAIN (ANALYZE, BUFFERS) <query>` |

O plano **real** é muito superior ao estimado: é ele que mostra a divergência
entre linhas estimadas e efetivas, que é o sintoma clássico de estatística velha
ou predicado não-sargável.

Grave em `.specs/fixes/<ISSUE>/plans/mainquery-execplan.<ext>` junto com o texto
da query e os parâmetros usados.

## Artefato opcional, mas de alto valor

**Profiler pós-correção.** Na fase Execute, repita a captura do Smart View com a
correção aplicada e rode o script em modo `-Compare`. É a prova objetiva de que o
hotspot deixou de dominar — e o que fecha o critério de aceite de performance.
Mesmo volume nas duas capturas: assim o `Delta` em segundos passa a ser válido.
