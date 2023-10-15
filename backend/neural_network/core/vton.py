import cv2
import torch
import torch.nn as nn
from diffusers import StableDiffusionInpaintPipeline
from PIL import Image
from transformers import (
    AutoModelForSemanticSegmentation,
    BlipForConditionalGeneration,
    BlipProcessor,
    SegformerImageProcessor,
)


class VirtualTryOn:
    def __init__(self, device: str = "cuda"):
        self.device = device
        self._clothes_types_mapping = {
            "upper-clothes": 4,
            "pants": 6,
        }
        self.segmentation_processor = SegformerImageProcessor.from_pretrained(
            "mattmdjaga/segformer_b2_clothes"
        )
        self.segmentation_model = AutoModelForSemanticSegmentation.from_pretrained(
            "mattmdjaga/segformer_b2_clothes"
        )
        self.captioning_processor = BlipProcessor.from_pretrained(
            "Salesforce/blip-image-captioning-base"
        )
        self.captioning_model = BlipForConditionalGeneration.from_pretrained(
            "Salesforce/blip-image-captioning-base"
        )
        self.inpainting_pipeline = StableDiffusionInpaintPipeline.from_pretrained(
            "runwayml/stable-diffusion-inpainting", torch_dtype=torch.float16
        ).to(device)

    def _segment_clothes(self, image: Image.Image, clothes_type: str) -> Image.Image:
        inputs = self.segmentation_processor(images=image, return_tensors="pt")
        outputs = self.segmentation_model(**inputs)
        logits = outputs.logits.cpu()
        upsampled_logits = (
            nn.functional.interpolate(
                logits,
                size=image.size[::-1],
                mode="bilinear",
                align_corners=False,
            )
            .detach()
            .cpu()
            .numpy()
        )
        pred_seg = upsampled_logits[0, self._clothes_types_mapping[clothes_type], :, :]
        _, bw_image = cv2.threshold(pred_seg, 1, 255, cv2.THRESH_BINARY)
        mask_image = Image.fromarray(bw_image).convert("RGB")
        return mask_image

    def _get_clothes_description(self, clothes_image: Image.Image) -> str:
        inputs = self.captioning_processor(clothes_image, return_tensors="pt")
        out = self.captioning_model.generate(**inputs)
        return self.captioning_processor.decode(out[0], skip_special_tokens=True)

    def _virtual_try_on(
        self,
        person_image: Image.Image,
        mask_image: Image.Image,
        clothes_description: str,
    ) -> Image.Image:
        return self.inpainting_pipeline(
            prompt=f"a human in {clothes_description}",
            image=person_image,
            mask_image=mask_image,
        ).images[0]

    def __call__(
        self,
        person_image: Image.Image,
        clothes_image: Image.Image,
        clothes_type: str = "upper-clothes",
    ) -> Image.Image:
        clothes_mask_image = self._segment_clothes(person_image, clothes_type)
        clothes_description = self._get_clothes_description(clothes_image)
        return self._virtual_try_on(
            person_image, clothes_mask_image, clothes_description
        )
