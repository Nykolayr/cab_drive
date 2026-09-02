"""HTTP API T‑Bank — контракт бывших Cloud Run сервисов для приложения."""

from __future__ import annotations

import json
import traceback

from flask import Response, blueprints, request

import tinkoff.client
import tinkoff.events_log as events_log
from errors import IncorrectDataValue
from logger import logger
import utils

app = blueprints.Blueprint('tinkoff', __name__, url_prefix='/api/tinkoff')


def _json_response(payload: dict, status: int = 200) -> Response:
    return Response(
        response=json.dumps(payload, ensure_ascii=False),
        mimetype='application/json',
        status=status,
    )


def _handle(route: str, fn):
    try:
        result = fn()
        logger.info('[tinkoff.api.%s] OK result_keys=%s', route, list(result.keys()) if isinstance(result, dict) else type(result))
        return _json_response(result)
    except IncorrectDataValue as e:
        logger.error('[tinkoff.api.%s] BAD_REQUEST %s', route, e.message)
        events_log.append_event(
            'api_error',
            level='error',
            message=f'{route}: {e.message}',
        )
        return _json_response({'Success': False, 'Message': e.message}, status=400)
    except Exception:
        logger.error('[tinkoff.api.%s] INTERNAL\n%s', route, traceback.format_exc())
        events_log.append_event(
            'api_error',
            level='error',
            message=f'{route}: internal',
        )
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
    logger.info(
        '[tinkoff.api.init-payment] IN amount=%s orderId=%s customerKey=%s desc=%s ip=%s',
        data.get('amount'),
        data.get('orderId'),
        data.get('customerKey'),
        str(data.get('description') or '')[:80],
        request.remote_addr,
    )

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

    return _handle('init-payment', run)


@app.route('/init-recurrent-payment', methods=['POST'])
def init_recurrent_payment_view():
    """Привязка карты: Init + Recurrent=Y → {paymentUrl, paymentId}"""
    data = request.get_json(silent=True) or {}
    logger.info(
        '[tinkoff.api.init-recurrent] IN amount=%s orderId=%s customerKey=%s',
        data.get('amount'),
        data.get('orderId'),
        data.get('customerKey'),
    )

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

    return _handle('init-recurrent', run)


@app.route('/prepare-recurrent-payment', methods=['POST'])
def prepare_recurrent_payment_view():
    """Подготовка Charge → {paymentId}"""
    data = request.get_json(silent=True) or {}
    logger.info(
        '[tinkoff.api.prepare-recurrent] IN amount=%s orderId=%s',
        data.get('amount'),
        data.get('orderId'),
    )

    def run():
        amount = data.get('amount')
        if amount is None:
            raise IncorrectDataValue('amount обязателен')
        return tinkoff.client.prepare_recurrent_payment(
            amount=int(amount),
            order_id=str(data.get('orderId') or ''),
            description=str(data.get('description') or ''),
        )

    return _handle('prepare-recurrent', run)


@app.route('/charge-recurrent-payment', methods=['POST'])
def charge_recurrent_payment_view():
    """Списание по RebillId → Success / paymentId / …"""
    data = request.get_json(silent=True) or {}
    logger.info(
        '[tinkoff.api.charge] IN paymentId=%s hasRebill=%s',
        data.get('paymentId'),
        bool(data.get('rebillId')),
    )

    def run():
        return tinkoff.client.charge_recurrent_payment(
            payment_id=str(data.get('paymentId') or ''),
            rebill_id=str(data.get('rebillId') or ''),
        )

    return _handle('charge', run)


@app.route('/get-card-list', methods=['POST'])
def get_card_list_view():
    """Список карт → {cards: [{CardId, Pan, …}]}"""
    data = request.get_json(silent=True) or {}
    logger.info(
        '[tinkoff.api.get-card-list] IN customerKey=%s',
        data.get('customerKey'),
    )

    def run():
        return tinkoff.client.get_card_list(
            customer_key=str(data.get('customerKey') or ''),
        )

    return _handle('get-card-list', run)


@app.route('/config', methods=['GET'])
def public_config_view():
    """Публичный конфиг для МП: paymentsBaseUrl + mode (без секретов)."""
    try:
        cfg = tinkoff.client.public_config()
        logger.info('[tinkoff.api.config] %s', cfg)
        return _json_response(cfg)
    except Exception:
        logger.error('[tinkoff.api.config] FAIL\n%s', traceback.format_exc())
        return _json_response(
            {
                'paymentsBaseUrl': 'https://cab.artean.ru',
                'mode': 'test',
            }
        )


@app.route('/return', methods=['GET'])
def payment_return_view():
    """SuccessURL / FailURL для T‑Банка (редирект из WebView)."""
    result = (request.args.get('result') or '').strip().lower()
    logger.info(
        '[tinkoff.api.return] result=%s args=%s',
        result,
        dict(request.args),
    )
    title = 'Оплата прошла' if result == 'success' else 'Не получилось оплатить'
    text = (
        'Можно вернуться в приложение.'
        if result == 'success'
        else 'Банк отклонил оплату. Вернитесь в приложение — там будет подробности.'
    )
    html = f"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title}</title></head>
<body style="font-family:sans-serif;padding:24px;text-align:center">
<h2>{title}</h2><p>{text}</p>
</body></html>"""
    return Response(html, status=200, mimetype='text/html')


@app.route('/notification', methods=['POST'])
def notification_view():
    """NotificationURL T‑Банка. Ответ всегда OK (иначе банк ретраит)."""
    data = request.get_json(silent=True)
    if data is None:
        data = request.form.to_dict() if request.form else {}
    logger.info(
        '[tinkoff.api.notification] IN Status=%s PaymentId=%s OrderId=%s Amount=%s ErrorCode=%s Message=%s Success=%s',
        (data or {}).get('Status') if isinstance(data, dict) else None,
        (data or {}).get('PaymentId') if isinstance(data, dict) else None,
        (data or {}).get('OrderId') if isinstance(data, dict) else None,
        (data or {}).get('Amount') if isinstance(data, dict) else None,
        (data or {}).get('ErrorCode') if isinstance(data, dict) else None,
        (data or {}).get('Message') if isinstance(data, dict) else None,
        (data or {}).get('Success') if isinstance(data, dict) else None,
    )
    if isinstance(data, dict):
        events_log.append_event(
            'notification',
            level='info',
            message='notification received',
            order_id=str(data.get('OrderId') or ''),
            payment_id=str(data.get('PaymentId') or ''),
            amount=data.get('Amount'),
            error_code=str(data.get('ErrorCode') or ''),
            status=str(data.get('Status') or ''),
        )
    try:
        import tinkoff.webhook as webhook

        result = webhook.process_notification(data if isinstance(data, dict) else {})
        logger.info('[tinkoff.api.notification] RESULT %s', result)
        path = '{}/tinkoff_notify.log'.format(utils.get_script_dir())
        with open(path, 'a', encoding='utf-8') as f:
            f.write('\n{}\n{}\n{}\n'.format(
                __import__('datetime').datetime.now(), data, result
            ))
    except Exception:
        logger.error('[tinkoff.api.notification] ERROR\n%s', traceback.format_exc())
        path = '{}/tinkoff_notify.log'.format(utils.get_script_dir())
        with open(path, 'a', encoding='utf-8') as f:
            f.write('\n{}\n'.format(traceback.format_exc()))
    # Tinkoff ждёт тело "OK"
    return Response('OK', status=200, mimetype='text/plain')

