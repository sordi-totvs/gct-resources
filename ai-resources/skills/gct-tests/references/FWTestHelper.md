# FWTestHelper — Referência de API

Documentação da classe `FWTestHelper` utilizada pelo framework AdvPR para automação de testes não-interface no TOTVS Protheus.

---

## Sumário

- [Ciclo de Vida](#ciclo-de-vida)
- [Assertions](#assertions)
- [Ambiente e Filial](#ambiente-e-filial)
- [Parâmetros (SX6)](#parâmetros-sx6)
- [Perguntas (SX1)](#perguntas-sx1)
- [Dados e Modelo](#dados-e-modelo)
- [Commit e Execução](#commit-e-execução)
- [Verificação de Banco](#verificação-de-banco)
- [Manipulação de Banco](#manipulação-de-banco)
- [Relatórios](#relatórios)
- [REST / SOAP / WebService](#rest--soap--webservice)
- [EAI — Mensagem Única](#eai--mensagem-única)
- [SmartLink](#smartlink)
- [Smart View](#smart-view)
- [Audit Trail](#audit-trail)
- [Autocontidas e SIGAMAT](#autocontidas-e-sigamat)
- [Arquivos e Comparação](#arquivos-e-comparação)
- [Utilitários](#utilitários)
- [Telnet](#telnet)
- [Mock Server](#mock-server)
- [Procedures (SPS)](#procedures-sps)
- [Outros](#outros)

---

## Ciclo de Vida

### Activate()

Ativa e valida a classe para uso. Deve ser chamado após a configuração inicial (SetCSV, SetXml, etc.).

```advpl
Local oHelper := FWTestHelper():New()
oHelper:Activate()
```

### DeActivate()

Desativa a classe ao final da execução.

```advpl
oModel:Deactivate()
oHelper:Deactivate()
```

---

## Assertions

### AssertTrue( lCondition, cHelp )

Define que o teste espera um retorno verdadeiro para passar.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| lCondition | Lógico | Condição que define se o teste passou ou não | `.T.` | X |
| cHelp | Caractere | Mensagem customizada exibida no console caso o teste falhe | `""` | |

```advpl
oHelper:AssertTrue( oHelper:lOk, "Expected operation to succeed" )
```

### AssertFalse( lCondition, cErro )

Define que o teste espera um retorno falso para passar.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| lCondition | Lógico | Condição que define se o teste passou ou não | `.T.` | X |
| cErro | Caractere | Mensagem customizada exibida no console caso o teste falhe | `""` | |

```advpl
oHelper:AssertFalse( oHelper:lOk, "Expected operation to fail" )
```

### AssertHelp( cHelp, cErro )

Define que o teste espera uma resposta de Help para passar.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cHelp | Caractere | Texto parcial do Help para verificar se o teste passou | `"HELP"` | X |
| cErro | Caractere | Mensagem customizada exibida no console | `""` | |

```advpl
oHelper:AssertHelp( "HELP", "" )
```

---

## Ambiente e Filial

### UTOpenFilial( cEmpresa, cFil, cMod, aTable, cUser, cPsw )

Abre a filial de acordo com os parâmetros passados.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cEmpresa | Caractere | Empresa que deseja acessar | | X |
| cFil | Caractere | Filial que deseja acessar | | X |
| cMod | Caractere | Módulo que deseja acessar | `"FAT"` | |
| aTable | Array | Tabelas que deseja abrir | | |
| cUser | Caractere | Usuário de acesso | `"ADMIN"` | |
| cPsw | Caractere | Senha do usuário | | |

```advpl
oHelper:UTOpenFilial( "T1", "D RJ01 ", "CRM",, "VENDFAT05", "1" )
```

### UTCloseFilial()

Fecha a empresa após a execução dos casos de testes.

```advpl
oHelper:UTCloseFilial()
```

### ChangeFil( cFilDest )

Altera a filial logada durante o cenário do teste.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cFilDest | Caractere | Filial que será alterada | X |

> **Importante:** Após finalizar as alterações necessárias, retorne à filial original. Não suportado para testes que consomem Web Service.

```advpl
oHelper:ChangeFil( "D MG 02 " )
// ... operações ...
oHelper:ChangeFil( "D MG 01 " )
```

### UTUpdSpecialKey()

Atualiza a chave `SpecialKey` do `.ini` com `environment+data+hora+segundo`. Deve ser utilizada **antes** de `UTOpenFilial`.

```advpl
oHelper:UTUpdSpecialKey()
oHelper:UTOpenFilial("T1","D MG 01 ","PCP")
```

### UTDateCurrent( lCurrent )

Informa se será utilizada a data do sistema operacional ou a data em que o ambiente foi aberto. Deve ser utilizado **antes** de `UTOpenFilial()`.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| lCurrent | Lógico | `.T.` = data corrente do SO; `.F.` = data do script | `.T.` | |

```advpl
oHelper:UTDateCurrent(.T.)
```

---

## Parâmetros (SX6)

### UTSetParam( cParam, xValue, lChange )

Altera os parâmetros (SX6).

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cParam | Caractere | Nome do parâmetro a ser alterado | | X |
| xValue | Indefinido | Novo valor do parâmetro | `""` | X |
| lChange | Lógico | Se o parâmetro será alterado imediatamente ou depende de `LoadData()` | `.F.` | |

```advpl
oHelper:UTSetParam( "MV_BXCNAB", 'S', .T. )
oHelper:UTSetParam( "MV_FINJRTP", 2, .T. )
```

### UTRestParam( aParam )

Restaura os parâmetros para seus valores originais.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| aParam | Array | Array de parâmetros que serão restaurados | X |

```advpl
oHelper:UTRestParam( oHelper:aParamCT )
```

---

## Perguntas (SX1)

### UTChangePergunte( cGrupo, cOrdem, xValue )

Altera o conteúdo das perguntas do SX1.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cGrupo | Caractere | Grupo da rotina a ser alterada | X |
| cOrdem | Caractere | Sequência da pergunta | X |
| xValue | Indefinido | Valor a ser alterado | X |

```advpl
oHelper:UTChangePergunte( "AFA010", "01", 2 )  // Mostra Lançamento - N
oHelper:UTChangePergunte( "AFA010", "02", 2 )  // Repete Chapa - S
oHelper:UTChangePergunte( "AFA010", "03", 2 )  // Desc. Estendida - N
oHelper:UTChangePergunte( "AFA010", "04", 1 )  // Copia valores - TODOS
```

---

## Dados e Modelo

### UTSetValue( cModel, cField, xValue, cAuxiliar )

Inclui valor em um campo de modelo MVC ou em um array (aCab/aItens).

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cModel | Caractere | Nome do modelo ou array (`"aCab"`, `"aItens"`, `"CPIDETAIL"`, etc.) | X |
| cField | Caractere | Nome do campo | X |
| xValue | Indefinido | Valor a ser incluído | X |
| cAuxiliar | Caractere | Valor auxiliar | |

**Exemplo MVC:**

```advpl
oHelper:UTSetValue('FW3MASTER', 'FW3_SOLICI', cIdSolic)
oHelper:UTSetValue('FW3MASTER', 'FW3_NACION', '1')
oHelper:UTSetValue('FW4DETAIL', 'FW4_ITEM', '01')
```

**Exemplo Array (ExecAuto):**

```advpl
oHelper:UTSetValue("aCab", "E1_PREFIXO", "AUT")
oHelper:UTSetValue("aCab", "E1_NUM", cE1_Num)
oHelper:UTSetValue("aItens", "UB_PRODUTO", "TMK002")
oHelper:UTSetValue("aItens", "UB_QUANT", 1)
```

### UTAddLine( cModel )

Inclui uma nova linha em um modelo de dados ou em um array.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cModel | Caractere | Nome do array ou modelo onde inserir nova linha | X |

```advpl
// Adição em array
oHelper:UTSetValue( "aItens", 'N3_VORIG1', 1000 )
oHelper:UTAddLine( 'aItens' )
oHelper:UTSetValue( "aItens", "N3_CBASE", "ATF038 ")

// Adição no modelo de dados
oHelper:UTAddLine( "CPIDETAIL" )
oHelper:UTSetValue( "CPIDETAIL", "CPI_CODORG", '000002' )
```

### UTGetaCab()

Recupera o `aCab` declarado através de `UTSetValue()`.

```advpl
oHelper:UTCommitData( {|x,y,z| ATFA010(x,y,z)}, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

### UTGetaItens()

Recupera o `aItens` declarado através de `UTSetValue()`.

```advpl
oHelper:UTCommitData( {|x,y,z| ATFA010(x,y,z)}, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

### SetModel( oModel, lValid )

Ativa o modelo que será utilizado nas operações em fontes MVC.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| oModel | Objeto | Modelo a ser carregado | X |
| lValid | Lógico | Interrompe execução em caso de falha ao instanciar (default `.F.`) | |

```advpl
oHelper:SetModel( oModel )
```

### UTLoadData( lClearDB, aParam )

Importação dos layouts XML e execução dos layouts CSV.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| lClearDB | Lógico | Define se deve ser realizada a limpeza das tabelas | |
| aParam | Array | Array de backup dos parâmetros a serem restaurados | |

```advpl
oHelper:UTLoadData( .T., ::aParam )
```

### SetCsv( cLayout, cTxtFiel, xAlias )

Informa um arquivo CSV para importação de dados.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cLayout | Caractere | Nome do layout no MILE | X |
| cTxtFiel | Caractere | Nome do arquivo CSV a ser carregado | X |
| xAlias | Indefinido | Nome da tabela principal ou array de tabelas a serem limpas | X |

```advpl
oHelper:SetCSV( "CTBA010", "ctba010.csv", "CTG" )
oHelper:SetCSV( "CTBA020", "ctba020.csv", "CT1" )
```

### SetXml( cXml )

Informa um layout de importação XML.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cXML | Caractere | Nome do layout XML a ser carregado | X |

```advpl
oHelper:SetXml( "ctba010.xml" )
oHelper:SetXml( "ctba020.xml" )
```

---

## Commit e Execução

### UTCommitData( bExec, xParam1, xParam2, ... xParam20 )

Executa o commit de teste e captura erros.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| bExec | Bloco | Bloco de execução do MsExecAuto | |
| xParam1..20 | Indefinido | Parâmetros adicionais passados ao bloco | |

**Rotina automática (ExecAuto):**

```advpl
oHelper:UTCommitData( {|x,y,z| ATFA010(x,y,z)}, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

**MVC:**

```advpl
oHelper:UTCommitData()
```

### UTGetError()

Procura e retorna o erro do MsExecAuto / MVC.

### SetMsErroAuto( lMsAuto, lErrFile )

Seta variáveis privadas da execução automática.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| lMsAuto | Lógico | Retorno dos erros no MsExecAuto (`.T.` = houve erro) | `.F.` | |
| lErrFile | Lógico | Se `.T.`, a variável `__aErrAuto` será alimentada | `.T.` | |

```advpl
oHelper:SetMsErroAuto()
```

### GetParAuto( cProgram, lCabItem, aHeader )

Para programas que não estão preparados para receber informações automáticas. Retorna array a ser informado no TestCase.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProgram | Caractere | Nome do TestCase que retornará o array | | X |
| lCabItem | Lógico | Preenche variáveis simulando `Enchoice()` e `GetDados()` | `.F.` | |
| aHeader | Array | Array do aHeader da rotina (se `lCabItem = .T.`) | | |

### ExecStatic( cStaticFun, aPrgNames )

Executa uma função static de um fonte.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cStaticFun | Caractere | Nome da função estrutural a ser executada | |
| aPrgNames | Array | Array unidimensional com os nomes dos programas | X |

```advpl
Local aProgramas := {"TEC880EXE","TECA001","teca010","TECA011"}
Local lOk := oHelper:ExecStatic("ModelDef", aProgramas)
```

### UTSchedule( cRotina, cFilSched )

Realiza o agendamento e a execução de uma rotina. Utilizar `UTChangePergunte` para configurar os parâmetros.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cRotina | Caractere | Nome da rotina a ser agendada e executada | X |
| cFilSched | Caractere | Filial do agendamento | |

```advpl
oHelper:UTChangePergunte("MTA320","01",2)
oHelper:UTSchedule("MATA320")
```

### UTExecPredecessor( cNomeCT, cNumeroCT, aPar )

Executa os predecessores de um caso de teste.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cNomeCT | Caractere | Nome do TestCase (ex: `"TSSNFESBRANORSPTestCase"`) | X |
| cNumeroCT | Caractere | Nome do método (ex: `"NFE_001"`) | X |
| aPar | Array | Parâmetros do caso de teste | X |

```advpl
oHelper:UTExecPredecessor("TSSNFESBRANORSPTestCase","NFE_001",{cEntidade,cSerie,cNota})
```

---

## Verificação de Banco

### UTCheckDB( cAlias, cField, xValue )

Valida se o conteúdo do campo confere com o valor gravado no banco de dados.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cAlias | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo a ser verificado | X |
| xValue | Indefinido | Conteúdo esperado | X |

```advpl
oHelper:UTCheckDB( "SE1", "E1_VALOR", 1000 )
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTQueryDB( cTable, cField, cFilter, xValue, cFil, lAssert )

Realiza uma query de verificação de resultado esperado.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cTable | Caractere | Alias da tabela | | X |
| cField | Caractere | Campo para composição da query e validação | | X |
| cFilter | Caractere | Filtro da condição (WHERE) | | X |
| xValue | Indefinido | Valor esperado do campo | `""` | X |
| cFil | Caractere | Filial específica (desconsiderando a do Setup) | | |
| lAssert | Lógico | Execução por `AssertTrue` ou `AssertFalse` | `.F.` | |

```advpl
cQuery := "FW6_ITEM = '01' AND FW6_SOLICI = '" + cSolicit + "'"
oHelper:UTQueryDB( "FW6", "FW6_PORCEN", cQuery, 100 )
oHelper:UTQueryDB( "FW6", "FW6_CC", cQuery, 'FIN10101' )
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTContDB( cAlias, nCount )

Conta a quantidade de registros de uma tabela.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cAlias | Caractere | Nome da tabela | X |
| nCount | Numérico | Quantidade esperada | X |

```advpl
nRegister := oHelper:UTContDB( "SA1", 13 )
```

### UTCountRows( cTable, cFilter )

Conta linhas em uma tabela de acordo com um filtro.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela | X |
| cFilter | Caractere | Filtro usado como WHERE | |

**Retorno:** `nCount` (Numérico) — quantidade de linhas encontradas.

```advpl
nCount := oHelper:UTCountRows( "SA2", "A2_EST = 'SP'" )
```

### UTFindReg( cTabela, nIndice, cPesq, cFil, aPesq )

Encontra e posiciona em um registro de uma tabela.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTabela | Caractere | Nome da tabela | X |
| nIndice | Numérico | Índice de busca | X |
| cPesq | Caractere | Texto de pesquisa | X |
| cFil | Caractere | Filial específica (se diferente da logada) | |
| aPesq | Array | Dados de pesquisa (normalizado pelo grupo de campo) | |

> Não é necessário informar a filial (`xFilial('SA1')`). É considerada a filial logada ou a alterada por `ChangeFil`.

```advpl
oHelper:UTFindReg( "FNG", 1, cFNG_GRUPO + cFNG_TIPO + cFNG_TPSALD )
oHelper:UTFindReg( "SNI", 1, '00000000000000000008'+'000001', , {'00000000000000000008','000001'} )
```

### UTSelectDB( cTable, aFields, cFilter )

Retorna registros de uma tabela através de consulta SQL.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome físico da tabela (ex: `"SE1T10"`) | X |
| aFields | Array | Lista de campos a serem retornados | X |
| cFilter | Caractere | Filtro para condição WHERE | X |

**Retorno:** `aRows` (Array) — lista bidimensional com os registros encontrados.

```advpl
Local aFields := {"E1_TIPO","E1_DATAIN","E1_VALOR"}
Local cFilter := "E1_NUM = '000000001' AND E1_FILIAL = 'D MG 01 '"
aTitulos := oHelper:UTSelectDB('SE1T10', aFields, cFilter)
```

### UTRetReg( cTable, cFiltro, aFields )

Encontra registros em uma tabela via SQL.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela (ex: `RetSqlName("SA1")`) | X |
| cFiltro | Caractere | Filtro SQL | X |
| aFields | Array | Campos a serem retornados | X |

```advpl
aRet := oHelper:UTRetReg(RetSqlName("SA1"), "A1_COD = '0001' AND A1_TPCLI = 'R'", {"A1_COD","A1_TPCLI"})
```

---

## Manipulação de Banco

### UTAppendData( cTable, lExcluir, cFile )

Apenda dados para a tabela da base conforme `appServer.ini`.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cTable | Caractere | Nome da tabela para append | | X |
| lExcluir | Lógico | Se deve excluir dados da tabela antes | `.T.` | |
| cFile | Caractere | Nome do arquivo utilizado para append | `""` | |

**Retorno:** `oHelper:lOk` (Lógico) — indica sucesso.

```advpl
oHelper:UTAppendData("TAFST2",,"AdvPR_007")
oHelper:UTAppendData("SA1",.F.,"AdvPR_008")  // Sem deletar registros
```

### UTClearDB( aAlias )

Limpa os dados de tabelas específicas.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| aAlias | Array | Array de aliases a serem excluídos | X |

```advpl
oHelper:UTClearDB( {"ACG","B44","SEZ","SFQ","SK1","SC5","SC6","SC9","SDA"} )
```

### UTDeleteDB( cTable, cFilter )

Deleta registros de uma tabela de forma definitiva.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cTable | Caractere | Nome físico da tabela (com grupo de empresa, ex: `"SA1T10"`) | `""` | X |
| cFilter | Caractere | Filtro WHERE | `""` | |

> **Atenção:** Os dados são apagados de maneira definitiva. O AdvPR não realiza restore.

```advpl
oHelper:UTDeleteDB("SA1T10","A1_LOJA = '01'")
oHelper:UTDeleteDB("SFTT10","FT_NFISCAL = '000006' AND FT_SERIE = '664'")
```

### UTUpdateDB( cTable, cField, xVal, cFilter )

Altera registros no banco de dados através de filtro SQL.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome físico da tabela | X |
| cField | Caractere | Campo a ser atualizado | X |
| xVal | Indefinido | Valor a ser gravado no campo | X |
| cFilter | Caractere | Filtro WHERE | |

**Retorno:** `oHelper:lOk` (Lógico) — indica sucesso.

```advpl
oHelper:UTUpdateDB('SE1T10', "E1_NUM", "000000002", cFilter)
oHelper:UTUpdateDB('SE1T10', "E1_VALOR", 1000.00, cFilter)
```

### UTMarkReg( cTable, cField, cMark )

Marcação/desmarcação física de registro no banco (substitui MarkBrowse).

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Campo utilizado para marcação | X |
| cMark | Caractere | Marca a ser utilizada (vazio para desmarcar) | X |

> Deve ser usado em conjunto com `UTFindReg()`.

```advpl
oHelper:UTFindReg( "SA2", 1, '000002')
oHelper:UTMarkReg( "SA2", "A2_OK", "AT" )  // Marcação

oHelper:UTFindReg( "SA2", 1, '000002')
oHelper:UTMarkReg( "SA2", "A2_OK", "" )    // Desmarcação
```

### UTSetStamp( aTables, lGroup )

Adiciona o campo `S_T_A_M_P_` nas tabelas do Protheus.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| aTables | Array | Lista de tabelas a serem atualizadas | | X |
| lGroup | Lógico | Se será realizado `RetSqlName` na tabela | `.T.` | |

**Retorno:** `oHelper:lOk` (Lógico).

```advpl
oHelper:UTSetStamp({"SE1"})
```

### UTUpdComp( aSX2Data )

Altera o compartilhamento das tabelas no SX2.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| aSX2Data | Array | Informações da tabela e compartilhamento | X |

**Retorno:** Array com os valores anteriores à atualização (para restauração posterior).

```advpl
Local aNewComp := {}
aAdd(aNewComp, {"SB1", "E", "E", "E"})
aAdd(aNewComp, {"SGI", "E", "E", "E"})
::aSX2DataRest := oHelper:UTUpdComp(aNewComp)
```

### UTRestComp( aSX2DataRest )

Restaura o compartilhamento das tabelas no SX2 após os testes.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| aSX2DataRest | Array | Array retornado por `UTUpdComp` | X |

```advpl
oHelper:UTRestComp(::aSX2DataRest)
```

### UTAtuSX3( cTableName, aSX3Estr, aSX3Data )

Altera estrutura de campos do SX3 em tempo de execução.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTableName | Caractere | Nome da tabela a ser atualizada | X |
| aSX3Estr | Array | Estrutura dos campos (ex: `{"X3_CAMPO","X3_TAMANHO","X3_DECIMAL","X3_PICTURE"}`) | X |
| aSX3Data | Array | Dados a serem atualizados | X |

> Requer DBAccess 20220303 (Build 22.1.1.0) ou superior.

```advpl
Local aSX3Data := {}
Local aSX3Estr := {"X3_CAMPO", "X3_TAMANHO","X3_DECIMAL","X3_PICTURE"}
Aadd(aSX3Data, {"C6_PRCVEN", 15, 4, '@E 9,999,999,999.9999'})
oHelper:UTAtuSX3("SC6", aSX3Estr, aSX3Data)
```

### UTRestSX3()

Restaura a tabela alterada por `UTAtuSX3`.

```advpl
oHelper:UTRestSX3()
```

---

## Relatórios

### UTStartRpt( cReport, aListParam, cDef, cPerg, nOrder, wnrel, lEndReport, lEmptyLine )

Permite a geração de arquivos de relatório.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cReport | Caractere | Nome da função do relatório + número do caso de testes | | X |
| aListParam | Array | Perguntas do SX1 (desnecessário se usar `UTChangePergunte`) | `{}` | |
| cDef | Caractere | Nome da função quando não houver `ReportDef` | | |
| cPerg | Caractere | Nome do pergunte no SX1 | `""` | |
| nOrder | Numérico | Ordem de impressão | | |
| wnrel | Caractere | Nome do relatório (se diferente do fonte) | `""` | |
| lEndReport | Lógico | Imprime com "Total Geral" | `.F.` | |
| lEmptyLine | Lógico | Considera linhas em branco no Excel | `.F.` | |

```advpl
oHelper:UTChangePergunte( "FIN501", "01", "000007" )
oHelper:UTChangePergunte( "FIN501", "02", "000008" )
oHelper:UTStartRpt( "FINR501_001" )
```

### UTPrtCompare( cReport, lConvAcent, lConvAuto, aReplace, aReplaceX )

Compara relatório gerado com baseline.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cReport | Caractere | Nome da função do relatório + número do caso de testes | X |
| lConvAcent | Lógico | Converte caracteres para hexadecimal | |
| lConvAuto | Lógico | Converte arquivo autogerado para hexadecimal (arquivos `.rel`) | |
| aReplace | Array | Conteúdo a ser substituído no arquivo base (`{{"Original","Final"}}`) | |
| aReplaceX | Array | Substituição entre strings (`{{"TagInicial","TagFinal","Conteudo"}}`) | |

```advpl
oHelper:UTPrtCompare( "FINR130_001" )
```

### UTNotDeleteRel( lNotDeleteRel )

Impede a exclusão dos arquivos `.rel` da pasta Spool.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| lNotDeleteRel | Lógico | `.T.` = não excluir; `.F.` = permite exclusão | `.T.` | |

---

## REST / SOAP / WebService

### UTSetAPI( cApi, cTypeAPI )

Define o modelo de API que será consumido (REST ou SOAP).

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cApi | Caractere | Caminho da API na URL | | X |
| cTypeAPI | Caractere | Modelo da API: `"REST"` ou `"SOAP"` | `"REST"` | |

**Retorno:** `lOk` (Lógico).

```advpl
oHelper:UTSetAPI("/api/v1","REST")
```

### UTSetAuthorization( cUser, cPwd )

Autenticação de usuário para scripts de WebService. Converte login/senha para base64.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cUser | Caractere | Login do usuário | X |
| cPwd | Caractere | Senha | X |

**Retorno:** String em base64.

```advpl
Local aHeader := {"Content-Type: application/json", "Authorization: Basic " + oHelper:UTSetAuthorization("Admin", "1")}
```

### UTGetWS( aHeader, cFile, cGetParms, cURLRest, aReplace, aReplaceX, lLastResult, lRetry, aIgnoreProperty, lIgnoreNewProperty )

Consumo de APIs via GET. Atende REST/JSON e SOAP/XML.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| aHeader | Array | Strings do header da requisição | `{"Content-Type: application/json"}` | |
| cFile | Caractere | Nome do arquivo baseline para comparação (sufixo "base" automático) | `""` | |
| cGetParms | Caractere | Parâmetros enviados ao servidor HTTP | `""` | |
| cURLRest | Caractere | URL consumida (default via chave REST em `[ADVPR]`) | `"http://localhost:8787/"` | |
| aReplace | Array | Replace no response | `{}` | |
| aReplaceX | Array | Substitui valor entre duas strings (XML/Soap) | `{}` | |
| lLastResult | Lógico | `.T.` = GetResult (erros completos); `.F.` = GetLastError | `.F.` | |
| lRetry | Lógico | `.T.` = segunda chamada automática em caso de falha | `.T.` | |
| aIgnoreProperty | Array | Propriedades JSON com valores dinâmicos a ignorar | | |
| lIgnoreNewProperty | Lógico | `.T.` = ignora novas propriedades no JSON autogerado | `.F.` | |

**Retorno:** `cRet` (Caractere) — response da API.

```advpl
oHelper:UTSetAPI("/api/v1/","REST")
cRet := oHelper:UTGetWS(aHeader,"UTGETWS0001_REST")
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTPostWS( cBody, aHeader, cFile, cGetParms, cURLRest, aReplace, aReplaceX, lLastResult, lRetry )

Consumo de APIs via POST. Atende REST/JSON e SOAP/XML.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cBody | Caractere | Body da requisição (JSON ou XML) | `""` | |
| aHeader | Array | Header da requisição | `{"Content-Type: application/json"}` | |
| cFile | Caractere | Arquivo baseline para comparação | `""` | |
| cGetParms | Caractere | Parâmetros HTTP | `""` | |
| cURLRest | Caractere | URL consumida | `"http://localhost:8787/"` | |
| aReplace | Array | Replace no response | `{}` | |
| aReplaceX | Array | Substitui entre strings | `{}` | |
| lLastResult | Lógico | `.T.` = GetResult; `.F.` = GetLastError | `.F.` | |
| lRetry | Lógico | Segunda chamada em caso de falha | `.T.` | |

**Retorno:** `cRet` (Caractere) — response da API.

```advpl
Local cBody := '{"body_request":"advPr", "test_modelo": "interface"}'
oHelper:UTSetAPI("/api/v1","REST")
cRet := oHelper:UTPostWS(cBody, aHeader, "UTPostWs_004")
```

### UTPutWS( cBody, aHeader, cFile, cURLRest, aReplace, aReplaceX, lRetry )

Consumo de APIs via PUT. Mesma estrutura do POST (sem `cGetParms` e `lLastResult`).

**Retorno:** `cRet` (Caractere) — response da API.

```advpl
oHelper:UTSetAPI("/CRMMOPPORTUNITYCONTACT/","REST")
cRet := oHelper:UTPutWS(cBody, aHeader, "testcrmput")
```

### UTDeleteWS( cBody, aHeader, cFile, cURLRest, aReplace, aReplaceX, lRetry )

Consumo de APIs via DELETE. Mesma estrutura do PUT.

**Retorno:** `cRet` (Caractere) — response da API.

```advpl
oHelper:UTSetAPI("/CRMMOPPORTUNITYCONTACT/00024401/TMK035/","REST")
cRet := oHelper:UTDeleteWS(cBody, aHeader, "testcrmdelete")
```

### UTClientWSDL( cWSDL, cOperation, cXml, cFile, aReplace, cService )

Envia mensagem SOAP para serviço WSDL.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cWsdl | Caractere | URL do WSDL (default via chave SOAP em `[ADVPR]`) | `"http://localhost:8787/"` | |
| cOperation | Caractere | Nome do serviço consumido | `""` | |
| cXml | Caractere | XML enviado (se vazio, usar `UTSetSoapValue`) | `""` | |
| cFile | Caractere | Arquivo baseline para comparação | `""` | |
| aReplace | Array | Replace no response | `{}` | |
| cService | Caractere | Nome do serviço `.apw` | `""` | |

**Retorno:** `cRet` (Caractere) — response ou erro.

```advpl
oHelper:UTSetSoapValue("USERCODE","MSALPHA")
oHelper:UTSetSoapValue("GUIAS","000001")
cRet := oHelper:UTClientWSDL(,cOperation,,,,cService)
```

### UTSetSoapValue( cField, xValue )

Define valores no XML para estruturas simples de SOAP.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cField | Caractere | Nome da propriedade do XML | X |
| xValue | Indefinido | Valor a ser enviado | X |

**Retorno:** `lRet` (Lógico).

### UTSetLoginPP( cUser, cPassword, cTipoPortal )

Login no Portal Protheus, retorna SessionID para o header.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cUser | Caractere | Usuário do portal | X |
| cPassword | Caractere | Senha do portal | X |
| cTipoPortal | Caractere | Tipo do portal | X |

**Retorno:** `cSessionID` (Caractere).

```advpl
cSessionID := oHelper:UTSetLoginPP(cUser, cPassword, cTipoPortal)
```

### UTGetRACToken( cInteg, cClientID, cClientSecr )

Gera token do TOTVS RAC informando a integração ou credenciais.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cInteg | Caractere | Nome da integração (ex: `"TRANSMITE"`) | X |
| cClientID | Caractere | ClientID para geração do token | |
| cClientSecr | Caractere | ClientSecret para geração do token | |

**Retorno:** `cToken` (Caractere).

```advpl
oHelper:UTGetRACToken("TRANSMITE")
```

### UTRestartRest()

Reinicia o serviço de REST durante a execução do teste.

```advpl
oHelper:UTRestartRest()
```

---

## EAI — Mensagem Única

### UTEAIActivate( cProgram, cFormat, cVersion, cFilExec )

Ativa a configuração de envio do EAI.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProgram | Caractere | Nome do adapter configurado | | X |
| cFormat | Caractere | Formato do arquivo | `"XML"` | |
| cVersion | Caractere | Versão do adapter | | |
| cFilExec | Caractere | Filial de execução (XX4_FILEXE) | | |

**Retorno:** Lógico — se foi possível ativar o adapter.

```advpl
oHelper:UTEAIActivate( 'FINA010' )
```

### UTEAIReceive( cProgram, cFormat, cFilExec )

Habilita o recebimento do EAI.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProgram | Caractere | Nome do adapter configurado | | X |
| cFormat | Caractere | Formato do arquivo | `"XML"` | |
| cFilExec | Caractere | Filial de execução (XX4_FILEXE) | | |

**Retorno:** Lógico.

```advpl
oHelper:UTEAIReceive( 'FINA010' )
```

### UTExecEAI( cCodigo, cTestCase, cFormat, aReplaceX )

Executa mensagem única de RECEBIMENTO.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cCodigo | Caractere | Código de busca (XX3_UUID) | X |
| cTestCase | Caractere | Nome do caso de teste (para gerar baseline) | |
| cFormat | Caractere | Formato do arquivo | |
| aReplaceX | Array | Substitui valor entre strings | |

**Retorno:** Lógico.

```advpl
oHelper:UTExecEAI( "9000000000000000000037785" )
```

### UTVldEAI( cProgram, cTestCase, cFormat, aReplaceX, cFilExec, nPosition )

Compara o XML gerado na mensagem única de ENVIO.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProgram | Caractere | Nome do adapter | | X |
| cTestCase | Caractere | Nome do caso de teste | | X |
| cFormat | Caractere | Formato do arquivo | `"XML"` | |
| aReplaceX | Array | Substitui entre strings | | |
| cFilExec | Caractere | Filial de execução | | |
| nPosition | Numérico | Registro a coletar (0 = último incluído) | `0` | |

**Retorno:** Lógico.

> Requer `UTEAIActivate` previamente configurado.

```advpl
oHelper:UTEAIActivate( 'FINA010' )
oHelper:UTCommitData( {|x,y| FINA010(x,y)}, oHelper:GetaCab(), 3 )
oHelper:UTVldEAI( 'FINA010', 'FIN010_001' )
oHelper:AssertTrue(oHelper:lOk,"")
```

---

## SmartLink

### UTGetTenantID( cInteg )

Configura credenciais do TOTVS RAC e retorna Tenant ID da fila do SmartLink.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cInteg | Caractere | Nome da integração (ex: `"GESPLAN"`, `"CONTA DIGITAL"`) | X |

**Retorno:** `cTenantId` (Caractere).

```advpl
oHelper:UTGetTenantID("GESPLAN")
```

### UTSetConfigSendSmtLink( cInteg )

> Disponível com LIB >= 20230626.

Seta a configuração do TenantId e credenciais de envio para a fila do SmartLink, após validar que a fila está vazia. Usar quando o envio ocorre na rotina (não no teste).

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cInteg | Caractere | Nome da integração | X |

**Retorno:** `lRet` (Lógico).

```advpl
oHelper:UTSetConfigSendSmtLink("CONTA DIGITAL")
```

### UTReadSmtLink( cInteg )

> Disponível com LIB >= 20230626.

Inicia o Job de leitura das mensagens da fila do SmartLink.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cInteg | Caractere | Nome da integração | X |

**Retorno:** `lRet` (Lógico).

```advpl
oHelper:UTReadSmtLink("CONTA DIGITAL")
```

### UTExecSmtLink( cTypeMessage, cMessage, cAudience )

> Disponível com LIB >= 20230626.

Verifica status da fila, remove mensagens travadas, envia mensagem do teste e inicia leitura.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTypeMessage | Caractere | Tipo da mensagem | X |
| cMessage | Caractere | Corpo da mensagem | X |
| cAudience | Caractere | Audiência da mensagem | |

```advpl
oHelper:UTExecSmtLink( cTypeMessage, cMessage, cAudience )
```

> A partir da LIB 20240224, os jobs de subida/descida automáticos serão derrubados para o correto processamento.

**Configuração local** (`appserver.ini`):

```ini
[ADVPR]
TENANTID_SMTLINK=<tenant Id>
CLIENTID_SMTLINK_SEND=<client ID de envio>
CLIENTSECRET_SMTLINK_SEND=<client secret de envio>
CLIENTID_SMTLINK_READ=<client ID de leitura>
CLIENTSECRET_SMTLINK_READ=<client secret de leitura>
```

### UTVldSmtLink( cTestCase, aTagIgnore, aReplaceX )

> Disponível com LIB >= 20230626.

Compara o retorno das mensagens do SmartLink processadas pelo Protheus.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cTestCase | Caractere | Nome do TestCase para geração do arquivo | | X |
| aTagIgnore | Array | Tags ignoradas na validação (`{{"tag"," "}}`) | `{{"time"," "},{"tenantID"," "}}` | |
| aReplaceX | Array | Substituição entre strings | | |

```advpl
oHelper:UTVldSmtLink("C102XG_003")
```

---

## Smart View

### UTParamSmartView( cParam, xValue )

Informa parâmetros de relatório do Smart View, conforme definidos na fonte de dados do design.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cParam | Caractere | Nome do parâmetro do relatório | X |
| xValue | Indefinido | Conteúdo do parâmetro | X |

> Para parâmetros do tipo data, usar `totvs.framework.treports.date.stringToTimeStamp`.

```advpl
oHelper:UTParamSmartView("processo","00012")
oHelper:UTParamSmartView("periodo", totvs.framework.treports.date.stringToTimeStamp("20220121"))
oHelper:UTParamSmartView("filialDe","M PR 02")
```

### UTGenerateSmartView( cReport, cFileName, cType )

Gera relatórios utilizando Smart View a partir do Objeto de Negócios e arquivo `.trp` compilado.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cReport | Caractere | Nome do relatório (mesmo nome do `.trp` sem extensão) | | X |
| cFileName | Caractere | Nome do arquivo do caso de teste (gerado na pasta spool como `.csv`) | | X |
| cType | Caractere | Tipo de dado: `"report"`, `"data-grid"` ou `"pivot-table"` | `"report"` | |

> Para ambiente local: configurar `URL_SMARTVIEW` na seção `[ADVPR]` do `appserver.ini`.

```advpl
oHelper:UTGenerateSmartView("RELATORIO_FOLHA_FECHADA","RELATORIO_FOLHA_FECHADA_001")
```

### UTCompareSmartView( cFileName, aReplace, aReplaceX, lUpdateFile )

Compara o relatório gerado no Smart View com baseline.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cFileName | Caractere | Nome do arquivo do caso de teste | | X |
| aReplace | Array | Substituição de strings (`{{"Original","Novo"}}`) | `{}` | |
| aReplaceX | Array | Substituição entre strings (`{{"Início","Fim","Novo"}}`) | `{}` | |
| lUpdateFile | Lógico | Altera o arquivo autogerado após replaces | `.F.` | |

```advpl
aadd(aReplace,{"01/01/2016 até 31/01/2016","01/01/2023 até 31/01/2023"})
oHelper:UTCompareSmartView("RELATORIO_FOLHA_FECHADA_001",aReplace,aReplaceX,.T.)
```

### UTSchemaSmartView( cNameSpace, cBusinessObject, cFile, aReplace, aIgnoreProperty, lIgnoreNewProperty )

Gera e valida o Schema do objeto de negócios utilizado no Smart View.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cNameSpace | Caractere | Namespace do objeto de negócios | | X |
| cBusinessObject | Caractere | Nome da classe do objeto | | X |
| cFile | Caractere | Nome do arquivo do caso de teste | | X |
| aReplace | Array | Tags do JSON a serem alteradas | `{}` | |
| aIgnoreProperty | Array | Propriedades dinâmicas a ignorar | | |
| lIgnoreNewProperty | Lógico | Ignora novas propriedades no JSON | `.F.` | |

```advpl
oHelper:UTSchemaSmartView(cNameSpace, cBusinessObject, "OBJEST_001",, aIgnoreProperty, .T.)
```

### UTGetDataSmartView( cNameSpace, cBusinessObject, cFile, aReplace, jFilter )

Gera e valida o Data do objeto de negócios. Usar `UTParamSmartView` para informar parâmetros.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cNameSpace | Caractere | Namespace do objeto | | X |
| cBusinessObject | Caractere | Nome da classe | | X |
| cFile | Caractere | Nome do arquivo do caso de teste | | X |
| aReplace | Array | Tags do JSON a serem alteradas | `{}` | |
| jFilter | JSON | Filtro no formato JSON (expressão do Smart View) | | |

```advpl
oHelper:UTParamSmartView("MV_PAR01", {""})
oHelper:UTParamSmartView("MV_PAR02", {"ZZ"})
oHelper:UTGetDataSmartView(cNameSpace, cBusinessObject, "OBJEST_002")
```

### UTCustomSmartView( cNameSpace, cBusinessObject, cTable, cField, cName, cDescri, cType )

Adiciona campos personalizáveis do Smart View (FW_SV_CUSTOM).

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cNameSpace | Caractere | Namespace do objeto | X |
| cBusinessObject | Caractere | Classe do objeto | X |
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo | X |
| cName | Caractere | Nome do campo personalizado | X |
| cDescri | Caractere | Descrição do campo | X |
| cType | Caractere | Tipo do campo | X |

```advpl
oHelper:UTCustomSmartView(cNameSpace,cBusinessObject,"SN3","N3_CLVLDES","Clvl Cor.Dep","Classe de Vlr Cor. Depr.","string")
```

### UTRemoveCustomSmartView( cNameSpace, cBusinessObject, cTable, cField, cName, cDescri, cType )

Remove campos personalizáveis do Smart View (FW_SV_CUSTOM). Mesmos parâmetros de `UTCustomSmartView`.

### UTSetSVConfig()

Realiza a configuração da URL do Smart View.

**Retorno:** `oHelper:lOk` (Lógico).

```advpl
oHelper:UTSetSVConfig()
oHelper:UTCommitData({|| ESTSV023()})
```

---

## Audit Trail

### UTAuditField( cTable, cField )

Configura auditoria de um campo específico via Audit Trail. Deve ser colocado logo após `Activate()`.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo a ser auditado | X |

> Para múltiplos campos, repetir o método. Usar junto com `UTCheckAudit`.

```advpl
oHelper:Activate()
oHelper:UTAuditField("SE1","E1_NUM")
oHelper:UTAuditField("SE1","E1_TIPO")
```

### UTAuditNoField( cTable, cField )

Audita tabela inteira exceto um campo. Deve ser colocado logo após `Activate()`.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo a NÃO auditar | X |

```advpl
oHelper:UTAuditNoField("SE1","E1_NUM")
oHelper:UTAuditNoField("SE1","E1_TIPO")
```

### UTAuditTable( cTable )

Audita uma tabela inteira. Deve ser colocado logo após `Activate()`.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela | X |

```advpl
oHelper:UTAuditTable("SE1")
oHelper:UTAuditTable("SE2")
```

### UTCheckAudit( cRptName, lUseTxt, lConvAcent, cOrder )

Extrai dados das tabelas de auditoria e compara com arquivo base. Deve ser usado após o commit e em conjunto com `UTAuditField`, `UTAuditNoField` ou `UTAuditTable`.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cRptName | Caractere | Nome do relatório | | X |
| lUseTxt | Lógico | `.T.` = comparação via TXT (mais rápida); `.F.` = via relatório | `.T.` | |
| lConvAcent | Lógico | Converte acentos | `.T.` | |
| cOrder | Caractere | Chave de ordenação dos registros | `"TTAT_DTIME,TTAT_RECNO,TTAT_OPERATI,TTAT_FIELD"` | |

> Se comparação via TXT, o arquivo base fica na pasta `baseline`. Se via relatório, fica na pasta `spool`.

```advpl
oHelper:UTCommitData({|x,y| FINA040(x,y)}, oHelper:GetaCab(), 3)
oHelper:UTCheckAudit("FINA040_001")
oHelper:AssertTrue(oHelper:lOk,"")
```

---

## Autocontidas e SIGAMAT

### UTAlterAutoCont( cTable, nOrder, cSeek, aData )

Altera campo em tabela autocontida (que são sempre recriadas nos appends).

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cTable | Caractere | Nome da tabela autocontida | X |
| nOrder | Numérico | Índice de busca | X |
| cSeek | Caractere | Chave de pesquisa | X |
| aData | Array | Valor de preenchimento (`{ campo, valor }`) | X |

> Sempre restaurar com `UTRestAutoCont()` antes de finalizar.

```advpl
oHelper:UTAlterAutoCont( 'CC2', 1, "GO" + "14804", { { "CC2_PERMAT", 25 } } )
// ... operações ...
oHelper:UTRestAutoCont()
```

### UTRestAutoCont()

Restaura as alterações efetuadas na tabela autocontida.

```advpl
oHelper:UTRestAutoCont()
```

### UTAlterSM0( cAltFil, cCampo, xValue )

Altera um campo no SIGAMAT do sistema.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cAltFil | Caractere | Grupo de empresa + filial a ser alterada | X |
| cCampo | Caractere | Nome do campo | X |
| xValue | Indefinido | Conteúdo a ser alterado | X |

> Restaurar com `UTRestSM0()` após utilização.

```advpl
oHelper:UTAlterSM0("T1X TSS02", "M0_ESTCOB", "SP")
```

### UTRestSM0( aSM0 )

Restaura a filial/SIGAMAT.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| aSM0 | Array | Array de volta dos campos do SIGAMAT | X |

```advpl
oHelper:UTRestSM0( oHelper:aSM0 )
```

---

## Arquivos e Comparação

### UTArqCompare( cPath, cFileModel, cFileTest, cIdLinha, aReplace, lConvAcent, aReplaceX, lFullNoAcent )

Compara arquivo inteiro ou parcial com baseline.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cPath | Caractere | Caminho dos arquivos | StartPath do Protheus | |
| cFileModel | Caractere | Nome do arquivo modelo | `"Arquivo_001_Model.txt"` | X |
| cFileTest | Caractere | Nome do arquivo gerado pelo teste | `"Arquivo_001"` | X |
| cIdLinha | Caractere | Linha em que ocorrerá o replace | `""` | |
| aReplace | Array | De/Para de alteração de string | `{}` | |
| lConvAcent | Lógico | Converter acentos | `.T.` | |
| aReplaceX | Array | Substitui entre strings (`{{"TagInicial","TagFinal","Conteudo"}}`) | `{}` | |
| lFullNoAcent | Lógico | Conversão por string ou por caractere | `.F.` | |

```advpl
Aadd( aReplace, { "01112016", "03102016" } )
oHelper:UTArqCompare( "", cArqTest, cArqModel, "|E350", aReplace )
```

### UTLoadBody( cJson, lTrimLine )

Lê um arquivo da pasta `baseline`.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cJson | Caractere | Nome do arquivo com extensão | | X |
| lTrimLine | Lógico | Faz `AllTrim` na leitura das linhas | `.T.` | |

**Retorno:** Conteúdo do arquivo (Caractere).

```advpl
Local cJson := oHelper:UTLoadBody("ADVPR001.txt")
```

### UTCreateFile( cContent, cFileName, cPath )

Cria arquivo em pasta especificada.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cContent | Caractere | Conteúdo do arquivo | | X |
| cFileName | Caractere | Nome + extensão (se existir, será recriado) | | X |
| cPath | Caractere | Local de geração | `"baseline"` | |

**Retorno:** `lRet` (Lógico).

```advpl
oHelper:UTCreateFile("Conteúdo do arquivo","Nome.txt")
```

### TabForTxt( cPath, nExtensao, nTipo, aTables )

Converte dados de tabelas para arquivo de texto.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cPath | Caractere | Caminho para salvar o arquivo | | X |
| nExtensao | Numérico | Extensão (1=TXT; 2=CSV) | `1` | |
| nTipo | Numérico | Tipo (1=Modelo; 2=Teste) | `1` | |
| aTables | Array | Tabelas a serem geradas | | X |

```advpl
TabForTxt( cPath, 2, 2, { "SA1" } )
```

### Txt2Array( cArqTxt, cCond, aReplace )

Transforma um arquivo texto em array.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cArqTxt | Caractere | Nome do arquivo TXT | X |
| cCond | Caractere | Condição de aglutinação | X |
| aReplace | Array | Retorno do arquivo transformado em array | |

```advpl
aArqModel := Txt2Array( cArqModel, "|T001" )
```

---

## Utilitários

### UTPutError( cError )

Inclui um erro manualmente.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cError | Caractere | Mensagem de erro | X |

```advpl
oHelper:UTPutError("Problemas na estrutura da tabela TAFST1")
oHelper:AssertTrue( .F., "" )
```

### UTStartTimer( cOperation )

Marca o início da contagem de tempo de uma operação.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cOperation | Caractere | Identificação do timer | `"Default"` | |

```advpl
oHelper:UTStartTimer( 'TESTE 001' )
```

### UTStopTimer( cOperation )

Marca o final da contagem de tempo.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cOperation | Caractere | Identificação do timer | `"Default"` | |

```advpl
oHelper:UTStopTimer( 'TESTE 001' )
```

### GetReleaseRobo()

Verifica o conteúdo do `advpr.ini` para identificar o release do ambiente Protheus.

```advpl
If oHelper:GetReleaseRobo() >= "12.1.19"
    ::AddTestMethod("MAT030_001",,"Caso de teste 001")
EndIf
```

### EnvUpdExp()

Verifica o tipo de Base Congelada utilizada.

**Retorno:** Lógico — `.F.` quando for base MNT.

```advpl
If oHelper:EnvUpdExp()
    ::AddTestMethod("GPR010_001",,"Benefícios por Entidade")
EndIf
```

### ConvAcento( cString )

Converte caracteres com acento.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cString | Caractere | String a ser convertida | X |

```advpl
cRet := ConvAcento( cString )
```

### Conv2Hex( cChar )

Converte caractere em hexadecimal.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cChar | Caractere | Caractere a ser convertido | X |

```advpl
cRet := Conv2Hex( cChar )
```

### UTSerieID( cTabela, cCampo, cEspecie, cSerie )

Verifica novo formato de gravação do ID nos campos `_SERIE`.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cTable | Caractere | Tabela a ser validada | `""` | X |
| cCampo | Caractere | Campo a ser validado | `""` | X |
| cEspecie | Caractere | Espécie da nota | `""` | |
| cSerie | Caractere | Série da nota | `""` | |

```advpl
cSerieId := oHelper:UTSerieID( 'SF1', 'F1_SERIE', cEspecie, cSerie )
```

### GeraChvNfe( cUFEmi, cAAMMEmi, cCnpjEmi, cModeloNf, cSerieNf, cNumNf )

Gera chave do documento fiscal (NF-e).

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cUFEmi | Caractere | Código UF emitente | X |
| cAAMMEmi | Caractere | Ano/mês emissão (AAMM) | X |
| cCnpjEmi | Caractere | CNPJ emitente | X |
| cModeloNf | Caractere | Modelo do documento fiscal | X |
| cSerieNf | Caractere | Série do documento fiscal | X |
| cNumNf | Caractere | Número do documento fiscal | X |

```advpl
oHelper:GeraChvNfe('33','1809','00000000001082','57','001','000000001')
```

### UTAtzPsw()

Atualiza o `SIGAPSS.spf` de acordo com o backup da base congelada.

```advpl
oHelper:UTAtzPsw()
```

### UTDelPsw()

Apaga o `SIGAPSS.SPF`.

```advpl
oHelper:UTDelPsw()
```

---

## Telnet

### UTSetKey( cCommand1, cCommand2 )

Envia teclas (ações) do teclado para scripts via comunicação Telnet.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cCommand1 | Caractere | Tecla de comando (ex: `"ENTER"`) | X |
| cCommand2 | Caractere | Tecla auxiliar (ex: `"X"` para CTRL+X) | |

**Teclas válidas:**

| Tecla | Código |
|-------|--------|
| Backspace | `{BACKSPACE}`, `{BKSP}`, `{BS}` |
| Break | `{BREAK}` |
| Caps Lock | `{CAPSLOCK}` |
| Delete | `{DELETE}`, `{DEL}` |
| Down Arrow | `{DOWN}` |
| End | `{END}` |
| Enter | `{ENTER}`, `~` |
| Escape | `{ESC}` |
| Home | `{HOME}` |
| Insert | `{INSERT}`, `{INS}` |
| Left Arrow | `{LEFT}` |
| Page Down | `{PGDN}` |
| Page Up | `{PGUP}` |
| Right Arrow | `{RIGHT}` |
| Tab | `{TAB}` |
| Up Arrow | `{UP}` |
| F1–F16 | `{F1}` ... `{F16}` |

```advpl
oHelper:UTSetKey("ENTER")
oHelper:UTSetKey("CTRL","X")
```

### UTInputValue( cValue )

Envia dados digitados para scripts Telnet.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cValue | Caractere | Valor digitado | X |

```advpl
oHelper:UTInputValue("Admin")
oHelper:UTInputValue("Avenida Braz Leme")
```

### UTExecTelNet( cScript )

Executa scripts VBS para comunicação Telnet.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cScript | Caractere | Nome do caso de teste | X |

> Requer Python 3.7.9.

```advpl
oHelper:UTExecTelNet("ACD010_001")
```

---

## Mock Server

### UTSetRouteMock( cRoute, cSubRoute, lRegistry )

Seta a rota do server mock para testes de APIs e integrações.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cRoute | Caractere | Rota do módulo/produto no server mock | | X |
| cSubRoute | Caractere | Sub-rota (para mockar serviço com retorno diferente) | | |
| lRegistry | Lógico | Configura chaves do Registry no `appserver.ini` com endereço do mock | `.F.` | |

**Retorno:** `lRet` (Lógico).

> Para mock server local: configurar chave `SERVER_MOCK` na seção `[ADVPR]` com `http://ip:porta`.

```advpl
oHelper:UTSetRouteMock("techfin",,.T.)
```

### UTGetRouteMock()

Captura a URL do server mock com rota configurada.

**Retorno:** `cURLServerMock` (Caractere).

```advpl
cMockServer := oHelper:UTGetRouteMock()
oHelper:UTSetParam( "MV_RSKPLAT", cMockServer, .T. )
```

### UTRestRegistry()

Restaura no `.ini` o conteúdo original das chaves do Registry atualizadas por `UTSetRouteMock`.

**Retorno:** `lRet` (Lógico).

```advpl
oHelper:UTCommitData({|x| RskPostConcession(x)}, EndPoint)
oHelper:UTRestRegistry()
```

---

## Procedures (SPS)

### UTEngSPSInstall( cProcess, cCompany, cOrigin )

Instala um processo de procedures em uma empresa.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProcess | Caractere | Código do processo | | X |
| cCompany | Caractere | Grupo de empresa | Empresa logada | |
| cOrigin | Caractere | Origem do pacote | `"RPO"` | |

**Retorno:** `oHelper:lOk` (Lógico).

```advpl
oHelper:UTEngSPSInstall("01", "T1")
```

### UTEngSPSUninstall( cProcess, cCompany )

Desinstala um processo de procedures.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProcess | Caractere | Código do processo | | X |
| cCompany | Caractere | Grupo de empresa | Empresa logada | |

**Retorno:** `oHelper:lOk` (Lógico).

```advpl
oHelper:UTEngSPSUninstall("01", "T1")
```

### UTEngSPSBatch( cAction )

Instalação/desinstalação em lote de todos os processos em todas as empresas.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cAction | Caractere | `"1"` = Instalação; `"2"` = Remoção | X |

**Retorno:** `oHelper:lOk` (Lógico).

```advpl
oHelper:UTEngSPSBatch("1")
```

### UTEngSPSStatus( cProcess, cCompany )

Retorna o status do processo na empresa.

| Parâmetro | Tipo | Descrição | Default | Obrigatório |
|-----------|------|-----------|---------|:-----------:|
| cProcess | Caractere | Código do processo | | X |
| cCompany | Caractere | Grupo de empresa | Empresa logada | |

**Retorno:** Objeto JSON com as propriedades: `status`, `process`, `company`, `version`, `signature`, `idsps`, `generation`, `error`.

```advpl
oSPSStatus := oHelper:UTEngSPSStatus("02","T1")
```

---

## Outros

### UTXMLReplace( cXml, cPath, cReplace, lEncode64 )

Substitui o valor de um atributo do XML.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cXml | Caractere | String com o XML | X |
| cPath | Caractere | Caminho do atributo a buscar/substituir | X |
| cReplace | Caractere | Conteúdo de substituição | X |
| lEncode64 | Lógico | Se o conteúdo deve ser gravado em base64 | X |

**Retorno:** XML modificado.

```advpl
cNewXml := UTXMLReplace(cXml, "/infNFe/ide/serie", "1", .F.)
```

### UTXMLGETVALUE( cXml, cPath, lEncode64 )

Obtém valor de uma tag do XML.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cXml | Caractere | String com o XML | X |
| cPath | Caractere | Caminho do atributo | X |
| lEncode64 | Lógico | Se o conteúdo está em base64 | X |

```advpl
cPath := "SOAPENV:ENVELOPE/SOAPENV:BODY/NFS:SCHEMA/NFS:NFE/NFS:NOTAS/NFS:NFES/NFS:XML"
cNewXml := UTXMLGETVALUE(cXml, cPath, .T.)
```

### UTTSSNFE( cXml, cPath, aReplace )

Substitui valores dinâmicos no XML de NFE do TSS dentro do cliente.

| Parâmetro | Tipo | Descrição | Obrigatório |
|-----------|------|-----------|:-----------:|
| cXml | Caractere | String com o XML | X |
| cPath | Caractere | Caminho do atributo | X |
| aReplace | Array | Atributos a substituir dentro do cPath | X |

```advpl
aAdd(aReplace, {"/infNFe/ide/serie","1", .F.})
cPath := "SOAPENV:ENVELOPE/SOAPENV:BODY/NFS:SCHEMA/NFS:NFE/NFS:NOTAS/NFS:NFES/NFS:XML"
UTTSSNFE(cXml, cPath, aReplace)
```
