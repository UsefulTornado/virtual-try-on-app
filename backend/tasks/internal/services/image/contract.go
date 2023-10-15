package image

import (
	"context"

	"virtual-try-on-app/internal/repositories/image"
)

type ImageRepository interface {
	Save(ctx context.Context, img []byte) (string, error)
	Get(ctx context.Context, imageID string) (image.Image, error)
}
