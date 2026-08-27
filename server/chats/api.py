from typing import List, Dict, Optional
from datetime import datetime
from firebase_admin import firestore
from google.cloud.firestore_v1 import WriteBatch

from errors import IncorrectDataValue
from users.api import get_firebase_user_by_id  # можно не использовать, если используем batch-requests

def fetch_firebase_chats(page: int = 1, per_page: int = 10, sort_by: Optional[str] = None) -> Dict:
    try:
        db = firestore.client()
        collection_ref = db.collection("chats")

        # Обычная ветка: без сортировки по unread_count — вернем все chаты support==True с пагинацией (как раньше)
        if not sort_by or len(sort_by) == 0:
            query = collection_ref.where('support', '==', True)

            # Получаем все документы без ограничений
            documents = query.limit(per_page).offset((page - 1) * per_page).stream()

            data = []
            total_chats_query = collection_ref.where('support', '==',
                                                     True)  # Повторный запрос для получения общего количества
            total_chats = len(list(total_chats_query.stream()))  # Считаем количество
            total_pages = (total_chats + per_page - 1) // per_page  # Общее количество страниц

            for doc in documents:
                doc_data = doc.to_dict()
                doc_data['id'] = doc.id  # добавляем id документа


                users_list = []
                user_ids_list = []

                for user_ref in doc_data.get('users', []):
                    user_data = get_firebase_user_by_id(user_ref.id)
                    email = user_data.get('email')

                    if email and '79031082211' not in email:
                        users_list.append(email.split('@')[0])
                        user_ids_list.append(user_ref.id)

                messages = get_chat_messages(doc.reference)

                if len(user_ids_list) < 1:
                    continue

                chat_json = {
                    "id": doc_data.get("id"),
                    "date_created": doc_data.get('date_created'),
                    "support": doc_data.get('support'),
                    "users": users_list,
                    "messages": messages['messages'],
                    "user_id": user_ids_list[0],
                    "unread_count": messages['unread_count']
                }

                if isinstance(chat_json["date_created"], (int, float)):
                    chat_json["date_created"] = datetime.fromtimestamp(chat_json["date_created"])

                data.append(chat_json)


            return {
                "chats": data,
                "total_pages": total_pages,
                "total_chats": total_chats,
                "current_page": page,
            }

        # Ветка: sort_by == 'unread_count' — возвращаем только чаты с непрочитанными сообщениями (оптимизировано)
        # 1) Получаем все непрочитанные сообщения
        messages_ref = db.collection('messages')
        unread_query = messages_ref.where('read', '==', False)
        unread_info: Dict[str, Dict] = {}  # chat_id -> {'unread_count': int, 'last_message': {...}}

        for msg in unread_query.stream():
            md = msg.to_dict()
            chat_ref = md.get('chatRef')
            if not chat_ref:
                continue
            chat_id = chat_ref.id

            entry = unread_info.setdefault(chat_id, {'unread_count': 0, 'last_message': None})
            entry['unread_count'] += 1

            # сохраняем последнее (по дате) сообщение для превью/сортировки
            ts = md.get('date_created')
            last = entry['last_message']
            # Сравниваем timestamp'ы (если None, пропускаем корректно)
            if last is None or (ts is not None and (last.get('date_created') is None or ts > last.get('date_created'))):
                entry['last_message'] = {
                    'id': msg.id,
                    'date_created': ts,
                    'text': md.get('text'),
                    'sender': md.get('sender'),
                    'read': md.get('read')
                }

        chat_ids_with_unread = list(unread_info.keys())
        if not chat_ids_with_unread:
            return {
                "chats": [],
                "total_pages": 0,
                "total_chats": 0,
                "current_page": page,
            }

        # 2) Батч-берём документы чатов по id (get_all) и фильтруем support==True
        # Разбиваем на чанки, если много (get_all может принимать много, но на всякий случай безопасно чанкаем по 100)
        def chunked(lst, n):
            for i in range(0, len(lst), n):
                yield lst[i:i + n]

        chat_docs = []
        for chunk in chunked(chat_ids_with_unread, 100):
            refs = [collection_ref.document(cid) for cid in chunk]
            chat_docs.extend(db.get_all(refs))

        # Собираем пользователей, чтобы потом получить их данные батчем
        user_ids_needed = set()
        chats_tmp = {}
        for chat_doc in chat_docs:
            if not chat_doc.exists:
                continue
            cd = chat_doc.to_dict()
            chat_id = chat_doc.id
            # убеждаемся, что чат поддерживаемый
            if not cd.get('support', False):
                continue

            # собираем user ids
            for uref in cd.get('users', []):
                if uref and hasattr(uref, 'id'):
                    user_ids_needed.add(uref.id)

            chats_tmp[chat_id] = {
                'doc': cd,
            }

        # 3) Батч-берём пользователей
        users_map = {}  # id -> {email, ...}
        if user_ids_needed:
            users_ref = db.collection('users')
            for chunk in chunked(list(user_ids_needed), 100):
                refs = [users_ref.document(uid) for uid in chunk]
                for udoc in db.get_all(refs):
                    if udoc.exists:
                        ud = udoc.to_dict()
                        users_map[udoc.id] = ud

        # 4) Формируем итоговый список чатов (включаем unread_count и превью последнего сообщения)
        chats_list = []
        for chat_id, meta in chats_tmp.items():
            cd = meta['doc']
            users_list = []
            user_ids_list = []

            for uref in cd.get('users', []):
                if not uref or not hasattr(uref, 'id'):
                    continue
                uid = uref.id
                user_data = users_map.get(uid)
                email = user_data.get('email') if user_data else None
                if email and '79031082211' not in email:
                    users_list.append(email.split('@')[0])
                    user_ids_list.append(uid)

            if len(user_ids_list) < 1:
                continue

            unread_entry = unread_info.get(chat_id, {'unread_count': 0, 'last_message': None})

            chat_json = {
                "id": chat_id,
                "date_created": cd.get('date_created'),
                "support": cd.get('support'),
                "users": users_list,
                "messages": [unread_entry['last_message']] if unread_entry.get('last_message') else [],
                "user_id": user_ids_list[0],
                "unread_count": unread_entry['unread_count']
            }

            chats_list.append(chat_json)

        # 5) Сортировка и пагинация: например, сначала по unread_count desc, затем по дате последнего сообщения
        def last_msg_ts(item):
            lm = item.get('messages')
            if lm and len(lm) > 0:
                return lm[0].get('date_created') or 0
            return 0

        chats_list.sort(key=lambda x: (x.get('unread_count', 0), last_msg_ts(x)), reverse=True)

        total_chats = len(chats_list)
        total_pages = (total_chats + per_page - 1) // per_page
        start_index = (page - 1) * per_page
        end_index = start_index + per_page
        paginated = chats_list[start_index:end_index]

        return {
            "chats": paginated,
            "total_pages": total_pages,
            "total_chats": total_chats,
            "current_page": page,
        }

    except Exception as e:
        raise IncorrectDataValue(f'Ошибка при получении чатов из Firebase: {e}')

def get_chat_messages(chat_ref):
    db = firestore.client()
    messages_ref = db.collection('messages')

    # Запрос на получение сообщений для указанного chatRef
    query = messages_ref.where('chatRef', '==', chat_ref).order_by('date_created')

    messages = []
    unread_count = 0

    # Выполняем запрос и собираем результаты
    for msg in query.stream():
        message_data = msg.to_dict()
        message_data['id'] = msg.id  # Уникальный идентификатор сообщения

        if message_data.get('message_data'):
            # Сериализуем сообщение
            messages.append({
                'id': message_data['id'],
                'date_created': message_data['date_created'],
                'read': message_data['read'],
                'sender': message_data['sender'],
                'text': message_data['text']
            })

            # Считаем количество непрочитанных сообщений
            if not message_data['read']:
                unread_count += 1

    return {
        'messages': messages,
        'unread_count': unread_count
    }


def send_chat_message(chat_id: str, text: str, sender_id: str) -> Dict:
    try:
        db = firestore.client()
        messages_ref = db.collection('messages')

        # Создаем новое сообщение
        message_data = {
            "chatRef": db.collection('chats').document(chat_id),
            "sender": db.collection('users').document(sender_id),  # Ссылка на отправителя
            "text": text,
            "date_created": firestore.firestore.SERVER_TIMESTAMP,
            "read": False  # Устанавливаем статус как непрочитанное
        }

        # Сохраняем сообщение в Firestore
        messages_ref.add(message_data)

        return {
            "success": True,
            "message": "Сообщение успешно отправлено."
        }

    except Exception as e:
        raise IncorrectDataValue(f'Ошибка при отправке сообщения в Firebase: {e}')


from typing import Optional
from firebase_admin import firestore

BATCH_SIZE = 500

def mark_chat_messages_read(chat_id: str) -> int:
    """
    Пометить все непрочитанные сообщения чата как прочитанные.
    Параметр:
      - chat_id: id документа чата в коллекции 'chats'
    Возвращает количество обновлённых сообщений.
    """
    if not chat_id:
        raise ValueError("chat_id is required")

    db = firestore.client()
    chat_ref = db.collection('chats').document(chat_id)

    # Вариант A: сообщения находятся в глобальной коллекции 'messages' и ссылаются на chatRef
    messages_col = db.collection('messages')
    unread_query = messages_col.where('chatRef', '==', chat_ref).where('read', '==', False)

    # Если у вас сообщения лежат как подколлекция у чата, используйте:
    # unread_query = chat_ref.collection('messages').where('read', '==', False)

    unread_docs = list(unread_query.stream())
    total = len(unread_docs)
    if total == 0:
        # Можно попытаться обнулить unread_count на всякий случай
        try:
            chat_ref.update({'read': 0})
        except Exception:
            pass
        return 0

    # Батч-обновления по 500 операций
    updated = 0
    for i in range(0, total, BATCH_SIZE):
        batch: WriteBatch = db.batch()
        chunk = unread_docs[i:i + BATCH_SIZE]
        for doc in chunk:
            # Обновляем поле read и ставим дату прочтения
            batch.update(doc.reference, {
                'read': True,
                'date_read': firestore.SERVER_TIMESTAMP,  # или ваш формат поля
            })
        batch.commit()
        updated += len(chunk)

    # Обновляем поле unread_count в чате (если используете)
    # Здесь ставим 0. Важно: возможна гонка — новые сообщения могут появиться одновременно.
    try:
        chat_ref.update({'read': False})
    except Exception:
        # не критично, просто логируйте при необходимости
        pass

    return updated
