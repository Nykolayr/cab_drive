# Jump payout — сверка и операции (Cab Drive)

## Источники истины

| Что | Где |
|-----|-----|
| Баланс в МП (SoT) | Postgres `app_users.balance` / `bonus_balance` |
| Вывод на карту | Jump OpenAPI `GET /payments`, `POST /payments` |
| Тинькофф | только пополнения/оплаты заказов (`app_pay_orders`), не «кошелёк водителя» |
| Firestore `users` | legacy; при `APP_FS_MIRROR=0` не SoT |

## Поведение сервера (с 2026-09-13)

`POST /api/app/me/payout`:

1. Создаёт выплату в Jump.
2. **Списывает `balance=0` только если Jump вернул финальный успех** (status `оплачена` / `is_final`).
3. Если статус «нужно подтверждение» (id=4) — **баланс не трогаем**, в МП текст ошибки.
4. `contractor_id` из Jump пишем в PG, чтобы следующие выплаты шли без `/smart`.

## Зависшая выплата Дианы (пример)

- Телефон: `+79667499985`, uid PG: `132ipwKCpbXrRTyC2p4RNIkkf6D2`
- Jump payment **#182024002**, 12.09.2026 — **«нужно подтверждение»**, `paid_at` null
- PG balance **200 ₽** — корректно (деньги не ушли на карту)
- FS мог показать «пустой» balance после старого клиента — PG не менялся

**Действие оператора:** в [Jump Finance](https://jump.finance) подтвердить или отменить выплату #182024002. Пока не «оплачена» — не обнулять balance в PG вручную.

## Heal contractor_id

Если в FS есть `ContractorID`, а в PG `contractor_id` NULL — один раз:

```sql
UPDATE app_users
SET contractor_id = 21746092
WHERE id = '132ipwKCpbXrRTyC2p4RNIkkf6D2';
```

(подставить актуальный id из Jump `GET /contractors?search=...`)
