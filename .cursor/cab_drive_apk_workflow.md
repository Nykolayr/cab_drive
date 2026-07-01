# Cab Drive — сборка APK по запросу «сделай апк»

> Правило для агента: `.cursor/rules/cab-drive-apk-workflow.mdc` (alwaysApply).

## Когда пользователь пишет «сделай апк»

Выполнить **по порядку**, без лишних вопросов:

1. **Повысить версию** в `pubspec.yaml`: build после `+` на 1 (обычно `1.0.{build}+{build}`).
2. **Собрать release APK**:
   ```powershell
   cd D:\Projects\cab_drive\cab_drive
   flutter build apk --release
   ```
   Опционально (если ключ есть локально, не в git):
   `--dart-define=ORS_API_KEY=...`
3. **Скопировать** в `D:\Temp\`:
   ```powershell
   $build = 15   # число после + в pubspec
   New-Item -ItemType Directory -Force -Path "D:\Temp" | Out-Null
   Copy-Item -Force "build\app\outputs\flutter-apk\app-release.apk" "D:\Temp\cabdrive_$build.apk"
   Get-Item "D:\Temp\cabdrive_$build.apk"
   ```
4. **Git:** commit + **push** текущей ветки.

## Имя файла (только Cab Drive)

| Шаблон | Пример |
|--------|--------|
| `D:\Temp\cabdrive_{buildNumber}.apk` | `cabdrive_15.apk` при `1.0.15+15` |

Не использовать `{slug}_1_{n}` из общего `android_release.md`.

## Заметки

- Release сейчас подписан debug keystore в `build.gradle` — для стора позже release keystore.
- `verify_handoff.ps1` — отдельная проверка перед «готово», не заменяет этот сценарий.
