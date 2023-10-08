package get_image

type HandlerRequest struct {
	ImageID string `json:"image_id"`
}

type HandlerResponse struct {
	Status int                   `json:"status"`
	Error  *HandlerResponseError `json:"error,omitempty"`
	Image  []byte                `json:"image,omitempty"`
}

type HandlerResponseError struct {
	Message string `json:"message"`
}
