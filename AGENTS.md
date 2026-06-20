# AGENTS - Regras de Desenvolvimento do CodeQuest

Este arquivo orienta agentes de IA e desenvolvedores para manter consistência arquitetural no projeto.

## Princípios Obrigatórios

- Seguir Clean Architecture por feature.
- Aplicar DDD tático para regras de domínio.
- Aplicar SOLID em todas as camadas.
- Evitar lógica de negócio em widgets.
- Preservar separação de responsabilidades entre camadas.
- Não quebrar contratos públicos existentes sem versionamento claro.

## SOLID Aplicado no Projeto

### S - Single Responsibility Principle

- Widget renderiza UI.
- Use case executa regra de negócio.
- Repositório apenas acessa fonte de dados.

Regra para IA: se uma classe está validando regra, chamando Firebase e renderizando estado ao mesmo tempo, ela está errada.

### O - Open/Closed Principle

- Extender comportamento por novos casos de uso/implementações.
- Evitar editar classes estáveis para cada nova regra.

Regra para IA: adicionar novo provider/caso de uso em vez de inflar classe antiga com ifs de cenário.

### L - Liskov Substitution Principle

- Toda implementação concreta deve respeitar o contrato da abstração.
- Não mudar semântica do método herdado/interface.

Regra para IA: implementação de repositório não pode lançar comportamento inesperado fora do contrato definido no domínio.

### I - Interface Segregation Principle

- Interfaces pequenas e focadas por capacidade.
- Evitar contratos gigantes com métodos não usados.

Regra para IA: quebrar AuthRepositoryContract em capacidades menores quando necessário (ex.: sessão, cadastro, recuperação).

### D - Dependency Inversion Principle

- Camadas altas dependem de abstrações.
- Data depende de contrato do domínio, nunca o inverso.

Regra para IA: domínio não pode importar firebase_auth, cloud_firestore, flutter ou detalhes de infraestrutura.

## Anti-padrões Proibidos para IA

- Colocar regra de negócio dentro de Widget, Provider ou Controller de UI.
- Importar Firebase diretamente em classes de domínio.
- Criar função utilitária genérica sem contexto de domínio para esconder regra.
- Misturar DTO de API com entidade de domínio.
- Resolver tudo com classe singleton global mutável.

## Organização de Feature

Cada feature deve seguir:

```text
lib/features/<feature>/
  data/
  domain/
  providers/
  presentation/
```

## Fluxo de Implementação Padrão

1. Definir regras de domínio e casos de uso.
2. Definir contratos (repositórios/serviços).
3. Implementar adapters de dados (Firebase/local).
4. Expor providers para UI.
5. Implementar telas/widgets finos.
6. Criar testes essenciais.

## Padrões para Agentes de IA

- Antes de editar, revisar docs/ARCHITECTURE.md e docs/ENGINEERING_GUIDELINES.md.
- Toda nova implementação deve citar explicitamente a camada alterada.
- Se surgir ambiguidade, priorizar domínio e contratos.
- Propostas de refatoração devem minimizar impacto em rotas e providers públicos.

## Comandos do Projeto

- make up
- make infra-up
- make bootstrap
- make analyze
- make test

## Links de Documentação

- Arquitetura: docs/ARCHITECTURE.md
- Boas práticas: docs/ENGINEERING_GUIDELINES.md
- Core auth: docs/BUSINESS_CORE_AUTH.md
- Prompt base: prompt_agente_codequest.md
- Flutter docs: https://docs.flutter.dev/
- Firebase docs: https://firebase.google.com/docs
- Riverpod docs: https://riverpod.dev/
