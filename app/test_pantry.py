import json

from pantry import LocalPantry, Pantry, PantryItem


def test_pantry_item():
    item = PantryItem(
        name="apple",
        amount=3.0,
        unit="kg",
        notes="Golden Delicious",
        expiration_date="2023-03-01",
        storage_method="refrigerator",
        purchase_price=2.0,
        storage_location="crisper",
        purchase_location="local market",
    )
    assert item.name == "apple"
    assert item.amount == 3.0
    assert item.unit == "kg"
    assert item.notes == "Golden Delicious"
    assert item.expiration_date == "2023-03-01"
    assert item.storage_method == "refrigerator"
    assert item.purchase_price == 2.0
    assert item.storage_location == "crisper"
    assert item.purchase_location == "local market"


def test_local_pantry_dump_and_load():
    pantry = LocalPantry(
        items=[PantryItem(name="apple", amount=3.0, unit="kg")],
        filename="test_pantry.json",
    )
    pantry.dump()

    with open("test_pantry.json", "r") as f:
        data = json.load(f)

    assert len(data) == 1
    assert data[0]["name"] == "apple"


def test_PantryItem_id_is_generated():
    item = PantryItem(name="Eggs", amount=12, unit="unit")
    assert isinstance(item.id, str)


def test_PantryItem_date_purchased_is_generated():
    item = PantryItem(name="Eggs", amount=12, unit="unit")
    assert isinstance(item.date_purchased, str)


def test_LocalPantry_dump_and_load():
    pantry = LocalPantry(
        filename="pantry.json",
        items=[
            PantryItem(name="Eggs", amount=12, unit="unit"),
            PantryItem(name="Bread", amount=1, unit="loaf"),
        ],
    )
    pantry.dump()

    loaded_pantry = LocalPantry(filename="pantry.json", items=[])
    loaded_pantry.load()

    assert len(loaded_pantry.items) == 2
    assert loaded_pantry.items[0].name == "Eggs"
    assert loaded_pantry.items[1].name == "Bread"


def test_Pantry():
    pantry = Pantry(
        items=[
            PantryItem(name="Eggs", amount=12, unit="unit"),
            PantryItem(name="Bread", amount=1, unit="loaf"),
        ],
    )

    assert len(pantry.items) == 2
    assert pantry.items[0].name == "Eggs"
    assert pantry.items[1].name == "Bread"
