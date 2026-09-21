---
name: gct-tests
description: >-
  Cria a documentação de caso de teste de regressão (Kanoah / Adaptavist Test
  Management) e o script de teste AdvPR a partir do código de uma issue do
  módulo Gestão de Contratos (SIGAGCT). Identifica a origem das informações
  (especificação em .specs ou issue no JIRA), entende o cenário principal,
  descobre a rotina impactada, bloqueia duplicidade quando o caso de teste já
  existe, calcula o próximo código CT disponível, grava o Kanoah em
  tests/kanoah/{rotina}/{CTxxx}.md e implementa o método do caso de teste em
  tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW. Use quando o usuário disser:
  criar caso de teste, criar kanoah, documentar caso de teste, caso de teste de
  regressão, test case da issue, CT da issue, gct-tests, criar script de teste
  da issue, criar CT para correção.
license: MIT
metadata:
  domain: Protheus
  module: SIGAGCT - Gestão de Contratos
  maintainer: Engenharia Protheus - Gestão de Contratos
  version: 2.0.0
  category: Testing / Documentation
---

# GCT Tests — Caso de Teste de Regressão (Kanoah + Script AdvPR)

Transforma o código de uma issue em dois entregáveis rastreáveis: o **Kanoah** (documentação do caso de teste no padrão Adaptavist Test Management) e o **script AdvPR** correspondente.

```
┌───────────────────┐   ┌──────────────────┐   ┌───────────────┐   ┌───────────┐   ┌────────────┐
│ 1. DADOS DA ISSUE │ → │ 2. CENÁRIO       │ → │ 3. ROTINA/CT  │ → │ 4. KANOAH │ → │ 5. SCRIPT  │
└───────────────────┘   └──────────────────┘   └───────────────┘   └───────────┘   └────────────┘
   .specs OU JIRA         regra de negócio       + antiduplicidade    tests/kanoah/   TestCase.PRW
```

## Entrada e Saída

| | |
|---|---|
| **Entrada** | Código da issue (`GCT-1234`, `1234`, `#1234` ou URL `https://jira.totvs.com.br/browse/GCT-1234`) |
| **Saída 1 — Kanoah** | `tests/kanoah/{código da rotina}/{código do caso de teste}.md` |
| **Saída 2 — Script** | método `{PREFIXO}_{nnn}` em `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW` |
| **Exemplo** | `tests/kanoah/CNTA311/CT007.md` + método `CNT311_007` em `CNTA311TestCase.PRW` |

Um único caso de teste por execução: o cenário **principal** da issue. Se a issue cobrir mais de um cenário independente, informe ao usuário quais cenários foram identificados, documente o principal e pergunte se deseja gerar os demais.

---

## Modo de execução

O Kanoah é sempre o primeiro entregável — o script AdvPR é a implementação do que o Kanoah especifica, então **nunca** se cria script sem Kanoah.

| O usuário pediu | Comportamento |
|---|---|
| Apenas o **Kanoah** ("criar kanoah", "documentar o caso de teste") | Cria o Kanoah. Ao final, **pergunta** se também deve criar o script AdvPR. Só cria o script após confirmação. |
| Apenas o **script** ("criar o script de teste", "implementar o CT no TestCase") | **Avisa** que o Kanoah será criado primeiro, cria o Kanoah e em seguida cria o script — sem nova pergunta. |
| **Não especificou** ("criar caso de teste da issue GCT-1234") | Cria os dois, na ordem Kanoah → script. |

Declare o modo identificado ao usuário antes de começar, junto com a origem dos dados (passo 1.4).

---

## Passo 1 — Identificar os dados da issue

### 1.1 Normalizar o identificador

| Padrão informado | Chave a utilizar |
|---|---|
| Chave JIRA padrão (`GCT-1234`, `DFCONT-456`) | usar diretamente |
| ID numérico isolado (`1234`, `#1234`) | usar como ID numérico |
| URL com `/browse/` | extrair a chave (`GCT-1234`) |

### 1.2 Procurar especificação no repositório (prioridade)

Antes de consultar o JIRA, procure uma especificação relacionada em `.specs/`:

1. Pastas cujo nome contenha a chave ou o número da issue:
   - `.specs/features/*<issue>*/`
   - `.specs/fixes/*<issue>*/`
   - `.specs/quick/*<issue>*/`
2. Conteúdo dos artefatos `.md` em `.specs/` que cite a chave da issue (`spec.md`, `bug-spec.md`, `rca.md`, `tasks.md`, `context.md`, `design.md`, `TASK.md`, `SUMMARY.md`).

Considere encontrada quando houver correspondência por nome de pasta **ou** citação explícita da issue dentro de um artefato.

**Se encontrar** — a especificação é a fonte da verdade. Leia, em ordem de prioridade:

| Artefato | O que extrair |
|---|---|
| `bug-spec.md` | comportamento errado vs. esperado, passos de reprodução, escopo, critérios de aceite |
| `spec.md` | requisitos com IDs rastreáveis, regras de negócio |
| `rca.md` | causa raiz provada, fontes e campos afetados, correção mínima |
| `tasks.md` | fontes tocados, testes de regressão previstos |
| `design.md` / `context.md` | decisões e restrições |

**Se não encontrar** — consulte o JIRA (passo 1.3).

### 1.3 Consultar o JIRA

Use a tool `get-jira-issue` do MCP `advpl-tlpp-mcp-docs`:

- `issue_key`: chave normalizada (ex.: `"GCT-1234"`)
- Campos relevantes: `summary`, `description`, `status`, `assignee`, `priority`, `issuetype`, `comment`, `labels`, `components`

Aproveite:

| Campo | Uso no caso de teste |
|---|---|
| `summary` | base para o **Name** |
| `description` | base para **Objective**, **Preconditions**, **Steps** e **Expected Result** |
| `comment` | decisões, valores reais, correções de rumo do cenário |
| `priority` | insumo para **Priority** (revisar segundo a importância da funcionalidade, não a urgência do chamado) |
| `issuetype` | Bug → caso de teste de regressão do defeito; Melhoria → regressão da nova regra |

Se a issue não for localizada nem em `.specs/` nem no JIRA, **pare** e peça ao usuário o cenário em texto livre. Nunca invente o cenário.

### 1.4 Informar a origem ao usuário (obrigatório)

Antes de seguir para o passo 2, declare explicitamente o modo e a origem:

```
Modo: Kanoah + script AdvPR
Origem das informações: especificação `.specs/fixes/gct-1234-reajuste-indice/`
```

ou

```
Modo: apenas Kanoah (pergunto sobre o script ao final)
Origem das informações: JIRA GCT-1234 (nenhuma especificação encontrada em .specs)
```

---

## Passo 2 — Entender o cenário principal

Reduza a issue a **um** cenário de regressão verificável. Responda internamente:

1. **Qual operação** dispara o comportamento? (Incluir, Alterar, Excluir, Liberar, Aprovar, Efetivar, Reajustar, Medir, Estornar, Imprimir...)
2. **Qual rotina** é o ponto de entrada? (ex.: `CNTA300` — Manutenção de Contratos)
3. **Quais regras de negócio** o defeito/melhoria envolve? Somente as que o teste vai validar.
4. **Qual era o comportamento errado e qual é o esperado?** O esperado vira o **Expected Result**.
5. **Quais tabelas e campos** provam o resultado? (ex.: `CN9_VLATU`, `CNA_VLTOT`, `CND_VLTOT`)
6. **Quais parâmetros (SX6) e perguntas (SX1)** condicionam o cenário? (ex.: `MV_CNRJREV`, grupo `CN310`)
7. **Filial e data base** necessárias.

Quando algum destes pontos não estiver na origem consultada, use a **cadeia de verificação** abaixo. Nunca preencha com suposição silenciosa.

### Cadeia de verificação de conhecimento

```
1. Fontes do repositório (src/) e scripts existentes em tests/Scripts AdvPR/Cases/
2. Especificação em .specs/ (quando houver)
3. MCP advpl-tlpp-mcp-docs:
   - product-docs-search        → comportamento da rotina, pontos de entrada
   - execute-sql / get-object-details → dicionário: campos, tipos, índices (SX2/SX3/SIX)
   - program-parameters-search  → parâmetros SX6 usados pela rotina
   - language-system-docs-search→ APIs de framework
   - automation-docs-search     → AdvPR / FWTestHelper
4. Sinalizar como pendência no documento: <!-- PENDENTE: ... -->
```

Nunca fabrique nome de campo, tabela, parâmetro ou mensagem. Campo inexistente invalida o caso de teste inteiro.

---

## Passo 3 — Rotina, código CT e verificação de duplicidade

### 3.1 Código da rotina

O código da rotina segue o padrão Protheus: prefixo do módulo + numeração (`CNTA100`, `CNTA300`, `CNTA311`, `CNTR030`, `MATA120GCT`).

Determine na seguinte ordem:

1. Rotina citada explicitamente na especificação ou na issue.
2. Fonte alterado pela correção (`src/.../CNTA311.PRW` → `CNTA311`).
3. Script de teste existente: `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW`.

Se houver mais de uma rotina impactada, escolha o **ponto de entrada do cenário** (a rotina que o testador executa), não a função interna corrigida. Registre a decisão na resposta ao usuário.

### 3.2 Verificação de duplicidade — porta de parada

Execute **antes** de gerar qualquer arquivo. Se qualquer uma das condições abaixo ocorrer, **informe o usuário e pare**. Não sobrescreva, não renumere, não crie variante.

| Condição | Como verificar | Mensagem ao usuário |
|---|---|---|
| O usuário pediu um `CTxxx` específico e o Kanoah já existe | `tests/kanoah/{rotina}/{CTxxx}.md` existe | "O caso de teste `{CTxxx}` da rotina `{rotina}` já existe em `{caminho}`. Nada foi criado." |
| O usuário pediu um `CTxxx` específico e o script já existe | método `{PREFIXO}_{nnn}` já declarado/registrado no `{Rotina}TestCase.PRW` | "O script do `{CTxxx}` já existe no método `{PREFIXO}_{nnn}` de `{arquivo}`. Nada foi criado." |
| A issue já possui Kanoah documentado | algum `tests/kanoah/**/*.md` cita a chave da issue ou o rótulo `ISSUE:{numero}` | "A issue `{chave}` já está coberta pelo caso de teste `{CTxxx}` da rotina `{rotina}` em `{caminho}`. Nada foi criado." |

Ao parar, ofereça os próximos passos possíveis em vez de agir por conta própria:

- revisar/atualizar o Kanoah existente;
- criar apenas o script AdvPR, quando o Kanoah existe e o método ainda não;
- documentar um **cenário diferente** da mesma issue como novo CT, se o usuário confirmar que o cenário não é o mesmo.

Comando de apoio (PowerShell):

```powershell
$rotina = 'CNTA311'
$issue  = 'GCT-1234'
$numero = ($issue -replace '\D', '')

# Kanoah que já cite a issue
Get-ChildItem '.\tests\kanoah' -Recurse -Filter '*.md' -ErrorAction SilentlyContinue |
    Select-String -Pattern "$issue|ISSUE:$numero" |
    Select-Object Path, Line

# Kanoah de um CT específico
Test-Path (Join-Path (Join-Path '.\tests\kanoah' $rotina) 'CT007.md')

# Método já implementado no script
Select-String -Path (Join-Path '.\tests\Scripts AdvPR\Cases' ($rotina + 'TestCase.PRW')) -Pattern 'CNT311_007'
```

> Duplicidade parcial é informação, não bloqueio total: se o Kanoah existe mas o método AdvPR não, informe isso e pergunte se deve criar somente o script.

### 3.3 Próximo código CT disponível

Formato: `CT` + numeral sequencial de **três dígitos** (`CT001`, `CT016`, `CT127`).

Considere **todas** as fontes de numeração e use o maior valor + 1:

1. Documentos já existentes em `tests/kanoah/{rotina}/CT*.md`
2. Casos já implementados em `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW`:
   - métodos numerados (ex.: `CNT311_001` … `CNT311_006` → CT006)
   - descrições em `AddTestMethod` que citem `CTxxx`
3. Arquivos de continuação da mesma rotina, quando existirem (ex.: `CNTA121BTestCase.PRW` continua a numeração de `CNTA121TestCase.PRW`)

> Numeração da série 9xx (ex.: `CNT311_901`) é reservada a testes unitários de classes TLPP e **não** entra no cálculo do próximo CT funcional.

```powershell
$rotina  = 'CNTA311'
$pasta   = Join-Path '.\tests\kanoah' $rotina
$arqCase = @(Get-ChildItem '.\tests\Scripts AdvPR\Cases' -Filter ($rotina + '*TestCase.PRW') -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName)

$docs = @(Get-ChildItem (Join-Path $pasta 'CT*.md') -ErrorAction SilentlyContinue |
    ForEach-Object { [int]($_.BaseName -replace '\D', '') })

$script = @(Select-String -Path $arqCase -Pattern '(?:CT|_)(\d{3})' -AllMatches -ErrorAction SilentlyContinue |
    ForEach-Object { $_.Matches } |
    ForEach-Object { [int]$_.Groups[1].Value } |
    Where-Object { $_ -lt 900 })

$max = [int]((@(0) + $docs + $script) | Measure-Object -Maximum).Maximum
'CT{0:D3}' -f ($max + 1)
```

Se a pasta `tests/kanoah/{rotina}/` não existir, crie-a. Se nenhuma numeração for encontrada, o próximo código é `CT001`.

---

## Passo 4 — Gerar o Kanoah

Use o template de [references/test-case-template.md](references/test-case-template.md) e as regras de preenchimento de [references/GuiaPreenchimentoCasosDeTeste.md](references/GuiaPreenchimentoCasosDeTeste.md).

### Regras de preenchimento — resumo operacional

| Campo | Regra |
|---|---|
| **Name** | Operação primeiro, características de regra de negócio entre parênteses. Ex.: `Reajustar Contrato (Índice acumulado, Revisão automática)`. Sem pré-condições no nome. |
| **Objective** | Linguagem de usuário/cliente. Deve deixar claro o propósito da validação e o que a regressão protege. |
| **Preconditions** | Parâmetros (`MV_XXXX = valor`), registros da Base Congelada, usuário de login, filial de abertura, data base, módulo e caminho de menu. Só o que está diretamente ligado ao teste. |
| **Status** | `Ready` quando todos os campos estão concretos; `Needs Review` quando houver `<!-- PENDENTE -->` no documento. |
| **Priority** | Importância da funcionalidade no sistema (`High` / `Normal` / `Low`) — não a urgência do chamado. |
| **Estimated Time** | Tempo de execução **manual**, assumindo base congelada preparada. |
| **Labels** | Primeiro o `CTxxx`; depois a rastreabilidade da issue (`ISSUE:1234` ou `CH:1234`). |
| **Test Type** | `AdvPR` quando o script for criado nesta execução ou já existir; `Manual` quando o usuário optar por não criar o script. |
| **Complexity** | Complexidade de execução, conforme as opções do campo no Kanoah (ex.: Baixa / Média / Alta). |
| **Steps** | Preferencialmente **um único passo**. Vários passos apenas quando o cenário atravessa rotinas diferentes pela interface. Campos sempre como `Nome na tela (CAMPO_REAL): Valor`. |
| **Expected Result** | Apenas o que pertence ao objetivo: tabelas/campos no mesmo formato, mensagens de sistema, cor de legenda no Browse, indicação de Consulta Genérica quando aplicável. |
| **Attachments** | Só para relatórios/arquivos: PDF modelo, XML (Planilha), `.txt`/`.ini`. |

### Convenções da Base Congelada — Gestão de Contratos

Os registros de pré-condição do módulo seguem o padrão de nomenclatura observado nos scripts existentes:

```
GCT_{ROTINA}_{CTxxx}     → GCT_CNTA121_102
GCT_{ROTINA}CT{nn}       → GCT_CNTA300CT38
GCT_{PERGUNTE}_{CTxxx}   → GCT_CN310_CT001
```

Valores usuais dos testes do módulo (confirme na origem antes de fixar):

- Filial de abertura: `D MG 01 ` (matriz) ou `D MG 02 ` (filial)
- Usuário: `Admin`, senha em branco
- Módulo: `SIGAGCT — Gestão de Contratos`

Quando o cenário exigir um registro novo na Base Congelada, informe-o na pré-condição já com o nome padronizado e sinalize que o cadastro precisa ser criado.

### Foco de regressão

O documento é um caso de **regressão**: ele existe para provar que o comportamento corrigido continua correto nas próximas versões.

- O **Expected Result** descreve o comportamento **correto**, nunca o defeito.
- Inclua na seção `Observações de regressão` o resumo do defeito original e o vínculo com a issue, para que a intenção do teste sobreviva ao tempo.
- Se o defeito era um bloqueio indevido ou uma mensagem de erro, o resultado esperado deve descrever a operação concluindo com sucesso; se o defeito era ausência de bloqueio, descreva a mensagem exata que deve aparecer.

### Encoding do Kanoah

O arquivo gerado é `.md` → grave em **UTF-8**. A regra de CP1252 do repositório vale apenas para fontes `.prw`, `.prx`, `.prg`, `.tlpp` e `.ch`. Português com acentuação e ortografia corretas.

### Transição para o passo 5

- **Modo "apenas Kanoah"**: informe o caminho do arquivo criado e pergunte — "Kanoah `{CTxxx}` criado em `{caminho}`. Deseja que eu crie também o script AdvPR no `{Rotina}TestCase.PRW`?" Só siga ao passo 5 após confirmação. Se o usuário recusar, grave `Test Type: Manual`.
- **Modo "script" ou "não especificado"**: siga direto ao passo 5.

---

## Passo 5 — Gerar o script AdvPR

Implemente o método do caso de teste em `tests/Scripts AdvPR/Cases/{Rotina}TestCase.PRW`, espelhando exatamente o que o Kanoah especifica.

Regras completas, padrão de nomenclatura, pontos de inserção e templates: [references/advpr-test-script-pattern.md](references/advpr-test-script-pattern.md).
API do helper: [references/FWTestHelper.md](references/FWTestHelper.md).

Resumo do que precisa acontecer:

1. **Nome do método** — prefixo de 6 caracteres (3 letras + 3 dígitos da rotina) + `_` + número do CT: `CNTA311` → `CNT311_007`; `CNTR030` → `CNT030_007`; `MATA120GCT` → `MATA120_001`.
2. **Três pontos de edição no arquivo** — declaração `METHOD` no bloco `CLASS ... ENDCLASS`, registro `::AddTestMethod(...)` no construtor e implementação `METHOD ... CLASS ...` ao final, na ordem numérica.
3. **Corpo do método** — traduzir Preconditions → `ChangeFil` / `dDataBase` / `UTSetParam` / `UTChangePergunte`; Steps → `FWLoadModel` + `SetModel` + `UTSetValue` ou `UTCommitData`; Expected Result → `UTQueryDB` + `AssertTrue(oHelper:lOk, ...)`.
4. **Restauração de ambiente** — `dDataBase := DATE()` e `oHelper:UTRestParam(oHelper:aParamCT)` antes do `Return oHelper`.
5. **Encoding CP1252** — o arquivo é `.PRW`. Após a edição, converta com a skill `utf8-to-cp1252-conversion` e confirme que a acentuação dos comentários permaneceu íntegra.
6. **Compilação** — pergunte ao usuário se deseja compilar; em caso afirmativo, acione a skill `advpl-tlpp-compile`. Se houver erro, corrija a causa raiz e repita até zero erros.

Quando o `{Rotina}TestCase.PRW` **não existir**, crie o trio Case + Group + Suite usando `CNTA311TestCase.PRW`, `CNTA311TestGroup.PRW` e `CNTA311TestSuite.PRW` como modelo canônico, e avise o usuário de que a rotina passou a ter estrutura de testes nova.

Se algum ponto do cenário não for automatizável (validação de componente de tela, conferência visual de relatório), **não invente chamada de API**: implemente o que é verificável, marque o restante com comentário `//-- PENDENTE: verificação manual — {motivo}` e mantenha `Test Type: Manual` no Kanoah quando a automação não cobrir o objetivo.

---

## Passo 6 — Validação obrigatória

Antes de declarar concluído, confirme:

**Fluxo e antiduplicidade**

- [ ] O modo de execução (Kanoah / script / ambos) foi declarado ao usuário.
- [ ] A origem das informações (`.specs` ou JIRA) foi declarada ao usuário.
- [ ] A verificação de duplicidade foi executada nas três frentes (Kanoah do CT, método do script, Kanoah que já cita a issue).
- [ ] Nenhum arquivo existente foi sobrescrito.

**Kanoah**

- [ ] O código da rotina corresponde ao ponto de entrada do cenário.
- [ ] O código CT é o próximo disponível, considerando `tests/kanoah/` **e** os `{Rotina}*TestCase.PRW`.
- [ ] O arquivo foi criado em `tests/kanoah/{rotina}/{CTxxx}.md`, em UTF-8, pt-BR com acentuação correta.
- [ ] `Name` começa por uma operação e traz as regras de negócio entre parênteses.
- [ ] Todos os campos seguem o formato `Nome na tela (CAMPO_REAL): Valor`.
- [ ] Todo campo, tabela, parâmetro e pergunta citados foram verificados (dicionário, fonte ou MCP) — nenhum inventado.
- [ ] Pré-condições contêm apenas registros diretamente ligados ao teste.
- [ ] `Expected Result` descreve o comportamento correto e apenas o que pertence ao objetivo.
- [ ] `Labels` traz `CTxxx` + rastreabilidade da issue.
- [ ] `Test Type` reflete a existência real de script AdvPR.
- [ ] Pendências, se houver, estão marcadas com `<!-- PENDENTE: ... -->` e `Status = Needs Review`.

**Script AdvPR** (quando gerado)

- [ ] Método declarado, registrado em `AddTestMethod` e implementado — os três pontos.
- [ ] Nome do método segue o prefixo da rotina e o número do CT.
- [ ] Descrição em `AddTestMethod` cita o `CTxxx` e o cenário.
- [ ] As verificações `UTQueryDB` cobrem os campos declarados no `Expected Result` do Kanoah.
- [ ] Ambiente restaurado (`dDataBase`, `UTRestParam`) antes do `Return oHelper`.
- [ ] Arquivo convertido para CP1252 sem BOM, acentuação preservada.
- [ ] Compilação oferecida ao usuário; se executada, terminou sem erros.

Ao final, informe: modo, origem dos dados, rotina identificada, código CT atribuído, caminhos dos arquivos criados/alterados, nome do método gerado e lista de pendências que exigem confirmação humana.

---

## Skills relacionadas

| Necessidade | Skill |
|---|---|
| Padrões avançados de script AdvPR (REST, relatórios, Smart View) | `advpr-test-generator` |
| Converter o `.PRW` alterado para CP1252 | `utf8-to-cp1252-conversion` |
| Compilar o `{Rotina}TestCase.PRW` | `advpl-tlpp-compile` |
| Provar a causa raiz antes de documentar a regressão | `advpl-tlpp-root-cause-analysis` |
| Consultar estrutura de tabelas e campos do dicionário | `data-dictionary-lookup` |
| Especificar a feature/bug que originou a issue | `advpl-tlpp-sdd` |
| Teste de interface do mesmo cenário | `tir-test-generator` |

## Referências

- [test-case-template.md](references/test-case-template.md) — template do Kanoah e exemplo preenchido
- [advpr-test-script-pattern.md](references/advpr-test-script-pattern.md) — padrão do script AdvPR e tradução Kanoah → código
- [GuiaPreenchimentoCasosDeTeste.md](references/GuiaPreenchimentoCasosDeTeste.md) — regras completas de preenchimento no Kanoah
- [FWTestHelper.md](references/FWTestHelper.md) — API do `FWTestHelper` (AdvPR)
