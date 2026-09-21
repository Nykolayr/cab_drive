#Requires -Version 5.1
<#
.SYNOPSIS
  Надёжная release-сборка Cab Drive: RuStore APK + Google Play AAB.

.DESCRIPTION
  1) Gate ключей (.env не placeholder)
  2) sync_env
  3) gradlew --stop + сброс desugar lock
  4) APK с CAB_DRIVE_RUSTORE=true → D:\Temp\cabdrive_{N}_rustore.apk
  5) AAB без rustore → D:\Temp\cabdrive_{N}.aab

  Gradle-кэш: GRADLE_USER_HOME = cab_drive_app\.gradle_home (не %USERPROFILE%\.gradle).
  После одной успешной online-сборки: -Offline — Gradle не лезет в Maven.

.EXAMPLE
  cd cab_drive_app
  powershell -File scripts/release_android.ps1
  powershell -File scripts/release_android.ps1 -Offline
  powershell -File scripts/release_android.ps1 -ApkOnly
#>
param(
    [switch]$Offline,
    [switch]$ApkOnly
)
$ErrorActionPreference = 'Stop'

function Write-Step([string]$msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutterBin = if (Test-Path 'C:\src\flutter\bin\flutter.bat') {
    'C:\src\flutter\bin'
} else {
    Split-Path -Parent (Get-Command flutter -ErrorAction SilentlyContinue).Source
}
if (-not $flutterBin -or -not (Test-Path (Join-Path $flutterBin 'flutter.bat'))) {
    throw 'Flutter SDK not found (expected C:\src\flutter\bin)'
}

$sys32 = "$env:SystemRoot\System32"
$psDir = "$env:SystemRoot\System32\WindowsPowerShell\v1.0"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$env:Path = ($flutterBin + ';' + $sys32 + ';' + $psDir + ';' + $userPath + ';' + $machinePath)
if (-not $env:PUB_CACHE) { $env:PUB_CACHE = 'D:\Projects\cab_drive\.pub-cache' }
# Всегда проектный кэш — не наследовать sandbox/%USERPROFILE%\.gradle
$env:GRADLE_USER_HOME = Join-Path $root '.gradle_home'
if (-not (Test-Path $env:GRADLE_USER_HOME)) {
    New-Item -ItemType Directory -Force -Path $env:GRADLE_USER_HOME | Out-Null
}
Remove-Item Env:CAB_DRIVE_RUSTORE -ErrorAction SilentlyContinue

$flutter = Join-Path $flutterBin 'flutter.bat'
$dart = Join-Path $flutterBin 'dart.bat'

# Offline: не через `flutter -- --offline` (Flutter ест это как target file).
# Вместо этого init-скрипт Gradle startParameter.offline=true в GRADLE_USER_HOME.
$gradleOfflineInit = Join-Path $env:GRADLE_USER_HOME 'init.d\cab_drive_offline.gradle'
if ($Offline) {
    $initDir = Split-Path $gradleOfflineInit
    New-Item -ItemType Directory -Force -Path $initDir | Out-Null
    Set-Content -Path $gradleOfflineInit -Value "gradle.startParameter.offline = true`r`n" -Encoding ASCII
    Write-Host "OFFLINE: Gradle init $gradleOfflineInit" -ForegroundColor Yellow
} else {
    if (Test-Path $gradleOfflineInit) {
        Remove-Item -Force $gradleOfflineInit -ErrorAction SilentlyContinue
    }
    Write-Host "ONLINE: Maven allowed if cache miss (cache: $env:GRADLE_USER_HOME)" -ForegroundColor DarkGray
}

# --- version ---
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\+(\d+)') {
    throw 'Cannot parse version from pubspec.yaml'
}
$versionName = "$($Matches[1]).$($Matches[2]).$($Matches[3])"
$buildNumber = [int]$Matches[4]
if ($Matches[3] -ne $Matches[4]) {
    throw "Version scheme must be 1.1.{N}+{N}, got $versionName+$buildNumber"
}
Write-Step "version $versionName+$buildNumber"

# --- gate keys ---
Write-Step 'gate .env keys'
$envFile = Join-Path $root '.env'
if (-not (Test-Path $envFile)) { throw '.env missing - copy from cab_drive_old/.env' }
$required = @('YANDEX_MAPKIT_KEY', 'YANDEX_GEOCODER_KEY', 'ORS_API_KEY')
$envMap = @{}
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    if ($line -match '^(?<k>[A-Za-z0-9_]+)\s*=\s*(?<v>.*)$') {
        $envMap[$Matches['k']] = $Matches['v'].Trim().Trim('"').Trim("'")
    }
}
foreach ($k in $required) {
    if (-not $envMap.ContainsKey($k)) { throw "Missing $k in .env" }
    $v = $envMap[$k]
    if ([string]::IsNullOrWhiteSpace($v) -or $v -match '^(your-|xxx|changeme|TODO|placeholder)') {
        throw "Placeholder/empty $k in .env - refuse release build"
    }
    Write-Host "OK $k len=$($v.Length)"
}
if (-not (Test-Path (Join-Path $root 'android\app\key.jks'))) {
    throw 'android/app/key.jks missing'
}
Write-Host 'OK key.jks'

# --- sync_env ---
Write-Step 'sync_env'
& $dart run tool/sync_env.dart
if ($LASTEXITCODE -ne 0) { throw "sync_env failed: $LASTEXITCODE" }

# --- gradle stop + unlock ---
Write-Step 'gradlew --stop + clear desugar lock'
Push-Location (Join-Path $root 'android')
try {
    & .\gradlew.bat --stop 2>&1 | Out-Host
} finally {
    Pop-Location
}
Start-Sleep -Seconds 2
$desugar = Join-Path $root 'build\app\intermediates\desugar_lib_dex'
if (Test-Path $desugar) {
    Remove-Item -Recurse -Force $desugar -ErrorAction SilentlyContinue
}

function Invoke-ReleaseBuild([scriptblock]$buildBlock, [string]$label) {
    & $buildBlock
    if ($LASTEXITCODE -eq 0) { return }
    Write-Host "WARN: $label failed (exit $LASTEXITCODE) - stop gradle, clear desugar, one retry" -ForegroundColor Yellow
    Push-Location (Join-Path $root 'android')
    try { & .\gradlew.bat --stop 2>&1 | Out-Null } finally { Pop-Location }
    Start-Sleep -Seconds 2
    if (Test-Path $desugar) { Remove-Item -Recurse -Force $desugar -ErrorAction SilentlyContinue }
    & $buildBlock
    if ($LASTEXITCODE -ne 0) { throw "$label failed after retry: $LASTEXITCODE" }
}

New-Item -ItemType Directory -Force -Path 'D:\Temp' | Out-Null
$aapt = Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools\*\aapt.exe" -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending | Select-Object -First 1

# --- RuStore APK ---
Write-Step 'RuStore APK (CAB_DRIVE_RUSTORE=true)'
$env:CAB_DRIVE_RUSTORE = 'true'
try {
    Invoke-ReleaseBuild {
        & $flutter build apk --release
    } 'APK'
} finally {
    if (Test-Path $gradleOfflineInit) {
        Remove-Item -Force $gradleOfflineInit -ErrorAction SilentlyContinue
    }
}
Remove-Item Env:CAB_DRIVE_RUSTORE -ErrorAction SilentlyContinue

$apkSrc = Join-Path $root 'build\app\outputs\flutter-apk\app-release.apk'
$apkDst = "D:\Temp\cabdrive_${buildNumber}_rustore.apk"
$apkAlias = "D:\Temp\cab_drive_1_${buildNumber}.apk"
Copy-Item -Force $apkSrc $apkDst
Copy-Item -Force $apkSrc $apkAlias
if ($aapt) {
    $badging = & $aapt.FullName dump badging $apkDst | Select-String 'package:'
    Write-Host $badging
    $line = [string]$badging
    if ($line -notmatch "name='com\.appwawe\.YDrive'") {
        throw "RuStore APK package mismatch: $line"
    }
    if ($line -notmatch "versionCode='$buildNumber'") {
        throw "RuStore APK versionCode mismatch: expected $buildNumber, got $line"
    }
}
Write-Host "APK_OK $apkDst"
Write-Host "APK_OK $apkAlias"

if ($ApkOnly) {
    Write-Step 'DONE (ApkOnly — AAB skipped)'
    Get-Item $apkDst, $apkAlias | Format-List FullName, Length, LastWriteTime
    Write-Host "Release $versionName+$buildNumber APK ready. Next time: -Offline if cache warm." -ForegroundColor Green
    exit 0
}

# --- Play AAB ---
Write-Step 'Google Play AAB (no rustore)'
Remove-Item Env:CAB_DRIVE_RUSTORE -ErrorAction SilentlyContinue
if ($Offline) {
    $initDir = Split-Path $gradleOfflineInit
    New-Item -ItemType Directory -Force -Path $initDir | Out-Null
    Set-Content -Path $gradleOfflineInit -Value "gradle.startParameter.offline = true`r`n" -Encoding ASCII
}
try {
    Invoke-ReleaseBuild {
        & $flutter build appbundle --release
    } 'AAB'
} finally {
    if (Test-Path $gradleOfflineInit) {
        Remove-Item -Force $gradleOfflineInit -ErrorAction SilentlyContinue
    }
}
$aabSrc = Join-Path $root 'build\app\outputs\bundle\release\app-release.aab'
$aabDst = "D:\Temp\cabdrive_${buildNumber}.aab"
Copy-Item -Force $aabSrc $aabDst
Write-Host "AAB_OK $aabDst"

Write-Step 'DONE'
Get-Item $apkDst, $apkAlias, $aabDst | Format-List FullName, Length, LastWriteTime
Write-Host "Release $versionName+$buildNumber ready. Next time: -Offline if cache warm." -ForegroundColor Green

