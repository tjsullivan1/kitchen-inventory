from uuid import UUID

from pydantic import BaseModel, constr, validator

uuid_pattern = r"^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$"


class PantryItem(BaseModel):
    id: constr(
        strip_whitespace=True,
        min_length=36,
        max_length=36,
        pattern=uuid_pattern,
    )
    name: str
    amount: float
    unit: str
    notes: str = None
    datePurchased: str = None
    expirationDate: str = None
    storageMethod: str = None
    purchasePrice: float = None
    storageLocation: str = None
    purchaseLocation: str = None

    @validator("id")
    def validate_uuid(cls, v):
        try:
            UUID(v, version=4)
        except ValueError:
            raise ValueError("Not a valid UUID")
        return v
