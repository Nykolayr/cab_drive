from functools import wraps
from flask_jwt_extended import get_jwt_identity
from flask import jsonify
from typing import Literal


def role_required(model_class: Literal['user', 'driver', 'any']):
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            identity = get_jwt_identity()

            if not identity or 'account_type' not in identity or 'id' not in identity:
                return jsonify({'msg': 'Invalid token'}), 401

            account_type = identity.get('account_type')
            account_id = identity.get('id')

            if model_class.lower() != account_type and model_class != 'any':
                return jsonify({'msg': 'Unauthorized'}), 403

            param_name = f"{account_type}_id"
            kwargs[param_name] = account_id

            if model_class == 'any':
                if param_name == 'user_id':
                    kwargs['driver_id'] = None
                else:
                    kwargs['user_id'] = None

            return fn(*args, **kwargs)

        return wrapper

    return decorator