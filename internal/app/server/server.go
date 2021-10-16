package server

import (
	"fmt"
	"log"
	"net/http"
)

type arcHandler struct {
	jsonFile string
}

// ServeHTTP handles the HTTP request.
func (t *arcHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// use fileServer := http.FileServer(http.Dir("web/template"))
	// this fileServer.ServeHTTP(w, r)

	html := Parse(t.jsonFile, r.URL.Path[1:])
	fmt.Fprintln(w, html)
}

func Serve(addr, storyFile string) {
	http.Handle("/", &arcHandler{
		jsonFile: storyFile,
	})

	// Start Web Server
	fmt.Println("Starting the server on #{addr}")
	if err := http.ListenAndServe(addr, http.DefaultServeMux); err != nil {
		log.Fatal("ListenAndServe:", err)
	}
}
