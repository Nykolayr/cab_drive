# Регрессионный гейт (ЖЕЛЕЗО)

## Что есть

- `cab_drive_app/scripts/pre_apk_regression.ps1` — гейт из 6+ шагов:
  версия синк, инварианты auth (сервер+клиент), инварианты статусных
  наборов заказа, `flutter test`, `flutter analyze`, pytest гардов.
- `mac-release.ps1` (`D:\Projects\_tools`) прогоняет гейт автоматически
  перед iOS-синком на мак — упал = сборка отменена.
- `release_android.ps1` прогоняет его перед APK/AAB.
- `lib/order_status_groups.dart` — ЕДИНСТВЕННОЕ место наборов статусов
  вкладок «Мои заказы» и доступности отмены. Тест:
  `test/order_status_groups_test.dart` (покрытие = ни один статус
  не «сирота»).
- `server/tests/test_order_guards.py` — pytest гардов
  `cancel_order_by_customer` / `set_order_status` / `accept_bid`
  (моки, без БД).
- `.devin/docs/RELEASE_SMOKE.md` — ручной smoke-лист после релиза.

## Обязательно

1) Правка статусов заказа / отмены / выплат / пушей → **добавить пункт
   в соответствующий тест** (order_status_groups_test или
   test_order_guards), не только «поправить и проверить глазами».
2) Наборы статусов НЕ писать инлайн в виджетах — только через
   `order_status_groups.dart` (гейт grep'ит это).
3) Новый статус StatusOrder → обязательно распределить в наборы
   `order_status_groups.dart`, иначе тест покрытия упадёт.
4) Один коммит = одна зона (не смешивать сервер+клиент+инфру
   в одной правке).
5) `pytest` локально может отсутствовать — гейт честно пишет SKIP,
   это не повод удалять серверные тесты.
