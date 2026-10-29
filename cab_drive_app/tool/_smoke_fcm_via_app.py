import json
import app  # noqa: F401
import app_push

print(
    json.dumps(
        app_push.smoke_to_phone(
            "+79526818276",
            title="Cab Drive",
            body="Тест пуша: смена цены",
        ),
        ensure_ascii=False,
    )
)
