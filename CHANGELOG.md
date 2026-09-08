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
- Documento `docs/protheus-ia.excalidraw` com o fluxo de uso do Dex.

### Modificado

- `README.md`: catálogo de skills e árvore de estrutura atualizados para incluir
  `advpl-tlpp-performance-analysis` e `gct-pr-text`.
