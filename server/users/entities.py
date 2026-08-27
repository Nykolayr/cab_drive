from flask_jwt_extended import create_access_token
from sqlalchemy import Column, orm
from db import Base
import sqlalchemy as db
import datetime
import config
import requests
import utils


class FirebaseUser(Base):
    __tablename__ = 'fb_users'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    phone = Column(db.String(24))
    password = Column(db.String(64))
    firebase_id = Column(db.String(128))
    fcm_token = Column(db.String(256), default=None)
    user_id = Column(db.String(256), default=None)


    def schema(self):
        data = {
            'id': self.id,
            'phone': '+7' + self.phone,
            'password': self.password,
            'email': f'{self.phone}@ydrive.appwave.com',
            'firebase_id': self.firebase_id,
            'fcm_token': self.fcm_token,
            'user_id': self.user_id
        }

        return data

class User(Base):
    __tablename__ = 'users'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    phone = Column(db.String(24))
    name = Column(db.String(64))
    created_at = Column(db.DateTime, default=datetime.datetime.now)
    password = Column(db.String(64))
    is_admin = Column(db.Boolean, default=False)
    photo_uuid = Column(db.String(64), default=None)
    is_removed = Column(db.Boolean, default=False)
    account_type = Column(db.Integer, default=0)
    fcm_token = Column(db.String(256), default=None)

    def schema(self):
        data = {
            'id': self.id,
            'phone': '+7' + self.phone,
            'name': self.name,
            'created_at': self.created_at,
            'photo_uuid': self.photo_uuid,
            'fcm_token': self.fcm_token
        }

        return data

    def send_socket(self, event, data, description) -> bool:
        return self.send_ws(self.id, event, data, description)

    @staticmethod
    def send_ws(user_id, event, data, description) -> bool:
        url = '{}/user'.format(config.Production.TROIKA_S_BASE_URL)
        data = {
            'id': user_id,
            'event': event,
            'data': utils.to_json(data),
            'description': description
        }

        try:
            response = requests.post(url, json=data)
        except:
            return False

        if response.status_code != 200:
            return False

        data = response.json()
        return data['status']

    def get_type(self) -> str:
        if self.account_type == 0:
            return 'Клиент'
        elif self.account_type == 1:
            return 'Диспетчер'
        elif self.account_type == 2:
            return 'Администратор'
        else:
            return '---'

    def get_access_token(self) -> str:
        access_token = create_access_token(
            identity={
                'account_type': 'user',
                'id': self.id
            },
            expires_delta=datetime.timedelta(days=365)
        )
        return access_token


class AuthCode(Base):
    __tablename__ = 'auth_codes'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    identity = Column(db.String(128))
    code = Column(db.String(16))
    created_at = Column(db.DateTime, default=datetime.datetime.now)