# Cab Drive: проверка перед «готово» (агент запускает сам, не пользователь).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "==> 0/4 sync .env -> Android/iOS native"
if (-not (Test-Path ".env")) {
  throw "Нет .env — скопируй .env.example в .env и заполни ключи."
}
dart run tool/sync_env.dart
if ($LASTEXITCODE -ne 0) { throw "sync_env failed" }

Write-Host "==> 1/4 Yandex MapKit configured"
if (-not (Select-String -Path "pubspec.yaml" -Pattern "yandex_mapkit" -Quiet)) {
  throw "pubspec.yaml: missing yandex_mapkit"
}
if (-not (Select-String -Path "android\app\src\main\kotlin\com\example\my_project\MainActivity.kt" -Pattern "MapKitFactory.setApiKey" -Quiet)) {
  throw "MainActivity.kt: MapKitFactory.setApiKey before super.configureFlutterEngine"
}
if (Select-String -Path "pubspec.yaml" -Pattern "google_maps_flutter" -Quiet) {
  throw "pubspec.yaml: remove google_maps_flutter"
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
