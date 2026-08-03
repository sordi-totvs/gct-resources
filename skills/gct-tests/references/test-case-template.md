# Template do Caso de Teste — Kanoah

Estrutura obrigatória do arquivo `tests/kanoah/{rotina}/{CTxxx}.md`. Cada seção corresponde a um campo do Adaptavist Test Management (Kanoah), o que permite copiar o conteúdo diretamente para a ferramenta.

---

## Template

```markdown
# {CTxxx} — {Name}

| Campo | Valor |
|---|---|
| **Folder** | Brasil / SIGAGCT - Gestão de Contratos / {ROTINA} |
| **Status** | Ready \| Needs Review \| Draft |
| **Priority** | High \| Normal \| Low |
| **Estimated Time** | {mm}m |
| **Labels** | {CTxxx}, ISSUE:{numero} |
| **Test Type** | AdvPR \| Manual \| PWA |
| **Complexity** | Baixa \| Média \| Alta |
| **Issue** | {CHAVE-JIRA} — {summary} |
| **Origem** | .specs/{caminho} \| JIRA {CHAVE} |

## Name

{Operação} {Objeto} ({Regra de negócio 1}, {Regra de negócio 2})

## Objective

{Propósito do teste em linguagem de usuário: o que a rotina deve garantir e qual
regra de negócio é protegida por esta regressão.}

## Preconditions

**Ambiente**

- Módulo: SIGAGCT — Gestão de Contratos
- Caminho de menu: {Menu} > {Submenu} > {Rotina}
- Filial de abertura: {D MG 01 }
- Data base: {dd/mm/aaaa}
- Usuário: Admin (senha em branco)

**Parâmetros**

- {MV_XXXXXX} = {valor}

**Perguntas (SX1 — grupo {GRUPO})**

- {01} — {Descrição da pergunta}: {valor}

**Registros da Base Congelada**

- {Entidade} ({CAMPO_CHAVE}): {GCT_ROTINA_CTxxx}
- {Entidade} ({CAMPO_CHAVE}): {valor}

## Steps

### Passo 1

**Ação**

1. Acessar {Menu} > {Submenu} > {Rotina}.
2. Posicionar em {Entidade} ({CAMPO_CHAVE}): {valor}.
3. Acionar {Botão / Ação Relacionada}.
4. Preencher:
   - {Nome na tela} ({CAMPO_REAL}): {valor}
   - {Nome na tela} ({CAMPO_REAL}): {valor}
5. Confirmar em {Botão}.

**Expected Result**

- Tabela {ALIAS} — {descrição do registro}:
  - {Nome na tela} ({CAMPO_REAL}): {valor}
  - {Nome na tela} ({CAMPO_REAL}): {valor}
- Mensagem do sistema: "{texto exato}" *(quando o teste valida bloqueio/alerta)*
- Legenda no Browse: {cor} — {significado} *(quando relevante)*
- Verificação possível via Consulta Genérica: {ALIAS} *(quando aplicável)*

## Attachments

- {arquivo.pdf} — relatório modelo para conferência manual
- {arquivo.xml} — Planilha do relatório para execução automatizada
- (Sem anexos quando o teste não envolve relatório ou arquivo texto.)

## Observações de regressão

- **Issue de origem:** {CHAVE-JIRA} — {summary}
- **Defeito original:** {resumo do comportamento errado, em uma ou duas frases}
- **Comportamento correto validado:** {resumo do comportamento esperado}
- **Script AdvPR:** `tests/Scripts AdvPR/Cases/{ROTINA}TestCase.PRW` → método `{PREFIXO}_{nnn}`
  (ou: script ainda não implementado)
```

---

## Exemplo preenchido

```markdown
# CT007 — Reajustar Contrato (Índice acumulado, Revisão automática)

| Campo | Valor |
|---|---|
| **Folder** | Brasil / SIGAGCT - Gestão de Contratos / CNTA311 |
| **Status** | Ready |
| **Priority** | High |
| **Estimated Time** | 15m |
| **Labels** | CT007, ISSUE:1234 |
| **Test Type** | AdvPR |
| **Complexity** | Média |
| **Issue** | GCT-1234 — Reajuste automático não considera índice acumulado na revisão |
| **Origem** | .specs/fixes/gct-1234-reajuste-indice/ |

## Name

Reajustar Contrato (Índice acumulado, Revisão automática)

## Objective

Garantir que o reajuste automático de contratos aplique o índice acumulado do
período sobre o valor da planilha, gerando a revisão com o valor atualizado
correto. Protege a regra de acúmulo de índices, que deixava o contrato com valor
defasado quando havia mais de um histórico de índice no intervalo do reajuste.

## Preconditions

**Ambiente**

- Módulo: SIGAGCT — Gestão de Contratos
- Caminho de menu: Atualizações > Contratos > Reajuste Automático
- Filial de abertura: D MG 01
- Data base: 01/02/2018
- Usuário: Admin (senha em branco)

**Parâmetros**

- MV_CNRJREV = .T. (gera revisão no reajuste)

**Perguntas (SX1 — grupo CN310)**

- 01 — Contrato De: GCT_CN310_CT007
- 08 — Data de Reajuste: 01/03/2018
- 09 — Data de Referência: 01/03/2018
- 10 — Índice: 018

**Registros da Base Congelada**

- Contrato (CN9_NUMERO): GCT_CN310_CT007, revisão 000
- Histórico de Índices (CNC_INDICE): 018, com dois registros no intervalo
  01/01/2018 a 01/03/2018

## Steps

### Passo 1

**Ação**

1. Acessar Atualizações > Contratos > Reajuste Automático.
2. Informar os parâmetros do pergunte CN310 conforme as pré-condições.
3. Confirmar em **OK**.

**Expected Result**

- Tabela CN9 — contrato GCT_CN310_CT007, revisão 001:
  - Situação (CN9_SITUAC): 05 - Vigente
  - Valor Atual (CN9_VLATU): 13.050,00
  - Data do Reajuste (CN9_DTREAJ): 01/03/2018
  - Data de Referência (CN9_DREFRJ): 01/03/2018
- Tabela CNA — planilha do contrato, revisão 001:
  - Valor Total (CNA_VLTOT): 13.050,00
- Verificação possível via Consulta Genérica: CN9

## Attachments

Sem anexos — o teste não envolve relatório nem arquivo texto.

## Observações de regressão

- **Issue de origem:** GCT-1234 — Reajuste automático não considera índice
  acumulado na revisão
- **Defeito original:** o reajuste aplicava apenas o último índice do período,
  ignorando os índices anteriores do intervalo, e gravava CN9_VLATU defasado.
- **Comportamento correto validado:** o índice acumulado do intervalo é aplicado
  sobre o valor da planilha e replicado para a revisão gerada.
- **Script AdvPR:** `tests/Scripts AdvPR/Cases/CNTA311TestCase.PRW` → método
  `CNT311_007`
```

---

## Notas de formatação

- Toda referência a campo usa `Nome na tela (CAMPO_REAL): valor`. Sem exceção — vale para Steps e Expected Result.
- Um único passo é o padrão. Divida em passos numerados apenas quando o cenário atravessa rotinas diferentes pela interface.
- Componentes de tela (botões, pastas, grids, Ações Relacionadas) em **negrito**, para replicar o destaque exigido no Kanoah.
- Valores monetários e datas no formato brasileiro (`13.050,00`, `01/03/2018`).
- Pendências que dependem de confirmação humana ficam inline como `<!-- PENDENTE: descrição -->` e forçam `Status = Needs Review`.
- Não repita no `Name` informações que já estão em `Preconditions`.
