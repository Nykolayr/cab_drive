"""ByteHand SMS API v2 — отправка кодов авторизации SMS-кой.

Замена zvonok flashcall: код генерируем сами и шлём текстом.
Ключ в config.py: BYTEHAND_API_KEY (X-Service-Key), BYTEHAND_SENDER.
"""
from errors import *
import requests
import config
from random import randint
import logging

logger = logging.getLogger(__name__)

_API_URL = 'https://api.bytehand.com/v2/sms/messages'
_TIMEOUT = 10


def _send(receiver: str, text: str) -> dict:
    try:
        resp = requests.post(
            _API_URL,
            headers={
                'Content-Type': 'application/json',
                'X-Service-Key': config.Production.BYTEHAND_API_KEY,
            },
            json={
                'sender': getattr(config.Production, 'BYTEHAND_SENDER', 'SMS-INFO'),
                'receiver': receiver,
                'text': text,
            },
            timeout=_TIMEOUT,
        )
    except requests.RequestException as e:
        logger.warning('[bytehand] request failed: %s', e)
        raise IncorrectDataValue('Ошибка при отправке SMS. Попробуйте позже')

    if resp.status_code != 200:
        logger.warning('[bytehand] status=%s body=%s', resp.status_code, resp.text[:300])
        raise IncorrectDataValue('Ошибка при отправке SMS. Попробуйте позже')

    data = resp.json() if resp.content else {}
    if not isinstance(data, dict) or data.get('result') != 'created':
        logger.warning('[bytehand] unexpected response: %s', data)
        raise IncorrectDataValue('Ошибка при отправке SMS. Попробуйте позже')
    return data


def send_sms(phone: str, code: str) -> None:
    """Шлём уже выданный код (повторная отправка)."""
    _send(f'+7{phone}', f'Ваш код подтверждения: {code}')


def send_code(phone: str) -> str:
    """Генерим код и шлём SMS. Возвращает код (контракт как у zvonok.call)."""
    code = str(randint(1000, 9999))
    send_sms(phone, code)
    return code
