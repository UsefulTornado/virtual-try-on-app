import logging

from fastapi import APIRouter

router = APIRouter()
logging.getLogger().setLevel(logging.INFO)


@router.post("/hello", status_code=200)
async def hello() -> dict:
    return {
        "message": "Hello",
    }
