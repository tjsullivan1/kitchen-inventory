from uuid import UUID

from pydantic import BaseModel


class PantryItem(BaseModel):
    id: UUID
    name: str
    amount: float
    unit: str
    notes: str | None = None
    datePurchased: str | None = None
    expirationDate: str | None = None
    storageMethod: str | None = None
    purchasePrice: float | None = None
    storageLocation: str | None = None
    purchaseLocation: str | None = None
