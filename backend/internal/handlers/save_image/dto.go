package save_image

type HandlerRequest struct {
	Image []byte `json:"image"`
}

type HandlerResponse struct {
	Status  int                   `json:"status"`
	Error   *HandlerResponseError `json:"error,omitempty"`
	ImageID string                `json:"image_id,omitempty"`
}

type HandlerResponseError struct {
	Message string `json:"message"`
}
