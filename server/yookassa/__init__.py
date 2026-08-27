from uuid import uuid4
from requests.auth import HTTPBasicAuth
import requests
import config
from errors import IncorrectDataValue


def create_payment(amount: int, description: str, customer_phone: str):
    url = 'https://api.yookassa.ru/v3/payments'

    headers = {
        'Idempotence-Key': str(uuid4()),
    }

    auth = HTTPBasicAuth(username=config.Production.YOOKASSA_SHOP_ID, password=config.Production.YOOKASSA_TOKEN)

    data = {
        'amount': {
            'value': amount,
            'currency': 'RUB'
        },
        'capture': True,
        'confirmation': {
            'type': 'redirect',
            'return_url': 'https://treshka-taxi.ru/#tarif'
        },
        'description': description,
        'receipt': {
            'customer': {
                'phone': '7' + customer_phone
            },
            'items': [
                {
                    'description': description,
                    'amount': {
                        'value': amount,
                        'currency': 'RUB'
                    },
                    'vat_code': 1,
                    'quantity': 1,
                    'payment_subject': 'service',
                    'payment_mode': 'full_payment'
                }
            ]
        }
    }

    response = requests.post(url, headers=headers, auth=auth, json=data)

    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка создания платежа')

    data = response.json()

    return data['id'], data['confirmation']['confirmation_url']