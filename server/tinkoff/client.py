"""T‑Bank (Tinkoff) Acquiring: Init / Recurrent / Charge / GetCardList."""

from __future__ import annotations

import hashlib
from typing import Any

import requests

import config
import settings
from errors import IncorrectDataValue
from logger import logger
import tinkoff.events_log as events_log


def _safe_log_payload(payload: dict[str, Any]) -> dict[str, Any]:
    """Копия тела без Token/Password для логов."""
    skip = {'Token', 'Password', 'password'}
    out: dict[str, Any] = {}
    for key, value in payload.items():
        if key in skip:
            out[key] = '***'
            continue
        out[key] = value
    return out


def _mode() -> str:
    try:
        mode = (settings.get_model().tinkoff_mode or 'test').strip().lower()
    except Exception:
        mode = 'test'
    return mode if mode in ('test', 'prod') else 'test'


def _terminal_key() -> str:
    mode = _mode()
    if mode == 'prod':
        return getattr(config.Production, 'TINKOFF_PROD_TERMINAL_KEY', '') or ''
    return (
        getattr(config.Production, 'TINKOFF_TEST_TERMINAL_KEY', None)
        or getattr(config.Production, 'TINKOFF_TERMINAL_KEY', '')
        or ''
    )


def _password() -> str:
    mode = _mode()
    if mode == 'prod':
        return getattr(config.Production, 'TINKOFF_PROD_PASSWORD', '') or ''
    return (
        getattr(config.Production, 'TINKOFF_TEST_PASSWORD', None)
        or getattr(config.Production, 'TINKOFF_PASSWORD', '')
        or ''
    )


def _api_base() -> str:
    return (
        getattr(config.Production, 'TINKOFF_API_URL', None)
        or 'https://securepay.tinkoff.ru/v2'
    ).rstrip('/')


def _ssl_verify() -> bool:
    return bool(getattr(config.Production, 'TINKOFF_SSL_VERIFY', True))


def _token_str(value: Any) -> str:
    """T‑Bank: bool → true/false (не Python True/False)."""
    if isinstance(value, bool):
        return 'true' if value else 'false'
    return str(value)


def _passwords_for_terminal(terminal_key: str = '') -> list[str]:
    """Пароли для проверки нотификации (тест + прод)."""
    test_pwd = (
        getattr(config.Production, 'TINKOFF_TEST_PASSWORD', None)
        or getattr(config.Production, 'TINKOFF_PASSWORD', '')
        or ''
    )
    prod_pwd = getattr(config.Production, 'TINKOFF_PROD_PASSWORD', '') or ''
    test_key = (
        getattr(config.Production, 'TINKOFF_TEST_TERMINAL_KEY', None)
        or getattr(config.Production, 'TINKOFF_TERMINAL_KEY', '')
        or ''
    )
    prod_key = getattr(config.Production, 'TINKOFF_PROD_TERMINAL_KEY', '') or ''

    ordered: list[str] = []
    if terminal_key and terminal_key == prod_key and prod_pwd:
        ordered.append(prod_pwd)
    if terminal_key and (terminal_key == test_key or str(terminal_key).endswith('DEMO')) and test_pwd:
        ordered.append(test_pwd)
    # запас: текущий режим, затем оба
    for pwd in (_password(), test_pwd, prod_pwd):
        if pwd and pwd not in ordered:
            ordered.append(pwd)
    return ordered


def build_token(payload: dict[str, Any], *, password: str | None = None) -> str:
    skip = {'Token', 'Receipt', 'DATA', 'Data'}
    data: dict[str, Any] = {}
    for key, value in payload.items():
        if key in skip:
            continue
        if isinstance(value, (dict, list)):
            continue
        data[key] = value
    data['Password'] = password if password is not None else _password()
    parts = [_token_str(data[k]) for k in sorted(data.keys())]
    return hashlib.sha256(''.join(parts).encode('utf-8')).hexdigest()


def token_matches(payload: dict[str, Any], incoming: str) -> bool:
    """Проверка Token нотификации: bool-нормализация + пароль по TerminalKey."""
    if not incoming:
        return False
    terminal_key = str(payload.get('TerminalKey') or '')
    for pwd in _passwords_for_terminal(terminal_key):
        expected = build_token(payload, password=pwd)
        if incoming.lower() == expected.lower():
            return True
    return False


def _ensure_credentials() -> None:
    if not _terminal_key() or not _password():
        raise IncorrectDataValue(
            f'Tinkoff ({_mode()}): не заданы ключи терминала в config'
        )


def _post(method: str, body: dict[str, Any], *, allow_list: bool = False) -> Any:
    _ensure_credentials()
    payload = dict(body)
    payload['TerminalKey'] = _terminal_key()
    payload['Token'] = build_token(payload)

    url = f'{_api_base()}/{method}'
    logger.info(
        '[tinkoff.%s] REQUEST mode=%s url=%s body=%s',
        method,
        _mode(),
        url,
        _safe_log_payload(payload),
    )
    try:
        response = requests.post(
            url, json=payload, timeout=30, verify=_ssl_verify()
        )
    except requests.RequestException as e:
        logger.error('[tinkoff.%s] NETWORK_ERROR %s', method, e)
        raise IncorrectDataValue(f'Tinkoff: сеть — {e}') from e

    try:
        data = response.json()
    except ValueError as e:
        logger.error(
            '[tinkoff.%s] BAD_JSON http=%s body=%s',
            method,
            response.status_code,
            (response.text or '')[:500],
        )
        raise IncorrectDataValue(
            f'Tinkoff: не JSON (HTTP {response.status_code})'
        ) from e

    if allow_list and isinstance(data, list):
        logger.info('[tinkoff.%s] OK list_len=%s', method, len(data))
        return data

    if isinstance(data, dict) and not data.get('Success'):
        message = data.get('Message') or data.get('Details') or f'{method} failed'
        error_code = data.get('ErrorCode', '')
        logger.error(
            '[tinkoff.%s] BANK_FAIL ErrorCode=%s Message=%s Details=%s Status=%s PaymentId=%s raw=%s',
            method,
            error_code,
            data.get('Message'),
            data.get('Details'),
            data.get('Status'),
            data.get('PaymentId'),
            data,
        )
        events_log.append_event(
            'bank_fail',
            level='error',
            message=str(message),
            payment_id=str(data.get('PaymentId') or ''),
            order_id=str(body.get('OrderId') or ''),
            amount=body.get('Amount'),
            error_code=str(error_code or ''),
            status=str(data.get('Status') or ''),
            customer_key=str(body.get('CustomerKey') or ''),
            mode=_mode(),
        )
        raise IncorrectDataValue(f'Tinkoff {method} [{error_code}]: {message}')

    if isinstance(data, dict):
        logger.info(
            '[tinkoff.%s] OK Success=%s Status=%s PaymentId=%s hasPaymentURL=%s ErrorCode=%s',
            method,
            data.get('Success'),
            data.get('Status'),
            data.get('PaymentId'),
            bool(data.get('PaymentURL') or data.get('PaymentUrl')),
            data.get('ErrorCode'),
        )
        if method == 'Init':
            events_log.append_event(
                'bank_ok',
                level='info',
                message='Init OK',
                payment_id=str(data.get('PaymentId') or ''),
                order_id=str(body.get('OrderId') or ''),
                amount=body.get('Amount'),
                status=str(data.get('Status') or ''),
                customer_key=str(body.get('CustomerKey') or ''),
                mode=_mode(),
            )
    return data


def _payment_pair(data: dict[str, Any]) -> dict[str, str]:
    payment_url = data.get('PaymentURL') or data.get('PaymentUrl') or ''
    payment_id = data.get('PaymentId')
    if payment_id is not None:
        payment_id = str(payment_id)
    else:
        payment_id = ''
    return {
        'paymentUrl': payment_url,
        'paymentId': payment_id,
    }


def _payments_base() -> str:
    try:
        base = (settings.get_model().payments_base_url or '').rstrip('/')
    except Exception:
        base = ''
    if not base:
        base = 'https://cab.artean.ru'
    return base


def _notification_url() -> str:
    return f'{_payments_base()}/api/tinkoff/notification'


def _success_url() -> str:
    return f'{_payments_base()}/api/tinkoff/return?result=success'


def _fail_url() -> str:
    return f'{_payments_base()}/api/tinkoff/return?result=fail'


def init_payment(
    *,
    amount: int,
    order_id: str,
    description: str = '',
    customer_key: str = '',
    recurrent: bool = False,
) -> dict[str, str]:
    if amount is None or int(amount) <= 0:
        raise IncorrectDataValue('Tinkoff: amount должен быть > 0 (копейки)')
    if not order_id:
        raise IncorrectDataValue('Tinkoff: orderId обязателен')

    body: dict[str, Any] = {
        'Amount': int(amount),
        'OrderId': str(order_id),
        'NotificationURL': _notification_url(),
        'SuccessURL': _success_url(),
        'FailURL': _fail_url(),
    }
    if description:
        body['Description'] = str(description)[:250]
    if customer_key:
        body['CustomerKey'] = str(customer_key)
    if recurrent:
        body['Recurrent'] = 'Y'
        if not customer_key:
            raise IncorrectDataValue(
                'Tinkoff: для recurrent нужен customerKey'
            )

    logger.info(
        '[tinkoff.Init] start amount=%s orderId=%s customerKey=%s recurrent=%s '
        'desc=%s notify=%s success=%s fail=%s',
        amount,
        order_id,
        customer_key,
        recurrent,
        (description or '')[:80],
        _notification_url(),
        _success_url(),
        _fail_url(),
    )
    events_log.append_event(
        'init',
        level='info',
        message='Init request' + (' (recurrent)' if recurrent else ''),
        order_id=order_id,
        amount=amount,
        customer_key=customer_key,
        mode=_mode(),
    )
    try:
        data = _post('Init', body)
    except IncorrectDataValue as e:
        events_log.append_event(
            'init_fail',
            level='error',
            message=str(e.message),
            order_id=order_id,
            amount=amount,
            customer_key=customer_key,
            mode=_mode(),
        )
        raise
    result = _payment_pair(data)
    if not result['paymentUrl'] or not result['paymentId']:
        logger.error('[tinkoff.Init] missing PaymentURL/PaymentId data=%s', data)
        events_log.append_event(
            'init_fail',
            level='error',
            message='missing PaymentURL/PaymentId',
            order_id=order_id,
            amount=amount,
            customer_key=customer_key,
            mode=_mode(),
        )
        raise IncorrectDataValue('Tinkoff: в ответе нет PaymentURL / PaymentId')
    logger.info(
        '[tinkoff.Init] done paymentId=%s paymentUrl=%s',
        result['paymentId'],
        result['paymentUrl'][:120],
    )
    return result


def prepare_recurrent_payment(
    *,
    amount: int,
    order_id: str,
    description: str = '',
) -> dict[str, str]:
    if amount is None or int(amount) <= 0:
        raise IncorrectDataValue('Tinkoff: amount должен быть > 0 (копейки)')
    if not order_id:
        raise IncorrectDataValue('Tinkoff: orderId обязателен')

    body: dict[str, Any] = {
        'Amount': int(amount),
        'OrderId': str(order_id),
        'NotificationURL': _notification_url(),
    }
    if description:
        body['Description'] = str(description)[:250]

    data = _post('Init', body)
    payment_id = data.get('PaymentId')
    if payment_id is None:
        raise IncorrectDataValue('Tinkoff: в ответе нет PaymentId')
    return {'paymentId': str(payment_id)}


def charge_recurrent_payment(
    *,
    payment_id: str,
    rebill_id: str,
) -> dict[str, Any]:
    if not payment_id:
        raise IncorrectDataValue('Tinkoff: paymentId обязателен')
    if not rebill_id:
        raise IncorrectDataValue('Tinkoff: rebillId обязателен')

    try:
        pid: Any = int(str(payment_id))
    except ValueError:
        pid = str(payment_id)

    data = _post(
        'Charge',
        {
            'PaymentId': pid,
            'RebillId': str(rebill_id),
        },
    )
    pair = _payment_pair(data)
    return {
        'Success': True,
        'Message': data.get('Message') or '',
        'ErrorCode': str(data.get('ErrorCode', '0')),
        'paymentUrl': pair['paymentUrl'],
        'paymentId': pair['paymentId'] or str(payment_id),
        'Status': data.get('Status'),
    }


def get_card_list(*, customer_key: str) -> dict[str, Any]:
    if not customer_key:
        raise IncorrectDataValue('Tinkoff: customerKey обязателен')

    data = _post(
        'GetCardList',
        {'CustomerKey': str(customer_key)},
        allow_list=True,
    )

    if isinstance(data, list):
        cards = data
    elif isinstance(data, dict):
        cards = data.get('Cards') or data.get('cards')
        if cards is None:
            raw = data.get('Payload') or data.get('Data')
            cards = raw if isinstance(raw, list) else []
    else:
        cards = []

    normalized = []
    for card in cards or []:
        if not isinstance(card, dict):
            continue
        normalized.append(
            {
                'CardId': card.get('CardId') or card.get('cardId'),
                'Pan': card.get('Pan') or card.get('pan'),
                'Status': card.get('Status') or card.get('status'),
                'RebillId': card.get('RebillId') or card.get('rebillId'),
                'ExpDate': card.get('ExpDate') or card.get('expDate'),
            }
        )
    return {'cards': normalized}


def public_config() -> dict[str, Any]:
    model = settings.get_model()
    return {
        'paymentsBaseUrl': (model.payments_base_url or 'https://cab.artean.ru').rstrip('/'),
        'mode': model.tinkoff_mode or 'test',
    }
