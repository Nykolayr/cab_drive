# Firestore WRITE audit (cab_drive_app) — 2026-09-13 (обновлено)

Цель: app-data SoT = Postgres. Ниже — **реальные write** в Firestore (не типы/DocumentReference).

## Исправлено

| Файл | Было | Стало |
|------|------|--------|
| `lib/driver/sposobviplat/sposobviplat_widget.dart` | Jump с телефона + FS balance delete | `POST /api/app/me/payout` |
| `lib/custom_code/actions/users_ball.dart` | FS balance increment | no-op (SoT=PG) |
| `lib/pages/menu/izmenit_imya|famil|pochtu` | FS users.update | `AppMeApi.patchMe` |
| `lib/pages/menu/nastroiki` | FS photo/dfb | `patchMe` |
| `lib/customer/create_map_page/main_user_widget.dart` | FS fbId | `patchMe` |
| `lib/login/verif/verif_driver` | FS photoUrl | `patchMe` |
| `lib/customer/order_page_customer` | FS complete fallback | API only + SnackBar |
| `lib/customer/responsed_detail` | FS accept/pay_order/viewed | API only / skip viewed FS |
| `lib/customer/order_menu_p_o_p_u_p` | FS hide fallback | API only |
| `lib/driver/popolnit_balans` | pay_order.set | local PayOrder from API id |
| `lib/driver/delete_card` | card.delete FS | `AppMeApi.deleteCard` |
| `lib/admin/admin_vrf`, `orklonit`, `detali_zayavki_admin` | FS verif fallback | API only |
| `lib/login/login` | FS user+chat | `patchMe` + `ensureSupportChat` |
| `lib/pages/menu/rate_app` | FS reviews_of_the_app | skip FS (нет PG endpoint) |

## Ещё WRITE (хвосты)

| Файл | Что |
|------|-----|
| `lib/auth/firebase_auth/firebase_auth_manager.dart` | delete user doc в FS при удалении аккаунта (Auth cleanup; PG отдельно) |
| schema `FieldValue.delete` в struct serializers | не UI-write |

## Сервер

- `POST /api/app/me/payout` — Jump + `balance=0` в PG (`app_payout_ops.py`)
- Прод: `APP_FS_MIRROR=0` — soft_fs не пишет
