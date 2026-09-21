# Padrão do Script AdvPR — `{Rotina}TestCase.PRW`

Regras para implementar o método do caso de teste depois que o Kanoah já foi gravado. O script é a tradução direta do Kanoah: cada pré-condição, passo e resultado esperado tem um equivalente em `FWTestHelper`.

Consulte [FWTestHelper.md](FWTestHelper.md) para a API completa. Nunca invente método do helper.

---

## Nomenclatura do método

Prefixo de **6 caracteres** (3 primeiras letras do prefixo do módulo + os 3 dígitos da rotina) + `_` + número do CT com 3 dígitos.

| Rotina | Prefixo | Método do CT007 |
|---|---|---|
| `CNTA311` | `CNT311` | `CNT311_007` |
| `CNTA090` | `CNT090` | `CNT090_007` |
| `CNTR030` | `CNT030` | `CNT030_007` |
| `MATA120GCT` | `MATA120` | `MATA120_007` |

- Rotinas com sufixo de módulo (`MATA120GCT`) mantêm o código base da rotina (`MATA120`) como prefixo.
- A série **9xx** (`CNT311_901`) é reservada a testes unitários de classes TLPP. Não use para caso de teste funcional.
- Métodos auxiliares de testes unitários usam nomes curtos (`C901DFT`, `C902SUC`) e **não** são registrados em `AddTestMethod`.

---

## Três pontos de edição no arquivo

O `{Rotina}TestCase.PRW` exige alteração em três lugares. Esquecer qualquer um deles faz o caso de teste não executar.

### 1. Declaração no bloco da classe

```advpl
CLASS CNTA311TestCase from FWDefaultTestCase
	DATA oHelper
	METHOD SetUpClass()

	METHOD CNTA311TestCase() CONSTRUCTOR
	METHOD CNT311_001()
	METHOD CNT311_002()
	...
	METHOD CNT311_007()   // <-- novo método, na sequência numérica
ENDCLASS
```

### 2. Registro no construtor

```advpl
METHOD CNTA311TestCase() CLASS CNTA311TestCase
	_Super:FWDefaultTestSuite()

	::AddTestMethod("CNT311_001",,"Caso de teste CT001")
	...
	::AddTestMethod("CNT311_007",,"CT007 - Reajusta contrato aplicando o índice acumulado do período na revisão")
Return
```

A descrição deve citar o `CTxxx` e o cenário validado — é o que aparece no relatório de execução e o único lugar onde a intenção do teste fica legível sem abrir o Kanoah.

### 3. Implementação

Ao final do arquivo, respeitando a ordem numérica dos métodos existentes. Métodos funcionais antes da série 9xx.

---

## Template do método

```advpl
/*/{Protheus.doc} CNT311_007
	CT007 - Testa o reajuste automático aplicando o índice acumulado do período na revisão gerada.
@author {email do autor}
@since {dd/mm/aaaa}
@version 12.1.2510
@return oHelper, instancia de FwTestHelper
/*/
METHOD CNT311_007() CLASS CNTA311TestCase
	Local oHelper	:= FWTestHelper():New()
	Local oModel	:= Nil
	Local cTable	:= ""
	Local cQuery	:= ""
	Local cContra	:= 'GCT_CN310_CT007'

	//-- Pré-condições: filial, data base e parâmetros
	oHelper:ChangeFil("D MG 01 ")
	dDataBase := cTod("01/02/2018")
	oHelper:UTSetParam("MV_CNRJREV", .T., .T.)

	oModel := FWLoadModel('CNTA310')
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oHelper:SetModel(oModel)
	oHelper:Activate()

	//-- Passos: parâmetros do pergunte CN310
	oHelper:UTChangePergunte("CN310","01", cContra)
	oHelper:UTChangePergunte("CN310","08", '20180301')
	oHelper:UTChangePergunte("CN310","09", '20180301')
	oHelper:UTChangePergunte("CN310","10", '018')
	CN310Perg() //-- Realiza o reajuste automático

	oHelper:UTCommitData()

	//-- Resultado esperado: contrato
	cTable := "CN9"
	cQuery := "CN9_NUMERO = '"+cContra+"' AND CN9_REVISA = '001'"
	oHelper:UTQueryDB(cTable,'CN9_SITUAC',cQuery, '05')
	oHelper:UTQueryDB(cTable,'CN9_VLATU' ,cQuery, 13050)
	oHelper:UTQueryDB(cTable,'CN9_DTREAJ',cQuery, Ctod('01/03/2018'))
	oHelper:AssertTrue(oHelper:lOk,'CT007 - contract adjusted value must reflect the accumulated index')

	//-- Resultado esperado: planilha
	cTable := "CNA"
	cQuery := "CNA_CONTRA = '"+cContra+"' AND CNA_REVISA = '001' AND CNA_NUMERO = '000001'"
	oHelper:UTQueryDB(cTable,'CNA_VLTOT' ,cQuery, 13050)
	oHelper:AssertTrue(oHelper:lOk,'CT007 - worksheet total must follow the adjusted contract value')

	//-- Restaura o ambiente
	dDataBase := DATE()
	oHelper:UTRestParam(oHelper:aParamCT)

Return oHelper
```

---

## Tradução Kanoah → código

| Seção do Kanoah | Equivalente no script |
|---|---|
| Filial de abertura | `oHelper:ChangeFil("D MG 01 ")` |
| Data base | `dDataBase := cTod("dd/mm/aaaa")` |
| Parâmetros (`MV_XXXX`) | `oHelper:UTSetParam("MV_XXXX", <valor>, .T.)` |
| Perguntas (SX1) | `oHelper:UTChangePergunte("<GRUPO>","<nn>", <valor>)` |
| Registro da Base Congelada | variável local com o código padronizado (`cContra := 'GCT_CN310_CT007'`) |
| Passo com rotina MVC | `FWLoadModel(...)` + `SetOperation(...)` + `Activate()` + `oHelper:SetModel(oModel)` |
| Preenchimento de campo | `oHelper:UTSetValue(...)` |
| Confirmação da operação | `oHelper:UTCommitData()` |
| Resultado em tabela/campo | `oHelper:UTQueryDB(cTable, 'CAMPO', cQuery, <valor esperado>)` |
| Fechamento de cada bloco de verificação | `oHelper:AssertTrue(oHelper:lOk, '<mensagem em inglês>')` |
| Mensagem de sistema esperada | verificar o help/retorno conforme a API disponível no `FWTestHelper`; se não houver, marcar como verificação manual |
| Legenda no Browse / conferência visual | não automatizável — marcar como verificação manual |

Regras de conteúdo:

- Mensagens de assert em **inglês**, citando o CT e o comportamento validado. Assert com mensagem vazia (`''`) existe no legado, mas não deve ser usado em código novo.
- Verifique apenas os campos que constam no `Expected Result` do Kanoah. Verificação extra dispersa a análise da falha.
- Datas comparadas com `Ctod('dd/mm/aaaa')`; valores monetários como numérico puro (`13050`).
- Um bloco `cTable`/`cQuery` + `UTQueryDB`s + `AssertTrue` por entidade verificada, para localizar a falha rapidamente.
- Restaure sempre o ambiente antes do `Return oHelper`: `dDataBase := DATE()` e `oHelper:UTRestParam(oHelper:aParamCT)`. Se o método trocou a filial, restaure a filial de origem.

---

## Convenções de estilo do arquivo legado

Os `TestCase.PRW` do módulo seguem convenções próprias que devem ser preservadas — consistência com o arquivo vale mais que preferência pessoal:

- Indentação com **tabulação**.
- Palavras reservadas em `Local`, `METHOD`, `CLASS`, `Return` conforme o arquivo já usa.
- `Local` com inicialização direta, sem cláusula `as` (padrão do arquivo). Se optar por tipar, declare o tipo em uma linha e inicialize em outra — em `.prw` é proibido combinar tipagem e inicialização na mesma linha.
- Bloco `Protheus.doc` antes de cada método, com `@author`, `@since`, `@version` e `@return`.
- Comentários em pt-BR com acentuação correta.

---

## Quando o `{Rotina}TestCase.PRW` não existe

Crie o trio completo, usando `CNTA311TestCase.PRW`, `CNTA311TestGroup.PRW` e `CNTA311TestSuite.PRW` como modelo canônico:

| Arquivo | Responsabilidade |
|---|---|
| `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW` | classe `FROM FWDefaultTestCase`, construtor com `AddTestMethod`, `SetUpClass()` retornando `FWTestHelper():New()`, métodos dos CTs |
| `tests/Scripts AdvPR/Group/{Rotina}TestGroup.PRW` | classe `FROM FWDefaultTestSuite` com `Self:AddTestCase({Rotina}TestCase():{Rotina}TestCase())` |
| `tests/Scripts AdvPR/Suite/{Rotina}TestSuite.PRW` | classe `FROM FWDefaultTestSuite` com `SetUpSuite()` (`UTOpenFilial`, `UTSetParam`, `Activate`, `UTLoadData`) e `TearDownSuite()` (`UTRestParam`, `UTCloseFilial`) |

Adicionar um método a um arquivo existente **não** exige alteração no Group nem no Suite.

Arquivos de continuação (`{Rotina}BTestCase.PRW`) existem quando o arquivo principal fica grande demais. Eles entram no cálculo da numeração, mas o método novo vai no arquivo principal, salvo orientação explícita do usuário — o arquivo de continuação pode estar desativado no Group.

---

## Encoding e compilação

1. O arquivo é `.PRW` → deve permanecer em **Windows-1252 (CP1252), sem BOM**. Ferramentas de edição gravam UTF-8 por padrão.
2. Após editar, acione a skill `utf8-to-cp1252-conversion`.
3. Confirme que a acentuação dos comentários existentes não foi corrompida: acentos devem ocupar **um** byte (`ç` = `0xE7`, `ã` = `0xE3`); ausência de BOM `EF BB BF` no início.
4. Pergunte ao usuário se deseja compilar. Em caso afirmativo, acione `advpl-tlpp-compile`. Compilação bem-sucedida registra `[Info] All files compiled successfully.`
5. Se houver erro, analise a causa raiz, corrija o fonte e repita — nunca declare concluído com erro de compilação pendente.

---

## Checklist do script

- [ ] Método declarado no bloco `CLASS ... ENDCLASS`.
- [ ] Método registrado em `::AddTestMethod` com descrição citando o `CTxxx`.
- [ ] Método implementado na ordem numérica correta, antes da série 9xx.
- [ ] Nome do método segue o prefixo de 6 caracteres + `_NNN`.
- [ ] Pré-condições do Kanoah refletidas em `ChangeFil` / `dDataBase` / `UTSetParam` / `UTChangePergunte`.
- [ ] Todos os campos do `Expected Result` verificados com `UTQueryDB`.
- [ ] `AssertTrue` com mensagem em inglês por bloco de verificação.
- [ ] Ambiente restaurado antes do `Return oHelper`.
- [ ] `Return oHelper` presente.
- [ ] Nenhum método de `FWTestHelper` usado sem constar em `FWTestHelper.md`.
- [ ] Arquivo em CP1252 sem BOM, acentuação preservada.
- [ ] Compilação oferecida e, se executada, sem erros.
