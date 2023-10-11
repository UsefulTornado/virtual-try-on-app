package image

import (
	"context"
	"errors"
	"fmt"
	"virtual-try-on-app/internal/repositories/image"
)

type Service struct {
	imageRepo image.Repository
}

func New(imageRepo image.Repository) Service {
	return Service{imageRepo: imageRepo}
}

func (s Service) Save(ctx context.Context, img []byte) (string, error) {
	imageID, err := s.imageRepo.Save(ctx, img)
	if err != nil {
		if errors.Is(err, image.ErrNotPNGImage) {
			return "", ErrNotPNGImage
		}
		return "", fmt.Errorf("error while saving image")
	}

	return imageID, nil
}

func (s Service) Get(ctx context.Context, imageID string) ([]byte, error) {
	imageData, err := s.imageRepo.Get(ctx, imageID)
	if err != nil {
		if errors.Is(err, image.ErrImageNotExist) {
			return nil, ErrImageNotExist
		}
		return nil, fmt.Errorf("error while getting image")
	}

	return imageData.Bytes, nil
}
