# MARIO

## Descrição

Descrição: Criar um agente autônomo responsável pela resolução de issues de manutenção (bugs) do sistema Totvs Protheus. O agente atuará como parte de uma equipe de desenvolvedores.

## Fases

O fluxo de solução de uma issue passa por 6 fases. As fases 1 a 3 serão realizadas pelo agente, passando pela validação e aprovação de um humano no final de cada uma. As fases 4 a 6 serão feitas por um humano.

1 - Refinamento de negócio
Nessa fase, a issue aberta pelo time de atendimento ao cliente é avaliada para determinar, principalmente, se realmente se trata de um bug. Essa fase deve gerar um documento .md respondendo as seguintes perguntas:
- Qual é a jornada do usuário para reproduzir o erro?
- Qual seria o comportamento esperado?
- Qual é o comportamento atual?
- Existe algum documento no TDN, um padrão forte de mercado, uma norma ou lei que apoia a definição do comportamento esperado? Se sim, quais?
Também deve apresentar uma nota de confiabilidade dessas respostas, de 0 a 10. Vamos decidir juntos os critérios para a definição dessa nota.
Nós vamos criar uma skill para analisar diferentes fontes de informação, inclusive o próprio código, para responder a essas perguntas.

2 - Refinamento técnico
Nessa fase o código é analisado a fundo para determinar, principalmente, a causa raiz do bug. Serão gerados 3 documentos: 
- Bug Spec
- RCA
- Documento de caso de teste de regressão

3 - Codificação
Nessa fase serão implementados os ajustes. O código deve ser alterado o mínimo possível para resolver o bug pontualmente. Se outros problemas forem encontrados, um relatório deve ser gerado para o usuário analisar se eles também devem ser corrigidos ou não.
Nessa fase, serão entregues:
- Documento de tasks
- Codificação do erro (execução de todas as tasks)
- Codificação da automação em ADVPR
- Documento técnico em arquivo .md
- Texto do Pull Request em arquivo .md

4 - Validação
Um humano vai validar tudo o que foi feito nas fases anteriores e seguir com o pull request manualmente.

5 - Code Review
Um humano vai pedir para o agente fazer o code review, e vai analisar o que deve ou não ser reportado. Depois, vai prosseguir com o merge.

6 - Teste de Aceitação
As esteiras de CI/CD vão gerar o pacote .ptm e um humano vai fazer a última validação antes da entrega para o cliente.

## Regras

Algumas skills vão tentar usar pastas específicas para salvar os arquivos de especificação, mas quero que eles sejam organizados na pasta .specs/mario/{issue}.

## Pré-requisitos

Para o agente funcionar corretamente, deve estar disponível no ambiente o MCP server `advpl-tlpp-mcp-docs`. Se ele não estiver disponível, o agente deve informar ao usuário, explicar que a qualidade da análise será impactada e perguntar se o usuário quer continuar mesmo assim.

As skills abaixo são pré-requisitos e, se não estiverem disponíveis, o agente não deve continuar:
- advpl-tlpp-root-cause-analysis
- advpl-tlpp-sdd
- kanoah-advpr-generator
- tdn-technical-doc-writer