from fastapi import APIRouter
from pydantic import BaseModel

from typing import Union

router = APIRouter()

class Item(BaseModel):
    name: str
    description: Union[str, None] = None

@router.post("/")
async def get_item(item: Item):
    return {
      "message": f"Good morning {item.name}",
      "description": f"{item.description}"
    }