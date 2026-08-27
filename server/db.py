from sqlalchemy import create_engine, event, exc
from sqlalchemy.pool import Pool
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from pymysql.connections import Connection
import config

engine = create_engine(config.Production.SQLALCHEMY_DATABASE_URI, pool_pre_ping=True, pool_size=16, max_overflow=0,
                       pool_recycle=600)

Session = sessionmaker(bind=engine, autoflush=True, expire_on_commit=False)

Base = declarative_base()


@event.listens_for(Pool, "checkout")
def ping_connection(dbapi_connection, connection_record, connection_proxy):
    cursor = dbapi_connection.cursor()
    try:
        cursor.execute("SELECT 1")
    except:
        raise exc.DisconnectionError()
    cursor.close()


@event.listens_for(Pool, "connect")
def log_connect(dbapi_connection, connection_record):
    pass


@event.listens_for(Pool, "checkout")
def log_checkout(dbapi_connection, connection_record, connection_proxy):
    pass


@event.listens_for(Pool, "checkin")
def log_checkin(dbapi_connection, connection_record):
    pass


def init_db():
    Base.metadata.create_all(bind=engine)