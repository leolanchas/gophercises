package server

import (
	"bytes"
	"html/template"
	"t3/internal/app/json"
)

func init() {
	tmpl = template.Must(template.ParseFiles("web/template/index.html"))
}

var tmpl *template.Template

func Parse(path, storyName string) string {
	stories := json.ParseArcs(path)
	story, ok := stories[storyName]

	if !ok {
		story = stories["intro"]
	}

	var tpl bytes.Buffer
	if err := tmpl.Execute(&tpl, story); err != nil {
		return err.Error()
	}

	return tpl.String()
}
