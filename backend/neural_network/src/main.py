import io

import requests
from core.vton import VirtualTryOn
from fastapi import FastAPI
from PIL import Image
from pydantic import BaseModel

app = FastAPI()
vton = VirtualTryOn()

get_image_URL = "http://127.0.0.1:1101/api/get_image"


class Request(BaseModel):
    person_image_id: str
    clothes_image_id: str


def get_images(req: Request) -> dict:
    response = requests.post(
        get_image_URL,
        json={
            "person_image_id": req.person_image_id,
            "clothes_image_id": req.clothes_image_id,
        },
    )

    return response.json()


def process_images(person_img, clothes_img):
    return vton(Image.open(io.BytesIO(person_img)), Image.open(io.BytesIO(clothes_img)))


@app.post("/api/style_image")
async def style_image(req: Request):
    images = get_images(req)
    process_images(images["person_image"], images["clothes_image"])
    return "ok", 200
