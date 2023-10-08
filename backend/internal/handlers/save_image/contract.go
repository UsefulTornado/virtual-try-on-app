package save_image

import "context"

type ImageService interface {
	Save(ctx context.Context, img []byte) (string, error)
}
