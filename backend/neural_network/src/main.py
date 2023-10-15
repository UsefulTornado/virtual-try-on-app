import io
import requests
from core.vton import VirtualTryOn
from PIL import Image
from pydantic import BaseModel
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
import sys
sys.path.append("..")


app = FastAPI()
vton = VirtualTryOn()

get_image_URL = "http://127.0.0.1:1101/api/get_image"
save_image_URL = "http://127.0.0.1:1101/api/save_image"


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


def style_images(person_img, clothes_img):
    image = vton(Image.open(io.BytesIO(person_img)), Image.open(io.BytesIO(clothes_img)))

    img_byte_arr = io.BytesIO()
    image.save(img_byte_arr, format='PNG')
    img_byte_arr = img_byte_arr.getvalue()
    response = requests.post(save_image_URL, data=img_byte_arr, headers={"content-type": "image/png"})

    return response.json()["image_id"]


@app.post("/api/style_image")
async def style_image(req: Request):
    images = get_images(req)
    styled_image_id = style_images(images["person_image"], images["clothes_image"])
    json_compatible_image_id = jsonable_encoder(styled_image_id)
    return JSONResponse(content=json_compatible_image_id)
