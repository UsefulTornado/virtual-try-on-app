package image

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"image/png"
	"io"
	"os"
	"path"

	"github.com/google/uuid"
)

type Repository struct {
	folderPath string
}

func New(folderPath string) Repository {
	return Repository{folderPath: folderPath}
}

const ImageFormat = ".png"

func (r Repository) Save(ctx context.Context, img []byte) (string, error) {
	imageID := uuid.New().String()
	imageName := imageID + ImageFormat
	imagePath := path.Join(r.folderPath, imageName)

	f, err := os.Create(imagePath)
	if err != nil {
		return "", fmt.Errorf("error while creating image file %s: %w", imagePath, err)
	}
	defer func() { _ = f.Close() }()

	decodedPNG, err := png.Decode(bytes.NewReader(img))
	if err != nil {
		var formatError png.FormatError
		if errors.As(err, &formatError) {
			return "", ErrNotPNGImage
		}
		return "", fmt.Errorf("error while decoding image: %w", err)
	}

	err = png.Encode(f, decodedPNG)
	if err != nil {
		return "", fmt.Errorf("error while encoding image to file: %w", err)
	}

	return imageID, nil
}

func (r Repository) Get(ctx context.Context, imageID string) (Image, error) {
	imageName := imageID + ImageFormat
	imagePath := path.Join(r.folderPath, imageName)

	_, err := os.Stat(imagePath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return Image{}, ErrImageNotExist
		}
		return Image{}, fmt.Errorf("error while checking image existance: %w", err)
	}

	f, err := os.Open(imagePath)
	if err != nil {
		return Image{}, fmt.Errorf("error while opening image: %w", err)
	}

	imageBytes, err := io.ReadAll(f)
	if err != nil {
		return Image{}, fmt.Errorf("error while getting image: %w", err)
	}

	imageConfig, err := png.DecodeConfig(f)
	//if err != nil {
	//	return Image{}, fmt.Errorf("error while getting image header: %w", err)
	//}

	return Image{
		Bytes:  imageBytes,
		Width:  int64(imageConfig.Width),
		Height: int64(imageConfig.Height),
	}, nil
}
