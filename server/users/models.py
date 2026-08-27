from pydantic import BaseModel, Field
from typing import List
import models
import datetime


class UserModel(BaseModel):
    id: int = Field(description='ID пользователя')
    phone: str = Field(description='Телефон пользователя')
    name: str = Field(description='Имя пользователя')
    created_at: datetime.datetime = Field(description='Дата регистрации')
    photo_uuid: str | None = Field(description='UUID фотографии')
    fcm_token: str | None = Field(description='FCM Token')


class FirebaseUserAuthModel(BaseModel):
    id: int = Field(description='ID пользователя')
    phone: str = Field(description='Телефон пользователя')
    password: str = Field(description='Пароль для авторизации')
    firebase_id:  str = Field(description='ID Firebase')



class FirebaseUserModel(BaseModel):
    admin: bool = Field(description='IS ADMIN')
    display_name: str = Field(description='Имя пользователя')
    email: str = Field(description='Email пользователя')
    is_driver: bool = Field(description='Водитель ли')
    login_complete: bool = Field(description='Завершил авторизацию')
    created_time: datetime.datetime = Field(description='Дата регистрации')
    photo_uuid: str | None = Field(description='UUID фотографии')
    fcm_tokens: List[str] | None = Field(description='FCM Tokens')



class FirebaseUserModelListRequest(BaseModel):
    query: str = Field(description='Поисковое значение', default="")
    is_driver: bool = Field(description='Водитель ли', default=None)
    login_complete: bool = Field(description='Завершил авторизацию', default=None)

class FirebaseUserModelListResponse(BaseModel):
    users: List[FirebaseUserModel] = Field(description='')

class FirebaseCarModel(BaseModel):
    nomer: str = Field(description='Car number')
    mark: str | None = Field(description='Марка')
    images: List[str] | None = Field(description='Изображения')

class AuthRequestModel(BaseModel):
    phone: str = Field(description='Номер телефона пользователя в любом формате', default='')


class AuthResponseModel(models.SuccessAnswer):
    call_token: str = Field(description='Токен звонка, который необходимо передавать в методе подтверждения авторизации')


class AuthByCodeRequestModel(BaseModel):
    call_token: str = Field(description='Токен звонка, полученный в методе авторизации')
    code: int = Field(description='4 последних цифры номера входящего звонка')


class AuthByCodeResponseModel(models.SuccessAnswer):
    user: FirebaseUserAuthModel = Field(description='Модель пользователя')
    access_token: str = Field(description='Bearer токен авторизации')


class AuthModel(BaseModel):
    phone: str
    date: datetime.datetime
    code: int


class GetMeResponse(models.SuccessAnswer):
    user: UserModel = Field(description='Модель пользователя')


class EditUserRequest(BaseModel):
    name: str | None = Field(description='Имя пользователя')
    photo_uuid: str | None = Field(description='UUID аватарки пользователя')


class EditUserResponse(models.SuccessAnswer):
    user: UserModel = Field(description='Модель пользователя')


class CheckPosition(BaseModel):
    position: models.PointModel = Field(description='Местоположение пользователя')


class SetFCMRequest(BaseModel):
    fcm_token: str | None = Field(description='FCM Token')
    uid: str = Field(description='UID Firebase')
    user_id: str = Field(description='Auth Id Firebase')

class PushRequest(BaseModel):
    tokens: List[str] | None = Field(description='Список токенов. null - чтобы отправить всем', default=None)
    title: str = Field(description='Заголовок')
    text: str = Field(description='Текст')


class CheckInnRequest(BaseModel):
    inn: str = Field(description='INN')


class SendPushToUsersRequest(BaseModel):
    user_ids: List[str] = Field(description='Список firebase_id пользователей (например ["HjEbmhRCdmPWORTEK7JNr78HVOh2"])')
    title: str = Field(description='Заголовок уведомления')
    text: str = Field(description='Текст уведомления')
    data: dict | None = Field(description='Дополнительные данные (например {"order_id": "xxx"})', default=None)