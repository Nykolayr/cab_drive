from flask import blueprints, request, render_template, session, abort, redirect, url_for
from errors import *
from .models import *
import traceback
import utils
import json
import trips

app = blueprints.Blueprint('trips', __name__, url_prefix='/api/trips')


@app.route('/processing')
def processing_trips_view():
    try:
        trips.api.processing()
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e))

    return utils.get_answer('ok')


@app.route('/cancel')
def cancel_trip_view():
    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)

    trip_id = request.values.get('id', 0, int)

    try:
        trips.api.cancel_trip_by_admin(user, trip_id)
    except IncorrectDataValue as e:
        return utils.get_error(e.message, status=200)
    except Exception as e:
        print(traceback.format_exc())
        return utils.get_error(str(e), status=200)

    return utils.get_answer('Поездка успешно отменена')


@app.route('/list')
def get_trips_table_view():
    user = utils.get_user([1, 2])
    if user is None:
        return abort(401)

    handler = trips.api.create_trips_table_handler()
    return handler.get_table(request.values.to_dict(), user)
