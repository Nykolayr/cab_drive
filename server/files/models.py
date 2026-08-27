from pydantic import BaseModel, Field
from flask_openapi3 import FileStorage
import models


class UploadFileQuery(BaseModel):
    file: FileStorage = Field(title='Изображение')


class UploadFileResponse(models.SuccessAnswer):
    uuid: str = Field(description='UUID изображения')


class UploadBinaryQuery(BaseModel):
    file: str
    filename: str


class GetFileQuery(BaseModel):
    uuid: str = Field(title='UUID файла')
