PHONY: clean all init generate generate_mocks

all: build/main

COMPILER = go
BUILD_OPTS = -a -buildmode=exe -ldflags="-s -w"
BUILDER = ${COMPILER} build ${BUILD_OPTS}
BUILD_DST ?= build/main

build/main: cmd/main.go generated
	@echo "Building..."
	${BUILDER} -o ${BUILD_DST} $<

clean:
	rm -rf generated

init: generate
	go mod tidy
	go mod vendor

test:
	go test -short -coverprofile coverage.out -v ./...

generate: generated generate_mocks

generated: api.yml
	@echo "Generating files..."
	mkdir generated || true
	oapi-codegen --package generated -generate types,fiber,spec $< > generated/api.gen.go

INTERFACES_GO_FILES := $(shell find repository -name "interfaces.go")
INTERFACES_GEN_GO_FILES := $(INTERFACES_GO_FILES:%.go=%.mock.gen.go)

generate_mocks: $(INTERFACES_GEN_GO_FILES)
$(INTERFACES_GEN_GO_FILES): %.mock.gen.go: %.go
	@echo "Generating mocks $@ for $<"
	mockgen -source=$< -destination=$@ -package=$(shell basename $(dir $<))%
