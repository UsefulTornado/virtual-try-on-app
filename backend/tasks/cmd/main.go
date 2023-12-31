package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	handlerGetImage "virtual-try-on-app/internal/handlers/get_image"
	handlerSaveImage "virtual-try-on-app/internal/handlers/save_image"
	imageRepository "virtual-try-on-app/internal/repositories/image"
	serviceImage "virtual-try-on-app/internal/services/image"
)

func main() {
	imageRepo := imageRepository.New(imageDirectory)

	imageService := serviceImage.New(imageRepo)

	getImageHandler := handlerGetImage.New(imageService)
	saveImageHandler := handlerSaveImage.New(imageService)

	mux := http.NewServeMux()

	mux.Handle("/api/get_image", getImageHandler)
	mux.Handle("/api/save_image", saveImageHandler)

	server := http.Server{
		Addr:    "0.0.0.0:" + "1101",
		Handler: mux,
	}

	go func() {
		fmt.Println("server started")
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			fmt.Println("error while starting server", err)
		}
	}()

	// graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM, syscall.SIGQUIT)
	<-quit
	fmt.Println("shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err := server.Shutdown(ctx)
	if err != nil {
		fmt.Println("error while shutting down")
	}
}
