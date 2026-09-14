# GCT Resources

Repositório de recursos compartilhados para os squads **Gestão de Contratos** e **Gestão de Receitas** (Engenharia Protheus — TOTVS).

Contém recursos de IA utilizados no dia a dia dos times para automação de documentação, especificação e testes: **skills** do Kiro e **agentes** customizados.

## Skills

| Skill | Descrição |
|---|---|
| [advpl-tlpp-performance-analysis](skills/advpl-tlpp-performance-analysis/SKILL.md) | Analisa performance de relatórios que migraram do fonte legado (AdvPL/TLPP) para Smart View / TReports, comparando os dois caminhos via LogProfiler e plano de execução para provar o gargalo e propor a correção mínima. |
| [gct-pr-text](skills/gct-pr-text/SKILL.md) | Redige o texto do Pull Request a partir das alterações da branch atual em relação à master, encerrando com o resumo para check-in no TFS. |
| [gct-sdd](skills/gct-sdd/SKILL.md) | Orquestra em paralelo a documentação de múltiplas issues do JIRA — cria `bug-spec.md` e `rca.md` em branches isoladas, uma por issue, sem interação humana. |
| [gct-tests](skills/gct-tests/SKILL.md) | Cria caso de teste de regressão (Kanoah / Adaptavist) e script AdvPR a partir de uma issue do módulo Gestão de Contratos (SIGAGCT). |
| [mario](skills/mario/SKILL.md) | Conduz a resolução de uma issue de manutenção (bug) do Protheus em 6 fases — refinamento de negócio, refinamento técnico e codificação executados pelo agente, com aprovação humana ao final de cada fase. |

## Agentes

| Agente | Descrição |
|---|---|
| [MARIO Agent](agents/mario.agent.md) | Identidade e fluxo do MARIO: as 6 fases, os gates de aprovação e os pré-requisitos. O detalhamento vive na skill `mario`. Disponível em dois formatos equivalentes: `mario.agent.md` (Markdown) e `mario.json` (JSON). |

## Estrutura

```
agents/
├── mario.agent.md
└── mario.json
skills/
├── advpl-tlpp-performance-analysis/
│   ├── SKILL.md
│   ├── references/
│   │   ├── execution-plan-analysis.md
│   │   ├── legacy-vs-smartview.md
│   │   ├── perf-analysis-template.md
│   │   ├── prerequisites.md
│   │   ├── profiler-analysis.md
│   │   └── tlpp-master-rules.md
│   └── scripts/
│       └── Parse-FwLogProfiler.ps1
├── gct-pr-text/
│   └── SKILL.md
├── gct-sdd/
│   ├── SKILL.md
│   └── references/
│       ├── issue-agent.md
│       ├── orchestrator.md
│       └── worktree.md
├── gct-tests/
│   ├── SKILL.md
│   └── references/
│       ├── advpr-test-script-pattern.md
│       ├── FWTestHelper.md
│       ├── GuiaPreenchimentoCasosDeTeste.md
│       └── test-case-template.md
└── mario/
    ├── SKILL.md
    └── references/
        ├── phase-1-business-refinement.md
        ├── phase-2-technical-refinement.md
        └── phase-3-coding.md
```

## Como usar

As skills são consumidas pelo Kiro IDE. Existem duas formas de instalá-las no seu workspace:

### Via extensão Dex (recomendado)

A [extensão Dex](https://github.com/gdesordi/dex-ai) sincroniza skills de repositórios públicos do GitHub diretamente para o diretório correto do workspace (`.kiro/skills/`).

1. Instale a extensão Dex no VS Code ou Kiro.
2. Na view **Fontes de skills Dex** (Explorer), clique em **+** para adicionar uma fonte.
3. Preencha os campos solicitados:
   - **URL**: `https://github.com/sordi-totvs/gct-resources`
   - **Reference**: `main`
   - **Folder**: `skills`
4. A extensão baixa e instala as skills automaticamente. Use o botão de sincronização a qualquer momento para atualizar.

### Manualmente

1. Abra o repositório do módulo (ex.: `gestao-de-contratos`) no Kiro.
2. Copie a pasta da skill desejada para `.kiro/skills/` do repositório alvo.

### Instalando os agentes

A extensão Dex sincroniza apenas o conteúdo da pasta `skills`, então a instalação
dos agentes é manual:

1. Abra o repositório do módulo no Kiro.
2. Copie o arquivo do agente para `.kiro/agents/` do repositório alvo. O MARIO Agent
   está disponível em dois formatos equivalentes — use o `mario.json` (recomendado
   para o Kiro) ou o `mario.agent.md`; basta um dos dois.
3. O agente aparece na lista de agentes do Kiro e pode ser selecionado na sessão.

O agente MARIO Agent depende da skill `mario`: instale as duas.

### Acionando as skills

Após a instalação, acione via chat do Kiro:

- `"rodar gct-sdd DTEXPRO-6805, DTEXPRO-6866"`
- `"criar caso de teste da issue GCT-1234"`
- `"redige o texto do PR"`
- `"analisar performance do relatório Smart View da issue GCT-1234"`
- `"rodar o mario na DTEXPRO-6805"` (ou `"rodar a fase 2 da DTEXPRO-6805"`)

## Licença

MIT
