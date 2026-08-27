from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
from .models import *
import datetime
import traceback
import utils
import json
import payments

app = blueprints.Blueprint('payments', __name__, url_prefix='/api/payments')


@app.route('/callback', methods=['POST'])
def callback_payment_view():
    data = request.json

    path = '{}/yookassa.log'.format(utils.get_script_dir())

    with open(path, 'a', encoding='utf-8') as f:
        f.write('\n\n{}:\n{}'.format(datetime.datetime.now().strftime('%d.%m.%Y %H:%M'), data))

    pay_token = data['object']['id']
    pay_event = data['event']

    if pay_event == 'payment.succeeded':
        try:
            payments.api.approve_payment(pay_token, True)
        except:
            with open(path, 'a', encoding='utf-8') as f:
                f.write('\n\n{}'.format(traceback.format_exc()))
    elif pay_event == 'payment.canceled':
        try:
            payments.api.approve_payment(pay_token, False)
        except:
            with open(path, 'a', encoding='utf-8') as f:
                f.write('\n\n{}'.format(traceback.format_exc()))

    return utils.get_answer('OK')