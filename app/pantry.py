import json
from dataclasses import dataclass
from datetime import datetime
from typing import List
from uuid import uuid4


@dataclass
class PantryItem:
    name: str
    amount: float
    unit: str
    id: str | None = None
    notes: str = None
    date_purchased: str | None = None
    expiration_date: str = None
    storage_method: str = None
    purchase_price: float = None
    storage_location: str = None
    purchase_location: str = None

    def __post_init__(self):
        if self.id is None:
            self.id = str(uuid4())
        if self.date_purchased is None:
            self.date_purchased = str(datetime.utcnow())


@dataclass
class Pantry:
    items: List[PantryItem]


@dataclass
class LocalPantry(Pantry):
    filename: str

    def dump(self):
        with open(self.filename, "w") as f:
            json_list = []
            for item in self.items:
                json_list.append(item.__dict__)

            json.dump(json_list, f, indent=4)

    def load(self):
        with open(self.filename, "r") as f:
            pantry_data = json.load(f)

        self.items = [PantryItem(**item) for item in pantry_data]


def sample():
    carrots = PantryItem(name="Carrots", amount=5.0, unit="pounds")

    rice = PantryItem(name="Rice", amount=500, unit="grams")

    myPantry = LocalPantry(filename="pantry.json", items=[])
    myPantry.items.append(carrots)
    myPantry.items.append(rice)

    print(myPantry)
