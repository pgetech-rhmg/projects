# EPIC Compliance Reviewer — build + release
#
# The pipeline pulls a version-pinned Linux binary from S3 and runs it in the
# cleaned workspace. `make release` produces that binary.

VERSION   ?= dev
BINARY    := epic-compliance
PKG       := ./cmd/epic-compliance
LDFLAGS   := -s -w -X main.version=$(VERSION)

# Local shift-left channel: a single rolling GitHub Release holding
# unversioned, always-latest binaries. Overwritten on each publish (no git
# history, no repo bloat). The versioned S3 channel above is unchanged.
REPO      := pgetech/epic-compliance
LOCAL_TAG := local
LOCAL_DIR := dist/local

.PHONY: build
build: ## Build for the host platform into ./bin
	go build -ldflags "$(LDFLAGS)" -o bin/$(BINARY) $(PKG)

.PHONY: release
release: ## Build the static linux/amd64 binary the EPIC agent runs
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		go build -ldflags "$(LDFLAGS)" -o dist/$(BINARY)-$(VERSION)-linux-amd64 $(PKG)

.PHONY: release-darwin
release-darwin: ## Build the static darwin/arm64 binary (Apple Silicon Mac)
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 \
		go build -ldflags "$(LDFLAGS)" -o dist/$(BINARY)-$(VERSION)-darwin-arm64 $(PKG)

.PHONY: release-darwin-amd64
release-darwin-amd64: ## Build the static darwin/amd64 binary (Intel Mac)
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 \
		go build -ldflags "$(LDFLAGS)" -o dist/$(BINARY)-$(VERSION)-darwin-amd64 $(PKG)

.PHONY: release-windows
release-windows: ## Build the static windows/amd64 binary (.exe)
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 \
		go build -ldflags "$(LDFLAGS)" -o dist/$(BINARY)-$(VERSION)-windows-amd64.exe $(PKG)

.PHONY: release-all
release-all: release release-darwin release-darwin-amd64 release-windows ## Build every release binary (linux, mac arm+intel, windows) for GitHub Releases

.PHONY: local-binaries
local-binaries: ## Build the UNVERSIONED local shift-left binaries into dist/local/
	@mkdir -p $(LOCAL_DIR)
	CGO_ENABLED=0 GOOS=darwin  GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o $(LOCAL_DIR)/$(BINARY)-darwin-arm64      $(PKG)
	CGO_ENABLED=0 GOOS=darwin  GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o $(LOCAL_DIR)/$(BINARY)-darwin-amd64      $(PKG)
	CGO_ENABLED=0 GOOS=linux   GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o $(LOCAL_DIR)/$(BINARY)-linux-amd64       $(PKG)
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o $(LOCAL_DIR)/$(BINARY)-windows-amd64.exe $(PKG)

.PHONY: publish-local
publish-local: local-binaries ## Refresh the rolling 'local' GitHub Release with the latest binaries (needs gh auth)
	@gh release view $(LOCAL_TAG) --repo $(REPO) >/dev/null 2>&1 || \
		gh release create $(LOCAL_TAG) --repo $(REPO) \
			--title "local (rolling shift-left build)" \
			--notes "Always-latest epic-compliance binaries for local shift-left. Overwritten on each build; not version-pinned. CI uses the versioned S3 binary, not these."
	gh release upload $(LOCAL_TAG) --repo $(REPO) --clobber $(LOCAL_DIR)/*

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
