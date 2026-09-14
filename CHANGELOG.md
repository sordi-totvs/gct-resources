# Changelog

Todas as mudanças relevantes deste projeto são registradas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).
As datas das versões publicadas usam o formato mensal `YYYY-MM`.

## [Não publicado]

### Adicionado

- `CHANGELOG.md` na raiz do repositório, para registrar o histórico de mudanças.
- `AGENTS.md` com as instruções de agente deste repositório: escopo (repositório de
  skills, sem código de produto), idioma, estrutura, convenções de autoria de skills,
  precisão de conteúdo e manutenção de `README.md` e `CHANGELOG.md`.
- Skill `gct-sdd` — orquestra em paralelo a documentação de múltiplas issues do JIRA,
  criando `bug-spec.md` e `rca.md` em branches isoladas, uma por issue.
- Skill `gct-tests` — cria caso de teste de regressão (Kanoah / Adaptavist) e script
  AdvPR a partir de uma issue do módulo Gestão de Contratos (SIGAGCT).
- Skill `advpl-tlpp-performance-analysis` — análise comparativa de performance entre
  relatório legado (AdvPL/TLPP) e Smart View / TReports, a partir de LogProfiler e
  plano de execução da query do objeto de negócio.
- Skill `gct-pr-text` — redige o texto do Pull Request a partir das alterações da
  branch atual em relação à master, incluindo o resumo para check-in no TFS.
- Skill `mario` — conduz a resolução de uma issue de manutenção (bug) do Protheus em
  6 fases, executando refinamento de negócio, refinamento técnico e codificação com
  aprovação humana ao final de cada fase, gravando todos os artefatos em
  `.specs/mario/{ISSUE}` e delegando às skills `advpl-tlpp-sdd`, `gct-tests`,
  `tdn-technical-doc-writer` e `gct-pr-text`.
- Pasta `agents/` na raiz, novo tipo de recurso do repositório, com o agente
  `mario.agent.md` (identidade, fluxo das 6 fases e gates). A instalação é manual,
  por cópia para `.kiro/agents/` do repositório alvo, porque a extensão Dex
  sincroniza somente a pasta `skills`.
- `agents/mario.json` — versão em JSON do agente MARIO Agent, formato exigido pelo
  Kiro, equivalente ao `mario.agent.md` (campos `name` e `description` mais o corpo
  Markdown no campo `prompt`).
- Steering `mario-agent-sync` (em `.kiro/steering/`) instruindo a manter
  `mario.agent.md` e `mario.json` sempre sincronizados na mesma tarefa.
- Documento `docs/protheus-ia.excalidraw` com o fluxo de uso do Dex.

### Modificado

- `README.md`: catálogo de skills e árvore de estrutura atualizados para incluir
  `advpl-tlpp-performance-analysis` e `gct-pr-text`.
- `README.md`: seção de agentes, skill `mario` no catálogo, pasta `agents/` na árvore
  de estrutura e instruções de instalação do agente.
- Skill `gct-pr-text` (1.1.0): a gravação do texto do PR em arquivo, quando pedida
  explicitamente, deixa de ser contrariada pela tabela de escopo e pelo checklist
  final — o arquivo passa a ser adicional à entrega no chat, não substituto dela.
- Agente renomeado de `MARIO` para `MARIO Agent` no `mario.agent.md` e no
  `mario.json`, para que o agente tenha nome distinto da skill `mario`. `README.md`
  atualizado (catálogo de agentes, árvore de estrutura e instalação).
- Skill `mario` (1.1.0): passa a ler as steerings do repositório alvo
  (`.kiro/steering/*.md`) no preflight, classificá-las por `inclusion` (antecipando
  as `fileMatch`), extrair as regras concretas para a nova seção "Steerings
  aplicáveis" do `mario.status.md` e repassá-las às skills delegadas (`gct-tests`,
  `advpl-tlpp-sdd`, `tdn-technical-doc-writer`) em bloco de regras que prevalece
  sobre os defaults delas. A declaração do `ancestor_id` no `technical-doc.md`
  passou a ser condicional: resolvido pela convenção quando uma steering o fixa, só
  pendência quando nenhuma steering resolve o valor.

### Corrigido

- Agente MARIO Agent (`mario.agent.md` e `mario.json`) não enxergava as ferramentas
  do MCP `advpl-tlpp-mcp-docs`, embora o servidor funcione no agente default. Como
  agente customizado, ele não herda os servidores do `mcp.json` sem declaração
  explícita. Adicionados os campos `includeMcpJson: true`, `tools: ["*"]` e
  `allowedTools: ["@advpl-tlpp-mcp-docs"]` em ambos os formatos, mantendo a paridade.
