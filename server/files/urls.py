from flask import send_file
from flask_openapi3 import Tag, APIView
from uuid import uuid4
from .entities import File
from .models import *
from errors import *
from db import Session
import base64
import files
import utils
import traceback
import os
import datetime


tag = Tag(name='Files', description='Файловое хранилище')
app = APIView(url_prefix='/kek/files', view_tags=[tag])
security = [{"JWT": []}]


@app.route('/upload')
class UpdateFile:
    @app.doc(
        summary='Загрузка файла',
        responses={
            '200': UploadFileResponse,
            '500': models.ErrorAnswer
        },
        security=None
    )
    def post(self, form: UploadFileQuery):
        try:
            file_uuid, filename = files.api.create_file(form.file)
        except:
            print(traceback.format_exc())
            return utils.get_error('Ошибка', 500)
        return utils.get_answer('ok', {'uuid': file_uuid, 'filename': filename})


@app.route('/get')
class GetFile:
    @app.doc(
        summary='Получение файла по UUID',
        security=None
    )
    def get(self, query: GetFileQuery):
        uuid = query.uuid
        with Session() as db_session:
            file = db_session.query(File).filter(File.uuid == uuid).first()
            if file is None:
                return utils.get_error('Файл не найден')

            path_name = '{}/storage/{}.{}'.format(utils.get_script_dir(), file.uuid, file.extension)

        return send_file(path_name, as_attachment=True)