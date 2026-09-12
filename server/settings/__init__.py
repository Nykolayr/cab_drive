from .urls import app
from .models import *
from errors import *
from logger import logger
import utils
import json
import os
import traceback


def _model_path() -> str:
    return os.path.join(utils.get_script_dir(), "settings_model", "model.json")


def get_model() -> SiteModel:
    path = _model_path()
    try:
        with open(path, "r", encoding="utf-8") as f:
            model = SiteModel.model_validate(json.loads(f.read()))
        logger.debug(
            "[settings.get_model] loaded path=%s tinkoff_mode=%s multi_orders: "
            f"max_extra_distance_km={model.extra_order_max_extra_distance_km}, "
            f"max_extra_time_min={model.extra_order_max_extra_time_min}, "
            f"search_radius_km={model.extra_order_search_radius_km}, "
            f"driver_max_queue_size={model.driver_max_queue_size}, "
            f"notify_cooldown_sec={model.extra_order_notify_cooldown_sec}",
            path,
            model.tinkoff_mode,
        )
    except Exception:
        logger.error(
            "[settings.get_model] failed path=%s, returning defaults:\n%s",
            path,
            traceback.format_exc(),
        )
        return SiteModel()
    return model


def save_model(model: SiteModel):
    """Атомарная запись model.json (tmp + replace), чтобы режим Тинькофф не терялся."""
    path = _model_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    payload = json.dumps(
        model.model_dump(),
        ensure_ascii=False,
        indent=3,
        default=utils.json_serial,
    )
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(payload)
        f.write("\n")
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp, path)
    logger.info(
        "[settings.save_model] wrote path=%s tinkoff_mode=%s payments_base_url=%s",
        path,
        getattr(model, "tinkoff_mode", None),
        getattr(model, "payments_base_url", None),
    )
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


def update_tinkoff_settings(*, mode: str | None = None, payments_base_url: str | None = None):
    model = get_model()
    # защита: get_model() при ошибке чтения отдаёт пустой SiteModel() —
    # нельзя затирать model.json дефолтами.
    if not model.driver_tariffs:
        raise IncorrectDataValue(
            "Не удалось загрузить текущие настройки (пустые тарифы). Сохранение отменено — проверьте model.json"
        )
    if mode is None and payments_base_url is None:
        raise IncorrectDataValue("Нечего сохранять: укажите mode и/или payments_base_url")
    if mode is not None:
        mode = str(mode).strip().lower()
        if mode not in ("test", "prod"):
            raise IncorrectDataValue("mode: test или prod")
        model.tinkoff_mode = mode
    if payments_base_url is not None:
        url = str(payments_base_url).strip().rstrip("/")
        if not url.startswith("https://") and not url.startswith("http://"):
            raise IncorrectDataValue("URL должен начинаться с http:// или https://")
        model.payments_base_url = url
    save_model(model)
    # read-back: убеждаемся, что воркеры/диск видят то же значение
    check = get_model()
    if mode is not None and (check.tinkoff_mode or "").strip().lower() != mode:
        raise IncorrectDataValue(
            f"Режим не сохранился на диск (ожидали {mode}, прочитали {check.tinkoff_mode})"
        )
    logger.info(
        "[settings.update_tinkoff] ok mode=%s url=%s",
        check.tinkoff_mode,
        check.payments_base_url,
    )
    return check