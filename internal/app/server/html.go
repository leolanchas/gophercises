package server

import (
	"bytes"
	"html/template"
	"t3/internal/app/json"
)

func Parse(path, storyName string) string {
	if storyName == "" {
		storyName = "intro"
	}

	tmpl := template.Must(template.ParseFiles("web/template/index.html"))

	var tpl bytes.Buffer
	story := json.ParseArcs(path)[storyName]

	if err := tmpl.Execute(&tpl, story); err != nil {
		return err.Error()
	}

	return tpl.String()
}
