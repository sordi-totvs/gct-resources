# Sincronização do agente MARIO Agent (.md e .json)

O agente MARIO Agent existe em dois formatos equivalentes na pasta `agents/`:

- `agents/mario.agent.md` — frontmatter YAML + corpo em Markdown (prompt do sistema);
- `agents/mario.json` — os mesmos campos em JSON, com o corpo do Markdown no campo `prompt`.

Os dois arquivos descrevem o **mesmo** agente e precisam permanecer idênticos em
conteúdo. Toda alteração em um deles obriga a alteração equivalente no outro, na
mesma tarefa.

## Regras

- Ao editar `agents/mario.agent.md`, replique a mudança em `agents/mario.json`, e
  vice-versa. Nenhum dos dois pode ficar para trás.
- Mantenha a paridade de campos: `name` e `description` do frontmatter equivalem às
  chaves `name` e `description` do JSON; o corpo Markdown (a partir do título `#`)
  equivale ao campo `prompt` do JSON.
- O `name` do agente é `MARIO Agent`, diferente do `name` da skill (`mario`). Não
  reunifique os dois nomes: agente e skill precisam ter nomes distintos.
- Ao validar, confirme que `agents/mario.json` é JSON válido antes de concluir a
  tarefa.
- Se um dos formatos for renomeado ou removido, atualize `README.md` e
  `CHANGELOG.md` na mesma tarefa, conforme o `AGENTS.md`.
