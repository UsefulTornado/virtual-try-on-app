package get_image

import (
	"context"
	"encoding/json"
	"errors"
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
	w.Header().Set("Content-Type", handlers.ContentTypeJSON)
	defer func() { _ = r.Body.Close() }()

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		_ = json.NewEncoder(w).Encode(HandlerResponse{
			Status: http.StatusMethodNotAllowed,
			Error: &HandlerResponseError{
				Message: handlers.ErrMsgMethodNotAllowed,
			},
		})
		return
	}

	var request HandlerRequest
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(HandlerResponse{
			Status: http.StatusBadRequest,
			Error: &HandlerResponseError{
				Message: handlers.ErrMsgBadRequest,
			},
		})
		return
	}
	response := h.handle(r.Context(), request)
	w.WriteHeader(response.Status)
	_ = json.NewEncoder(w).Encode(response)

	return
}

func (h Handler) handle(ctx context.Context, request HandlerRequest) HandlerResponse {
	if request.PersonImageID == "" {
		return HandlerResponse{
			Status: http.StatusBadRequest,
			Error: &HandlerResponseError{
				Message: "id shouldn't be empty",
			},
		}
	}

	personImageBytes, err := h.imageService.Get(ctx, request.PersonImageID)

	var clothesImageBytes []byte
	if request.ClothesImageID != nil {
		clothesImageBytes, err = h.imageService.Get(ctx, *request.ClothesImageID)
	}

	if err != nil {
		if errors.Is(err, image.ErrImageNotExist) {
			return HandlerResponse{
				Status: http.StatusBadRequest,
				Error: &HandlerResponseError{
					Message: "image doesn't exist",
				},
			}
		}
		return HandlerResponse{
			Status: http.StatusInternalServerError,
			Error: &HandlerResponseError{
				Message: handlers.ErrMsgInternaL,
			},
		}
	}

	return HandlerResponse{Status: http.StatusOK, PersonImage: personImageBytes, ClothesImage: clothesImageBytes}
}
