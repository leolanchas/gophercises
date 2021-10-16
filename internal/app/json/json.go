package json

import (
	encoder "encoding/json"
	"log"
	"t3/internal/pkg/util"
)

type Story map[string]Arc

type Arc struct {
	Title   string
	Story   []string
	Options []Option
}

type Option struct {
	Text string
	Arc  string
}

func ParseArcs(jsonPath string) (s Story) {
	arcsBytes, err := util.Load(jsonPath)

	if err != nil {
		log.Fatal(err)
	}

	if err := encoder.Unmarshal(arcsBytes, &s); err != nil {
		log.Fatal(err)
	}

	return s
}
