# Copy to config.py and fill secrets. config.py is gitignored.
class Production:
    PROJECT_NAME = 'Cab Drive'
    SQLALCHEMY_DATABASE_URI = "mysql+pymysql://USER:PASSWORD@HOST/DB"

    PORT = 5000

    ZVONOK_API_KEY = 'CHANGE_ME'
    ZVONOK_CAMPAIGN_ID = 0

    REDIS_ADDRESS = '127.0.0.1'
    REDIS_PORT = 6379
    REDIS_PASSWORD = 'CHANGE_ME'

    MAPS_TOKEN = 'CHANGE_ME'

    TROIKA_S_BASE_URL = 'http://HOST:PORT'

    YANDEX_SUGGEST = 'CHANGE_ME'

    TWO_GIS_KEY = 'CHANGE_ME'

    YOOKASSA_SHOP_ID = 'CHANGE_ME'
    YOOKASSA_TOKEN = 'CHANGE_ME'

    SMS_NUMBER = 'CHANGE_ME'
    SMS_TOKEN = 'Bearer CHANGE_ME'

    GOOGLE_API_KEY = 'CHANGE_ME'
