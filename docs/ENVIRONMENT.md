# Variáveis de Ambiente

Este documento define como configurar ambiente para desenvolvimento local com Docker + emuladores e para produção.

## Arquivos

- .env.example: template versionado com variáveis base.
- .env: arquivo local não versionado (deve ser criado pelo desenvolvedor).

## Setup Local (Docker + Emuladores)

1. Executar make env-init para gerar .env automaticamente.
2. Ajustar portas se houver conflito local.
3. Subir infraestrutura com make infra-up ou make up.

Variáveis usadas pelo docker-compose:

- FIREBASE_PROJECT_ID
- FIREBASE_EMULATOR_UI_PORT
- FIRESTORE_EMULATOR_PORT
- FIREBASE_AUTH_EMULATOR_PORT
- FIREBASE_FUNCTIONS_EMULATOR_PORT
- FIREBASE_MESSAGING_EMULATOR_PORT

Observações:

- O serviço seed-runner usa rede interna do Docker para falar com emuladores.
- Hosts internos no container não devem ser alterados para localhost.

## Setup do App Flutter em Local

- Use USE_EMULATOR=true via --dart-define.
- O app usa host 10.0.2.2 no Android Emulator para acessar serviços locais.

Exemplo:

```bash
flutter run --dart-define=USE_EMULATOR=true
```

## Setup Produção

Produção não usa Docker/emuladores.

Regras:

- USE_EMULATOR=false
- Firebase deve apontar para projeto real
- Credenciais e segredos devem vir de ambiente do provedor de CI/CD, nunca de arquivos versionados

Exemplo de build:

```bash
flutter build apk --release --dart-define=USE_EMULATOR=false
```

## Boas práticas

- Nunca commitar .env com segredos.
- Manter .env.example atualizado sempre que adicionar nova variável.
- Toda variável nova deve ser documentada neste arquivo com contexto de uso.
- Em PRs, informar impacto de variáveis de ambiente no checklist.
