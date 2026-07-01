# Cab Drive: проверка перед «готово» (агент запускает сам, не пользователь).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "==> 1/4 yandex/mapkit leftovers"
$hits = @()
if (Select-String -Path "pubspec.yaml" -Pattern "yandex_mapkit" -Quiet) { $hits += "pubspec.yaml: yandex_mapkit" }
Get-ChildItem -Path "android","lib","ios" -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\\.gradle\\|\\build\\' } |
  Select-String -Pattern "MapKitFactory|maps\.mobile|package:yandex_mapkit|YandexMapsMobile" -List |
  ForEach-Object { $hits += $_.Path }
if ($hits.Count -gt 0) {
  $hits | ForEach-Object { Write-Host $_ }
  throw "Found Yandex/MapKit references. Remove before handoff."
}

Write-Host "==> 2/4 mainDriver must not block UI on null location"
if (Select-String -Path "lib\driver\main_driver\main_driver_widget.dart" -Pattern "currentUserLocationValue == null" -Quiet) {
  Write-Error "main_driver still blocks build on null location (white screen risk)."
}

Write-Host "==> 3/4 flutter analyze (errors only)"
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$analyzeOut = (flutter analyze 2>&1 | Out-String)
$ErrorActionPreference = $prevEap
$errors = $analyzeOut -split "`n" | Where-Object { $_ -match '^\s*error -' }
if ($errors) {
  $errors | ForEach-Object { Write-Host $_ }
  throw "flutter analyze reported errors."
}
Write-Host "analyze: no errors"

Write-Host "==> 4/4 debug APK build"
$ErrorActionPreference = 'Continue'
$buildOut = (flutter build apk --debug 2>&1 | Out-String)
$ErrorActionPreference = $prevEap
if ($LASTEXITCODE -ne 0) {
  ($buildOut -split "`n" | Select-Object -Last 30) | ForEach-Object { Write-Host $_ }
  throw "Debug APK build failed."
}

Write-Host "OK: handoff checks passed"
