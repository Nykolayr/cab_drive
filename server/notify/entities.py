from firebase_admin import credentials, messaging
from typing import List, Optional
from errors import *
from datetime import datetime
import firebase_admin
import logging
import os


class FirebasePushService:
    def __init__(self, service_account_key_path: str, log_file_path: str = None):
        """
        Инициализация Firebase Admin SDK

        Args:
            service_account_key_path: Путь к JSON файлу с ключами сервисного аккаунта
            log_file_path: Путь к файлу логов (опционально)
        """
        if not firebase_admin._apps:
            cred = credentials.Certificate(service_account_key_path)
            firebase_admin.initialize_app(cred)

        # Настройка логгера
        self.logger = logging.getLogger('firebase_push_service')
        self.logger.setLevel(logging.INFO)

        # Очищаем существующие обработчики
        self.logger.handlers.clear()

        # Создаем форматтер
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )

        # Настраиваем вывод в файл
        if log_file_path:
            # Создаем директорию для логов если не существует
            log_dir = os.path.dirname(log_file_path)
            if log_dir and not os.path.exists(log_dir):
                os.makedirs(log_dir)

            # Файловый обработчик с ротацией
            from logging.handlers import RotatingFileHandler
            file_handler = RotatingFileHandler(
                log_file_path,
                maxBytes=10 * 1024 * 1024,  # 10MB
                backupCount=5,
                encoding='utf-8'
            )
            file_handler.setLevel(logging.INFO)
            file_handler.setFormatter(formatter)
            self.logger.addHandler(file_handler)
        else:
            # По умолчанию создаем файл логов в папке logs/
            logs_dir = 'logs'
            if not os.path.exists(logs_dir):
                os.makedirs(logs_dir)

            log_filename = f"{logs_dir}/firebase_push_{datetime.now().strftime('%Y%m')}.log"

            from logging.handlers import RotatingFileHandler
            file_handler = RotatingFileHandler(
                log_filename,
                maxBytes=10 * 1024 * 1024,  # 10MB
                backupCount=5,
                encoding='utf-8'
            )
            file_handler.setLevel(logging.INFO)
            file_handler.setFormatter(formatter)
            self.logger.addHandler(file_handler)

        # Дополнительно выводим в консоль (опционально)
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.WARNING)  # В консоль только предупреждения и ошибки
        console_handler.setFormatter(formatter)
        self.logger.addHandler(console_handler)

        self.logger.info("FirebasePushService инициализирован")

    def send_push_notification(self,
                               fcm_tokens: Optional[List[str]] = None,
                               title: str = None,
                               message: str = None,
                               data: dict = None,
                               topic: str = None) -> dict:
        if not title and not message:
            raise IncorrectDataValue("Необходимо указать title или message")

        # Подготовка дополнительных данных
        # Включаем title и body в data для data-only сообщений
        if data is None:
            data = {}

        # Добавляем title и body в data для обработки клиентом
        data['title'] = title or ""
        data['body'] = message or ""

        self.logger.info(f"[FCM] Preparing data-only message: title='{title}', body='{message}'")

        result = {
            'success_count': 0,
            'failure_count': 0,
            'failed_tokens': [],
            'errors': []
        }

        try:
            if fcm_tokens:
                result = self._send_to_tokens(fcm_tokens, title, message, data)
            else:
                topic_name = topic or 'all'
                result = self._send_to_topic(topic_name, title, message, data)

        except Exception as e:
            self.logger.error(f"Ошибка при отправке уведомлений: {str(e)}")
            result['errors'].append(str(e))
            result['failure_count'] = 1

        return result

    def _send_to_tokens(self, tokens: List[str], title: str, body: str, data: dict) -> dict:
        """
        Отправка DATA-ONLY уведомлений конкретным токенам.

        ВАЖНО: Отправляем только data (без notification) чтобы приложение
        само создавало уведомление через AwesomeNotifications с кастомным звуком.
        Если отправить notification, Android сам покажет уведомление со стандартным звуком.
        """
        total_success = 0
        total_failure = 0
        failed_tokens = []
        errors = []

        self.logger.info(f"[FCM] Sending data-only message to {len(tokens)} token(s)")

        # Проверяем, поддерживается ли send_multicast
        if hasattr(messaging, 'send_multicast') and hasattr(messaging, 'MulticastMessage'):
            # Используем новый API для batch отправки
            batch_size = 500

            for i in range(0, len(tokens), batch_size):
                batch_tokens = tokens[i:i + batch_size]

                # Android config - высокий приоритет для немедленной доставки
                # НЕ включаем notification - только data!
                android_config = messaging.AndroidConfig(
                    priority='high',
                )

                # iOS config - используем content_available и alert для показа уведомления
                # На iOS data-only сообщения требуют особой обработки
                apns_config = messaging.APNSConfig(
                    headers={
                        'apns-priority': '10',  # High priority
                        'apns-push-type': 'alert',  # Alert type for visible notification
                    },
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            alert=messaging.ApsAlert(
                                title=title,
                                body=body,
                            ),
                            sound='default',
                            badge=1,
                            content_available=True,
                            mutable_content=True,  # Allow modification by app
                        )
                    )
                )

                # DATA-ONLY сообщение (без notification!)
                # Приложение получит его и создаст уведомление через AwesomeNotifications
                message = messaging.MulticastMessage(
                    # notification=None - НЕ включаем notification!
                    data=data,  # title и body уже в data
                    tokens=batch_tokens,
                    android=android_config,
                    apns=apns_config,  # iOS требует alert в APNS
                )

                try:
                    response = messaging.send_multicast(message)
                    total_success += response.success_count
                    total_failure += response.failure_count

                    # Обработка неуспешных отправок
                    if response.failure_count > 0:
                        for idx, resp in enumerate(response.responses):
                            if not resp.success:
                                failed_token = batch_tokens[idx]
                                failed_tokens.append(failed_token)
                                error_msg = resp.exception.code if resp.exception else "Unknown error"
                                errors.append(f"Token {failed_token}: {error_msg}")

                    self.logger.info(
                        f"[FCM] Batch sent (data-only): {response.success_count} success, {response.failure_count} failed")

                except Exception as e:
                    self.logger.error(f"[FCM] Batch error: {str(e)}")
                    total_failure += len(batch_tokens)
                    failed_tokens.extend(batch_tokens)
                    errors.append(f"Batch error: {str(e)}")
        else:
            # Используем старый API - отправка по одному токену
            self.logger.info("[FCM] Using legacy API - sending one by one")

            android_config = messaging.AndroidConfig(
                priority='high',
            )

            apns_config = messaging.APNSConfig(
                headers={
                    'apns-priority': '10',
                    'apns-push-type': 'alert',
                },
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        alert=messaging.ApsAlert(
                            title=title,
                            body=body,
                        ),
                        sound="notify.aiff",
                        badge=1,
                        content_available=True,
                        mutable_content=True,
                    ),

                )
            )

            for token in tokens:
                message = messaging.Message(
                    # notification=None - НЕ включаем!
                    data=data,
                    token=token,
                    android=android_config,
                    apns=apns_config,
                )

                try:
                    response = messaging.send(message)
                    total_success += 1
                    self.logger.debug(f"[FCM] Sent to token {token[:20]}...: {response}")

                except messaging.UnregisteredError:
                    total_failure += 1
                    failed_tokens.append(token)
                    errors.append(f"Token {token[:20]}...: Unregistered token")
                    self.logger.warning(f"[FCM] Unregistered token: {token[:20]}...")

                except messaging.InvalidArgumentError as e:
                    total_failure += 1
                    failed_tokens.append(token)
                    errors.append(f"Token {token[:20]}...: Invalid argument - {str(e)}")
                    self.logger.warning(f"[FCM] Invalid argument for token {token[:20]}...: {str(e)}")

                except Exception as e:
                    total_failure += 1
                    failed_tokens.append(token)
                    error_msg = str(e)
                    errors.append(f"Token {token[:20]}...: {error_msg}")
                    self.logger.error(f"[FCM] Error sending to token {token[:20]}...: {error_msg}")

            self.logger.info(f"[FCM] Individual sending complete: {total_success} success, {total_failure} failed")

        return {
            'success_count': total_success,
            'failure_count': total_failure,
            'failed_tokens': failed_tokens,
            'errors': errors
        }

    def _send_to_topic(self, topic: str, title: str, body: str, data: dict) -> dict:
        """
        Отправка DATA-ONLY уведомления в топик (массовая рассылка)
        """
        self.logger.info(f"[FCM] Sending data-only message to topic: {topic}")

        # Для топиков также используем data-only подход
        android_config = messaging.AndroidConfig(
            priority='high',
        )

        apns_config = messaging.APNSConfig(
            headers={
                'apns-priority': '10',
                'apns-push-type': 'alert',
            },
            payload=messaging.APNSPayload(
                aps=messaging.Aps(
                    alert=messaging.ApsAlert(
                        title=title,
                        body=body,
                    ),
                    sound='default',
                    badge=1,
                    content_available=True,
                    mutable_content=True,
                )
            )
        )

        message = messaging.Message(
            # notification=None - НЕ включаем!
            data=data,
            topic=topic,
            android=android_config,
            apns=apns_config,
        )

        try:
            response = messaging.send(message)
            self.logger.info(f"[FCM] Sent to topic {topic}: {response}")
            return {
                'success_count': 1,
                'failure_count': 0,
                'failed_tokens': [],
                'errors': [],
                'message_id': response
            }
        except Exception as e:
            self.logger.error(f"[FCM] Error sending to topic {topic}: {str(e)}")
            return {
                'success_count': 0,
                'failure_count': 1,
                'failed_tokens': [],
                'errors': [str(e)]
            }

    def subscribe_to_topic(self, tokens: List[str], topic: str) -> dict:
        """
        Подписка токенов на топик для массовых рассылок
        """
        try:
            response = messaging.subscribe_to_topic(tokens, topic)
            if len(response.errors) > 0:
                raise IncorrectDataValue('Ошибка: {}'.format(response.errors[0].reason))
            self.logger.info(f"Подписано на топик {topic}: {response.success_count} успешно")
            return {
                'success_count': response.success_count,
                'failure_count': response.failure_count
            }
        except Exception as e:
            self.logger.error(f"Ошибка подписки на топик: {str(e)}")
            return {
                'success_count': 0,
                'failure_count': len(tokens),
                'error': str(e)
            }

    def unsubscribe_from_topic(self, tokens: List[str], topic: str) -> dict:
        """
        Отписка токенов от топика
        """
        try:
            response = messaging.unsubscribe_from_topic(tokens, topic)
            self.logger.info(f"Отписано от топика {topic}: {response.success_count} успешно")
            return {
                'success_count': response.success_count,
                'failure_count': response.failure_count
            }
        except Exception as e:
            self.logger.error(f"Ошибка отписки от топика: {str(e)}")
            return {
                'success_count': 0,
                'failure_count': len(tokens),
                'error': str(e)
            }