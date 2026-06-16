# CodeQuest - Firebase e Publicacao Android

Este guia descreve o caminho para sair do ambiente local com Firebase Emulators e publicar o app Android usando um projeto real no Firebase e Google Play Console.

## Estado atual

- O desenvolvimento local usa Firebase Emulator Suite via Docker.
- O app roda com `--dart-define=USE_EMULATOR=true`.
- `lib/core/firebase_config.dart` usa opcoes locais placeholder para bootstrap.
- O Android usa `applicationId = "com.example.codequest"`, que deve ser trocado antes de producao.
- O build release ainda assina com a chave debug em `android/app/build.gradle.kts`.
- `firebase/.firebaserc` aponta para `codequest-local`.

## 1. Criar o projeto real no Firebase

1. Acesse o Firebase Console: https://console.firebase.google.com/
2. Crie um projeto, por exemplo `codequest-prod`.
3. Ative os produtos usados pelo app:
   - Authentication.
   - Cloud Firestore.
   - Cloud Functions.
   - Cloud Storage, se o app for usar avatar/arquivos.
   - Cloud Messaging, se o app for usar notificacoes push.
4. No Authentication, habilite o provedor `Email/password`.
5. No Firestore, crie o banco em modo nativo e escolha a regiao antes de publicar dados reais.

## 2. Baixar/configurar a "planta" Firebase no Flutter

No Flutter, a forma recomendada e usar Firebase CLI + FlutterFire CLI. Isso registra o app Android no projeto Firebase e gera os arquivos de configuracao.

Instale ou atualize as CLIs:

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

Configure o app Android:

```powershell
flutterfire configure `
  --project=<firebase-project-id> `
  --platforms=android `
  --android-package-name=<package-id-real>
```

Resultado esperado:

- `lib/firebase_options.dart` gerado.
- `android/app/google-services.json` criado ou atualizado.
- App Android registrado no Firebase com o package id escolhido.

Decisao para este projeto:

- Versionar `lib/firebase_options.dart`, porque ele e necessario para builds reproduziveis e nao contem segredo privado.
- Decidir se `android/app/google-services.json` sera versionado ou injetado por CI. Hoje `.gitignore` ignora esse arquivo; se a estrategia for versionar, remover essa linha do `.gitignore`.
- Nao versionar chaves de assinatura, `key.properties`, `.jks`, `.keystore`, `.env` ou credenciais de service account.

## 3. Alteracoes necessarias no app antes de producao

1. Trocar o package id Android:

```kotlin
namespace = "br.com.codequest.app"
applicationId = "br.com.codequest.app"
```

2. Atualizar inicializacao Firebase:

- Substituir as opcoes placeholder de `AppFirebaseOptions.currentPlatform` pelo arquivo gerado pelo FlutterFire CLI.
- Em producao, rodar com `USE_EMULATOR=false`.
- Manter `USE_EMULATOR=true` somente para desenvolvimento local.

3. Configurar assinatura release:

- Criar uma upload key local segura.
- Criar `android/key.properties` local, nao versionado.
- Atualizar `android/app/build.gradle.kts` para usar `signingConfigs.release`.
- Gerar Android App Bundle assinado para Play Store.

4. Ajustar versao do app em `pubspec.yaml` antes de cada release:

```yaml
version: 1.0.0+1
```

## 4. Deploy do backend Firebase

Antes de deploy:

```powershell
firebase login
firebase use <firebase-project-id>
```

Deploy inicial recomendado:

```powershell
firebase deploy --only firestore,functions
```

Deploys separados quando necessario:

```powershell
firebase deploy --only firestore
firebase deploy --only functions
```

Observacoes:

- `firebase/firebase.json` ja referencia regras e indices do Firestore.
- Antes de publicar, revisar `firebase/firestore.rules`.
- Functions usam Node 18 no `package.json`; use Node 18 localmente ou rode installs via ambiente compativel.
- Nao rodar seed de desenvolvimento contra producao sem script separado e revisado.

## 5. Build Android de producao

Validar localmente:

```powershell
make analyze
make test
```

Build de producao:

```powershell
flutter build appbundle --release --dart-define=USE_EMULATOR=false
```

Artefato esperado:

```text
build/app/outputs/bundle/release/app-release.aab
```

Use `.aab` para Google Play. APK release pode ser util para validacao manual fora da loja, mas a Play Store prioriza Android App Bundle.

## 6. Publicar na Google Play Console

1. Criar conta de desenvolvedor na Google Play Console.
2. Criar o app com o mesmo package id usado no Android.
3. Preencher:
   - Nome do app.
   - Categoria.
   - Politicas de privacidade.
   - Data safety.
   - Classificacao indicativa.
   - Publico alvo.
   - Store listing com screenshots, icone e descricao.
4. Criar release em teste interno primeiro.
5. Enviar o arquivo `.aab`.
6. Validar instalacao pelo link de teste.
7. Depois de validar, promover para teste fechado/aberto ou producao conforme a situacao da conta.

## 7. Checklist antes do primeiro release

- Package id real definido e definitivo.
- Projeto Firebase real criado.
- App Android registrado no Firebase.
- `firebase_options.dart` gerado e usado pelo app.
- `google-services.json` disponivel no build local/CI.
- `USE_EMULATOR=false` validado em build release.
- Firestore rules revisadas.
- Functions testadas em ambiente real ou staging.
- Assinatura release configurada sem chave debug.
- `flutter build appbundle --release --dart-define=USE_EMULATOR=false` concluindo sem erro.
- Teste interno publicado e instalado em dispositivo real.

## Referencias oficiais

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase CLI e deploy: https://firebase.google.com/docs/cli
- FlutterFire CLI: https://firebase.flutter.dev/docs/cli/
- Android app signing: https://developer.android.com/studio/publish/app-signing
- Google Play internal testing: https://support.google.com/googleplay/android-developer/answer/9845334
