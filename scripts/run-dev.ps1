# scripts/run-dev.ps1
# Inicia o emulador Android (se necessario) e roda o app Flutter no modo dev.

$sdkRoot = [System.Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")
if (-not $sdkRoot) {
    $sdkRoot = "C:\Users\$env:USERNAME\AppData\Local\Android\sdk"
}

$env:ANDROID_HOME     = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
$env:PATH             = "$env:PATH;$sdkRoot\platform-tools;$sdkRoot\emulator"

$adb      = "$sdkRoot\platform-tools\adb.exe"
$emulator = "$sdkRoot\emulator\emulator.exe"
$avdName  = "Pixel8_API35"

Write-Host ""
Write-Host "=== CodeQuest: Run Dev ===" -ForegroundColor Cyan

# -------------------------------------------------------
# 1. Verificar se emulador ja esta rodando
# -------------------------------------------------------
$devices = & $adb devices 2>&1
$running = ($devices | Select-String "emulator.*device$").Count -gt 0

if (-not $running) {
    Write-Host "[run-dev] Iniciando emulador $avdName..."
    Start-Process $emulator -ArgumentList @("-avd", $avdName, "-gpu", "swiftshader_indirect", "-no-snapshot-load") -WindowStyle Normal
    Write-Host "[run-dev] Aguardando emulador inicializar (pode levar 1-2 minutos)..."
    & $adb wait-for-device
    # Aguarda o boot completo do Android
    do {
        Start-Sleep -Seconds 3
        $bootProp = & $adb shell getprop sys.boot_completed 2>$null
    } while ($bootProp -notmatch "1")
    Write-Host "[run-dev] Emulador pronto!" -ForegroundColor Green
} else {
    Write-Host "[run-dev] Emulador ja em execucao."
}

# -------------------------------------------------------
# 2. Rodar Flutter
# -------------------------------------------------------
Write-Host "[run-dev] Iniciando Flutter..."
flutter run --dart-define=USE_EMULATOR=true --no-enable-impeller
