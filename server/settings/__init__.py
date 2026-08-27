from .urls import app
from .models import *
from errors import *
from logger import logger
import utils
import json
import traceback


def get_model() -> SiteModel:
    try:
        with open('{}/settings_model/model.json'.format(utils.get_script_dir()), 'r', encoding='utf-8') as f:
            model = SiteModel.model_validate(json.loads(f.read()))
        logger.debug(
            "[settings.get_model] loaded multi_orders: "
            f"max_extra_distance_km={model.extra_order_max_extra_distance_km}, "
            f"max_extra_time_min={model.extra_order_max_extra_time_min}, "
            f"search_radius_km={model.extra_order_search_radius_km}, "
            f"driver_max_queue_size={model.driver_max_queue_size}, "
            f"notify_cooldown_sec={model.extra_order_notify_cooldown_sec}"
        )
    except:
        logger.error(f"[settings.get_model] failed to load, returning defaults:\n{traceback.format_exc()}")
        return SiteModel()
    return model


def save_model(model: SiteModel):
    print(model)
    with open('{}/settings_model/model.json'.format(utils.get_script_dir()), 'w', encoding='utf-8') as f:
        f.write(json.dumps(model.model_dump(), ensure_ascii=False, indent=3, default=utils.json_serial))
    return model


def update_model(new_model: SiteModel):
    model = get_model()

    if len(new_model.driver_tariffs) == 0:
        raise IncorrectDataValue('Добавьте хотя бы один тариф')

    model.driver_tariffs = new_model.driver_tariffs
    model.minutes_for_delete_order = new_model.minutes_for_delete_order
    model.deadline_minutes = new_model.deadline_minutes

    save_model(model)


def update_polygons(polygons: List[Area]):
    model = get_model()

    if len(polygons) == 0:
        raise IncorrectDataValue('Добавьте хотя бы одну зону работы')

    model.polygons = polygons
    save_model(model)


def update_cities(polygons: List[Area]):
    model = get_model()

    model.cities = polygons
    save_model(model)