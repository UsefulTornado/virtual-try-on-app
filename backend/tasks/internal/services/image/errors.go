package image

import "errors"

var ErrNotPNGImage = errors.New("image should be in png format")
var ErrImageNotExist = errors.New("image doesn't exist")
