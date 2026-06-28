@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
::  CodeQuest - Setup inicial do ambiente de desenvolvimento
::  Execute este arquivo UMA VEZ depois de clonar o projeto.
::
::  O que este script faz:
::    1. Verifica pre-requisitos (Flutter, Docker, Node.js)
::    2. Verifica Android Studio e SDK Command-line Tools
::    3. Configura ANDROID_HOME e variaveis de ambiente
::    4. Instala system image Android e cria emulador
::    5. Instala dependencias do projeto (Flutter + Node)
::    6. Sobe Firebase Emulators via Docker
::
::  Requisito manual ANTES de rodar este script:
::    Android Studio > More Actions > SDK Manager >
::    aba "SDK Tools" > marcar "Android SDK Command-line Tools (latest)" > Apply
:: ============================================================

title CodeQuest - Setup Dev

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║         CodeQuest - Setup inicial do projeto         ║
echo ╚══════════════════════════════════════════════════════╝
echo.
echo  Este script vai configurar tudo que voce precisa para
echo  rodar o CodeQuest pela primeira vez.
echo.
echo  Pressione qualquer tecla para comecar ou feche a janela para cancelar.
pause >nul

echo.
echo ──────────────────────────────────────────────────────
echo  [1/6] Verificando pre-requisitos
echo ──────────────────────────────────────────────────────
echo.

:: ── Flutter ──────────────────────────────────────────────
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Flutter nao encontrado no PATH.
    echo.
    echo  Como resolver:
    echo    1. Acesse: https://docs.flutter.dev/get-started/install/windows
    echo    2. Baixe o Flutter SDK e extraia em uma pasta sem espacos
    echo       Ex: C:\flutter
    echo    3. Adicione C:\flutter\bin ao PATH do sistema
    echo    4. Feche e abra este script novamente
    echo.
    goto :erro_fatal
)
echo  [OK] Flutter encontrado.

:: ── Docker ───────────────────────────────────────────────
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Docker nao encontrado no PATH.
    echo.
    echo  Como resolver:
    echo    1. Acesse: https://www.docker.com/products/docker-desktop/
    echo    2. Baixe e instale o Docker Desktop
    echo    3. Reinicie o computador apos instalar
    echo    4. Rode este script novamente
    echo.
    goto :erro_fatal
)

:: Verifica se o Docker esta em execucao
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Docker esta instalado mas NAO esta rodando.
    echo.
    echo  Como resolver:
    echo    1. Abra o Docker Desktop na barra de tarefas
    echo    2. Aguarde o icone ficar verde ^(status: running^)
    echo    3. Rode este script novamente
    echo.
    goto :erro_fatal
)
echo  [OK] Docker rodando.

:: ── Node.js ──────────────────────────────────────────────
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo  [AVISO] Node.js nao encontrado. Firebase Functions pode nao funcionar.
    echo.
    echo  Como resolver:
    echo    1. Acesse: https://nodejs.org/
    echo    2. Baixe e instale a versao LTS
    echo    3. Rode este script novamente
    echo.
    echo  Pressione qualquer tecla para continuar mesmo assim ou feche para cancelar.
    pause >nul
) else (
    echo  [OK] Node.js encontrado.
)

echo.
echo ──────────────────────────────────────────────────────
echo  [2/6] Verificando Android Studio e SDK
echo ──────────────────────────────────────────────────────
echo.

set SDK_ROOT=%LOCALAPPDATA%\Android\sdk
set SDK_MGR=%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat

if not exist "%SDK_ROOT%" (
    echo  [ERRO] Android SDK nao encontrado em:
    echo    %SDK_ROOT%
    echo.
    echo  Como resolver:
    echo    1. Instale o Android Studio: https://developer.android.com/studio
    echo    2. Na primeira execucao ele instala o SDK automaticamente
    echo    3. Rode este script novamente
    echo.
    goto :erro_fatal
)
echo  [OK] Android SDK encontrado em: %SDK_ROOT%

if not exist "%SDK_MGR%" (
    echo.
    echo  [ERRO] Android SDK Command-line Tools NAO esta instalado.
    echo.
    echo  ╔─────────────────────────────────────────────────────────╗
    echo  │  PASSO OBRIGATORIO - Faca isso AGORA no Android Studio: │
    echo  │                                                         │
    echo  │  1. Abra o Android Studio                               │
    echo  │  2. Clique em "More Actions" ^(tela inicial^)             │
    echo  │     OU va em Tools ^> SDK Manager                        │
    echo  │  3. Clique na aba "SDK Tools"                           │
    echo  │  4. Marque "Android SDK Command-line Tools ^(latest^)"    │
    echo  │  5. Clique "Apply" e aguarde o download                 │
    echo  │  6. Feche o SDK Manager e rode este script novamente    │
    echo  ╚─────────────────────────────────────────────────────────╝
    echo.
    goto :erro_fatal
)
echo  [OK] Android SDK Command-line Tools encontrado.

echo.
echo ──────────────────────────────────────────────────────
echo  [3/6] Configurando ambiente Android
echo ──────────────────────────────────────────────────────
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0scripts\android-setup.ps1"
if %errorlevel% neq 0 (
    echo.
    echo  [ERRO] Falha na configuracao do Android.
    echo  Verifique as mensagens acima e tente novamente.
    echo.
    goto :erro_fatal
)

echo.
echo ──────────────────────────────────────────────────────
echo  [4/6] Instalando dependencias do projeto
echo ──────────────────────────────────────────────────────
echo.

echo  Instalando dependencias Flutter...
flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo  [ERRO] Falha ao instalar dependencias Flutter.
    echo  Verifique sua conexao com a internet e tente novamente.
    echo.
    goto :erro_fatal
)
echo  [OK] Dependencias Flutter instaladas.

echo.
echo  Instalando dependencias Firebase Functions...
call npm --prefix firebase/functions install
if %errorlevel% neq 0 (
    echo  [AVISO] Falha ao instalar dependencias das Functions. Continuando...
) else (
    echo  [OK] Dependencias Functions instaladas.
)

echo  Instalando dependencias Firebase Seed...
call npm --prefix firebase/seed install
if %errorlevel% neq 0 (
    echo  [AVISO] Falha ao instalar dependencias do Seed. Continuando...
) else (
    echo  [OK] Dependencias Seed instaladas.
)

echo.
echo ──────────────────────────────────────────────────────
echo  [5/6] Configurando arquivo .env
echo ──────────────────────────────────────────────────────
echo.

if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env >nul
        echo  [OK] Arquivo .env criado a partir de .env.example
    ) else (
        echo  [AVISO] .env.example nao encontrado. Pulando criacao do .env.
    )
) else (
    echo  [OK] Arquivo .env ja existe.
)

echo.
echo ──────────────────────────────────────────────────────
echo  [6/6] Subindo Firebase Emulators via Docker
echo ──────────────────────────────────────────────────────
echo.

echo  Iniciando containers (Docker pull pode demorar na primeira vez)...
docker compose up -d --build
if %errorlevel% neq 0 (
    echo.
    echo  [ERRO] Falha ao subir o Docker Compose.
    echo.
    echo  Causas comuns:
    echo    - Docker Desktop nao esta rodando. Abra e aguarde ficar verde.
    echo    - Porta ja em uso: verifique se outra instancia esta rodando.
    echo    - Execute: docker compose logs  para ver o erro detalhado.
    echo.
    goto :erro_fatal
)
echo  [OK] Firebase Emulators no ar.

:: ── Sucesso ──────────────────────────────────────────────
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║              Setup concluido com sucesso!            ║
echo ╚══════════════════════════════════════════════════════╝
echo.
echo  Proximos passos:
echo.
echo    Para rodar o app agora:
echo      run-dev.bat
echo.
echo    Ou pelo terminal (Git Bash / PowerShell):
echo      make run-dev
echo.
echo  Servicos disponiveis:
echo    Firebase Emulator UI  →  http://localhost:4000
echo    Firestore             →  localhost:8080
echo    Auth                  →  localhost:9099
echo    Functions             →  localhost:5001
echo.
echo  Usuarios de teste:
echo    dev@codequest.com   /  Dev@123456
echo    alice@codequest.com /  Dev@123456
echo    bob@codequest.com   /  Dev@123456
echo.
goto :fim

:: ── Erro fatal ───────────────────────────────────────────
:erro_fatal
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║      Setup interrompido. Corrija o erro acima.       ║
echo ║      Depois rode este arquivo novamente.             ║
echo ╚══════════════════════════════════════════════════════╝
echo.
pause
exit /b 1

:fim
echo  Pressione qualquer tecla para fechar.
pause >nul
endlocal
