package save_image

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"

	"virtual-try-on-app/internal/handlers"
	"virtual-try-on-app/internal/services/image"
)

type Handler struct {
	imageService ImageService
}

func New(imageService ImageService) Handler {
	return Handler{imageService: imageService}
}

func (h Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "image/png")
	defer func() { _ = r.Body.Close() }()

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		_ = json.NewEncoder(w).Encode(HandlerResponse{
			Status: http.StatusMethodNotAllowed,
			Error: &HandlerResponseError{
				Message: handlers.ErrMsgMethodNotAllowed,
			},
		})
		fmt.Println(handlers.ErrMsgMethodNotAllowed)
		return
	}

	imageBytes, err := io.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(HandlerResponse{
			Status: http.StatusBadRequest,
			Error: &HandlerResponseError{
				Message: handlers.ErrMsgBadRequest,
			},
		})
		fmt.Println(handlers.ErrMsgBadRequest)
		return
	}
	response := h.handle(r.Context(), imageBytes)
	w.WriteHeader(response.Status)
	_ = json.NewEncoder(w).Encode(response)

	return
}

func (h Handler) handle(ctx context.Context, imageBytes []byte) HandlerResponse {
	imageID, err := h.imageService.Save(ctx, imageBytes)
	if err != nil {
		if errors.Is(err, image.ErrNotPNGImage) {
			fmt.Println("image should be png")
			return HandlerResponse{
				Status: http.StatusBadRequest,
				Error: &HandlerResponseError{
					Message: "image should be png",
				},
			}
		}

		fmt.Println(handlers.ErrMsgInternaL)
		return HandlerResponse{
			Status: http.StatusInternalServerError,
			Error: &HandlerResponseError{
				Message: handlers.ErrMsgInternaL,
			},
		}
	}

	return HandlerResponse{Status: http.StatusOK, ImageID: imageID}
}
