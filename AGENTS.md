# GCT Resources — Instruções para agentes

Este repositório **não contém código de produto**. Ele é o repositório de recursos
compartilhados dos squads **Gestão de Contratos** e **Gestão de Receitas**
(Engenharia Protheus — TOTVS), e o que se versiona aqui são **skills de agente**
(arquivos markdown) consumidas pelo Kiro, além de scripts de apoio e documentação.

Consequência prática: nenhuma tarefa neste repositório compila, executa ou publica
software Protheus. As regras abaixo tratam de **autoria de skills e documentação**.

> Regras de desenvolvimento AdvPL/TLPP (dicionário de dados, MVC, SmartX, SonarQube,
> compilação) pertencem aos repositórios de módulo, não a este arquivo. Quando uma
> skill daqui gerar código AdvPL/TLPP, ela própria deve carregar as convenções
> necessárias no seu `SKILL.md` ou em `references/`.

## Idioma

Português do Brasil em todo conteúdo: skills, documentação, mensagens de commit,
respostas no chat e revisões. Exceção: identificadores técnicos (nomes de funções,
classes, tabelas, campos, parâmetros) e termos de programação, que permanecem na
forma original.

## Estrutura do repositório

```
ai-resources/
├── skills/<nome-da-skill>/
│   ├── SKILL.md          # obrigatório — frontmatter + corpo da skill
│   ├── references/*.md   # opcional — conteúdo carregado sob demanda
│   └── scripts/*         # opcional — scripts determinísticos de apoio
└── agents/
    ├── <nome>.agent.md   # frontmatter YAML + corpo em Markdown
    └── <nome>.json       # formato JSON equivalente do agente
docs/                 # diagramas e material de apoio
.specs/dex/           # uso exclusivo das skills dex-spec-manage / dex-spec-plan
.dex/sync.json        # fontes de skills sincronizadas pela extensão Dex
```

`.kiro/agents` e `.kiro/skills` são **ignorados pelo Git** (`.gitignore`): são
instalados localmente pela extensão Dex e nunca devem ser versionados aqui.

Não leia nem escreva em `.specs/dex/` fora das skills `dex-spec-manage` e
`dex-spec-plan`, conforme `.specs/dex/readme.md`.

## Convenções de autoria de skills

- Uma skill por pasta. O nome da pasta usa **kebab-case** e deve ser idêntico ao
  campo `name` do frontmatter.
- O `SKILL.md` começa com frontmatter YAML contendo, no mínimo, `name`,
  `description` e `license`, mais o bloco `metadata` (`domain`, `maintainer`,
  `author`, `version`, `category` e `depends-on` quando houver dependência de
  outra skill). Siga o formato já usado pelas skills existentes.
- A `description` é o único gatilho de ativação: descreva **o que a skill faz** e
  termine com as frases de acionamento reais, no formato
  `Use quando o usuário disser: ...`. Sem os gatilhos, a skill não é encontrada.
- Aplique **divulgação progressiva**: o `SKILL.md` traz o fluxo e as decisões;
  detalhamento longo (templates, tabelas de referência, exemplos extensos) vai
  para `references/*.md`, referenciado por caminho relativo a partir do `SKILL.md`.
- Prefira delegar transformações determinísticas a um script em `scripts/` em vez
  de descrever a transformação em prosa para o agente executar à mão.
- Ao alterar o comportamento de uma skill, atualize a `version` no `metadata` e
  registre a mudança no `CHANGELOG.md`.

## Precisão do conteúdo

Skills instruem agentes que agem sobre repositórios de produto, então conteúdo
impreciso vira erro em código real.

- Não invente classes, métodos, funções, parâmetros, tabelas ou campos do Protheus.
  Quando a skill precisar citar uma API, ela deve instruir a consulta às fontes de
  verdade (documentação oficial / MCP `advpl-tlpp-mcp-docs`) em vez de fixar
  conhecimento presumido no texto.
- Não documente caminhos, comandos ou arquivos que você não verificou neste
  repositório.
- Ao editar uma skill existente, leia o arquivo inteiro antes de alterar: preserve
  o fluxo e o vocabulário já estabelecidos.

## Manutenção da documentação (obrigatório)

A raiz mantém três arquivos: `AGENTS.md`, `README.md` e `CHANGELOG.md`. Toda
mudança que afete o que o repositório oferece ou como ele é usado exige a
atualização do arquivo correspondente **na mesma tarefa**.

### `README.md`

Atualize quando:

- uma skill for adicionada, renomeada ou removida — ajuste a tabela de skills
  **e** a árvore de estrutura;
- a forma de instalar ou acionar as skills mudar (extensão Dex, cópia manual,
  frases de gatilho);
- requisitos, ferramentas suportadas ou licença mudarem.

Documente apenas o que existe de fato. **Nunca invente** comandos, requisitos ou
funcionalidades: leia os arquivos afetados (por exemplo, a `description` no
frontmatter de cada `skills/*/SKILL.md`) e descreva o comportamento real.

### `CHANGELOG.md`

Padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), com as
categorias `Adicionado`, `Modificado`, `Corrigido`, `Removido` e `Segurança`,
usadas somente quando aplicáveis.

- Registre toda mudança relevante em `## [Não publicado]`, na própria tarefa que a
  produziu.
- Versões publicadas usam data **mensal**: `## [1.0.0] - 2026-09`. **Nunca** use
  dia (`YYYY-MM-DD`).
- Não reescreva o histórico existente sem solicitação; aplique o formato acima às
  entradas novas e às editadas no trabalho atual.

## Git e segurança

- Preserve conteúdo existente: complemente, não sobrescreva.
- Não crie commits, tags, releases ou publicações sem pedido explícito do usuário.
- Nunca faça push direto em `main`.
