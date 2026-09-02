"""Обработка Notification URL от T‑Банка → Firestore pay_order + баланс."""

from __future__ import annotations

import traceback
from typing import Any

from firebase_admin import firestore

import tinkoff.client as tinkoff_client
import utils
from logger import logger


SUCCESS_STATUSES = {'CONFIRMED', 'AUTHORIZED'}


def _verify_notification_token(data: dict[str, Any]) -> bool:
    incoming = str(data.get('Token') or '')
    payload = {k: v for k, v in data.items() if k != 'Token'}
    return tinkoff_client.token_matches(payload, incoming)


def process_notification(data: dict[str, Any]) -> dict[str, Any]:
    if not _verify_notification_token(data):
        logger.error(
            '[tinkoff.webhook] bad Token '
            f"status={data.get('Status')} paymentId={data.get('PaymentId')} "
            f"terminal={data.get('TerminalKey')}"
        )
        return {'ok': False, 'error': 'bad token'}

    status = str(data.get('Status') or '')
    payment_id = data.get('PaymentId')
    if payment_id is not None:
        payment_id = str(payment_id)

    if not payment_id:
        return {'ok': False, 'error': 'no PaymentId'}

    if status not in SUCCESS_STATUSES:
        logger.info(
            f'[tinkoff.webhook] ignore status={status} paymentId={payment_id}'
        )
        return {'ok': True, 'ignored': True, 'status': status}

    client = utils.init_firebase_client()
    docs = list(
        client.collection('pay_order')
        .where('paymentId', '==', payment_id)
        .limit(5)
        .stream()
    )
    if not docs:
        try:
            docs = list(
                client.collection('pay_order')
                .where('paymentId', '==', int(payment_id))
                .limit(5)
                .stream()
            )
        except Exception:
            docs = []

    if not docs:
        logger.error(
            f'[tinkoff.webhook] pay_order not found paymentId={payment_id}'
        )
        return {'ok': False, 'error': 'pay_order not found'}

    results = []
    for doc in docs:
        results.append(_apply_paid(client, doc, data))
    return {'ok': True, 'results': results}


def _apply_paid(client, doc, data: dict[str, Any]) -> dict[str, Any]:
    body = doc.to_dict() or {}
    doc_ref = doc.reference

    if body.get('is_paid') is True:
        return {'id': doc_ref.id, 'skipped': 'already_paid'}

    amount_cop = body.get('amount_in_cop') or 0
    try:
        amount_cop = int(amount_cop)
    except (TypeError, ValueError):
        amount_cop = 0
    amount_rub = amount_cop / 100.0

    summ = body.get('summ_upd_ballance')
    if summ is not None:
        try:
            amount_rub = float(summ)
        except (TypeError, ValueError):
            pass

    try:
        doc_ref.update(
            {
                'is_paid': True,
                'tinkoff_status': str(data.get('Status') or ''),
                'tinkoff_paid_at': firestore.SERVER_TIMESTAMP,
            }
        )
    except Exception:
        logger.error(
            f'[tinkoff.webhook] pay_order update fail\n{traceback.format_exc()}'
        )
        return {'id': doc_ref.id, 'error': 'update failed'}

    credited = []
    list_users = body.get('list_users_upd_ballance') or []
    user_ref = body.get('user')
    has_order = body.get('current_order_doc_ref') is not None

    try:
        if list_users and amount_rub > 0:
            for uref in list_users:
                if uref is None:
                    continue
                uref.update({'balance': firestore.Increment(amount_rub)})
                credited.append(getattr(uref, 'id', str(uref)))
        elif user_ref is not None and amount_rub > 0 and not has_order:
            # Пополнение баланса (нет привязанного заказа)
            user_ref.update({'balance': firestore.Increment(amount_rub)})
            credited.append(getattr(user_ref, 'id', str(user_ref)))
    except Exception:
        logger.error(
            f'[tinkoff.webhook] balance credit fail\n{traceback.format_exc()}'
        )

    order_ref = body.get('current_order_doc_ref')
    if order_ref is not None:
        try:
            order_ref.update({'is_paid': True})
        except Exception:
            logger.error(
                f'[tinkoff.webhook] order is_paid fail\n{traceback.format_exc()}'
            )

    logger.info(
        f'[tinkoff.webhook] paid pay_order={doc_ref.id} amount={amount_rub} credited={credited}'
    )
    return {
        'id': doc_ref.id,
        'paid': True,
        'amount_rub': amount_rub,
        'credited': credited,
    }
