#!/usr/bin/make

## help: Print help.
.PHONY: help
help:
	@echo Possible commands:
	@cat Makefile | grep '##' | grep -v "Makefile" | sed -e 's/^##/  -/'

## install_dev: Install dependencies for development.
.PHONY: install_dev
install_dev:
	pip install pre-commit
	pre-commit install

## build_test: Build the test image.
.PHONY: build_test
build_test:
	docker build \
		--file Dockerfile \
		--tag docs-test  \
		--cache-from=docs-test \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		${PWD}

## run_pre_commit: Run pre-commit.
.PHONY: run_pre_commit
run_pre_commit: build_test
	docker run --rm \
		--volume ${PWD}:/app \
		docs-test \
		-c "pre-commit run --all-files"

## build_latex: Build the LaTeX image.
.PHONY: build_latex
build_latex:
	docker build \
		--file ${PWD}/docs/LaTeX/Dockerfile \
		--tag latex \
		${PWD}

## compile_documentation: Compile the documentation.
.PHONY: compile_documentation
compile_documentation: build_latex
	docker run --rm --volume ${PWD}/docs/LaTeX:/docs latex
