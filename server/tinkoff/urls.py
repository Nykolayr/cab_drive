"""HTTP API T‑Bank — контракт бывших Cloud Run сервисов для приложения."""

from __future__ import annotations

import json
import traceback

from flask import Response, blueprints, request

import tinkoff.client
from errors import IncorrectDataValue
import utils

app = blueprints.Blueprint('tinkoff', __name__, url_prefix='/api/tinkoff')


def _json_response(payload: dict, status: int = 200) -> Response:
    return Response(
        response=json.dumps(payload, ensure_ascii=False),
        mimetype='application/json',
        status=status,
    )


def _handle(fn):
    try:
        return _json_response(fn())
    except IncorrectDataValue as e:
        return _json_response({'Success': False, 'Message': e.message}, status=400)
    except Exception:
        path = '{}/tinkoff.log'.format(utils.get_script_dir())
        with open(path, 'a', encoding='utf-8') as f:
            f.write('\n\n{}'.format(traceback.format_exc()))
        return _json_response(
            {'Success': False, 'Message': 'Internal error'},
            status=500,
        )


@app.route('/init-payment', methods=['POST'])
def init_payment_view():
    """Body: amount, description, orderId, customerKey → {paymentUrl, paymentId}"""
    data = request.get_json(silent=True) or {}

    def run():
        amount = data.get('amount')
        if amount is None:
            raise IncorrectDataValue('amount обязателен')
        return tinkoff.client.init_payment(
            amount=int(amount),
            order_id=str(data.get('orderId') or ''),
            description=str(data.get('description') or ''),
            customer_key=str(data.get('customerKey') or ''),
            recurrent=False,
        )

    return _handle(run)


@app.route('/init-recurrent-payment', methods=['POST'])
def init_recurrent_payment_view():
    """Привязка карты: Init + Recurrent=Y → {paymentUrl, paymentId}"""
    data = request.get_json(silent=True) or {}

    def run():
        amount = data.get('amount')
        if amount is None:
            raise IncorrectDataValue('amount обязателен')
        return tinkoff.client.init_payment(
            amount=int(amount),
            order_id=str(data.get('orderId') or ''),
            description=str(data.get('description') or ''),
            customer_key=str(data.get('customerKey') or ''),
            recurrent=True,
        )

    return _handle(run)


@app.route('/prepare-recurrent-payment', methods=['POST'])
def prepare_recurrent_payment_view():
    """Подготовка Charge → {paymentId}"""
    data = request.get_json(silent=True) or {}

    def run():
        amount = data.get('amount')
        if amount is None:
            raise IncorrectDataValue('amount обязателен')
        return tinkoff.client.prepare_recurrent_payment(
            amount=int(amount),
            order_id=str(data.get('orderId') or ''),
            description=str(data.get('description') or ''),
        )

    return _handle(run)


@app.route('/charge-recurrent-payment', methods=['POST'])
def charge_recurrent_payment_view():
    """Списание по RebillId → Success / paymentId / …"""
    data = request.get_json(silent=True) or {}

    def run():
        return tinkoff.client.charge_recurrent_payment(
            payment_id=str(data.get('paymentId') or ''),
            rebill_id=str(data.get('rebillId') or ''),
        )

    return _handle(run)


@app.route('/get-card-list', methods=['POST'])
def get_card_list_view():
    """Список карт → {cards: [{CardId, Pan, …}]}"""
    data = request.get_json(silent=True) or {}

    def run():
        return tinkoff.client.get_card_list(
            customer_key=str(data.get('customerKey') or ''),
        )

    return _handle(run)


@app.route('/config', methods=['GET'])
def public_config_view():
    """Публичный конфиг для МП: paymentsBaseUrl + mode (без секретов)."""
    try:
        return _json_response(tinkoff.client.public_config())
    except Exception:
        return _json_response(
            {
                'paymentsBaseUrl': 'https://cab.artean.ru',
                'mode': 'test',
            }
        )


@app.route('/notification', methods=['POST'])
def notification_view():
    """NotificationURL T‑Банка. Ответ всегда OK (иначе банк ретраит)."""
    data = request.get_json(silent=True)
    if data is None:
        data = request.form.to_dict() if request.form else {}
    try:
        import tinkoff.webhook as webhook

        result = webhook.process_notification(data if isinstance(data, dict) else {})
        path = '{}/tinkoff_notify.log'.format(utils.get_script_dir())
        with open(path, 'a', encoding='utf-8') as f:
            f.write('\n{}\n{}\n{}\n'.format(
                __import__('datetime').datetime.now(), data, result
            ))
    except Exception:
        path = '{}/tinkoff_notify.log'.format(utils.get_script_dir())
        with open(path, 'a', encoding='utf-8') as f:
            f.write('\n{}\n'.format(traceback.format_exc()))
    # Tinkoff ждёт тело "OK"
    return Response('OK', status=200, mimetype='text/plain')

