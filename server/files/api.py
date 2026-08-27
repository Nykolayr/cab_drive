from typing import Union
from .entities import File
from db import Session
from uuid import uuid4
import utils


def get_file_by_uuid(uuid, session=None) -> Union[File, None]:
    if session is None:
        with Session() as session:
            file = session.query(File).filter(File.uuid == uuid).first()
    else:
        file = session.query(File).filter(File.uuid == uuid).first()
    return file


def create_file(file_storage):
    file_uuid = str(uuid4())

    file_array = str(file_storage.filename).split('.')
    extension = file_array[-1]
    name = str(file_storage.filename).replace(extension, '')
    name = name[:-1]

    path_name = '{}/storage/{}.{}'.format(utils.get_script_dir(), file_uuid, extension)
    file_storage.save(path_name)

    with Session() as db_session:
        file = File(filename=name, uuid=file_uuid, extension=extension, mimetype=file_storage.mimetype)
        db_session.add(file)
        db_session.commit()
    return file_uuid, '{}.{}'.format(name, extension)


def get_file(uuid, files_list=None):
    if files_list is None:
        with Session() as db_session:
            file = db_session.query(File).filter(File.uuid == uuid).first()
        return file
    else:
        result = None
        for file in files_list:
            if file.uuid == uuid:
                result = file
                break
        return result


def get_files():
    with Session() as db_session:
        files = db_session.query(File).all()
    return files


def get_files_by_uuids(uuids_list):
    with Session() as session:
        files_list = session.query(File).filter(File.uuid.in_(uuids_list)).all()
    return files_list