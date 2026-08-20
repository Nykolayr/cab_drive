# Cab Drive: pre-handoff checks (agent runs this, not the user).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "==> 0/4 sync .env -> Android/iOS native"
if (-not (Test-Path ".env")) {
  throw "Missing .env - copy .env.example to .env and fill keys."
}
dart run tool/sync_env.dart
if ($LASTEXITCODE -ne 0) { throw "sync_env failed" }

Write-Host "==> 1/4 Yandex MapKit configured"
if (-not (Select-String -Path "pubspec.yaml" -Pattern "yandex_mapkit" -Quiet)) {
  throw "pubspec.yaml: missing yandex_mapkit"
}
if (-not (Select-String -Path "android\app\src\main\kotlin\com\example\my_project\CabDriveApplication.kt" -Pattern "MapKitFactory.setApiKey" -Quiet)) {
  throw "CabDriveApplication.kt: MapKitFactory.setApiKey before FlutterEngine"
}
if (-not (Select-String -Path "android\app\src\main\kotlin\com\example\my_project\MainActivity.kt" -Pattern "FlutterEngineCache" -Quiet)) {
  throw "MainActivity.kt: must reuse FlutterEngineCache (resume from background)"
}
if (-not (Select-String -Path "android\app\src\main\kotlin\com\example\my_project\MainActivity.kt" -Pattern "shouldDestroyEngineWithHost" -Quiet)) {
  throw "MainActivity.kt: shouldDestroyEngineWithHost must return false"
}
if (Select-String -Path "pubspec.yaml" -Pattern "google_maps_flutter" -Quiet) {
  throw "pubspec.yaml: remove google_maps_flutter"
}
$orderGoogle = Get-ChildItem -Path "lib\customer","lib\driver" -Filter "*.dart" -Recurse -ErrorAction SilentlyContinue |
  Select-String -Pattern "FlutterFlowGoogleMap|google_maps_flutter" -ErrorAction SilentlyContinue
if ($orderGoogle) {
  throw "Order/driver screens still reference Google Maps UI"
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
$errors = $analyzeOut -split "`n" | Where-Object { $_ -match 'error •|error -|^\s*error\s' }
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
  ($buildOut -split "`n" | Select-Object -Last 25) | ForEach-Object { Write-Host $_ }
  throw "Debug APK build failed."
}

Write-Host "OK: handoff checks passed"
