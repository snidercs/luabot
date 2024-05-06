
class Data:
    def __init__(self, parsed):
        if not isinstance(parsed, dict):
            raise TypeError (parsed)
        self.data = parsed

    def typename(self):
        return self.data
