from db import Session
from .models import *
from models import PointModel
from errors import *
from drivers.entities import Driver

import utils
import enums
import tariffs
import drivers
import traceback
import requests
import config
import models
import settings


REQUESTS = []


def check_point(point: PointModel) -> bool:
    model = settings.get_model()
    return model.is_point_in_polygons(point)


def get_geo_info(point: PointModel) -> GetGeoInfoResponse:
    url = 'https://geocode-maps.yandex.ru/1.x/?apikey={}&geocode={},{}&format=json&kind=house'.format(
        config.Production.MAPS_TOKEN, point.longitude, point.latitude
    )

    response = requests.get(url)
    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка получения информации')

    try:
        members = response.json()['response']['GeoObjectCollection']['featureMember']
    except:
        print(traceback.format_exc())
        raise IncorrectDataValue('Ошибка получения данных')

    results = []

    for member in members:
        model = GeoInfoModel.model_validate(member['GeoObject'])
        try:
            for kind in member['GeoObject']['metaDataProperty']['GeocoderMetaData']['Address']['Components']:
                if kind['kind'] == 'province':
                    model.location = kind['name']
                if kind['kind'] == 'locality':
                    model.location = kind['name']
        except:
            print(traceback.format_exc())
        results.append(model)

    return GetGeoInfoResponse(results=results)


def get_geo_info_by_two_gis(point: PointModel) -> GetGeoInfoResponse:
    url = 'https://catalog.api.2gis.com/3.0/items/geocode?lon={}&lat={}&fields=items.addresss,items.point,items.adm_div&key={}&type={}&radius={}'.format(
        point.longitude, point.latitude, config.Production.TWO_GIS_KEY, "building", 100
    )

    response = requests.get(url)
    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка получения информации')

    try:
        members = response.json()['result']['items']
    except:
        members = []

    
    if len(members) < 1:
        url = 'https://catalog.api.2gis.com/3.0/items/geocode?lon={}&lat={}&fields=items.addresss,items.point,items.adm_div&key={}'.format(
            point.longitude, point.latitude, config.Production.TWO_GIS_KEY
        )

        response = requests.get(url)
        if response.status_code != 200:
            raise IncorrectDataValue('Ошибка получения информации')

        try:
            members = response.json()['result']['items']
        except:
            print(traceback.format_exc())
            raise IncorrectDataValue('Ошибка получения данных')

    results = []

    if len(members) == 0:
        raise IncorrectDataValue('Ничего не найдено')

    members.sort(key=lambda member: member['type'], reverse=True)

    for member in members:
        if member['type'] == 'adm_div' or member['type'] == 'building':
            try:
                location = member['adm_div'][-1]['name']
            except:
                location = member['name']
            model = GeoInfoModel(name=member['name'], description=member['name'], location=location)
        else:
            continue
        results.append(model)

    return GetGeoInfoResponse(results=results)



def suggest(query: str, point: PointModel | None = None) -> List[Suggest]:
    url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address'

    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token {}'.format(config.Production.DADATA_API_KEY),
        'X-Forwarded-For': '5.187.75.25'
    }

    data = {
        'query': query,
        "from_bound": {"value": "Город"},
        "to_bound": {"value": "house"},
    }
    if point is not None:
        data['locations_geo'] = [
            {
                'lat': point.latitude,
                'lon': point.longitude,
                'radius_meters': 100000
            }
        ]

    response = requests.post(url=url, headers=headers, json=data)
    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка соединения. Попробуйте позже')

    results = response.json()
    suggests = []

    for s in results['suggestions']:
        name = s['value']
        location = s['data']['city_with_type']
        if location is None:
            location = s['data']['settlement_with_type']
        point = models.PointModel(latitude=s['data']['geo_lat'], longitude=s['data']['geo_lon'])
        suggests.append(Suggest(name=name, point=point, location=location))

    return suggests


def get_distances(drivers_list: List[Driver], finish_point: models.PointModel) -> List[DistanceResult]:
    drivers_data = []

    for driver in drivers_list:
        drivers_data.append(
            DriverDistance(
                driver_id=driver.id,
                start=driver.get_position,
                finish=finish_point
            )
        )

    data = GetDistances(drivers=drivers_data)

    url = '{}/api/ors/distances'.format(config.Production.TROIKA_S_BASE_URL)

    response = requests.post(url, json=data.model_dump())

    data = response.json()
    results = [DistanceResult.model_validate(v) for v in data]
    return results


def get_distance(start: PointModel, finish: PointModel) -> DistanceResult | None:
    data = {
        'point_start': start.model_dump(),
        'point_finish': finish.model_dump(),
    }

    url = '{}/api/ors/distance'.format(config.Production.TROIKA_S_BASE_URL)

    response = requests.post(url, json=data)

    if response.status_code != 200:
        print(response.text)
        print(response.status_code)
        return None

    data = response.json()
    return DistanceResult.model_validate(data)


def get_pickup_time(model: GetPickupTimeRequest, radius=20) -> List[PickupTime]:
    results = []

    conditions_list = [
        drivers.Driver.status == enums.DriverStatus.ONLINE,
        drivers.Driver.current_trip_id == None,
        drivers.Driver.is_blocked == False,
        drivers.Driver.last_position != None
    ]

    with Session() as session:
        tariffs_list = tariffs.api.get_tariffs(session=session)
        tariffs_dict = {tariff.id: tariff for tariff in tariffs_list}

        drivers_list = drivers.api.get_nearby_drivers(model.point, radius, conditions_list=conditions_list, session=session)

        for tariff_id in model.tariff_ids:
            tariff = tariffs_dict.get(tariff_id)
            if tariff is None:
                continue

            drivers_in_tariff = list(filter(lambda driver: drivers.api.get_driver_tariff_status(driver, tariff_id), drivers_list))
            if len(drivers_in_tariff) == 0:
                results.append(
                    PickupTime(tariff_id=tariff.id, tariff_name=tariff.name, pickup_time=None)
                )
                continue

            if len(drivers_in_tariff) > 2:
                drivers_in_tariff = drivers_in_tariff[:2]

            distances = get_distances(drivers_in_tariff, model.point)
            if len(distances) == 0:
                results.append(
                    PickupTime(tariff_id=tariff.id, tariff_name=tariff.name, pickup_time=None)
                )
                continue

            results.append(
                PickupTime(tariff_id=tariff.id, tariff_name=tariff.name, pickup_time=distances[0].duration, pickup_distance=distances[0].distance)
            )
            continue
    return results


def yandex_suggest(token: str, query: str, point: PointModel | None = None) -> List[YandexSuggest]:
    url = 'https://suggest-maps.yandex.ru/v1/suggest'

    params = {
        'apikey': config.Production.YANDEX_SUGGEST,
        'text': query,
        'print_address': '1',
        'attrs': 'uri',
        'sessiontoken': token
    }
    if point:
        params['ll'] = '{},{}'.format(point.longitude, point.latitude)

    response = requests.get(url=url, params=params)

    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка. Попробуйте позже')

    data = response.json()

    results = []

    for result in data['results']:
        title = result['title']['text']
        try:
            subtitle = result['subtitle']['text']
        except:
            subtitle = None
        tags = result['tags']
        address = result['address'],
        uri = result['uri']

        components = [YandexSuggestAddressComponent.model_validate(c) for c in address[0]['component']]
        address = YandexSuggestAddress(formatted_address=address[0]['formatted_address'], component=components)

        results.append(
            YandexSuggest(
                title=title,
                subtitle=subtitle,
                tags=tags,
                address=address,
                uri=uri
            )
        )

    set_yandex_lines(results)

    return results


# def twogis_suggest(query: str, point: PointModel | None = None) -> List[TwoGisSuggest]:
#     url = 'https://catalog.api.2gis.com/3.0/items'
#
#     params = {
#         'key': config.Production.TWO_GIS_KEY,
#         'q': query,
#         'fields': 'items.point,items.adm_div',
#         'sort': 'distance'
#     }
#     if point:
#         params['point'] = '{},{}'.format(point.longitude, point.latitude)
#         params['radius'] = 40000
#
#     response = requests.get(url=url, params=params)
#
#     if response.status_code != 200:
#         raise IncorrectDataValue('Ошибка. Попробуйте позже')
#
#     data = response.json()
#
#     for result in data['result']['items']:
#         location = []
#         adm_start = False
#         print(result)
#         for adm_div in result['adm_div']:
#             if adm_start is False and adm_div['type'] in ['city', 'settlement']:
#                 adm_start = True
#                 location.append(adm_div['name'])
#                 continue
#             if adm_start:
#                 location.append(adm_div['name'])
#
#         if len(location) > 0:
#             result['location'] = ', '.join(location)
#         else:
#             result['location'] = result['adm_div'][-1]['name']
#
#         result['point'] = {'latitude': result['point']['lat'], 'longitude': result['point']['lon']}
#
#     return [TwoGisSuggest.model_validate(s) for s in data['result']['items']]


def twogis_suggest(query: str, point: PointModel | None = None) -> List[TwoGisSuggest]:
    url = 'https://catalog.api.2gis.com/3.0/suggests'

    params = {
        'key': config.Production.TWO_GIS_KEY,
        'q': query,
        'fields': 'items.point,items.adm_div',
        'search_nearby': 'true',
        'suggest_type': 'route_endpoint'
    }
    if point:
        params['location'] = '{},{}'.format(point.longitude, point.latitude)

    response = requests.get(url=url, params=params)

    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка. Попробуйте позже')

    data = response.json()

    res_list = []

    for result in data['result']['items']:
        location = []
        adm_start = False
        if 'extend' in result:
            continue
        if 'adm_div' not in result:
            continue
        for adm_div in result['adm_div']:
            if adm_start is False and adm_div['type'] in ['city', 'settlement']:
                adm_start = True
                location.append(adm_div['name'])
                continue
            if adm_start:
                location.append(adm_div['name'])

        if len(location) > 0:
            result['location'] = ', '.join(location)
        else:
            result['location'] = result['adm_div'][-1]['name']

        result['point'] = {'latitude': result['point']['lat'], 'longitude': result['point']['lon']}
        res_list.append(result)

    return [TwoGisSuggest.model_validate(s) for s in res_list]


def get_point_by_uri(uri: str) -> GetPointByURIResponse:
    url = 'https://geocode-maps.yandex.ru/1.x/?apikey={}&uri={}&format=json'.format(
        config.Production.MAPS_TOKEN, uri
    )

    response = requests.get(url)
    if response.status_code != 200:
        raise IncorrectDataValue('Ошибка получения информации')

    try:
        members = response.json()['response']['GeoObjectCollection']['featureMember']
    except:
        print(traceback.format_exc())
        raise IncorrectDataValue('Ошибка получения данных')

    if len(members) == 0:
        raise IncorrectDataValue('Ничего не найдено')

    result = members[0]

    try:
        pos = result['GeoObject']['Point']['pos'].split()
        result = PointModel(latitude=pos[1], longitude=pos[0])
    except:
        print(traceback.format_exc())
        raise IncorrectDataValue('Ошибка. Попробуйте позже')

    return GetPointByURIResponse(point=result)


def set_yandex_lines(models_list: List[YandexSuggest]):
    for model in models_list:
        model.line_1 = model.title

        values = []

        for component in model.address.component:
            if component.kind[0] in ['LOCALITY']:
                values.append(component.name)
            if component.kind[0] == 'STREET' and component.name.lower() not in model.title.lower():
                values.append(component.name)
            if component.kind[0] == 'HOUSE' and component.name.lower() not in model.title.lower().split():
                values.append(component.name)

        model.line_2 = ", ".join([v for v in values])
        if model.line_2 is not None:
            if model.line_2 == model.line_1:
                model.line_2 = ''
            if len(model.line_2) == 0:
                model.line_2 = None
