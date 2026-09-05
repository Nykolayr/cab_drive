#Requires -Version 5.1
# Обёртка: всегда предпочитает готовый APK (минуты → секунды).
Set-Location (Split-Path -Parent $PSScriptRoot)
& "$PSScriptRoot\run_debug_device.ps1" @args
