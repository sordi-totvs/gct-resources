# mBrowse — Abertura do browse utilizando Smart X

> Transcrição em Markdown da página do TDN "mBrowse - Abertura do browse utilizando
> Smart X" (espaço "5. Desenvolvimento com Smart X"), criada por Julio Cesar Correia
> Teixeira, última alteração em 05/10/2026. Rótulos da página: `documento_tecnico`,
> `smartx`.
>
> Notas de transcrição estão marcadas como **[Nota de transcrição]** e não fazem parte
> do documento original. Quando houver dúvida sobre o comportamento, a fonte de verdade
> é a documentação oficial (MCP `advpl-tlpp-mcp-docs`, tools `smartx-docs-search` e
> `language-system-docs-search`).

O Smart X traz uma nova experiência de visualização de dados (Browse) e formulários,
pensada na experiência de usabilidade, interface e disponibilização de novos recursos
modernos. Devido à sua modularidade, é possível utilizar suas operações (visualização
de dados, inclusão, edição, visualização e deleção) de forma segmentada, sem precisar
usar todas as funcionalidades em conjunto.

Para disponibilizar esses recursos para rotinas já existentes de forma simples, os
recursos de visualização de dados (Data View) do Smart X foram implementados na função
`mBrowse`, permitindo a utilização desse recurso com pouca interação.

## Pré-requisitos

- Ambientes produtivos: funcionamento a partir da **Release 12.1.2610**.
- Ambientes de desenvolvimento interno: necessário o uso do **RPO D-1**.

## Habilitando a nova visualização de dados (Browse)

No fonte onde a função `mBrowse` é chamada, defina a utilização do novo browse através
da função `SetSmartX()`.

> **Atenção — SetSmartX:** a função `SetSmartX` deve estar **no mesmo fonte e na mesma
> função** onde ocorre a chamada do `mBrowse`. Caso não esteja, será gerada exceção.

### Função SetSmartX

**Sintaxe**

```
SetSmartX(<nIndex>, <lOrderAsc>) -> NIL
```

**Descrição:** função de ativação da conversão de `mBrowse` para browse Smart X.

**Parâmetros**

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| `nIndex` | Numérico | Número do índice a ser utilizado na ordenação inicial. A utilização de um índice inexistente causará exceção. O índice `0` indica ordenação pelo `RECNO`. | | Não |
| `lOrderAsc` | Lógico | Indica a ordenação: `.T.` = ASC e `.F.` = DESC. | `.T.` | Não |

### Exemplo

```advpl
#include "protheus.ch"
#include "fwmbrowse.ch"

Function MEUFONTMVC()

    local aLegendas as array
    local cFilterDefault as character
    local nIndex as numeric
    local lOrderAsc as logical

    cFilterDefault := "@ ZA0_TIPO IN ('1','2')"

    aLegendas := {}
    aAdd(aLegendas,{"ZA0_TIPO=='1'", "YELLOW", "Teste"})
    aAdd(aLegendas,{"ZA0_TIPO=='2'", "GREEN", "Interprete",,,"color-12"})

    If hasSmartX() // Proteção para garantir que o ambiente atende os pré-requisitos
        nIndex := 2 //ZA0_FILIAL+ZA0_NOME
        lOrderAsc := .T.
        setSmartX( nIndex, lOrderAsc ) // Chamada que define a utilização do browse Smart X
    EndIf

    mBrowse(,,,,"ZA0",,,,,,aLegendas,,,,,,,,cFilterDefault)

    FwFreeArray(aLegendas)

Return Nil
```

> **[Nota de transcrição]** No original, a variável é declarada como `lOrderAsc`, mas
> atribuída e passada como `lOderAsc` (erro de digitação da página). O exemplo acima usa
> `lOrderAsc` de forma consistente. No exemplo, o alias está na 5ª posição do `mBrowse`,
> `aLegendas` na 11ª e `cFilterDefault` na 19ª.

## Restrições do browse convertido

> **Atenção — DbSetFilter:** caso exista o uso de `DbSetFilter` no alias, no browse
> convertido esse filtro **não será considerado**.

> **Atenção — Personalização:** as configurações realizadas via browse ou papel de
> trabalho que impactavam características visuais (cor de fonte, estilo de fonte, cor
> de linha e outras) **não serão mais aplicadas** no browse convertido.

### oBrowse:isSmartX()

O browse em Smart X tem uma arquitetura diferente do browse legado. Por isso, no browse
convertido, não é mais viável recuperar o objeto do browse após sua ativação para
executar alguns métodos. Para simplificar o tratamento do código legado, foi
disponibilizado o método `oBrowse:isSmartX()`, que retorna um valor lógico informando se
está em um browse Smart X ou não.

```advpl
oBrwAux := GetMBrowse()

if !oBrwAux:isSmartX()
    oFilAux := oBrwAux:FwFilter()
endif
```

## Menu

O menu é convertido automaticamente de acordo com as operações definidas:

- Apenas a **primeira operação do tipo `3` (Inclusão)** fica como `pageAction`.
- As demais ficam como `tableAction`, ou seja, ações que dependem da seleção de um ou
  mais registros para interação.
- As operações de **pesquisa** são ignoradas na conversão, por não serem mais
  compatíveis com a nova visão.

> **Atenção — Uso de condicionais dentro da função `MenuDef`:** a função `MenuDef` não
> deve possuir condicionais, devido aos contextos em que ela é chamada/executada fora da
> rotina. Mais detalhes no documento "MenuDef" do TDN.

Caso outra ação precise ser apresentada como `pageAction`, configure essa opção no array
`aRotina` do `MenuDef`:

```advpl
Static Function MenuDef()
    Local aRotina as Array
    Local lPageAction as logical

    lPageAction := .T.
    aRotina := {}

    //Exemplo montando o array
    /*
    aAdd(aRotina,{'Visualizar','VIEWDEF.COMP011_MVC',0,2,0,,,,, })
    aAdd(aRotina,{'Incluir' ,'VIEWDEF.COMP011_MVC',0,3,0,,,,, })
    aAdd(aRotina,{'Alterar' ,'VIEWDEF.COMP011_MVC',0,4,0,,,,, })
    aAdd(aRotina,{'Excluir' ,'VIEWDEF.COMP011_MVC',0,5,0,,,,, })
    aAdd(aRotina,{'Incluir Complemento','COMPLE',0,3,0,,,,, lPageAction })//Será apresentado como pageAction
    */

    //Exemplo usando comandos
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMP011_MVC' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.COMP011_MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.COMP011_MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.COMP011_MVC' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.COMP011_MVC' OPERATION 8 ACCESS 0 PAGEACTION
    ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.COMP011_MVC' OPERATION 9 ACCESS 0

Return aRotina
```

> **[Nota de transcrição]** No formato de array, o indicador `lPageAction` ocupa a
> **10ª posição** do item de `aRotina`. No original, as declarações e atribuições de
> `lPageAction` e `aRotina` aparecem na mesma linha; aqui foram separadas.

> **Atenção — Comandos:** a definição de `PAGEACTION` via comandos depende da
> atualização dos arquivos `.ch` de framework. Os arquivos `.ch` com esse recurso estão
> disponíveis a partir de 12/01/2026 no portal da engenharia.

> **Atenção — Imprimir do Browse:** para o correto funcionamento da opção "Imprimir"
> padrão do browse, a operação enviada deve ser a **8**, como no exemplo acima. Caso o
> fonte utilize o `fwmvcdef.ch`, é possível usar o define `OP_IMPRIMIR`.

```advpl
#include "protheus.ch"
#include "fwmvcdef.ch"
(...)
ADD OPTION aRotina TITLE 'Imprimir' ACTION 'VIEWDEF.GTPA811' OPERATION OP_IMPRIMIR ACCESS 0 // Imprimir
(...)
```

```advpl
#include "protheus.ch"
#include "fwmvcdef.ch"
(...)
aAdd(aRotina, {'Imprimir' , 'VIEWDEF.OGA960', 0, OP_IMPRIMIR , 0, NIL})
(...)
```

### Impacto na conversão da opção "Legenda" no menu

Os itens definidos no `MenuDef` que possuírem a opção de **"Legenda"** (ação específica
para visualização de regras de cores) **não serão levados para o menu no Smart X**. Na
nova arquitetura, essa configuração legada é ignorada: a visualização de status é
tratada nativamente pelos componentes de interface (Tags), que já exibem o texto da
legenda, e não mais por chamadas de menu dedicadas.

## Legendas

A configuração das legendas continua disponível na função `mBrowse`, porém o array
passa a ter uma nova posição para as cores disponíveis em PO-UI. O parâmetro é do tipo
caractere e deve receber uma das cores `caption-tag-01` a `caption-tag-35`.

**Paleta disponível:** `caption-tag-01`, `caption-tag-02`, ..., `caption-tag-35`
(7 linhas × 5 colunas na página original, em tons claros, médios e escuros).

### Estrutura do array de legendas

| Posição | Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|---|
| 1 | `xCondition` | Expressão | Expressão AdvPL ou Code-Block com a regra da legenda | X |
| 2 | `cColor` | Caracter | Cor que identifica a regra | X |
| 3 | `cTitle` | Caracter | Título da legenda, utilizado na janela de visualização das legendas | X |
| 4 | `cID` | Caracter | Id | |
| 5 | `lFilter` | Lógico | Indica se deve ser exibido filtro da legenda | |
| 6 | `cColorPoUi` | Caracter | Cor da legenda caso o browse seja em PO-UI | |

### De-para de cores

Caso `cColorPoUi` não seja informado, é feito um de-para das cores atuais para as cores
disponíveis no PO-UI:

| Cor atual | Nova cor |
|---|---|
| `DISABLE` | `caption-tag-02` |
| `ENABLE` | `caption-tag-12` |
| `br_azul.bmp` | `caption-tag-19` |
| `br_amarelo.bmp` | `caption-tag-06` |
| `VERMELHO` \| `RED` | `caption-tag-03` |
| `LARANJA` \| `ORANGE` | `caption-tag-07` |
| `AMARELO` \| `YELLOW` | `caption-tag-08` |
| `BR_MARRON_OCEAN` | `caption-tag-09` |
| `MARROM` \| `BROWN` | `caption-tag-10` |
| `VERDE` \| `GREEN` | `caption-tag-13` |
| `VERDE_ESCURO` \| `HGREEN` | `caption-tag-14` |
| `AZUL_CLARO` \| `LBLUE` | `caption-tag-17` |
| `AZUL` \| `BLUE` | `caption-tag-18` |
| `VIOLETA` \| `VIOLET` | `caption-tag-23` |
| `ROXO` | `caption-tag-24` |
| `PINK` | `caption-tag-28` |
| `BRANCO` \| `WHITE` | `caption-tag-31` |
| `CINZA` \| `GRAY` | `caption-tag-33` |
| `PRETO` \| `BLACK` | `caption-tag-35` |
| `BR_PRETO_0` | `caption-tag-34` |
| `BR_PRETO_1` | `caption-tag-32` |
| `BR_PRETO_2` | `caption-tag-30` |
| `BR_PRETO_3` | `caption-tag-29` |
| `BR_PRETO_4` | `caption-tag-27` |
| `BR_PRETO_5` | `caption-tag-26` |
| `BR_PRETO_6` | `caption-tag-25` |
| `BR_PRETO_7` | `caption-tag-04` |
| `BR_PRETO_8` | `caption-tag-22` |
| `BR_PRETO_9` | `caption-tag-21` |
| `BR_PRETO_A` | `caption-tag-20` |
| `BR_PRETO_B` | `caption-tag-16` |
| `BR_PRETO_C` | `caption-tag-15` |

> **Informação:**
> - As cores antigas (`color-01`, `color-02`, ..., `color-12`) são mantidas por
>   compatibilidade.
> - Caso o novo parâmetro não seja informado e a cor definida não esteja na tabela
>   acima, **será gerada uma exceção**.
> - **Não são aceitos ícones.**

## Filtros

É possível definir filtros para o browse em Smart X, assim como no browse atual. Por
enquanto, apenas o parâmetro de filtro `cFilterDefault` pode ser utilizado, e nele deve
ser informada uma **expressão SQL**. Expressões AdvPL não serão consideradas.

## Resultado

A página original traz um vídeo demonstrativo ("Vídeo sem título.mp4") do browse
convertido, não transcrito.
