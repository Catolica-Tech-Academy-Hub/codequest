# PROMPT — Agente de IA: Gerar Estrutura Inicial do CodeQuest

## Contexto do Projeto

Você é um engenheiro de software sênior especialista em Flutter, Dart e Firebase. Sua tarefa é gerar toda a estrutura inicial de arquivos do projeto **CodeQuest** — um aplicativo mobile gamificado para ensino de programação — pronto para ser commitado no GitHub como arquitetura base.

O projeto usa:
- **Flutter + Dart** — frontend mobile (Android/iOS)
- **Firebase Firestore** — banco NoSQL em tempo real
- **Firebase Auth** — autenticação
- **Firebase Cloud Functions** — lógica de backend (Node.js)
- **Firebase Cloud Messaging** — notificações push
- **Firebase Storage** — arquivos e avatares
- **Riverpod 2.x** — gerenciamento de estado
- **Hive** — persistência local offline
- **Docker Compose** — emuladores Firebase para desenvolvimento local
- **GitHub Actions** — CI/CD

---

## Tarefa

Gere TODOS os arquivos listados abaixo com conteúdo real e funcional. Não gere stubs vazios — cada arquivo deve ter o conteúdo mínimo necessário para o projeto compilar, rodar e demonstrar a arquitetura escolhida.

---

## Arquivos a Gerar

### Raiz do projeto

**`pubspec.yaml`**
Inclua as seguintes dependências (versões estáveis mais recentes):
- flutter_riverpod, riverpod_annotation
- firebase_core, cloud_firestore, firebase_auth, firebase_storage, firebase_messaging, cloud_functions
- hive, hive_flutter
- go_router
- freezed_annotation, json_annotation
- equatable

Dev dependencies:
- build_runner, riverpod_generator, freezed, json_serializable, hive_generator
- flutter_test, flutter_lints, mocktail

**`analysis_options.yaml`**
Baseado em flutter_lints com regras adicionais:
- prefer_single_quotes
- always_use_package_imports
- avoid_print (use logger)
- require_trailing_commas

**`README.md`**
Inclua:
- Descrição do projeto
- Pré-requisitos
- Comandos para subir o ambiente (docker compose up, flutter run)
- Credenciais do seed: email: dev@codequest.com / senha: Dev@123456
- Estrutura de pastas resumida
- Como alternar entre dev e produção

---

### Docker e Firebase

**`docker-compose.yml`**
Conforme especificado no documento de arquitetura:
- Serviço firebase-emulators com healthcheck
- Serviço seed-runner que depende do healthcheck
- Volume persistente emulator-data
- Portas: 4000 (UI), 8080 (Firestore), 9099 (Auth), 5001 (Functions), 9150 (FCM)

**`Dockerfile.emulators`**
Baseado em node:18-slim com firebase-tools instalado globalmente.

**`firebase/firebase.json`**
Configure os emuladores para Firestore, Auth, Functions e Pub/Sub com as portas corretas.

**`firebase/firestore.rules`**
Regras básicas de segurança:
- Usuário autenticado pode ler/escrever seus próprios dados (users/{uid})
- Trilhas e atividades são leitura pública para autenticados
- Rankings são leitura pública para autenticados, escrita apenas por Cloud Functions (usando admin SDK)

**`firebase/firestore.indexes.json`**
Índices compostos para:
- leagues/{leagueId}/members ordenado por xp DESC
- users/{uid}/xpHistory ordenado por weekStart DESC

**`firebase/functions/package.json`**
Dependências Node.js para as Cloud Functions:
- firebase-admin, firebase-functions
- Dev: typescript (opcional, use JS puro)

**`firebase/functions/index.js`**
Implemente as seguintes Cloud Functions reais:

1. `onLessonCompleted` — Trigger: onWrite em `users/{uid}/progress/{trailId}`. Quando um nível é concluído, atualiza o XP do usuário na sua liga em `leagues/{leagueId}/members/{uid}`.

2. `recalculateLeagueRankings` — Trigger: onWrite em `leagues/{leagueId}/members/{uid}`. Recalcula as posições de todos os membros da liga e salva deltaPosition (variação).

3. `weeklyReset` — Trigger: Cloud Scheduler, toda segunda-feira às 00:00 BRT (cron: `0 3 * * 1`). Reseta weeklyXp de todos os membros, promove top 15 para liga superior, rebaixa bottom 5.

4. `onUserDeleted` — Trigger: Auth `onDelete`. Remove todos os dados do usuário do Firestore (LGPD).

**`firebase/seed/seed.js`**
Script de seed real que popula o banco local com:
- 1 usuário admin: { uid: 'admin-001', email: 'admin@codequest.com', name: 'Admin' }
- 3 usuários de dev: dev@codequest.com, alice@codequest.com, bob@codequest.com (senha: Dev@123456)
- Liga Bronze com os 3 devs como membros
- 1 trilha com 5 níveis: Flutter Básico (Teoria→Quiz→Código→Quiz→Desafio)
- 3 atividades de exemplo para cada tipo

---

### Flutter — lib/

**`lib/main.dart`**
Entry point completo:
- Inicializa Firebase com `await Firebase.initializeApp()`
- Chama `configureFirebase()` para apontar para emuladores em debug
- Inicializa Hive com `await Hive.initFlutter()`
- Envolve o app com `ProviderScope` do Riverpod
- Monta o `MaterialApp.router` com o GoRouter

**`lib/core/firebase_config.dart`**
Conforme descrito no documento de arquitetura:
- Constante `kUseEmulator` via `bool.fromEnvironment('USE_EMULATOR', defaultValue: kDebugMode)`
- Função `configureFirebase()` que aponta para `10.0.2.2` em modo emulador

**`lib/core/router.dart`**
GoRouter com as seguintes rotas:
- `/` → splash/redirect (verifica auth)
- `/login` → LoginPage
- `/register` → RegisterPage
- `/home` → HomePage (shell com bottom nav)
- `/home/trails` → TrailsPage
- `/home/ranking` → RankingPage
- `/home/profile` → ProfilePage
- `/trail/:trailId/level/:levelId` → LevelPage
- Redirect: se não autenticado, manda para /login

**`lib/core/theme.dart`**
ThemeData completo com:
- Cor primária: vermelho escuro (#8B0000) — identidade visual do projeto
- Tipografia: Inter ou Roboto
- Modo escuro e claro definidos

**`lib/features/auth/`**
Estrutura completa do módulo de autenticação:

- `data/auth_repository.dart` — classe `AuthRepository` com métodos:
  - `signIn(email, password)` → Future<UserCredential>
  - `signUp(email, password, name)` → Future<UserCredential>
  - `signOut()` → Future<void>
  - `sendPasswordReset(email)` → Future<void>
  - `authStateChanges` → Stream<User?>

- `providers/auth_providers.dart` — Providers Riverpod:
  - `authRepositoryProvider`
  - `authStateProvider` (StreamProvider)
  - `currentUserProvider`

- `presentation/login_page.dart` — Tela de login funcional com campos email/senha, botão entrar, link para cadastro e esqueci a senha. Use StatefulWidget ou ConsumerWidget.

- `presentation/register_page.dart` — Tela de cadastro com nome, email, senha e confirmar senha.

**`lib/features/ranking/`**

- `data/ranking_repository.dart` — `RankingRepository` com:
  - `getLeagueMembers(leagueId)` → Stream<List<LeagueMember>>
  - `getUserPosition(uid, leagueId)` → Stream<LeagueMember>

- `domain/league_member.dart` — Modelo Freezed:
  ```dart
  @freezed
  class LeagueMember with _$LeagueMember {
    factory LeagueMember({
      required String uid,
      required String name,
      String? avatarUrl,
      required int xp,
      required int position,
      required int deltaPosition,
      required int weeklyXp,
      required String leagueId,
    }) = _LeagueMember;
  }
  ```

- `providers/ranking_providers.dart` — StreamProvider para lista de membros da liga

- `presentation/ranking_page.dart` — Lista com posição, avatar placeholder, nome, XP e seta de variação (verde↑ / vermelho↓)

**`lib/features/trails/`**

- `domain/trail.dart` — Modelo Freezed para trilha (id, title, language, totalLevels)
- `domain/trail_level.dart` — Modelo Freezed para nível (id, type, title, xpReward, order, isUnlocked, isCompleted, stars)
- `domain/level_type.dart` — Enum: theory, quiz, code, challenge
- `data/trails_repository.dart` — métodos para buscar trilhas e progresso
- `providers/trails_providers.dart` — providers Riverpod
- `presentation/trails_page.dart` — Lista de trilhas disponíveis
- `presentation/trail_map_page.dart` — Tela do mapa visual com lista de nós (representação simplificada por ora — Column com Cards para cada nível, mostrando estado visual)

**`lib/features/activities/`**

- `domain/activity.dart` — Modelo Freezed: id, type, question, options (List<String>), correctAnswer, hint, xpReward
- `domain/activity_type.dart` — Enum: multipleChoice, fillInBlank, dragAndDrop, codeOrder
- `data/activities_repository.dart`
- `providers/activities_providers.dart`
- `presentation/activity_page.dart` — Tela base de atividade que renderiza componente diferente por tipo. Por ora, implemente o MultipleChoice funcional.
- `presentation/widgets/multiple_choice_widget.dart` — Widget com 4 opções, feedback visual ao selecionar (verde/vermelho)

**`lib/shared/widgets/`**
- `app_button.dart` — Botão padrão do app com loading state
- `app_text_field.dart` — TextField padrão com validação visual
- `xp_badge.dart` — Badge de XP com ícone e valor
- `streak_indicator.dart` — Indicador de streak (dias consecutivos)
- `league_badge.dart` — Badge de liga (Bronze/Prata/Ouro/Diamante) com cor

**`lib/shared/theme/app_colors.dart`**
Constantes de cores:
```dart
class AppColors {
  static const primary = Color(0xFF8B0000);
  static const bronze  = Color(0xFFCD7F32);
  static const silver  = Color(0xFFC0C0C0);
  static const gold    = Color(0xFFFFD700);
  static const diamond = Color(0xFF89CFF0);
  // ... outras cores
}
```

---

### VS Code

**`.vscode/extensions.json`**
```json
{
  "recommendations": [
    "Dart-Code.flutter",
    "Dart-Code.dart-code",
    "ms-azuretools.vscode-docker",
    "usernamehw.errorlens",
    "aaron-bond.better-comments",
    "PKief.material-icons-theme",
    "eamodio.gitlens",
    "streetsidesoftware.code-spell-checker",
    "streetsidesoftware.code-spell-checker-portuguese-brazilian",
    "nash.awesome-flutter-snippets"
  ]
}
```

**`.vscode/settings.json`** e **`.vscode/launch.json`**
Conforme especificado no documento de arquitetura (formatOnSave, dart-define USE_EMULATOR, configurações de debug DEV e PROD).

---

### CI/CD

**`.github/workflows/ci.yml`**
Pipeline GitHub Actions que roda a cada push e pull request:
1. Checkout
2. Setup Flutter (usando `subosito/flutter-action@v2`, canal stable)
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `flutter analyze`
6. `flutter test`
7. `flutter build apk --release` (apenas na branch main)

---

### .gitignore

**`.gitignore`**
Inclua ignorar:
- `.dart_tool/`, `.flutter-plugins`, `.flutter-plugins-dependencies`
- `build/`, `*.g.dart`, `*.freezed.dart`
- `google-services.json`, `GoogleService-Info.plist` (credenciais reais)
- `firebase/functions/node_modules/`
- `firebase/seed-data/` (dados do emulador local)
- `.env`, `.env.*`

---

## Regras de Geração

1. **Todo código Dart deve ser válido** — use null safety, imports corretos, sem erros de compilação óbvios.
2. **Riverpod 2.x com code generation** — use `@riverpod` annotation onde aplicável.
3. **Freezed para modelos de domínio** — todos os modelos usam `@freezed`.
4. **Separação em camadas** — data (repositórios), domain (modelos), providers, presentation (páginas/widgets).
5. **Sem hardcode de dados** — tudo vem do Firestore emulado via repositórios.
6. **Comentários em português** — o time é brasileiro.
7. **Gere os arquivos na ordem** — raiz → firebase → lib/core → lib/features → lib/shared → .vscode → .github.
8. **Para cada arquivo**, mostre o caminho completo antes do código: `// === lib/features/auth/data/auth_repository.dart ===`

---

## Entrega Esperada

Ao final, o desenvolvedor deve conseguir:
```bash
git clone <repo>
cd codequest
docker compose up -d   # sobe emuladores + seed
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run             # app abre no AVD conectado aos emuladores locais
```

E ver o app funcional com login, lista de trilhas placeholder e ranking placeholder.
