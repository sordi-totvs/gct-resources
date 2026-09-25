# GCT Resources

Repositório de recursos compartilhados para os squads **Gestão de Contratos** e **Gestão de Receitas** (Engenharia Protheus — TOTVS).

Contém skills do Kiro utilizadas no dia a dia dos times para automação de documentação, especificação e testes.

## Skills

| Skill | Descrição |
|---|---|
| [mario](ai-resources/skills/mario/SKILL.md) | Resolve uma issue do Protheus por execução, de forma interativa e com gate humano por fase, em um de dois fluxos escolhidos pelo issuetype do JIRA: manutenção (bug) em 6 fases, ou apoio (`Apoio` / `Apoio - Cliente`) em 2 fases — entende o pedido (`support-request.md`) e produz um parecer com sugestão de resposta (`support-response.md`), sem alterar código. |
| [gct-sdd](ai-resources/skills/gct-sdd/SKILL.md) | Orquestra em paralelo a documentação de múltiplas issues do JIRA — cria `bug-spec.md` e `rca.md` em branches isoladas, uma por issue, sem interação humana. |
| [gct-tests](ai-resources/skills/gct-tests/SKILL.md) | Cria caso de teste de regressão (Kanoah / Adaptavist) e script AdvPR a partir de uma issue do módulo Gestão de Contratos (SIGAGCT). |
| [gct-pr-text](ai-resources/skills/gct-pr-text/SKILL.md) | Redige o texto do Pull Request a partir das alterações da branch atual em relação à master, incluindo o resumo para check-in no TFS. |
| [advpl-tlpp-performance-analysis](ai-resources/skills/advpl-tlpp-performance-analysis/SKILL.md) | Análise comparativa de performance entre relatório legado (AdvPL/TLPP) e Smart View / TReports, a partir de LogProfiler e do plano de execução da query do objeto de negócio. |

## Agentes

| Agente | Descrição |
|---|---|
| [MARIO Agent](ai-resources/agents/mario.agent.md) | Identidade e mapa do MARIO: carrega a skill `mario` e conduz o fluxo de manutenção (6 fases) ou de apoio (2 fases) conforme o issuetype. Disponível em `mario.agent.md` e no formato JSON `mario.json`. |

## Estrutura

```
ai-resources/
├── agents/
│   ├── mario.agent.md
│   └── mario.json
└── skills/
    ├── mario/
    │   ├── SKILL.md
    │   └── references/
    │       ├── flow-support.md
    │       ├── phase-1-business-refinement.md
    │       ├── phase-2-technical-refinement.md
    │       └── phase-3-coding.md
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
    ├── gct-pr-text/
    │   └── SKILL.md
    └── advpl-tlpp-performance-analysis/
        ├── SKILL.md
        ├── references/
        │   ├── execution-plan-analysis.md
        │   ├── legacy-vs-smartview.md
        │   ├── perf-analysis-template.md
        │   ├── prerequisites.md
        │   ├── profiler-analysis.md
        │   └── tlpp-master-rules.md
        └── scripts/
            └── Parse-FwLogProfiler.ps1
```

O agente MARIO Agent não é sincronizado pela extensão Dex (ela cobre apenas a
pasta `skills`); instale-o manualmente copiando `mario.agent.md` e `mario.json`
para `.kiro/agents/` do repositório alvo.

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

### Acionando as skills

Após a instalação, acione via chat do Kiro:

- `"rodar o mario na DTEXPRO-6805"` — fluxo escolhido pelo issuetype da issue
- `"responder o apoio da DTEXPRO-6900"` — fluxo de apoio
- `"rodar gct-sdd DTEXPRO-6805, DTEXPRO-6866"`
- `"criar caso de teste da issue GCT-1234"`

## Licença

MIT
