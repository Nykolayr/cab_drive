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
import tinkoff
from orders.api import check_order_status, notify_busy_drivers_about_new_orders

init_db()

# Миграция/сид суперадмина (безопасно при повторном старте)
try:
    from db import engine
    from sqlalchemy import text
    with engine.connect() as conn:
        conn.execute(text(
            "ALTER TABLE users ADD COLUMN is_super_admin TINYINT(1) NOT NULL DEFAULT 0"
        ))
        conn.commit()
except Exception:
    pass
try:
    users.api.ensure_bootstrap_super_admin()
except Exception:
    pass

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
app.register_blueprint(tinkoff.app)
# ЮKassa callback (подписки) — был импорт без register
app.register_blueprint(payments.app)

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



def _start_bg_exclusive(target, name: str):
    def _runner():
        import fcntl
        lock_path = f'/tmp/cab_drive_bg_{name}.lock'
        try:
            lock_f = open(lock_path, 'w')
            fcntl.flock(lock_f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError:
            return
        try:
            target()
        finally:
            try:
                lock_f.close()
            except Exception:
                pass

    t = threading.Thread(target=_runner, daemon=True, name=name)
    t.start()
    return t


_start_bg_exclusive(check_order_status, 'check_order_status')
_start_bg_exclusive(notify_busy_drivers_about_new_orders, 'extra_notify_loop')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config.Production.PORT)
