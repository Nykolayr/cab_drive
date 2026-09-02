"""Инварианты auth — гонять перед деплоем сервера."""
from users.entities import AUTH_EMAIL_DOMAIN, auth_email


def test_auth_email_domain():
    assert AUTH_EMAIL_DOMAIN == 'ydrive.appwave.com'


def test_auth_email_format():
    assert auth_email('9001112233') == '9001112233@ydrive.appwave.com'


def test_schema_email_matches_auth_email():
    from users.entities import FirebaseUser

    class _Row:
        id = 1
        phone = '9001112233'
        password = 'secret'
        firebase_id = 'fb-uid'
        fcm_token = None
        user_id = None

    row = _Row()
    user = FirebaseUser.__new__(FirebaseUser)
    user.id = row.id
    user.phone = row.phone
    user.password = row.password
    user.firebase_id = row.firebase_id
    user.fcm_token = row.fcm_token
    user.user_id = row.user_id

    assert user.schema()['email'] == auth_email(row.phone)
