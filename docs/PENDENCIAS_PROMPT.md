# Pendências do Prompt Inicial

Este documento consolida, em um único lugar, o que ainda falta implementar em relação ao prompt inicial e o que não faz mais sentido manter como artefato ativo.

## O que manter do prompt

- Referência de stack oficial do projeto (Flutter, Firebase, Riverpod, Hive, Docker, CI).
- Estrutura por feature com camadas data, domain, providers e presentation.
- Regras de arquitetura e separação de responsabilidades.
- Lista de funcionalidades alvo para evolução incremental.

## O que remover do prompt como artefato operacional

- Documento de prompt longo como checklist de execução diária.
- Instruções de geração em lote de arquivos que já foram implementados.
- Duplicação de orientações já cobertas em docs/ARCHITECTURE.md, docs/ENGINEERING_GUIDELINES.md e AGENTS.md.

Sugestão prática:

- Tratar docs/prompt_agente_codequest.md como histórico de bootstrap.
- Usar este documento como backlog curto de execução.

## Pendências técnicas atuais

### Firebase Functions

- Implementar triggers reais em firebase/functions/index.js:
  - onLessonCompleted
  - recalculateLeagueRankings
  - weeklyReset
  - onUserDeleted

### Ranking (feature)

- Criar domain model com Freezed para LeagueMember.
- Criar repository e providers de ranking conectados ao Firestore.
- Substituir placeholders visuais por dados reais da liga.

### Trails (feature)

- Criar modelos de domínio Trail e TrailLevel com Freezed.
- Criar repositório e providers para trilhas/progresso.
- Implementar trail_map_page.dart com estado de desbloqueio.

### Activities (feature)

- Criar modelos Activity e ActivityType.
- Criar repositório e providers de atividades.
- Implementar activity_page.dart com multiple choice funcional e widget dedicado.

### Auth (primeira implementação completa)

- Aplicar casos de uso explícitos na camada de domínio/aplicação.
- Adicionar validações de Value Objects (email, senha, nome).
- Cobrir fluxo de sessão com testes unitários e de providers.

### Qualidade e testes

- Adicionar testes para casos de uso de autenticação.
- Adicionar testes para repositórios de ranking/trilhas/activities.
- Configurar estratégia mínima de testes de integração com emuladores.

## Critério para encerrar esta lista

- Todas as features essenciais em modo funcional usando dados reais do Firestore local.
- Sem placeholders de dados hardcoded em presentation.
- Cobertura mínima de testes para fluxos críticos de auth e sessão.
