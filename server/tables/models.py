from typing import List, Union, Any, Callable
from pydantic import BaseModel, Field
import enums


class TData(BaseModel):
    start_index: int = Field(default=0, alias='start')
    page_count: int = Field(default=25, alias='length')
    sort_index: int = Field(default=0, alias='order[0][column]')
    sort_dir: str = Field(default='desc', alias='order[0][dir]')
    search_query: str = Field(default='', alias='search[value]')
    only_headers: int = Field(default=0, alias='only_headers')
    is_mobile: bool = Field(default=False, alias='is_mobile')
    is_export: bool = Field(default=False)


class TColumn:
    def __init__(self, name: str, path: Union[str, Callable],
                 hide_export=False,
                 export_path: Union[str, Callable, None] = None,
                 mobile_path: Union[str, Callable, None] = None,
                 db_sort: Union[str, None] = None,
                 xss_safe=True,
                 export_name: Union[str, None] = None,
                 hide_mobile: bool = False,
                 hide_pc: bool = False,
                 ):
        self.name = name
        self.path = path
        self.hide_export = hide_export
        self.export_path = export_path
        self.db_sort = db_sort
        self.xss_safe = xss_safe
        self.export_name = export_name
        self.mobile_path = mobile_path
        self.hide_mobile = hide_mobile
        self.hide_pc = hide_pc

    def get_name(self, is_export=False):
        if is_export and self.export_name is not None:
            return self.export_name
        return self.name
