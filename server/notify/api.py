from .entities import FirebasePushService
import utils


def init_service() -> FirebasePushService:
    s_path = '{}/s.json'.format(utils.get_script_dir())
    push_service = FirebasePushService(s_path)
    return push_service