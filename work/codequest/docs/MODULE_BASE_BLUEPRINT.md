# Módulo Base de Referência

Este documento descreve o padrão mínimo para evolução de novas features com separação clara entre frontend e backend.

## Objetivo

Garantir consistência de arquitetura, com papéis explícitos para actions, controllers e repository.

## Frontend (Flutter)

Estrutura de referência:

```text
lib/features/sample_module/
  domain/
    entities/
    repositories/
  application/
    actions/
  data/
    repositories/
  presentation/
    controllers/
    sample_page.dart
  providers/
```

Responsabilidades:

- domain: entidades e contratos de repositório.
- application/actions: casos de uso sem dependência de Flutter.
- data/repositories: implementação concreta (Firestore, API, cache).
- presentation/controllers: coordena ações para UI.
- providers: composição de dependências e estado.

## Backend (Firebase Functions)

Estrutura de referência:

```text
firebase/functions/modules/sample/
  repositories/
  actions/
  controllers/
  index.js
```

Responsabilidades:

- repositories: acesso ao Firestore.
- actions: regra de aplicação/negócio do endpoint.
- controllers: traduz HTTP para ações e respostas.
- index.js do módulo: composição de dependências.

## Fluxo padrão

1. UI chama controller.
2. Controller chama action.
3. Action chama contrato de repository.
4. Repository persiste/consulta dados.
5. Resultado volta para UI com tipo de domínio.

## Como identificar violações

- Se controller manipula detalhes de banco, está errado.
- Se action importa Flutter ou HTTP framework diretamente, está errado.
- Se repository contém regra de negócio de ranking/progressão, está errado.

## Arquivos de exemplo já criados

- Front:
  - lib/features/sample_module/domain/entities/sample_item.dart
  - lib/features/sample_module/domain/repositories/sample_repository_contract.dart
  - lib/features/sample_module/application/actions/create_sample_action.dart
  - lib/features/sample_module/application/actions/watch_samples_action.dart
  - lib/features/sample_module/data/repositories/sample_repository_impl.dart
  - lib/features/sample_module/presentation/controllers/sample_controller.dart
  - lib/features/sample_module/providers/sample_providers.dart
  - lib/features/sample_module/presentation/sample_page.dart

- Back:
  - firebase/functions/modules/sample/repositories/sample_repository.js
  - firebase/functions/modules/sample/actions/create_sample_action.js
  - firebase/functions/modules/sample/actions/list_samples_action.js
  - firebase/functions/modules/sample/controllers/sample_controller.js
  - firebase/functions/modules/sample/index.js
  - firebase/functions/index.js (endpoint sampleApi)
