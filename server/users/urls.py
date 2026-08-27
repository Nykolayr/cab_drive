from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
import utils
import json
import notify
import users

app = blueprints.Blueprint('users', __name__, url_prefix='/api/users')

@app.route('/edit', methods=['POST'])
def edit():
    user = utils.get_user()
    if user is None:
        return abort(401)

    # Извлечение данных из JSON тела запроса
    data = request.get_json()
    print(data)

    user_id = data.get('user_id')
    name = data.get('display_name', '')
    photo_url = data.get('photo_url')  # Не требуется дополнительная обработка
    is_driver = data.get('is_driver')
    is_blocked = data.get('is_blocked')
    block_comment = data.get('block_comment')
    phone_number = data.get('phone_number')
    verif_ne_proidena  = data.get('verif_ne_proidena')
    verif_compl  = data.get('verif_compl')
    on_verif_now  = data.get('on_verif_now')

    commission  = data.get('commission')
    balance  = data.get('balance')
    bonus_balance = data.get('bonus_balance')

    if bonus_balance is not None and str(bonus_balance).strip() != '' and str(bonus_balance) != 'None':
        print(f"[users/edit] received bonus_balance delta={bonus_balance!r} user_id={user_id}")

    if photo_url == '' or photo_url is None:
        photo_url = None
    elif not photo_url.startswith('http'):
        photo_url = 'http://' + utils.get_server_ip() + '/kek/files/get?uuid=' + photo_url

    try:
        users.api.update_firebase_user(user_id, name, photo_url, is_driver, is_blocked, block_comment, phone_number, verif_ne_proidena, balance, commission, verif_compl, on_verif_now, bonus_balance=bonus_balance)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')

@app.route('/verification_data/edit', methods=['POST'])
def edit_verification_data():
    user = utils.get_user()
    if user is None:
        return abort(401)

    # Извлечение данных из JSON тела запроса
    data = request.get_json()

    # Преобразование uuid в ссылки на фото
    def transform_photo_urls(photo_list):
        return [
            f'http://{utils.get_server_ip()}/kek/files/get?uuid={uuid}'
            if uuid and not uuid.startswith('http') else uuid for uuid in photo_list
        ]

    data['photo_avto'] = transform_photo_urls(data.get('photo_avto', []))
    data['photo_doc'] = transform_photo_urls(data.get('photo_doc', []))

    if data['avatar'] is not None:
        data['avatar'] = transform_photo_urls([data.get('avatar')])[0]

    update_fields = {
        'avatar': data.get('avatar'),
        'name': data.get('name'),
        'surname': data.get('surname'),
        'email': data.get('email'),
        'phone_number': data.get('phone_number'),
        'city': data.get('city'),
        'status': data.get('status'),
        'marka': data.get('marka'),
        'marka_avto': data.get('marka_avto'),
        'number_avto': data.get('number_avto'),
        'number_id': data.get('number_id'),
        'dateCreated': data.get('dateCreated'),
        'dfb': data.get('dfb'),
        'photo_avto': data['photo_avto'],
        'photo_doc': data['photo_doc'],
        'user': data.get('user')
    }

    try:
        users.api.update_driver_verification_data(data['user_id'], update_fields)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')

@app.route('/remove', methods=['POST'])
def remove_user():
    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)

    user_id = request.values.get('id', 0, int)

    try:
        users.api.remove_me(user_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Пользователь успешно заблокирован')

@app.route('/unremove', methods=['POST'])
def unremove_user():
    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)

    user_id = request.values.get('id', 0, int)

    try:
        users.api.unremove_me(user_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Пользователь успешно разблокирован')

@app.route('/get_balance', methods=['GET'])
def get_balance():
    user = utils.get_user()
    if user is None:
        return abort(401)

    user_id = request.args.get('id')
    date_start = request.args.get('date_start', None)
    date_end = request.args.get('date_end', None)

    try:
        balance = users.api.calculate_user_balance(user_id, date_start, date_end)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Баланс получен', info={'balance': balance})


@app.route('/send_message', methods=['GET'])
def send_message():
    user = utils.get_user()
    if user is None:
        return abort(401)

    user_id = request.args.get('user_id')
    message = request.args.get('message', None)

    try:
        users.api.send_message(user_id, message)
    except Exception as e:
        return utils.get_error(str(e), status=500)

    return utils.get_answer('Отправлено')