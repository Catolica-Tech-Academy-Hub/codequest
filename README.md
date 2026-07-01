# CodeQuest

Plataforma gamificada de aprendizado de programação, construída com Flutter, Firebase e Riverpod.

---

## Sumário

1. [Visão geral da stack](#1-visão-geral-da-stack)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Primeiro setup (Windows)](#3-primeiro-setup-windows)
4. [Primeiro setup (terminal / make)](#4-primeiro-setup-terminal--make)
5. [Rodando o app no dia a dia](#5-rodando-o-app-no-dia-a-dia)
6. [Comandos disponíveis (Makefile)](#6-comandos-disponíveis-makefile)
7. [Serviços disponíveis em desenvolvimento](#7-serviços-disponíveis-em-desenvolvimento)
8. [Usuários de teste](#8-usuários-de-teste)
9. [Arquitetura e padrões de código](#9-arquitetura-e-padrões-de-código)
10. [Estrutura de Dados e Backend (MVP)](#10-estrutura-de-dados-e-backend-mvp)
11. [Contribuindo (branch, commit e PR)](#11-contribuindo-branch-commit-e-pr)
12. [Solução de problemas](#12-solução-de-problemas)

---

## 1. Visão geral da stack

| Tecnologia              | Papel                                            |
| ----------------------- | ------------------------------------------------ |
| Flutter + Dart          | App mobile (Android)                             |
| Firebase Auth           | Autenticação de usuários                         |
| Cloud Firestore         | Banco de dados NoSQL                             |
| Firebase Functions      | Lógica server-side em Node.js                    |
| Firebase Emulator Suite | Ambiente local completo via Docker               |
| Riverpod 2.x            | Injeção de dependência e gerenciamento de estado |
| Docker Compose          | Orquestração dos emuladores Firebase             |
| Node.js 18+             | Runtime das Functions e scripts de seed          |

---

## 2. Pré-requisitos

Instale as ferramentas abaixo antes de qualquer coisa:

| Ferramenta                 | Versão mínima        | Download                                             |
| -------------------------- | -------------------- | ---------------------------------------------------- |
| Flutter SDK (canal stable) | 3.x                  | https://docs.flutter.dev/get-started/install/windows |
| Android Studio             | Flamingo ou superior | https://developer.android.com/studio                 |
| Docker Desktop             | 24+                  | https://www.docker.com/products/docker-desktop       |
| Node.js                    | 18 LTS               | https://nodejs.org                                   |
| Git                        | 2.x                  | https://git-scm.com                                  |

> **Dica:** Para rodar `make` no Windows, use **Git Bash**, **MSYS2** ou **WSL**.
> Se preferir não usar `make`, use os scripts `.bat` descritos na seção seguinte.

Validação rápida após instalar:

```bash
flutter --version
docker --version
docker compose version
node --version
```

### Passo obrigatório: Android SDK Command-line Tools

O Android Studio não instala essa ferramenta por padrão, e ela é necessária para criar o emulador.

1. Abra o **Android Studio**
2. Na tela inicial, clique em **More Actions → SDK Manager**
   (ou, se já tiver um projeto aberto, vá em **Tools → SDK Manager**)
3. Clique na aba **SDK Tools**
4. Marque **Android SDK Command-line Tools (latest)**
5. Clique **Apply** e aguarde o download concluir

> Esse passo só precisa ser feito uma vez por máquina.

---

## 3. Primeiro setup (Windows)

Se você está no Windows e quer um setup com clique duplo, use os scripts `.bat`:

### 3.1 Clonar o repositório

```
git clone <URL_DO_REPOSITORIO>
cd codequest
```

### 3.2 Executar o setup

```
setup-dev.bat
```

O que esse script faz, em ordem:

1. Verifica se Flutter, Docker (em execução) e Node.js estão instalados
2. Verifica se o Android SDK e o `cmdline-tools` estão presentes
3. Configura `ANDROID_HOME` e `ANDROID_SDK_ROOT` permanentemente nas variáveis de ambiente do usuário
4. Instala a system image `android-35;google_apis;x86_64` (se ausente)
5. Aceita todas as licenças do Android SDK
6. Cria o emulador `Pixel8_API35` (se ausente)
7. Instala dependências Flutter (`flutter pub get`) e Node.js das functions e seed
8. Cria o arquivo `.env` a partir de `.env.example` (se não existir)
9. Sobe o Firebase Emulator Suite via `docker compose up -d --build`

> O script é idempotente: pode ser executado várias vezes sem problemas.

---

## 4. Primeiro setup (terminal / make)

### 4.1 Clonar o repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd codequest
```

### 4.2 Configurar o ambiente local

```bash
make env-init
```

Cria o arquivo `.env` a partir de `.env.example`.

### 4.3 Subir a infraestrutura completa

```bash
make infra-up
```

O que esse comando faz automaticamente:

- Configura `ANDROID_HOME` e `ANDROID_SDK_ROOT` permanentemente
- Instala a system image `android-35;google_apis;x86_64` (se ausente)
- Aceita todas as licenças do SDK
- Cria o emulador `Pixel8_API35` (se ausente)
- Sobe o Docker + Firebase Emulators

### 4.4 Instalar dependências do app

```bash
flutter pub get
```

---

## 5. Rodando o app no dia a dia

### Windows (bat)

```
run-dev.bat
```

### Terminal / make

```bash
make run-dev
```

O que acontece ao executar:

1. Verifica se o emulador `Pixel8_API35` já está rodando
2. Se não estiver, inicia o emulador com renderização segura (`swiftshader_indirect`) e aguarda o boot completo
3. Roda `flutter run --dart-define=USE_EMULATOR=true --no-enable-impeller`

O flag `USE_EMULATOR=true` faz o app apontar para os emuladores locais do Firebase em vez da produção.

### Fluxo recomendado no PowerShell

Primeira subida completa:

```powershell
make up
```

Rodar apenas o app depois que a infra já está ativa:

```powershell
make run-dev
```

Parar somente o app Flutter:

```text
q
```

ou `Ctrl + C` no terminal onde o Flutter está rodando.

Parar Firebase/Docker:

```powershell
make down
```

Reiniciar tudo do zero:

```powershell
make down
adb emu kill
make up
```

---

## 6. Comandos disponíveis (Makefile)

| Comando              | O que faz                                                 |
| -------------------- | --------------------------------------------------------- |
| `make infra-up`      | Setup completo: Android SDK + Docker + Firebase Emulators |
| `make infra-down`    | Para e remove os containers Docker                        |
| `make down`          | Alias de `make infra-down`                                |
| `make run-dev`       | Inicia emulador (se necessário) + `flutter run`           |
| `make up`            | `infra-up` + `bootstrap` + `run-dev`                      |
| `make bootstrap`     | Instala dependências e roda geração de código             |
| `make analyze`       | `flutter analyze`                                         |
| `make test`          | `flutter test`                                            |
| `make ci`            | `bootstrap` + `analyze` + `test` (usado em pipeline)      |
| `make seed`          | Popula o Firestore com dados de teste                     |
| `make android-setup` | Configura Android SDK isoladamente (sem Docker)           |
| `make env-init`      | Cria `.env` a partir de `.env.example`                    |

---

## 7. Serviços disponíveis em desenvolvimento

| Serviço              | URL / Endereço        |
| -------------------- | --------------------- |
| Firebase Emulator UI | http://localhost:4000 |
| Authentication       | localhost:9099        |
| Firestore            | localhost:8080        |
| Cloud Functions      | localhost:5001        |

### Logs locais

Logs do app Android/Flutter:

```powershell
adb logcat | Select-String "flutter|FirebaseAuth|RecaptchaCallWrapper|Cleartext|E/flutter|FATAL|Exception"
```

Últimas linhas do app Android/Flutter:

```powershell
adb logcat -d -t 400 | Select-String "flutter|FirebaseAuth|RecaptchaCallWrapper|Cleartext|E/flutter|FATAL|Exception"
```

Logs dos emuladores Firebase:

```powershell
make logs
```

Status dos containers:

```powershell
docker compose ps
```

---

## 8. Usuários de teste

Os usuários abaixo são criados automaticamente pelo seed ao subir o emulador:

| E-mail              | Senha      |
| ------------------- | ---------- |
| dev@codequest.com   | Dev@123456 |
| alice@codequest.com | Dev@123456 |
| bob@codequest.com   | Dev@123456 |
| admin@codequest.com | Dev@123456 |

Para repopular os dados de teste:

```bash
make seed
```

---

## 9. Arquitetura e padrões de código

O projeto segue **Clean Architecture por feature**, **DDD tático** e **SOLID** em todas as camadas.

### Estrutura de uma feature

```
lib/features/<feature>/
  domain/          → entidades, contratos, value objects (sem dependências externas)
  application/     → casos de uso e regras de negócio
  data/            → implementações concretas (Firebase, HTTP, local)
  providers/       → injeção de dependência via Riverpod
  presentation/    → telas e widgets (somente renderização)
```

### Regras invioláveis

- A camada `domain` **nunca** importa Firebase, Flutter ou qualquer detalhe de infraestrutura
- Widgets **não** contêm regra de negócio
- Repositórios **apenas** acessam a fonte de dados
- Use cases **orquestram** as operações de domínio

### Documentação de referência

| Documento                                                          | Descrição                                   |
| ------------------------------------------------------------------ | ------------------------------------------- |
| [`AGENTS.md`](AGENTS.md)                                           | Regras para agentes de IA e devs            |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)                     | Arquitetura detalhada                       |
| [`docs/ENGINEERING_GUIDELINES.md`](docs/ENGINEERING_GUIDELINES.md) | Boas práticas de engenharia                 |
| [`docs/BUSINESS_CORE_AUTH.md`](docs/BUSINESS_CORE_AUTH.md)         | Regras de negócio do módulo de autenticação |
| [`docs/RELEASE_AND_FIREBASE.md`](docs/RELEASE_AND_FIREBASE.md)     | Firebase real, release e publicação Android |

---

## 10. Estrutura de Dados e Backend (MVP)

A modelagem do banco de dados (Cloud Firestore) foi estruturada para atender aos requisitos de gamificação e trilhas de aprendizado, garantindo a persistência do estado do usuário e a correção automática das atividades.

**Requisitos Atendidos (Tarefa BE-01):**
* ✅ **Autenticação e Perfil:** Estrutura de usuários (`/users`) com tracking de XP, ligas e ofensivas (streak).
* ✅ **Motor Gamificado:** Modelagem das trilhas (`/trails`), níveis e atividades (`/activities`), suportando múltiplos formatos de desafios.
* ✅ **Módulo de Ligas:** Estrutura relacional via subcoleções (`/leagues/{id}/members`) para viabilizar o Ranking.
* ✅ **Segurança:** Implementação de `firestore.rules` garantindo que dados sensíveis (como histórico de XP) sejam acessados apenas pelos proprietários.

> 📄 **Dicionário de Dados:** Para visualizar a modelagem completa de documentos, coleções e atributos, consulte a [Documentação do Banco de Dados (DATABASE.md)](https://github.com/Catolica-Tech-Academy-Hub/codequest/firebase/DATABASE.md).

---

## 11. Contribuindo (branch, commit e PR)

### 1. Atualizar a base local

```bash
git checkout main
git pull origin main
```

### 2. Criar uma branch

Use o padrão:

```
feat/<nome-curto>    → nova funcionalidade
fix/<nome-curto>     → correção de bug
chore/<nome-curto>   → tarefas de manutenção, configs
docs/<nome-curto>    → atualização de documentação
```

Exemplo:

```bash
git checkout -b feat/auth-login-flow
```

### 3. Validar antes de commitar

```bash
flutter analyze
flutter test
```

### 4. Commitar

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat(auth): add sign in with email and password"
git commit -m "fix(profile): handle missing leagueId on first login"
git commit -m "chore: update android setup script"
```

### 5. Abrir Pull Request

Inclua no corpo do PR:

- **Objetivo:** o que foi feito e por quê
- **Camadas alteradas:** ex. `domain`, `data`, `providers`
- **Como testar:** passo a passo para validar a mudança
- **Screenshot ou GIF** se houver alteração visual

**Checklist mínimo antes de abrir o PR:**

- [ ] App roda localmente sem erros
- [ ] `flutter analyze` sem warnings novos
- [ ] `flutter test` passando
- [ ] Documentação atualizada (se aplicável)

---

## 12. Solução de problemas

### Docker não sobe / erro de engine

**Sintoma:** `Cannot connect to the Docker daemon`

**Solução:**

1. Abra o Docker Desktop
2. Aguarde o ícone na bandeja do sistema ficar verde (status: running)
3. Execute `make infra-up` novamente

---

### App não conecta ao Firebase

**Sintoma:** erros de rede ou timeout ao tentar login/leitura

**Solução:**

1. Confirme que os emuladores estão ativos: http://localhost:4000
2. Verifique se o app está rodando com `--dart-define=USE_EMULATOR=true`
3. No Android Emulator, `localhost` dentro do emulador aponta para `10.0.2.2` — verifique se `firebase_config.dart` usa o endereço correto

---

### Login retorna "Erro inesperado de autenticacao"

**Sintoma:** ao tentar entrar com usuário seed, aparece `Erro inesperado de autenticacao`.

**Como diagnosticar:**

```powershell
adb logcat -d -t 400 | Select-String "FirebaseAuth|RecaptchaCallWrapper|Cleartext|E/flutter|Exception"
```

Se aparecer `Cleartext HTTP traffic to 10.0.2.2 not permitted`, o app instalado está desatualizado ou foi buildado sem a permissão local de HTTP.

**Solução:**

```powershell
adb emu kill
make run-dev
```

O projeto permite cleartext local no Android para conversar com Firebase Emulators via `10.0.2.2`.

---

### Emulador Android não aparece no `flutter devices`

**Sintoma:** `No supported devices connected`

**Solução:**

1. Verifique se o AVD existe: `make android-setup` (idempotente)
2. Inicie o emulador: `make run-dev`
3. Confirme a listagem: `flutter devices`

---

### App abre, mas mostra só o wallpaper/tela vazia do Android

**Sintoma:** o app parece estar aberto, mas a tela mostra apenas o fundo do Android Emulator ou uma tela sem widgets.

**Causa provável:** bug de renderização GPU do Android Emulator com o backend gráfico padrão.

**Solução:**

```powershell
adb emu kill
make run-dev
```

O script `make run-dev` inicia o AVD `Pixel8_API35` com `-gpu swiftshader_indirect -no-snapshot-load` e roda o app com `--no-enable-impeller`, que é o modo estável validado para este projeto no Windows.

---

### App fica preso em loading

**Sintoma:** aparece um loading circular e a tela de login não carrega.

**Solução:**

1. Confirme que os emuladores Firebase estão ativos em http://localhost:4000
2. Rode `make seed` se os usuários de teste não existirem no Auth Emulator
3. Reinicie o app com `make run-dev`

---

### Seed falhou ou dados estão inconsistentes

**Solução:**

```bash
make down
make infra-up
make seed
```

---

### `make` não encontrado no Windows

**Solução:**

- Use **Git Bash** (inclui `make` via MSYS2)
- Ou use os scripts `.bat` diretamente: `setup-dev.bat` e `run-dev.bat`
