from errors import *
import requests
import config
from random import randint, random


def call(phone):
    url = 'https://zvonok.com/manager/cabapi_external/api/v1/phones/flashcall/'
    data = {
        'public_key': config.Production.ZVONOK_API_KEY,
        'phone': f'+7{phone}',
        'campaign_id': config.Production.ZVONOK_CAMPAIGN_ID,
    }
    call_response = requests.post(url, data=data)
    if call_response.status_code != 200:
        raise IncorrectDataValue(f'Ошибка при совершении звонка. Попробуйте позже {call_response.text}')

    response_data = call_response.json()

    try:
        return str(response_data['data']['pincode'])
    except:
        raise IncorrectDataValue('Ошибка при совершении звонка. Попробуйте позже')
