#
# https://gist.github.com/thomaspoignant/5b72d579bd5f311904d973652180c705
#
GOCMD=go
GOTEST=$(GOCMD) test
GOVET=$(GOCMD) vet
BINARY_NAME=t3 # SET THIS <<<<<<<<<
VERSION?=0.0.0
SERVICE_PORT?=3000
DOCKER_REGISTRY?= #if set it should finished by /
EXPORT_RESULT?=false # for CI please set EXPORT_RESULT to true

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: fmt lint build test clean benchmark

all: help

## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)


clean: ## Remove build related file
	@echo "clean"
	$(GOCMD) clean
	rm ${BINARY_NAME}

## Build:
build: ## compile binary
# https://stackoverflow.com/a/4483467/2846161
# https://gist.github.com/sighingnow/deee806603ec9274fd47
	@echo "Building"
	GO111MODULE=on $(GOCMD) build -o $(BINARY_NAME) ./cmd/$(BINARY_NAME)

# Docker:
docker-build: ## Use the dockerfile to build the container
	docker build --rm --tag $(BINARY_NAME) .

run: ## go run ${BINARY_NAME}
	@echo "Running"
	$(GOCMD) run ./cmd/${BINARY_NAME}

## Test:
test: ## Run the tests of the project
ifeq ($(EXPORT_RESULT), true)
	GO111MODULE=off go get -u github.com/jstemmer/go-junit-report
	$(eval OUTPUT_OPTIONS = | tee /dev/tty | go-junit-report -set-exit-code > junit-report.xml)
endif
	$(GOTEST) -v -coverprofile=profile.cov -covermode=atomic -race ./... $(OUTPUT_OPTIONS)

coverage: ## Run the tests of the project and export the coverage
	$(GOTEST) -cover -covermode=count -coverprofile=profile.cov ./...
	$(GOCMD) tool cover -func profile.cov
ifeq ($(EXPORT_RESULT), true)
	GO111MODULE=off $(GOCMD) get -u github.com/AlekSi/gocov-xml
	GO111MODULE=off $(GOCMD) get -u github.com/axw/gocov/gocov
	gocov convert profile.cov | gocov-xml > coverage.xml
endif

benchmark: ## run benchmarks
	@echo "Run benchmarks"
	$(GOTEST) -run=NONE -benchmem -benchtime=5s -bench=. ./...

## Style check
lint: ## lint files
	@echo "Run linters using golangci-lint"
	@golangci-lint run

fmt: ## Format files
	@echo "fmt"
	@goimports -w $$(find . -name "*.go" -not -path "./vendor/*")
	@$(GOCMD) fmt ./...

tidy: ## tidy go.mod and go.sum
	@echo "tidying up"
	$(GOCMD) mod tidy

## Dependencies
dep: ## download dependencies
	$(GOCMD) mod download

vendor: ## Copy of all packages needed to support builds and tests in the vendor directory
	$(GOCMD) mod vendor

vet: ## report likely mistakes in packages
	$(GOCMD) vet

watch: ## Run the code with cosmtrek/air to have automatic reload on changes
#	$(eval PACKAGE_NAME=$(shell head -n 1 go.mod | cut -d ' ' -f2))
#	docker run -it --rm -w /go/src/$(PACKAGE_NAME) -v $(shell pwd):/go/src/$(PACKAGE_NAME) -p $(SERVICE_PORT):$(SERVICE_PORT) cosmtrek/air
