from abc import ABC, abstractmethod
from typing import List, Dict, Any, Union, Callable, Tuple, Type, Optional
from sqlalchemy import asc, desc, func
from sqlalchemy.orm import Session
from .models import TColumn, TData
from flask import Response
from enums import Enum

import traceback
import datetime
import json
import utils


def get_table_rows(entities_list: List[Any], columns: List[TColumn], user, tdata: TData) -> List[List[str]]:
    result_list = []

    search_query = tdata.search_query.lower()

    for entity in entities_list:
        result = []

        for column in columns:
            if not check_column(column, tdata):
                continue

            value = None

            if tdata.is_export and column.export_path is not None:
                if isinstance(column.export_path, str):
                    path_arr = column.export_path.split('.')

                    value = entity

                    for path in path_arr:
                        value = getattr(value, path, None)
                else:
                    try:
                        value = column.export_path(entity)
                    except:
                        print(traceback.format_exc())
                        value = 'Error'
            elif tdata.is_mobile and column.mobile_path is not None:
                if isinstance(column.mobile_path, str):
                    path_arr = column.mobile_path.split('.')

                    value = entity

                    for path in path_arr:
                        value = getattr(value, path, None)
                else:
                    try:
                        value = column.mobile_path(entity)
                    except:
                        print(traceback.format_exc())
                        value = 'Error'
            else:
                if isinstance(column.path, str):
                    path_arr = column.path.split('.')

                    value = entity

                    for path in path_arr:
                        value = getattr(value, path, None)
                else:
                    try:
                        value = column.path(entity)
                    except:
                        print(traceback.format_exc())
                        value = 'Error'

            if value is None:
                result.append('-')
                continue
            elif callable(value):
                result.append(get_str(value(), column.xss_safe, user))
            else:
                result.append(get_str(value, column.xss_safe, user))

        # if search_check is False:
        #     for v in result:
        #         if search_query in v.lower():
        #             search_check = True
        #             break

        result_list.append(result)

    return result_list


def check_column(column: TColumn, tdata: TData) -> bool:
    if tdata.is_export and column.hide_export:
        return False
    if tdata.is_mobile and column.hide_mobile:
        return False
    if tdata.is_mobile is False and column.hide_pc:
        return False
    return True


def get_sort_field(sort_index, columns: List[TColumn]) -> str:
    try:
        column = columns[sort_index]
        if column.db_sort is not None:
            return column.db_sort
        return 'id'
    except IndexError:
        return 'id'


def get_headers(columns: List[TColumn], tdata: TData) -> List[str]:
    result = [column.get_name(tdata.is_export) for column in columns if check_column(column, tdata)]
    return result


def get_validate_tcolumns(columns: List[TColumn], tdata: TData) -> List[TColumn]:
    result = [column for column in columns if check_column(column, tdata)]
    return result


def get_str(value: Any, xss_safe=True, user=None) -> str:
    if isinstance(value, datetime.datetime):
        return value.strftime('%d.%m.%Y %H:%M')
    elif isinstance(value, bool):
        return 'Да' if value is True else 'Нет'
    elif isinstance(value, Enum):
        return value.value
    else:
        try:
            value = str(value)
        except:
            value = '---'

        if xss_safe:
            value = utils.make_xss_safe(value)

        return value


class BaseTableHandler(ABC):
    def __init__(self, entity_class: Type, session_factory: Callable = Session):
        self.entity_class = entity_class
        self.session_factory = session_factory

    @abstractmethod
    def get_columns(self) -> List[TColumn]:
        pass

    @abstractmethod
    def get_base_query(self, session: Session, filters: Dict[str, Any] = None):
        query = session.query(self.entity_class)
        if filters:
            query = self._apply_filters(query, filters)
        return query

    def _apply_filters(self, query, filters: Dict[str, Any]):
        return query

    def _apply_search(self, query, search_query: str):
        return query

    def get_entities_count(self, filters: Dict[str, Any] = None, search_query: str = None,
                           session: Session = None) -> int:
        close_session = session is None
        if session is None:
            session = self.session_factory(autoflush=False)

        try:
            query = self.get_base_query(session, filters)

            if search_query:
                query = self._apply_search(query, search_query)

            return query.count()
        finally:
            if close_session:
                session.close()

    def get_entities_by_page(self, limit: int, offset: int, order_type: str, order_field: str,
                             filters: Dict[str, Any] = None, search_query: str = None,
                             session: Session = None) -> List[Any]:
        close_session = session is None
        if session is None:
            session = self.session_factory(autoflush=False)

        try:
            query = self.get_base_query(session, filters)

            if search_query:
                query = self._apply_search(query, search_query)

            sort_attr = getattr(self.entity_class, order_field, None)
            if sort_attr is not None:
                sort = asc(sort_attr) if order_type == 'asc' else desc(sort_attr)
                query = query.order_by(sort)

            return query.offset(offset).limit(limit).all()
        finally:
            if close_session:
                session.close()

    def get_entities_with_count(self, tdata: TData, sort_field: str, filters: Dict[str, Any] = None) -> Tuple[
        List[Any], int]:
        with self.session_factory(autoflush=False) as session:
            loaded_count = tdata.page_count
            if len(tdata.search_query) > 0 or tdata.is_export:
                loaded_count = self.get_entities_count(filters, tdata.search_query, session)

            if loaded_count > 1000 and not tdata.is_export:
                loaded_count = 1000

            entities_list = self.get_entities_by_page(
                loaded_count, tdata.start_index, tdata.sort_dir,
                sort_field, filters, tdata.search_query, session
            )

            entities_list = self.post_process_entities(entities_list, session)

            if tdata.is_export:
                entities_list.sort(key=lambda entity: entity.id, reverse=True)

            entities_count = self.get_entities_count(filters, tdata.search_query, session)

        return entities_list, entities_count

    def post_process_entities(self, entities_list: List[Any], session: Session) -> List[Any]:
        return entities_list

    def get_rows(self, data: Dict[str, str], user: Any) -> Tuple[
        Union[None, List[List[str]]], List[str], Union[None, int]]:

        columns = self.get_columns()
        tdata = TData.model_validate(data)

        filters = self.extract_filters(data, user)

        if tdata.only_headers == 1:
            return None, get_headers(columns, tdata), None

        sort_field = get_sort_field(tdata.sort_index, get_validate_tcolumns(columns, tdata))
        entities_list, entities_count = self.get_entities_with_count(tdata, sort_field, filters)

        rows = get_table_rows(entities_list, columns, user, tdata)

        if len(rows) > tdata.page_count and not tdata.is_export:
            rows = rows[:tdata.page_count]

        return rows, get_headers(columns, tdata), entities_count

    def get_table(self, data: Dict[str, str], user: Any) -> Response:
        """Получает данные таблицы в формате JSON"""
        draw = int(data.get('draw', 0))

        rows, headers, count = self.get_rows(data, user)
        if rows is None:
            answer = {
                'headers': headers,
            }
        else:
            answer = {
                'draw': draw,
                'recordsFiltered': count,
                'recordsTotal': count,
                'data': rows,
                'headers': headers,
            }

        return Response(
            status=200,
            response=json.dumps(answer, ensure_ascii=False, indent=3, default=utils.json_serial),
            mimetype='application/json'
        )

    def extract_filters(self, data: Dict[str, str], user) -> Dict[str, Any]:
        return {}