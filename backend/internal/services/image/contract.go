package image

import (
	"context"
	"mobile_project/virtual-try-on-app/backend/internal/repositories/image"
)

type ImageRepository interface {
	Save(ctx context.Context, img []byte) (string, error)
	Get(ctx context.Context, imageID string) (image.Image, error)
}
