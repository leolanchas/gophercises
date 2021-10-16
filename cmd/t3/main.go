package main

import (
	"t3/internal/app/server"
)

func main() {
	path := "assets/gopher.json"
	server.Serve(":8080", path)
}
