import json

from models import PantryItem

# from typing import List


class Pantry:
    def __init__(self, filename):
        self.items = []
        self.filename = filename

    def create_item(self, item: PantryItem):
        self.items.append(item)

    def read_items(self):
        return self.items

    def update_item(self, item: PantryItem):
        for i, existing_item in enumerate(self.items):
            if existing_item.id == item.id:
                self.items[i] = item
                return

    def delete_item(self, item_id: str):
        for i, existing_item in enumerate(self.items):
            if existing_item.id == item_id:
                del self.items[i]
                return

    # Create functions with enter and exit to make this a context manager
    def __enter__(self):
        self.load()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.dump()

    # define an equality function that returns True if the config dictionaries are equal
    def __eq__(self, other):
        try:
            return self.config == other.config
        except AttributeError:
            return False

    # Define a function that compares the keys of the config dictionaries using the __gt__ function
    def __gt__(self, other):
        return self.config.keys() > other.config.keys()

    # Define a function that compares the keys of the config dictionaries using the __lt__ function
    def __lt__(self, other):
        return self.config.keys() < other.config.keys()

    # Define a function that compares the keys of the config dictionaries using the __ge__ function
    def __ge__(self, other):
        return self.config.keys() >= other.config.keys()

    # Define a function that compares the keys of the config dictionaries using the __le__ function
    def __le__(self, other):
        return self.config.keys() <= other.config.keys()

    def load(self):
        with open(self.filename, "r") as file:
            self.items = json.load(file)

    def dump(self):
        with open(self.filename, "w") as file:
            json.dump(self.items, file, indent=4)
