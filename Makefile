# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# Show help by default.
.DEFAULT_GOAL := help

# Set app identity.
APP_NAME=hostname-server
PKG_NAME=github.com/mojochao/${APP_NAME}
VERSION=$(shell cat VERSION | tr -d '\n')

# Configure chart identity
CHART = charts/$(APP_NAME)

# Configure image identity
IMAGE_NAME ?= mojochao/${APP_NAME}
IMAGE_REPO ?= ghcr.io
IMAGE_TAG  ?= ${VERSION}
IMAGE_URL  ?= ${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# Set Docker image build configuration.
DOCKERFILE ?= Dockerfile

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

##@ Info targets

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: env
env: ## Display targets environment
	@echo "APP_NAME:    $(APP_NAME)"
	@echo "PKG_NAME:    $(PKG_NAME)"
	@echo "VERSION:     $(VERSION)"
	@echo "IMAGE_NAME:  $(IMAGE_NAME)"
	@echo "IMAGE_TAG:   $(IMAGE_TAG)"
	@echo "IMAGE_REPO:  $(IMAGE_REPO)"
	@echo "IMAGE_URL:   $(IMAGE_URL)"

## Development targets

.PHONY: run
run: ## Run the application
	@echo 'running $(APP_NAME)'
	go run main.go

.PHONY: build
build: ## Build the application
	@echo 'building $(APP_NAME)'
	go build -o $(APP_NAME) .

.PHONY: lint
lint: ## Lint the application
	@echo 'linting $(APP_NAME)'
	go vet ./...

.PHONY: test
test: ## Run all tests
	@echo 'testing $(APP_NAME)'
	go test -v ./...

.PHONY: clean
clean: ## Clean build artifacts
	@echo 'cleaning $(APP_NAME)'
	rm -f $(APP_NAME)

##@ Image targets

.PHONY: image-build
image-build: ## Build container image
	@echo 'building $(IMAGE_URL)'
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE_URL) .

.PHONY: image-lint
image-lint: ## Ling container image
	@echo 'linting $(IMAGE_URL)'
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE_URL) .

.PHONY: image-run
image-run: ## Run container image
	@echo 'running $(IMAGE_URL)'
	docker run --rm $(IMAGE_URL)

##@ Chart targets

.PHONY: chart-build
chart-build: ## Build helm chart
	@echo 'generating $(CHART)/README.md'
	cd $(CHART) && helm-docs

.PHONY: chart-lint
chart-lint: ## Lint helm chart
	@echo 'linting $(CHART)'
	helm lint $(CHART)

.PHONY: chart-install
chart-install: ## Install helm chart
	@echo 'installing $(CHART)'
	helm install $(APP_NAME) $(CHART) --namespace $(APP_NAME) --create-namespace

.PHONY: chart-uninstall
chart-uninstall: ## Uninstall helm chart
	@echo 'uninstalling $(CHART)'
	helm install $(APP_NAME) $(CHART) --namespace $(APP_NAME) --create-namespace
