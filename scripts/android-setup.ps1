# scripts/android-setup.ps1
# Setup inicial do ambiente Android para o projeto CodeQuest.
# Idempotente: pode ser executado multiplas vezes sem efeitos colaterais.

$ErrorActionPreference = "Stop"

$sdkRoot = "C:\Users\$env:USERNAME\AppData\Local\Android\sdk"
$sdkMgr = "$sdkRoot\cmdline-tools\latest\bin\sdkmanager.bat"
$avdMgr = "$sdkRoot\cmdline-tools\latest\bin\avdmanager.bat"
$avdName = "Pixel8_API35"
$sysImage = "system-images;android-35;google_apis;x86_64"
$platform = "platforms;android-35"
$sysImgDir = "$sdkRoot\system-images\android-35\google_apis\x86_64"

Write-Host ""
Write-Host "=== CodeQuest: Android Setup ===" -ForegroundColor Cyan

# -------------------------------------------------------
# 1. Validar pre-requisito: cmdline-tools instalado
# -------------------------------------------------------
if (-not (Test-Path $sdkMgr)) {
    Write-Host ""
    Write-Host "[ERRO] sdkmanager nao encontrado em:" -ForegroundColor Red
    Write-Host "  $sdkMgr" -ForegroundColor Red
    Write-Host ""
    Write-Host "Siga o passo obrigatorio no README:" -ForegroundColor Yellow
    Write-Host "  Android Studio > More Actions > SDK Manager > SDK Tools > Android SDK Command-line Tools (latest)" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# -------------------------------------------------------
# 2. Configurar variaveis de ambiente (permanente + sessao)
# -------------------------------------------------------
$existingHome = [System.Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")
if (-not $existingHome) {
    Write-Host "[setup] Configurando ANDROID_HOME permanentemente..."
    [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkRoot, "User")
    [System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkRoot, "User")
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $additions = "$sdkRoot\cmdline-tools\latest\bin;$sdkRoot\platform-tools;$sdkRoot\emulator"
    if ($currentPath -notlike "*cmdline-tools*") {
        [System.Environment]::SetEnvironmentVariable("PATH", "$currentPath;$additions", "User")
    }
    Write-Host "[setup] ANDROID_HOME configurado."
}
else {
    Write-Host "[setup] ANDROID_HOME ja configurado: $existingHome"
}

# Aplica na sessao atual
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
$env:PATH = "$env:PATH;$sdkRoot\cmdline-tools\latest\bin;$sdkRoot\platform-tools;$sdkRoot\emulator"

# -------------------------------------------------------
# 3. Instalar system image se ausente
# -------------------------------------------------------
if (-not (Test-Path $sysImgDir)) {
    Write-Host "[setup] Instalando system image Android 35 (pode levar alguns minutos)..."
    "y" | & $sdkMgr $sysImage $platform
    Write-Host "[setup] System image instalada."
}
else {
    Write-Host "[setup] System image ja instalada."
}

# -------------------------------------------------------
# 4. Aceitar licencas
# -------------------------------------------------------
Write-Host "[setup] Aceitando licencas Android..."
$licenseInputPath = Join-Path $env:TEMP "codequest-android-licenses.txt"
try {
    Set-Content -LiteralPath $licenseInputPath -Value ("y`r`n" * 20) -NoNewline -Encoding ASCII
    & cmd.exe /c "type `"$licenseInputPath`" | `"$sdkMgr`" --licenses >nul 2>nul"
    if ($LASTEXITCODE -ne 0) {
        throw "sdkmanager --licenses falhou com codigo de saida $LASTEXITCODE"
    }
}
finally {
    Remove-Item -LiteralPath $licenseInputPath -Force -ErrorAction SilentlyContinue
}
Write-Host "[setup] Licencas aceitas."

# -------------------------------------------------------
# 5. Criar AVD se nao existir
# -------------------------------------------------------
$avdList = & $avdMgr list avd 2>&1
if ("$avdList" -notlike "*$avdName*") {
    Write-Host "[setup] Criando emulador $avdName..."
    "no" | & $avdMgr create avd -n $avdName -k $sysImage --device "pixel_8" --force
    Write-Host "[setup] Emulador criado."
}
else {
    Write-Host "[setup] Emulador $avdName ja existe."
}

# -------------------------------------------------------
# 6. Habilitar plataforma Android no projeto Flutter
# -------------------------------------------------------
if (-not (Test-Path "android")) {
    Write-Host "[setup] Habilitando plataforma Android no projeto Flutter..."
    flutter create --platforms=android .
    Write-Host "[setup] Plataforma Android habilitada."
}
else {
    Write-Host "[setup] Plataforma Android ja habilitada."
}

Write-Host ""
Write-Host "=== Setup Android concluido! ===" -ForegroundColor Green
Write-Host "Agora rode: make run-dev" -ForegroundColor Cyan
Write-Host ""
