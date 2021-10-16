package util

import "io/ioutil"

func Load(filename string) ([]byte, error) {
	file, err := ioutil.ReadFile(filename)

	if err != nil {
		return nil, err
	}

	return file, err
}
