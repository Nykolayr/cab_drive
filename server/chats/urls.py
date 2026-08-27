from flask import blueprints, request, render_template, session, abort, redirect, url_for, jsonify

import chats.api
from chats.api import send_chat_message
from errors import *
import utils
import users

app = blueprints.Blueprint('chats', __name__, url_prefix='/api/chats')

@app.route('/send', methods=['POST'])
def send():
    user = utils.get_user()
    if user is None:
        return abort(401)

    # Извлечение данных из JSON тела запроса
    data = request.get_json()
    print(data)

    chat_id = data.get('chat_id')
    text = data.get('text', '')
    sender_id="MEkzqxquE2OqdVEZi4NrxZ9K8F03"


    try:

        send_chat_message(chat_id, text, sender_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')


@app.route('/mark_as_read', methods=['POST'])
def mark_as_read():
    user = utils.get_user()
    if user is None:
        return abort(401)

    # Извлечение данных из JSON тела запроса
    data = request.get_json()
    print(data)

    chat_id = data.get('chat_id')

    try:

        chats.api.mark_chat_messages_read(chat_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Сохранено')

@app.route('/firebase-config', methods=['GET'])
def get_firebase_config():
    firebase_config = {
        "apiKey": "AIzaSyDPFOenBVpndMVS-FvI89nCz2awxlagZo0",
        "authDomain": "ydrive-a35d2.firebaseapp.com",
        "projectId": "ydrive-a35d2",
        "storageBucket": "ydrive-a35d2.firebasestorage.app",
        "messagingSenderId": "1070996805603",
        "appId": "1:1070996805603:web:d1cf0e043f4867e2ebb2d6"
    }

    return jsonify(firebase_config)
