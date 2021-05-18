.DEFAULT_GOAL := help

# Job parameter: src directory.
CURRENT_DIR := $(shell pwd)

.PHONY: help build test push format lint install.dependencies version.get version.set version.bump

#help:	@ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#install.dependencies: @ install dependencies.
install.dependencies:
	@exec >&2; \
	echo "> Installing dependencies."; \
	echo "NOOP."

#build: @ Builds the package.
build:
	@exec >&2; \
	echo "> Building."; \
	echo "NOOP."

#test: @ Tests the package.
test:
	@exec >&2; \
	echo "> Testing."; \
	echo "NOOP."

#test: @ Push the package.
push:
	@exec >&2; \
	echo "> Pushing."; \
	echo "NOOP."

#format: @ Format code
format:
	@exec >&2; \
	echo "> Formatting."; \
	echo "NOOP."

#lint: @ Lint package
lint:
	@exec >&2; \
	echo "> Linting."; \
	echo "NOOP."

#version.get: @ Gets the version value.
version.get:
	@bump2version --allow-dirty --dry-run --list patch | grep current_version | sed "s|^.*=||"

#version.get-released: @ Gets the released version value.
version.get-released: version.get

#version.set: @ Sets the version value.
version.set:
	@exec >&2; \
	echo "> Setting version $(VERSION)"; \
	bump2version --allow-dirty --new-version $(VERSION) patch

#version.bump: @ Bump the version value.
version.bump:
	@exec >&2; \
	echo "> Bumping version."; \
	bump2version --allow-dirty patch
