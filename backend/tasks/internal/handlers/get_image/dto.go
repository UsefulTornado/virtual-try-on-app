package get_image

type HandlerRequest struct {
	PersonImageID  string  `json:"person_image_id"`
	ClothesImageID *string `json:"clothes_image_id"`
}

type HandlerResponse struct {
	Status       int                   `json:"status"`
	Error        *HandlerResponseError `json:"error,omitempty"`
	PersonImage  []byte                `json:"person_image,omitempty"`
	ClothesImage []byte                `json:"clothes_image,omitempty"`
}

type HandlerResponseError struct {
	Message string `json:"message"`
}
