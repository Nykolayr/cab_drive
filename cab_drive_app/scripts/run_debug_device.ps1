#Requires -Version 5.1
<#
.SYNOPSIS
  Быстрый debug-запуск Cab Drive на подключённый Android-телефон.

.DESCRIPTION
  1) PATH: Flutter + adb
  2) Проверка устройства
  3) gradle --stop (снимает зависшие daemon)
  4) Если есть свежий app-debug.apk и не -Rebuild → install + am start (секунды)
  5) Иначе flutter run -d <device>
  6) Параллельно logcat (заказ / Firestore / Flutter)

.EXAMPLE
  cd cab_drive_app
  powershell -File scripts/run_debug_device.ps1

.EXAMPLE
  powershell -File scripts/run_debug_device.ps1 -Rebuild
  powershell -File scripts/run_debug_device.ps1 -DeviceId 97c277d3
#>
param(
    [string]$DeviceId = '',
    [switch]$Rebuild,
    # По умолчанию ставим уже собранный debug APK (секунды), не ждём Gradle часами.
    [switch]$ForceApkRebuild,
    [int]$ApkMaxAgeMinutes = 10080
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
    $cmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($cmd) { Split-Path -Parent $cmd.Source } else { $null }
}
if (-not $flutterBin -or -not (Test-Path (Join-Path $flutterBin 'flutter.bat'))) {
    throw 'Flutter SDK not found (expected C:\src\flutter\bin)'
}

$adbCandidates = @(
    Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
    'C:\Android\Sdk\platform-tools\adb.exe'
    'C:\src\Android\Sdk\platform-tools\adb.exe'
)
$adb = $adbCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $adb) { throw 'adb.exe not found under Android SDK platform-tools' }

$sys32 = "$env:SystemRoot\System32"
$psDir = "$env:SystemRoot\System32\WindowsPowerShell\v1.0"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$adbDir = Split-Path -Parent $adb
$env:Path = ($flutterBin + ';' + $adbDir + ';' + $sys32 + ';' + $psDir + ';' + $userPath + ';' + $machinePath)
if (-not $env:PUB_CACHE) { $env:PUB_CACHE = 'D:\Projects\cab_drive\.pub-cache' }
if (-not $env:GRADLE_USER_HOME) { $env:GRADLE_USER_HOME = Join-Path $root '.gradle_home' }
Remove-Item Env:CAB_DRIVE_RUSTORE -ErrorAction SilentlyContinue

$flutter = Join-Path $flutterBin 'flutter.bat'
$packageId = 'com.cab.drive'
$activity = 'com.cab.drive.MainActivity'
$apkPath = Join-Path $root 'build\app\outputs\flutter-apk\app-debug.apk'
$apkPathAlt = Join-Path $root 'build\app\outputs\apk\debug\app-debug.apk'
if (-not (Test-Path $apkPath) -and (Test-Path $apkPathAlt)) {
    $apkPath = $apkPathAlt
}

Write-Step 'device'
$devOut = & $adb devices 2>&1 | Out-String
Write-Host $devOut.Trim()
$devices = @()
foreach ($line in (& $adb devices)) {
    if ($line -match '^(\S+)\s+device\s*$') { $devices += $Matches[1] }
}
if ($devices.Count -eq 0) {
    throw 'Нет подключённого Android-устройства (adb devices пуст). Подключи телефон с USB-отладкой.'
}
if ($DeviceId) {
    if ($devices -notcontains $DeviceId) {
        throw "DeviceId=$DeviceId не в списке: $($devices -join ', ')"
    }
    $serial = $DeviceId
} else {
    $serial = $devices[0]
}
Write-Host "Using device: $serial"

Write-Step 'stop hung gradle daemons'
Push-Location (Join-Path $root 'android')
try {
    & .\gradlew.bat --stop 2>&1 | Out-Host
} catch {
    Write-Host "gradlew --stop: $_" -ForegroundColor Yellow
}
Pop-Location

$desugar = Join-Path $root 'build\app\intermediates\desugar_lib_dex'
if (Test-Path $desugar) {
    Write-Step 'clear desugar lock dir (if any)'
    Remove-Item -Recurse -Force $desugar -ErrorAction SilentlyContinue
}

function Start-OrderLogcat {
    param([string]$Serial)
    Write-Step 'logcat (order / firestore / flutter) — Ctrl+C stops script logcat only if attached'
    Write-Host "Filter: flutter|Firestore|Firebase|order|Order|quota|429|Exception|Error"
    & $adb -s $Serial logcat -c | Out-Null
    # Non-blocking: user watches flutter run; we also dump recent after install path
}

function Install-And-Launch {
    param([string]$Serial, [string]$Apk)
    Write-Step "install $Apk"
    & $adb -s $Serial install -r $Apk
    if ($LASTEXITCODE -ne 0) { throw "adb install failed (exit $LASTEXITCODE)" }
    Write-Step "am start $packageId"
    & $adb -s $Serial shell am force-stop $packageId 2>$null
    & $adb -s $Serial shell am start -n "$packageId/$activity"
    if ($LASTEXITCODE -ne 0) {
        # fallback: monkey launch
        & $adb -s $Serial shell monkey -p $packageId -c android.intent.category.LAUNCHER 1
    }
    Start-OrderLogcat -Serial $Serial
    Write-Host ""
    Write-Host "App launched. Streaming logcat (Ctrl+C to stop)..." -ForegroundColor Green
    & $adb -s $Serial logcat -v time *:S flutter:V Firebase*:V AndroidRuntime:E libc:F | ForEach-Object {
        if ($_ -match 'order|Order|firestore|Firestore|quota|429|Exception|Error|error|create|Create|newOrder|PERMISSION|denied') {
            Write-Host $_
        } elseif ($_ -match '^\d|I/flutter|E/flutter|W/flutter') {
            Write-Host $_
        }
    }
}

$useApk = $false
$rebuildNeeded = $Rebuild -or $ForceApkRebuild
if (-not $rebuildNeeded -and (Test-Path $apkPath)) {
    $ageMin = [int]((Get-Date) - (Get-Item $apkPath).LastWriteTime).TotalMinutes
    if ($ageMin -le $ApkMaxAgeMinutes) {
        Write-Host "Using existing debug APK (age ${ageMin}m, max ${ApkMaxAgeMinutes}m)"
        $useApk = $true
    } else {
        Write-Host "Debug APK too old (${ageMin}m) — will rebuild (or pass without -Rebuild and raise -ApkMaxAgeMinutes)"
    }
} elseif (-not $rebuildNeeded) {
    Write-Host 'No debug APK found — will flutter run / build'
}

if ($useApk) {
    Install-And-Launch -Serial $serial -Apk $apkPath
    exit 0
}

Write-Step 'sync_env (keys → local.properties)'
& (Join-Path $flutterBin 'dart.bat') run tool/sync_env.dart
if ($LASTEXITCODE -ne 0) { throw 'sync_env failed' }

Write-Step "flutter run -d $serial (debug)"
Write-Host 'Tip: next time if APK is fresh, script installs in seconds without full Gradle.'
# flutter run blocks; start logcat in background job
$logJob = Start-Job -ScriptBlock {
    param($adbPath, $ser)
    & $adbPath -s $ser logcat -c | Out-Null
    & $adbPath -s $ser logcat -v time *:S flutter:V Firebase*:V AndroidRuntime:E
} -ArgumentList $adb, $serial

try {
    & $flutter run -d $serial --debug
    $code = $LASTEXITCODE
} finally {
    if ($logJob) {
        Receive-Job $logJob -ErrorAction SilentlyContinue | Where-Object {
            $_ -match 'order|Order|firestore|Firestore|quota|429|Exception|Error|error|create|Create|newOrder|I/flutter|E/flutter'
        } | ForEach-Object { Write-Host $_ }
        Stop-Job $logJob -ErrorAction SilentlyContinue
        Remove-Job $logJob -Force -ErrorAction SilentlyContinue
    }
}
exit $code
