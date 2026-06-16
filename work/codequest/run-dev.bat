@echo off
chcp 65001 >nul
title CodeQuest - Run Dev

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║          CodeQuest - Iniciando ambiente dev          ║
echo ╚══════════════════════════════════════════════════════╝
echo.

:: Verifica se o setup inicial ja foi feito
set SDK_ROOT=%LOCALAPPDATA%\Android\sdk
set AVD_DIR=%USERPROFILE%\.android\avd\Pixel8_API35.avd

if not exist "%AVD_DIR%" (
    echo  [AVISO] Emulador nao encontrado. Parece que o setup inicial nao foi feito.
    echo.
    echo  Execute primeiro:  setup-dev.bat
    echo.
    pause
    exit /b 1
)

docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Docker nao esta rodando.
    echo.
    echo  Abra o Docker Desktop, aguarde ficar verde e rode este arquivo novamente.
    echo.
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%~dp0scripts\run-dev.ps1"
