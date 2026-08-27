from flask_jwt_extended import jwt_required
from flask_openapi3 import Tag, APIView
from .models import *
from errors import *
from decorators import *
import utils
import tariffs
import traceback


tag = Tag(name='Tariffs', description='Управление тарифами')
app = APIView(url_prefix='/kek/tariffs', view_tags=[tag])
security = [{"jwt": []}]


@app.route('/list')
class GetTariffsListView:
    @app.doc(
        summary='Получение списка тарифов',
        responses={
            '200': GetTariffsList,
            '500': models.ErrorAnswer
        },
        security=security
    )
    @jwt_required()
    @role_required('any')
    def get(self, user_id: int | None = None, driver_id: int | None = None):
        try:
            tariffs_list = tariffs.api.get_tariffs()
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'tariffs': tariffs_list}
        )