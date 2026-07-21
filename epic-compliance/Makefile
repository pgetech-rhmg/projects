# EPIC Compliance Reviewer — build + release
#
# The pipeline pulls a version-pinned Linux binary from S3 and runs it in the
# cleaned workspace. `make release` produces that binary.

VERSION ?= dev
BINARY  := epic-compliance
PKG     := ./cmd/epic-compliance
LDFLAGS := -s -w -X main.version=$(VERSION)

.PHONY: build
build: ## Build for the host platform into ./bin
	go build -ldflags "$(LDFLAGS)" -o bin/$(BINARY) $(PKG)

.PHONY: release
release: ## Build the static linux/amd64 binary the EPIC agent runs
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		go build -ldflags "$(LDFLAGS)" -o dist/$(BINARY)-$(VERSION)-linux-amd64 $(PKG)

.PHONY: test
test: ## Run unit tests
	go test ./...

.PHONY: vet
vet: ## Static checks
	go vet ./...

.PHONY: run
run: build ## Build and scan a repo: make run REPO=/path/to/repo
	./bin/$(BINARY) $(REPO) --sarif compliance.sarif --out compliance.json

.PHONY: clean
clean:
	rm -rf bin dist

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'
