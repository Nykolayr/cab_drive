from flask_jwt_extended import jwt_required
from flask_openapi3 import Tag, APIView
from .models import *
from errors import *
from decorators import *

import settings
import models
import utils
import users
import traceback
import notify


tag = Tag(name='Users', description='Управление пользователем')
app = APIView(url_prefix='/kek/users', view_tags=[tag])
security = [{"jwt": []}]


@app.route('/auth')
class AuthView:
    @app.doc(
        summary='Авторизация - получение кода',
        responses={
            '200': AuthResponseModel,
            '500': models.ErrorAnswer
        },
        security=None
    )
    def post(self, form: AuthRequestModel):
        try:
            call_token = users.api.auth(form)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'call_token': call_token}
        )

@app.route('/auth_by_code')
class AuthByCodeView:
    @app.doc(
        summary='Авторизация - подтверждение кода',
        responses={
            '200': AuthByCodeResponseModel,
            '500': models.ErrorAnswer
        },
        security=None
    )
    def post(self, form: AuthByCodeRequestModel):
        try:
            user, access_token = users.api.auth_by_code(form)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except Exception as e:
            print(traceback.format_exc())
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'user': user, 'access_token': access_token}
        )


@app.route('/me')
class GetMeView:
    @app.doc(
        summary='[Role=User] Получение информации об аккаунте',
        responses={
            '200': GetMeResponse,
            '500': models.ErrorAnswer,
            '401': models.ErrorAnswer,
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def get(self, user_id: int):
        try:
            user = users.api.api_get_me(user_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'user': user}
        )




@app.route('/balance')
class EditUsdasserView:
    @app.doc(
        summary='BALANCE профиля',
        responses={
            '200': FirebaseUserModel,
            '500': models.ErrorAnswer,
            '401': models.ErrorAnswer
        },
        security=None
    )
    def post(self):
        try:
            balance = users.api.calculate_user_balance("4SEQn9A2c6MVjRSE03VOCvnWiCr1", None, None)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            '',
            {'balance': balance}
        )

@app.route('/fcm')
class SetFCMUserView:
    @app.doc(
        summary='Установка FCM токена',
        responses={
            '200': EditUserResponse,
            '500': models.ErrorAnswer,
            '401': models.ErrorAnswer
        },
        security=None
    )
    def post(self, form: SetFCMRequest):
        try:
            user = users.api.set_fcm_token(form.uid, form.fcm_token, form.user_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            'Установлено',

        )


@app.route('/delete_account')
class RemoveUserView:
    @app.doc(
        summary='[Role=User] Удаление аккаунта',
        responses={
            '200': models.SuccessAnswer,
            '500': models.ErrorAnswer,
        },
        security=security
    )
    @jwt_required()
    @role_required('user')
    def post(self, user_id: int):
        try:
            users.api.remove_me(user_id)
        except IncorrectDataValue as e:
            return utils.get_error(e.message)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e))

        return utils.get_answer(
            'Аккаунт успешно удалён',
        )



@app.route('/send_push')
class SendPushView:
    @app.doc(
        summary='Отправка пуш уведомлений',
        responses={
            '200': models.SuccessAnswer,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer,
        }
    )
    def post(self, body: PushRequest):
        try:
            result = notify.push_service.send_push_notification(
                fcm_tokens=body.tokens,
                title=body.title,
                message=body.text
            )
        except IncorrectDataValue as e:
            return utils.get_error(e.message, status=200)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e), status=200)

        return utils.get_answer(
            '', {'result': result}
        )


@app.route('/send_push_to_users')
class SendPushToUsersView:
    @app.doc(
        summary='Отправка пуш уведомлений по firebase_id пользователей',
        description='Находит FCM токены в Firestore и отправляет push. Автоматически удаляет невалидные токены.',
        responses={
            '200': models.SuccessAnswer,
            '500': models.ErrorAnswer,
        }
    )
    def post(self, body: SendPushToUsersRequest):
        try:
            result = users.api.send_push_to_firebase_users(
                user_ids=body.user_ids,
                title=body.title,
                text=body.text,
                data=body.data
            )
        except IncorrectDataValue as e:
            return utils.get_error(e.message, status=200)
        except Exception as e:
            traceback.print_exc()
            return utils.get_error(str(e), status=200)

        return utils.get_answer(
            '', {'result': result}
        )


@app.route('/check_inn')
class CheckInnView:
    @app.doc(
        summary='Проверка ИНН',
        responses={
            '200': models.SuccessAnswer,
            '500': models.ErrorAnswer,
            '451': models.ErrorAnswer,
        }
    )
    def get(self, query: CheckInnRequest):
        try:
            result = users.api.check_driver_inn(query.inn)
            print(result)
        except IncorrectDataValue as e:
            return utils.get_error(e.message, status=200)
        except AuthEmptyException:
            return utils.get_error('Неверный токен авторизации', status=401)
        except Exception as e:
            return utils.get_error(str(e), status=200)

        return utils.get_answer(
            '', result
        )