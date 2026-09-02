# Обязателен ПЕРЕД release APK/AAB для заказчика.
# См. docs/ARCHITECTURE_AND_FLOWS.md
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $root
Set-Location $root

Write-Host "==> pre_apk_regression: Cab Drive"
Write-Host "    doc: $repoRoot\docs\ARCHITECTURE_AND_FLOWS.md"

Write-Host "`n==> 1/5 Auth invariants (server files)"
$serverApi = Join-Path $repoRoot "server\users\api.py"
$serverEntities = Join-Path $repoRoot "server\users\entities.py"
foreach ($f in @($serverApi, $serverEntities)) {
  if (-not (Test-Path $f)) { throw "Missing $f" }
}
if (-not (Select-String -Path $serverEntities -Pattern "AUTH_EMAIL_DOMAIN = 'ydrive.appwave.com'" -Quiet)) {
  throw "server/entities.py: AUTH_EMAIL_DOMAIN must be ydrive.appwave.com"
}
if (-not (Select-String -Path $serverApi -Pattern "email = auth_email\(phone\)" -Quiet)) {
  throw "server/api.py: create_user_by_phone must use auth_email(phone)"
}
if (Select-String -Path $serverApi -Pattern "email = f'\{phone\}@ydrive\.com'" -Quiet) {
  throw "server/api.py: forbidden bare @ydrive.com for new users"
}

Write-Host "`n==> 2/5 Auth invariants (client files)"
if (-not (Select-String -Path "lib\login\load\load_widget.dart" -Pattern "firestoreIsDriver" -Quiet)) {
  throw "load_widget.dart: must sync driver role from Firestore (firestoreIsDriver)"
}
$profile = Get-Content "lib\pages\menu\profile\profile_widget.dart" -Raw
$cityIdx = $profile.IndexOf('Город поиска')
if ($cityIdx -lt 0) { throw "profile_widget: missing city picker" }
$beforeCity = $profile.Substring([Math]::Max(0, $cityIdx - 900), [Math]::Min(900, $cityIdx))
if ($beforeCity -match 'responsiveVisibility\([\s\S]*phone:\s*false') {
  throw "profile_widget: city picker must not be phone:false only"
}

Write-Host "`n==> 3/5 flutter test (auth + role)"
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
flutter test test/auth_architecture_test.dart test/role_selection_test.dart 2>&1 | ForEach-Object { Write-Host $_ }
$testExit = $LASTEXITCODE
$ErrorActionPreference = $prevEap
if ($testExit -ne 0) { throw "flutter test failed (exit $testExit)" }

Write-Host "`n==> 4/5 flutter analyze (errors only)"
$ErrorActionPreference = 'Continue'
$analyzeOut = (flutter analyze 2>&1 | Out-String)
$ErrorActionPreference = $prevEap
$errors = $analyzeOut -split "`n" | Where-Object { $_ -match 'error •|error -|^\s*error\s' }
if ($errors) {
  $errors | ForEach-Object { Write-Host $_ }
  throw "flutter analyze reported errors"
}
Write-Host "analyze: no errors"

Write-Host "`n==> 5/5 server auth unit tests (if pytest available)"
$serverTests = Join-Path $repoRoot "server\tests\test_auth_invariants.py"
if ((Test-Path $serverTests) -and (Get-Command pytest -ErrorAction SilentlyContinue)) {
  Push-Location (Join-Path $repoRoot "server")
  $ErrorActionPreference = 'Continue'
  pytest tests/test_auth_invariants.py -q 2>&1 | ForEach-Object { Write-Host $_ }
  $pyExit = $LASTEXITCODE
  $ErrorActionPreference = $prevEap
  Pop-Location
  if ($pyExit -ne 0) { throw "pytest auth invariants failed" }
} else {
  Write-Host "SKIP: pytest not installed or server tests missing"
}

Write-Host ""
Write-Host "OK: pre_apk_regression passed - release APK/AAB allowed"
Write-Host "Reminder: deploy server/users/* to VPS before customer handoff if changed."
