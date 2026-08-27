from sqlalchemy import Column, orm
from db import Base
import sqlalchemy as db
import datetime
import utils


class Payment(Base):
    __tablename__ = 'payments'
    id = Column(db.Integer, primary_key=True, autoincrement=True)
    driver_id = Column(db.Integer)
    pay_token = Column(db.String(64))
    amount = Column(db.Integer)
    status = Column(db.Integer, default=0)
    payment_url = Column(db.Text, default='')
    created_at = Column(db.DateTime, default=datetime.datetime.now)
    finished_at = Column(db.DateTime, default=None)
    tariff_hours = Column(db.Integer)
    tariff_name = Column(db.String(128))

    def schema(self):
        data = {
            'id': self.id,
            'amount': self.amount,
            'status': self.status,
            'status_text': self.status_text,
            'created_at': self.created_at,
            'finished_at': self.finished_at,
            'tariff_hours': self.tariff_hours,
            'tariff_name': self.tariff_name,
            'payment_url': self.payment_url,
        }
        return data

    @property
    def status_text(self):
        if self.status == 0:
            return 'Ожидание оплаты'
        elif self.status == 10:
            return 'Оплата проведена'
        else:
            return 'Оплата отменена'