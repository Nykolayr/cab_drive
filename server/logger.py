import logging
from logging.handlers import RotatingFileHandler
import os

# Создание папки logs, если нет
LOG_DIR = 'logs'
os.makedirs(LOG_DIR, exist_ok=True)

LOG_FILE = os.path.join(LOG_DIR, 'logs.log')

# Создание логгера
logger = logging.getLogger("logger")
logger.setLevel(logging.INFO)

# Формат логов
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

# Обработчик для файла
file_handler = RotatingFileHandler(LOG_FILE, maxBytes=5*1024*1024, backupCount=5)
file_handler.setFormatter(formatter)

# Обработчик для консоли
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)

# Добавляем обработчики, если ещё не добавлены
if not logger.handlers:
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
