import threading

from flask import Response, request, render_template
from flask_openapi3 import OpenAPI, Info
from flask import redirect, url_for
from flask_jwt_extended import JWTManager

import chats
import orders
from db import init_db
import notify
import datetime
import config
import utils
import users
import files
import dashboard
import tariffs
import drivers
import geo
import trips
import settings
import json
import payments
from orders.api import check_order_status, notify_busy_drivers_about_new_orders

init_db()

info = Info(title='CAB DRIVE API', version='1.0.0')
security_schemes = {"jwt": utils.get_jwt()}

app = OpenAPI(__name__, info=info, doc_prefix='/docs', security_schemes=security_schemes)
app.config.from_object(config.Production)
app.secret_key = 'k=00=r3wgjh4 gh423u9tg43ug 43ugbfu23tr23'

JWTManager(app)

app.register_blueprint(dashboard.app)
app.register_blueprint(users.app)
app.register_blueprint(trips.app)
app.register_blueprint(settings.app)
app.register_blueprint(chats.app)
app.register_blueprint(orders.app, url_prefix='/d/api/orders')

app.register_api_view(users.api_view)
app.register_api_view(orders.api_view)
app.register_api_view(files.app)
app.register_api_view(trips.api_view)


@app.route('/')
def home():
    return redirect(url_for('d.statistics_page'))

@app.after_request
def after_request(response: Response):
    url = request.url
    if 'kek' not in url:
        return response
    if request.method == 'GET':
        data = utils.requests_to_dict(request)
    else:
        try:
            data = request.json
        except:
            data = utils.requests_to_dict(request)

    with open('log.txt', 'a', encoding='utf-8') as f:
        date = datetime.datetime.now()
        try:
            f.write('[{}]: {}\n{}\n[{}]: {}\n\n'.format(
                date, url, json.dumps(data, ensure_ascii=False, indent=3), response.status_code, json.dumps(response.get_data(as_text=True), ensure_ascii=False, indent=3)
            ))
        except:
            pass
    return response

@app.route('/delete_request', methods=['GET', 'POST'])
def delete_request():
    if request.method == 'POST':
        email = request.form['email']
        reason = request.form['reason']
        # Здесь можно добавить логику для обработки запроса на удаление
        return render_template('request_sent.html')
    return render_template('delete_request.html')



driver_status_thread = threading.Thread(target=check_order_status)
driver_status_thread.daemon = True
driver_status_thread.start()

extra_notify_thread = threading.Thread(
    target=notify_busy_drivers_about_new_orders,
    name='extra_notify_loop',
)
extra_notify_thread.daemon = True
extra_notify_thread.start()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config.Production.PORT)
