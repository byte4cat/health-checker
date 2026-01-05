GO ?= go
GOFMT ?= gofmt "-s"
GO_VERSION=$(shell $(GO) version | cut -c 14- | cut -d' ' -f1 | cut -d'.' -f2)
PACKAGES ?= $(shell $(GO) list ./...)
GO_FILES := $(shell find . -name "*.go" -not -path "./vendor/*" -not -path ".git/*")
TEST_TAGS ?= ""
GIT_COMMIT_SHA := $(shell git rev-parse HEAD | cut -c 1-8)
GOLINT := $(shell which golangci-lint)

default: dev

run:
	@go run main.go

dev: clean
	@CompileDaemon -build="go build -race -o bin/server cmd/main.go" -command="./bin/server" -color=true -graceful-kill=true

clean:
	@go clean
	@-rm -f bin/server

test:
	@gotestsum --junitfile-hide-empty-pkg --format testname

tidy:
	@go mod tidy
	@go fmt ./...

lint:
	@if [ -z "$(GOLINT)" ]; then \
		echo "golangci-lint not found, installing..."; \
		$(GO) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
	fi
	@golangci-lint run ./...

install-tools:
	$(GO) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	$(GO) install github.com/githubnemo/CompileDaemon@latest
