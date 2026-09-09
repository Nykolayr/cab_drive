"""
Логика дополнительных заказов «по пути» (multi-orders).

Содержит:
    * is_route_compatible — сравнивает прирост маршрута при вставке нового заказа в
      план водителя через Google Directions API.
    * find_busy_drivers_for_order — ищет занятых водителей, для которых новый заказ
      «по пути».

Пороги совместимости берутся из settings (settings.get_model()):
    extra_order_max_extra_distance_km, extra_order_max_extra_time_min,
    extra_order_search_radius_km.
"""
from __future__ import annotations

import math
import traceback
from typing import Any, Dict, List, Optional, Tuple

import requests
from firebase_admin import firestore

import settings
from logger import logger


GOOGLE_DIRECTIONS_URL = "https://maps.googleapis.com/maps/api/directions/json"

# Статусы заказа, при которых водитель считается «занят с пассажиром/едет к нему»
ACTIVE_ORDER_STATUSES = ("spec_set", "place_pickup", "at_work")
# Статусы, в которых водитель ещё едет к pointA (pickup ещё впереди)
PRE_PICKUP_STATUSES = ("spec_set", "place_pickup")


# ----------------------------- утилиты -----------------------------

def _haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Прямая дистанция между двумя точками (км)."""
    R = 6371.0
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def _coord_str(lat: float, lng: float) -> str:
    return f"{lat},{lng}"


def _extract_point_latlng(point: Any) -> Optional[Tuple[float, float]]:
    """Достаёт (lat, lng) из PointStruct-like объекта (dict с 'latlng')."""
    if point is None:
        return None
    if isinstance(point, dict):
        ll = point.get("latlng") or point.get("latLng") or point
        if isinstance(ll, dict):
            lat = ll.get("latitude", ll.get("lat"))
            lng = ll.get("longitude", ll.get("lng"))
            if lat is not None and lng is not None:
                try:
                    return float(lat), float(lng)
                except Exception:
                    return None
        if isinstance(ll, (list, tuple)) and len(ll) >= 2:
            try:
                return float(ll[0]), float(ll[1])
            except Exception:
                return None
    if hasattr(point, "latitude") and hasattr(point, "longitude"):
        try:
            return float(point.latitude), float(point.longitude)
        except Exception:
            return None
    return None


def _extract_driver_location(driver_doc: Dict[str, Any]) -> Optional[Tuple[float, float]]:
    """Достаёт (lat, lng) из user-документа водителя (FS GeoPoint или PG driver_lat/lng)."""
    lat = driver_doc.get("driver_lat")
    lng = driver_doc.get("driver_lng")
    if lat is not None and lng is not None:
        try:
            return float(lat), float(lng)
        except Exception:
            pass
    loc = driver_doc.get("driver_location") or driver_doc.get("location")
    if loc is None:
        return None
    if hasattr(loc, "latitude") and hasattr(loc, "longitude"):
        return float(loc.latitude), float(loc.longitude)
    if isinstance(loc, dict):
        lat = loc.get("latitude", loc.get("lat"))
        lng = loc.get("longitude", loc.get("lng"))
        if lat is not None and lng is not None:
            return float(lat), float(lng)
    if isinstance(loc, (list, tuple)) and len(loc) >= 2:
        try:
            return float(loc[0]), float(loc[1])
        except Exception:
            return None
    return None


def _driver_uid_from_order(order: Dict[str, Any]) -> Optional[str]:
    drv = order.get("selected_driver") or order.get("selected_driver_id")
    if drv is None:
        return None
    if isinstance(drv, str):
        return drv.rsplit("/", 1)[-1] if "/" in drv else drv
    if isinstance(drv, dict) and "_ref" in drv:
        return str(drv["_ref"]).rsplit("/", 1)[-1]
    return getattr(drv, "id", None)


# ----------------------------- Google Directions -----------------------------

def _call_directions(
    origin: Tuple[float, float],
    destination: Tuple[float, float],
    waypoints: List[Tuple[float, float]],
    api_key: str,
) -> Optional[Tuple[float, float]]:
    """Вызывает Directions API. Возвращает (total_km, total_min) или None при ошибке."""
    params = {
        "origin": _coord_str(*origin),
        "destination": _coord_str(*destination),
        "language": "ru",
        "key": api_key,
        "units": "metric",
    }
    if waypoints:
        params["waypoints"] = "|".join(_coord_str(*w) for w in waypoints)
    try:
        resp = requests.get(GOOGLE_DIRECTIONS_URL, params=params, timeout=10)
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        logger.warning(f"[extra_orders._call_directions] HTTP failure: {e}")
        return None

    if data.get("status") != "OK" or not data.get("routes"):
        logger.warning(
            f"[extra_orders._call_directions] non-OK status={data.get('status')} "
            f"err={data.get('error_message')}"
        )
        return None

    route = data["routes"][0]
    tot_m = 0
    tot_s = 0
    for leg in route.get("legs", []):
        tot_m += int(leg.get("distance", {}).get("value", 0))
        tot_s += int(leg.get("duration", {}).get("value", 0))
    return tot_m / 1000.0, tot_s / 60.0


def _fallback_haversine_route(points: List[Tuple[float, float]]) -> Tuple[float, float]:
    """Грубая оценка по прямой между точками + средняя скорость 40 km/h."""
    total_km = 0.0
    for i in range(len(points) - 1):
        total_km += _haversine_km(points[i][0], points[i][1], points[i + 1][0], points[i + 1][1])
    total_min = (total_km / 40.0) * 60.0
    return total_km, total_min


def _route_metrics(
    points: List[Tuple[float, float]],
    api_key: str,
) -> Tuple[float, float, bool]:
    """Считает (km, min, used_google) для маршрута, с fallback на haversine."""
    if len(points) < 2:
        return 0.0, 0.0, False
    if api_key:
        result = _call_directions(points[0], points[-1], points[1:-1], api_key)
        if result is not None:
            return result[0], result[1], True
    km, mins = _fallback_haversine_route(points)
    return km, mins, False


# ----------------------------- основная логика -----------------------------

def is_route_compatible(
    current_order: Dict[str, Any],
    new_order: Dict[str, Any],
    driver_location: Tuple[float, float],
    api_key: str,
) -> Dict[str, Any]:
    """
    Сравнивает текущий маршрут водителя с маршрутом, в который вставлен новый заказ.

    Возвращает dict:
        {
            "compatible": bool,
            "delta_km": float,
            "delta_min": float,
            "base_km": float,
            "best_km": float,
            "best_min": float,
            "best_order": [coords...],
            "used_google": bool,
        }
    """
    model = settings.get_model()
    max_extra_km = model.extra_order_max_extra_distance_km
    max_extra_min = model.extra_order_max_extra_time_min

    cur_a = _extract_point_latlng(current_order.get("pointA"))
    cur_b = _extract_point_latlng(current_order.get("pointB"))
    new_a = _extract_point_latlng(new_order.get("pointA"))
    new_b = _extract_point_latlng(new_order.get("pointB"))

    cur_id = current_order.get("id")
    new_id = new_order.get("id")
    logger.info(f"[extra_orders.is_route_compatible] entry current={cur_id} new={new_id}")

    if not (cur_b and new_a and new_b and driver_location):
        logger.warning(
            f"[extra_orders.is_route_compatible] missing geometry: "
            f"cur_a={cur_a} cur_b={cur_b} new_a={new_a} new_b={new_b} drv={driver_location}"
        )
        return {
            "compatible": False,
            "delta_km": 0.0,
            "delta_min": 0.0,
            "reason": "missing_geometry",
        }

    cur_status = (current_order.get("status") or "").lower()
    has_picked_up = cur_status not in PRE_PICKUP_STATUSES  # at_work / place_delivery

    # Базовый маршрут (без доп.заказа)
    if has_picked_up:
        # пассажир уже в машине → driver_location -> cur_b
        base_points = [driver_location, cur_b]
    else:
        # ещё не подобрал → driver_location -> cur_a -> cur_b
        base_points = [driver_location, cur_a, cur_b] if cur_a else [driver_location, cur_b]
    base_km, base_min, used_google = _route_metrics(base_points, api_key)

    # Кандидаты вставки нового заказа. Берём 2 наивные перестановки и минимум.
    if has_picked_up:
        # Высадить текущего → потом забрать нового → высадить нового
        candidate_routes = [
            [driver_location, cur_b, new_a, new_b],
        ]
    else:
        # Возможные планы:
        #   plan A: текущий пассажир первым (стандарт), потом новый
        #     drv -> cur_a -> cur_b -> new_a -> new_b
        #   plan B: захватить нового по пути, потом текущего, потом высадки
        #     drv -> new_a -> cur_a -> cur_b -> new_b  (если новый pickup ближе)
        candidate_routes = [
            [driver_location, cur_a, cur_b, new_a, new_b],
            [driver_location, new_a, cur_a, cur_b, new_b],
        ]

    best = None
    for route in candidate_routes:
        km, mins, ug = _route_metrics(route, api_key)
        if best is None or mins < best[1]:
            best = (km, mins, route, ug)

    best_km, best_min, best_route, used_google_best = best
    delta_km = best_km - base_km
    delta_min = best_min - base_min
    compatible = delta_km <= max_extra_km and delta_min <= max_extra_min

    logger.info(
        f"[extra_orders.is_route_compatible] result current={cur_id} new={new_id} "
        f"compatible={compatible} delta_km={delta_km:.2f} delta_min={delta_min:.2f} "
        f"base_km={base_km:.2f} best_km={best_km:.2f} thresholds={max_extra_km}/{max_extra_min} "
        f"used_google={used_google and used_google_best}"
    )

    return {
        "compatible": compatible,
        "delta_km": round(delta_km, 3),
        "delta_min": round(delta_min, 2),
        "base_km": round(base_km, 3),
        "best_km": round(best_km, 3),
        "best_min": round(best_min, 2),
        "best_order": best_route,
        "used_google": used_google and used_google_best,
    }


# ----------------------------- поиск занятых водителей -----------------------------

def _list_active_orders_for_drivers() -> Dict[str, Dict[str, Any]]:
    """Возвращает map driver_uid -> active_order_dict для всех водителей в статусе spec_set/place_pickup/at_work."""
    out: Dict[str, Dict[str, Any]] = {}

    # Postgres SoT
    try:
        import app_pg

        if app_pg.enabled():
            rows = app_pg.list_orders_by_statuses(list(ACTIVE_ORDER_STATUSES), limit_per_status=200)
            for d in rows:
                drv_uid = _driver_uid_from_order(d)
                if drv_uid and drv_uid not in out:
                    out[drv_uid] = d
            if out:
                return out
    except Exception as e:
        logger.warning(f"[extra_orders._list_active_orders_for_drivers] PG failed: {e}")

    db = firestore.client()
    for status in ACTIVE_ORDER_STATUSES:
        try:
            docs = db.collection("order").where("status", "==", status).stream()
            for doc in docs:
                d = doc.to_dict() or {}
                d["id"] = doc.id
                drv_uid = _driver_uid_from_order(d)
                if drv_uid and drv_uid not in out:
                    out[drv_uid] = d
        except Exception as e:
            logger.warning(f"[extra_orders._list_active_orders_for_drivers] failed status={status}: {e}")
    return out


def _load_driver_user(driver_uid: str) -> Optional[Dict[str, Any]]:
    """Профиль водителя: PG get_me, fallback Firestore."""
    try:
        import app_pg

        if app_pg.enabled():
            me = app_pg.get_me(driver_uid)
            if me:
                return me
    except Exception as e:
        logger.warning(f"[extra_orders._load_driver_user] PG failed uid={driver_uid}: {e}")

    try:
        db = firestore.client()
        user_doc = db.collection("users").document(driver_uid).get()
        if not user_doc.exists:
            return None
        return user_doc.to_dict() or {}
    except Exception as e:
        logger.warning(f"[extra_orders._load_driver_user] FS failed uid={driver_uid}: {e}")
        return None


def find_busy_drivers_for_order(new_order: Dict[str, Any], api_key: str) -> List[Dict[str, Any]]:
    """
    Возвращает список совместимых занятых водителей, отсортированный по delta_min asc.

    Каждый элемент:
        {
            "driver_uid": str,
            "current_order_id": str,
            "delta_km": float,
            "delta_min": float,
            "queue_size": int,
        }
    """
    model = settings.get_model()
    search_radius_km = model.extra_order_search_radius_km
    max_queue = model.driver_max_queue_size

    new_a = _extract_point_latlng(new_order.get("pointA"))
    new_id = new_order.get("id")
    new_car = (new_order.get("car") or "").lower() if isinstance(new_order.get("car"), str) else ""

    logger.info(
        f"[extra_orders.find_busy_drivers_for_order] entry order_id={new_id} "
        f"pointA={new_a} car={new_car} radius_km={search_radius_km}"
    )

    if not new_a:
        logger.warning(f"[extra_orders.find_busy_drivers_for_order] order {new_id} has no pointA")
        return []

    active = _list_active_orders_for_drivers()
    if not active:
        logger.info(f"[extra_orders.find_busy_drivers_for_order] no active drivers found")
        return []

    results: List[Dict[str, Any]] = []

    for driver_uid, cur_order in active.items():
        try:
            user_data = _load_driver_user(driver_uid)
            if not user_data:
                continue

            if user_data.get("is_blocked"):
                continue
            if not user_data.get("on_shift"):
                continue

            # 2) Тариф (mark машины) — должен совпадать с new_order.car
            car = user_data.get("car") or {}
            mark = (car.get("mark") or "").lower() if isinstance(car, dict) else ""
            if new_car and mark and mark != new_car:
                continue

            # 3) Локация водителя
            drv_loc = _extract_driver_location(user_data)
            if not drv_loc:
                continue

            # 4) Радиус
            distance_km = _haversine_km(drv_loc[0], drv_loc[1], new_a[0], new_a[1])
            if distance_km > search_radius_km:
                continue

            # 5) Размер очереди
            queue = user_data.get("active_orders_queue") or []
            queue_size = len(queue)
            if queue_size >= max_queue:
                logger.debug(
                    f"[extra_orders.find_busy_drivers_for_order] skip uid={driver_uid} queue_full={queue_size}"
                )
                continue

            # 6) Совместимость маршрута
            verdict = is_route_compatible(cur_order, new_order, drv_loc, api_key)
            if not verdict.get("compatible"):
                continue

            results.append({
                "driver_uid": driver_uid,
                "current_order_id": cur_order.get("id"),
                "delta_km": verdict["delta_km"],
                "delta_min": verdict["delta_min"],
                "queue_size": queue_size,
                "driver_distance_km": round(distance_km, 3),
            })
        except Exception as e:
            logger.error(
                f"[extra_orders.find_busy_drivers_for_order] driver {driver_uid} error: {e}\n"
                f"{traceback.format_exc()}"
            )
            continue

    results.sort(key=lambda r: r["delta_min"])
    logger.info(
        f"[extra_orders.find_busy_drivers_for_order] result order_id={new_id} "
        f"compatible_count={len(results)}"
    )
    return results
