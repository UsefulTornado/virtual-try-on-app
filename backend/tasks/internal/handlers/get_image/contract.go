package get_image

import "context"

type ImageService interface {
	Get(ctx context.Context, imageID string) ([]byte, error)
}
