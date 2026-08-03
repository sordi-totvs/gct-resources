# Guia de Preenchimento de Casos de Teste

Resumo unificado das instruções de trabalho para criação e manutenção de Test Cases no Adaptavist Test Management (Kanoah).

---

## Estrutura de Pastas

Os Test Cases são organizados no projeto **Gestão de Testes - Protheus** seguindo a hierarquia:

- País
  - Módulo
    - Rotina

A ordenação de todos os diretórios deve ser **alfabética**. O último nível permitido é a rotina — não se deve criar subpastas abaixo dela.

---

## Campos da Aba Details

### Name (Nome)

Inicie sempre com a **operação** relacionada ao teste (Incluir, Alterar, Excluir, Liberar, Efetivar etc.), seguida das **características de regra de negócio** relevantes ao cenário, entre parênteses.

**Exemplo:** `Incluir Pedido de Venda (Rateio por centro de custo, Não atualiza estoque)`

Não detalhe todas as pré-condições no nome; informe apenas as regras de negócio que serão validadas.

### Objective (Objetivo)

Texto explicativo do propósito do teste, escrito em linguagem próxima do usuário/cliente. Deve transmitir com clareza o que o teste pretende validar.

### Preconditions (Pré-Condições)

Detalhar **tudo** que é necessário para execução do teste:

1. **Parâmetros de sistema** — nomes e respectivos valores (ex.: `MV_CQ = "98"`).
2. **Registros na base congelada** — informar de forma objetiva os cadastros pré-existentes necessários (ex.: `Fornecedor = COM003`). A nomenclatura dos registros segue o padrão da Base Congelada.
3. **Usuário de login** — o padrão é `Admin` com senha em branco. Informar outro usuário somente quando a regra de negócio exigir (ex.: vendedor CRM, alçada de aprovação).
4. **Filial de abertura e data base do sistema.**
5. **Módulo e caminho de menu** para acesso à rotina principal.

**Regra importante:** Somente cadastros diretamente ligados ao teste devem constar como pré-condição. Ex.: Em um teste de exclusão de Pedido de Venda, a pré-condição é o próprio Pedido — não o código do Produto ou Cliente utilizado nele.

---

## Campos da Seção Details (Metadados)

### Status

| Valor | Quando usar |
|-------|-------------|
| Draft | Test Case em desenvolvimento. |
| Identified | Identificado no Mapa Mental, possui apenas título e objetivo, mas ainda não está pronto. |
| Needs Review | Precisa ser revisado pela equipe. |
| Ready | Completo e pronto para uso. |
| Deprecated | Obsoleto — rotina evoluiu e um novo Test Case é mais viável que a manutenção do anterior. |

### Priority (Prioridade)

Reflete a **importância da funcionalidade** no sistema, considerando sua execução em teste sistêmico. Valores possíveis: **High**, **Normal** ou **Low**.

### Estimated Time (Tempo Estimado)

Tempo de execução **manual** do teste, considerando que todas as pré-condições já estão disponíveis (base congelada preparada).

### Labels (Rótulos)

- Primeiro rótulo: identificador do cenário no Mapa Mental, no formato **`CT` + numeral sequencial com três caracteres** (ex.: `CT001`, `CT127`).
- Rótulos adicionais: chamado ou Issue que motivou a criação/alteração, no formato `CH:<número>` ou `ISSUE:<número>`.

### Test Type (Tipo de Teste)

Indica o estado de automação do Test Case:

| Valor | Significado |
|-------|-------------|
| AdvPR | Já possui script de execução automática AdvPR. |
| Manual | Ainda não possui script de automação. |
| PWA | Já possui script de execução por interface (Protheus Web Automation). |

**Critérios para escolha da ferramenta de automação:**
- Se a validação é de **regra de negócio** → AdvPR é recomendado.
- Se a rotina não está preparada para execução automática → avaliar esforço de ajuste antes de optar por PWA.
- PWA deve ser considerada quando não há viabilidade de ajuste na rotina padrão ou quando as validações são de **componentes de tela**.

### Complexity (Complexidade)

Informar a complexidade de execução do caso de teste.

---

## Campos da Aba Test Script

### Steps (Passos)

Descrever **todas** as ações necessárias para executar o teste:

- Campos da rotina que devem ser preenchidos, com seus respectivos valores.
- Opções que devem ser selecionadas.
- Teclas de atalho utilizadas.
- Menus de Ações Relacionadas, pastas, grids etc.

**Formato obrigatório para campos:** `Nome na tela (Campo_real_na_tabela): Valor`
Exemplo: `Tipo de Pedido (C5_TIPPED): N - Normal`

Cada componente de tela utilizado deve ser **destacado**. O nível de detalhe deve permitir que qualquer pessoa execute o teste.

Em geral utiliza-se **um único passo** por Test Case, salvo exceções onde existe interação com outras rotinas via interface.

### Expected Result (Resultado Esperado)

Informar **apenas** o que faz parte do objetivo do teste:

- **Tabelas e campos** que devem ser verificados, no mesmo formato dos passos (ex.: `Valor Unitário (C6_VLUNIT): 347,59`).
- **Mensagens do sistema** — quando o teste valida bloqueios ou alertas.
- **Cor de legenda no Browse** — quando relevante ao registro.
- **Acesso ao Consulta Genérica** — indicar quando a validação pode/deve ser feita pelo sistema em vez do banco de dados diretamente.

**Boas práticas:**
- Promover formatação que facilite a leitura entre tabelas.
- Informar apenas campos e tabelas que realmente têm relação com as regras do Test Case.
- Resultado focado = análise mais rápida e direcionada.

---

## Anexos (Attachments)

Quando o Test Case valida **relatório ou arquivo texto**:

- Anexar o relatório modelo em formato **PDF** (para conferência visual em execução manual).
- Anexar o relatório em formato **XML** (opção Planilha do relatório).
- Arquivos `.TXT` e `.INI` devem ser anexados ao caso de teste.
- Para execução automatizada, o arquivo XML deve estar disponível em `protheus_data\spool`.

---

## Resumo Rápido dos Campos

| Campo | O que preencher |
|-------|-----------------|
| Name | Operação + regras de negócio entre parênteses |
| Objective | Propósito do teste em linguagem de usuário |
| Preconditions | Parâmetros, registros base, usuário, filial, módulo/menu |
| Status | Draft → Ready (ciclo de vida) |
| Priority | High / Normal / Low |
| Estimated Time | Tempo de execução manual com base preparada |
| Labels | CTxxx + CH/ISSUE do chamado |
| Test Type | AdvPR / Manual / PWA |
| Complexity | Complexidade de execução |
| Steps | Ações detalhadas com campos no formato `Nome (Campo): Valor` |
| Expected Result | Tabelas/campos/mensagens a validar, no mesmo formato |
| Attachments | PDF e XML de relatórios, arquivos TXT/INI quando aplicável |
