# Cab Drive — сборка APK по запросу «сделай апк»

> Для агента. Проект: `cab_drive`, ветка по умолчанию для фич — `feat/yandex-maps-1.0.14` (или текущая рабочая).

## Когда пользователь пишет «сделай апк» (или аналог)

Выполнить **по порядку**, без лишних вопросов:

1. **Повысить версию** в `pubspec.yaml`: увеличить **build number** после `+` на 1 (и при необходимости patch в `x.y.z`, чтобы совпадало с договорённостями; обычно `1.0.{build}+{build}`).
2. **Собрать release APK** из корня `D:\Projects\cab_drive\cab_drive`:
   ```powershell
   flutter build apk --release `
     --dart-define=ORS_API_KEY=<из local/joy_pick> `
     --dart-define=YANDEX_MAPKIT_KEY=<из local.properties / kurort>
   ```
   MapKit на Android также читает `yandex.maps.api.key` из `android/local.properties`.
3. **Скопировать** артефакт в `D:\Temp\` с именем:
   ```text
   cabdrive_{buildNumber}.apk
   ```
   где `{buildNumber}` — число после `+` в `pubspec.yaml` (например `+15` → `cabdrive_15.apk`).
4. **Git:** закоммитить bump версии (и только то, что нужно для сборки, если менялось), **push** в текущую рабочую ветку.

## Имя файла (фиксировано для Cab Drive)

| Шаблон | Пример |
|--------|--------|
| `D:\Temp\cabdrive_{buildNumber}.apk` | `D:\Temp\cabdrive_14.apk` при `version: 1.0.14+14` |

Не использовать шаблон `{slug}_1_{n}` из общего `android_release.md` для этого продукта — здесь только **`cabdrive_{build}`**.

## Проверка после сборки

```powershell
Get-Item "D:\Temp\cabdrive_*.apk" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

## Заметки

- Release сейчас подписан **debug keystore** в `build.gradle` — для RuStore/Play позже нужен release keystore.
- `minSdk 26` (Yandex MapKit).
