import math
import requests
from typing import List, Dict, Optional, Any, Tuple
from firebase_admin import firestore, initialize_app, credentials

import settings

# Наценка за километры/минуты внутри МКАД (cities полигонов).
IN_CITY_SURCHARGE = 1.15

# Инициализация firebase admin SDK (предположим, что у вас есть serviceAccountKey.json)
# В вашей среде замените путь/способ инициализации на свой.
db = firestore.client()

# Конфигурация тарифов
TARIFFS = {
    "largus": 1.0,
    "fiat": 1.2,  # +20%
    "largustermo": 1.4,     # +40% от базового
}

GOOGLE_DISTANCE_MATRIX_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"
GOOGLE_DIRECTIONS_URL = "https://maps.googleapis.com/maps/api/directions/json"


def call_directions_api(origin: str, destination: str, waypoint: Optional[str], api_key: str) -> Dict[str, Any]:
    """
    Вызов Google Directions API.
    origin/destination: "lat,lng"
    waypoint: "lat,lng" или None
    Возвращает распарсенный JSON.
    """
    params = {
        "origin": origin,
        "destination": destination,
        "language": "ru",
        "key": api_key,
        "units": "metric",
    }
    if waypoint:
        # можно использовать 'via:' если нужно обязательно прокладывать через точку
        params["waypoints"] = waypoint  # или f"via:{waypoint}" при необходимости
    resp = requests.get(GOOGLE_DIRECTIONS_URL, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json()

# Настройки для surge (можно тонко настраивать)
def compute_congestion_multiplier(available_count: int) -> float:
    """
    Простейшая логика: чем меньше доступных водителей, тем выше множитель.
    - <=2 водителя => 1.5x
    - <=5 => 1.2x
    - иначе => 1.0x
    """
    if available_count <= 2:
        return 1.5
    if available_count <= 5:
        return 1.2
    return 1.0

def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0  # радиус Земли в км
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def fetch_drivers_within_radius(user_lat: float, user_lng: float, radius_km: float = 10.0) -> List[Dict[str, Any]]:
    """
    Получает всех водителей из Firestore (is_driver == true, on_shift == true) и фильтрует по радиусу.
    Возвращает список словарей с полями документа (включая 'uid' и 'driver_location' как dict с lat/lng).
    """
    drivers = []
    # Для примера мы берем всех водителей, которые на смене. В продакшне стоит использовать геоиндексы.
    qs = db.collection("users").where("is_driver", "==", True).where("on_shift", "==", True).stream()
    for doc in qs:
        data = doc.to_dict()
        # Пропускаем заблокированных/неверифицированных, если нужно
        if data.get("is_blocked", False):
            continue
        loc = data.get("driver_location")
        # Ожидаем GeoPoint-like: {'latitude': .., 'longitude': ..} или firebase.GeoPoint
        if loc is None:
            continue
        # Поддержка нескольких форматов:
        if hasattr(loc, "latitude") and hasattr(loc, "longitude"):  # GeoPoint
            lat, lng = loc.latitude, loc.longitude
        elif isinstance(loc, dict) and ("latitude" in loc or "lat" in loc):
            lat = loc.get("latitude", loc.get("lat"))
            lng = loc.get("longitude", loc.get("lng"))
        elif isinstance(loc, list) and len(loc) >= 2:
            # пример: [lat, lng]
            lat, lng = float(loc[0]), float(loc[1])
        else:
            continue

        dist = haversine_distance_km(user_lat, user_lng, float(lat), float(lng))
        if dist <= radius_km:
            driver_info = {
                "uid": doc.id,
                "data": data,
                "lat": float(lat),
                "lng": float(lng),
                "distance_km": dist,
            }
            drivers.append(driver_info)
    return drivers

def call_distance_matrix(origins: List[str], destinations: List[str], api_key: str) -> Dict[str, Any]:
    """
    Вызов Google Distance Matrix API.
    origins/destinations — списки строк "lat,lng".
    Возвращает распарсенный JSON.
    """
    params = {
        "origins": "|".join(origins),
        "destinations": "|".join(destinations),
        "language": "ru",
        "key": api_key,
        "units": "metric",
    }
    resp = requests.get(GOOGLE_DISTANCE_MATRIX_URL, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json()

def get_pickup_times_all_tariffs(user_lat: float, user_lng: float, api_key: str, radius_km: float = 10.0) -> Dict[str, Optional[Dict[str, Any]]]:
    """
    Для каждого тарифа находит ближайшего доступного водителя соответствующего марки/тк (mark/tariff),
    проверяет ETA (время до подачи), и возвращает данные по каждому тарифу.
    Возвращаемая структура: { tariff_name: { 'eta_seconds': int, 'eta_text': str, 'driver_uid': str, 'driver_distance_km': float } | None }
    """
    # Получаем всех водителей в радиусе
    drivers = fetch_drivers_within_radius(user_lat, user_lng, radius_km)

    if not drivers:
        # Никто не доступен в радиусе
        return {t: None for t in TARIFFS.keys()}

    # Группируем водителей по mark (make/model) — предполагается, что поле mark совпадает с названием тарифа/типа
    drivers_by_mark = {}
    for d in drivers:
        mark = (d["data"].get("car").get("mark") or "").lower()
        drivers_by_mark.setdefault(mark, []).append(d)

    results: Dict[str, Optional[Dict[str, Any]]] = {}
    # Для каждого тарифа — берем ближайшего водителя соответствующего mark
    for tariff_name, multiplier in TARIFFS.items():
        mark_key = tariff_name.lower()  # предполагаем соответствие
        candidates = drivers_by_mark.get(mark_key, [])
        if not candidates:
            # нет доступных водителей данного типа
            results[tariff_name] = None
            continue
        # сортируем по дистанции (к уже найденным в radius)
        candidates.sort(key=lambda x: x["distance_km"])
        # Возьмём топ N (например 5) для батч-запроса к API (чтобы выбрать реально ближайшего по дороге, а не по прямой)
        top_candidates = candidates[:8]
        origins = [f"{c['lat']},{c['lng']}" for c in top_candidates]
        destinations = [f"{user_lat},{user_lng}"]  # время от каждого водителя до пользователя

        try:
            resp = call_distance_matrix(origins, destinations, api_key)
        except Exception as e:
            # В случае ошибки API — fallback: используем прямую дистанцию / примерное время (50 км/ч)
            fallback = top_candidates[0]
            approx_time_sec = int((fallback["distance_km"] / 40.0) * 3600)  # 40 km/h
            results[tariff_name] = {
                "eta_seconds": approx_time_sec,
                "eta_text": f"~{int(approx_time_sec/60)} мин",
                "driver_uid": fallback["uid"],
                "driver_distance_km": fallback["distance_km"],
            }
            continue

        # Парсим ответы: rows[i].elements[0] соответствует origins[i] -> destinations[0]
        best = None
        best_seconds = None
        for i, c in enumerate(top_candidates):
            try:
                elem = resp["rows"][i]["elements"][0]
                if elem.get("status") != "OK":
                    continue
                sec = int(elem["duration"]["value"])
                # выбираем минимальный по реальному времени
                if best_seconds is None or sec < best_seconds:
                    best_seconds = sec
                    best = {
                        "eta_seconds": sec,
                        "eta_text": elem["duration"]["text"],
                        "driver_uid": c["uid"],
                        "driver_distance_km": c["distance_km"],
                    }
            except Exception:
                continue

        results[tariff_name] = best

    return results


def get_prices_all_tariffs(
    user_lat: float,
    user_lng: float,
    dest_lat: float,
    dest_lng: float,
    api_key: str,
    intermediate_point: Optional[Tuple[float, float]] = None,
    base_per_km: float = 23.0,
    base_per_min: float = 3.0,
    base_fee: float = 50.0,
    radius_km: float = 10.0,
    pickup_speed_kmh: float = 40.0,
    movers: int = 0,
) -> Dict[str, Optional[Dict[str, Any]]]:
    """
    Расчёт цены поездки для всех тарифов с опциональной промежуточной точкой
    и с учётом подачи авто (pickup).
    pickup_speed_kmh — средняя скорость движения автомобиля при подаче (km/h).
    """
    # Сначала находим доступных водителей (для определения congestion и подачи)
    drivers = fetch_drivers_within_radius(user_lat, user_lng, radius_km)
    available_count = len(drivers)
    congestion_mult = compute_congestion_multiplier(available_count)

    # Найдём ближайшего водителя (по прямой, полагаем, что fetch_drivers_within_radius даёт поле distance_km)
    pickup_distance_km = 0.0
    pickup_driver_info = None
    if drivers:
        # drivers может быть списком dict или объектов — пробуем оба варианта
        def get_dist(d):
            if isinstance(d, dict):
                return float(d.get("distance_km", math.inf))
            return float(getattr(d, "distance_km", math.inf))

        nearest = min(drivers, key=get_dist)
        pd = get_dist(nearest)
        if pd is None or pd == math.inf:
            pickup_distance_km = 0.0
        else:
            pickup_distance_km = pd
        # минимальная информация о водителе для ответа
        if isinstance(nearest, dict):
            pickup_driver_info = {
                "uid": nearest.get("uid"),
                "display_name": nearest.get("display_name"),
                "phone_number": nearest.get("phone_number"),
                "lat": nearest.get("lat"),
                "lng": nearest.get("lng"),
                "distance_km": pickup_distance_km,
            }
        else:
            pickup_driver_info = {
                "uid": getattr(nearest, "uid", None),
                "display_name": getattr(nearest, "display_name", None),
                "phone_number": getattr(nearest, "phone_number", None),
                "lat": getattr(nearest, "lat", None),
                "lng": getattr(nearest, "lng", None),
                "distance_km": pickup_distance_km,
            }
    else:
        pickup_distance_km = 0.0
        pickup_driver_info = None

    # оценка времени подачи (в секундах)
    pickup_time_hours = pickup_distance_km / pickup_speed_kmh if pickup_speed_kmh > 0 else 0.0
    pickup_time_min = pickup_time_hours * 60.0
    pickup_time_sec = int(pickup_time_min * 60.0)

    distance_km = 0.0
    duration_s = 0
    route_polyline: Optional[str] = None

    try:
        origin = f"{user_lat},{user_lng}"
        destination = f"{dest_lat},{dest_lng}"
        waypoint = f"{intermediate_point[0]},{intermediate_point[1]}" if intermediate_point else None
        resp = call_directions_api(origin, destination, waypoint, api_key)
        if resp.get("status") != "OK" or not resp.get("routes"):
            raise ValueError(f"Directions API returned status {resp.get('status')}")
        route = resp["routes"][0]
        legs = route.get("legs", [])
        tot_dist_m = 0
        tot_dur_s = 0
        for leg in legs:
            if "distance" in leg and "value" in leg["distance"]:
                tot_dist_m += int(leg["distance"]["value"])
            if "duration" in leg and "value" in leg["duration"]:
                tot_dur_s += int(leg["duration"]["value"])
        distance_km = tot_dist_m / 1000.0
        duration_s = tot_dur_s
        duration_min = duration_s / 60.0
        route_polyline = (route.get("overview_polyline") or {}).get("points")
    except Exception:
        # fallback: грубая оценка по прямой (с учётом промежуточной точки, если есть)
        if intermediate_point:
            mid_lat, mid_lng = intermediate_point
            d1 = haversine_distance_km(user_lat, user_lng, mid_lat, mid_lng)
            d2 = haversine_distance_km(mid_lat, mid_lng, dest_lat, dest_lng)
            straight_km = d1 + d2
        else:
            straight_km = haversine_distance_km(user_lat, user_lng, dest_lat, dest_lng)
        distance_km = straight_km
        duration_min = (straight_km / 40.0) * 60.0  # средняя скорость 40 km/h
        duration_s = int(duration_min * 60)

    # Доля маршрута внутри cities-полигонов (МКАД) — для +15% наценки.
    site_model = settings.get_model()
    city_km = 0.0
    if route_polyline:
        try:
            city_km = site_model.route_length_in_cities(route_polyline) / 1000.0
        except Exception:
            city_km = 0.0
    city_km = max(0.0, min(city_km, distance_km))
    outside_km = max(0.0, distance_km - city_km)
    city_ratio = (city_km / distance_km) if distance_km > 0 else 0.0
    pickup_in_city = site_model.is_point_in_cities(user_lat, user_lng)

    # per-km и per-min с пропорциональной +15% наценкой за участок внутри МКАД.
    km_cost = outside_km * base_per_km + city_km * base_per_km * IN_CITY_SURCHARGE
    duration_min_total = duration_s / 60.0
    min_cost = base_per_min * duration_min_total * (
        (1.0 - city_ratio) + city_ratio * IN_CITY_SURCHARGE
    )
    base_fee_effective = base_fee * (IN_CITY_SURCHARGE if pickup_in_city else 1.0)

    # Подача авто: км — с наценкой если точка подачи внутри МКАД; минуты — без наценки.
    pickup_km_cost = base_per_km * pickup_distance_km * (
        IN_CITY_SURCHARGE if pickup_in_city else 1.0
    )
    pickup_min_cost = base_per_min * pickup_time_min

    results: Dict[str, Optional[Dict[str, Any]]] = {}
    for tariff_name, tariff_mult in TARIFFS.items():
        pickup_cost = pickup_km_cost + pickup_min_cost

        price_base_without_pickup = base_fee_effective + km_cost + min_cost
        price_base = price_base_without_pickup + pickup_cost

        price_after_tariff = price_base * tariff_mult
        price_after_congestion = price_after_tariff * congestion_mult

        # Стоимость грузчиков: 600 за каждого
        movers_cost = movers * 600
        final_price = price_after_congestion + movers_cost

        results[tariff_name] = {
            "price": round(final_price),
            "distance_km": round(distance_km, 3),
            "duration_sec": int(duration_s),
            "tariff_multiplier": tariff_mult,
            "congestion_multiplier": congestion_mult,
            "available_drivers_in_radius": available_count,
            "pickup_driver": pickup_driver_info,
            "breakdown": {
                "price_base_without_pickup": round(price_base_without_pickup, 2),
                "base_fee": round(base_fee_effective, 2),
                "km_cost": round(km_cost, 2),
                "min_cost": round(min_cost, 2),
                "city_km": round(city_km, 3),
                "outside_km": round(outside_km, 3),
                "in_city_surcharge": IN_CITY_SURCHARGE,
                "pickup_in_city": pickup_in_city,
                "pickup_distance_km": round(pickup_distance_km, 3),
                "pickup_time_sec": pickup_time_sec,
                "pickup_cost": round(pickup_cost, 2),
                "price_base": round(price_base, 2),
                "price_after_tariff": round(price_after_tariff, 2),
                "price_after_congestion": round(price_after_congestion, 2),
                "movers_count": movers,
                "movers_cost": movers_cost,
            },
            "intermediate_point": {
                "lat": intermediate_point[0],
                "lng": intermediate_point[1],
            } if intermediate_point else None,
        }

    return results