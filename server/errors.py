class IncorrectDataValue(Exception):
    def __init__(self, message):
        self.message = message


class AuthEmptyException(Exception):
    def __init__(self):
        pass


class NotArea(Exception):
    def __init__(self):
        pass