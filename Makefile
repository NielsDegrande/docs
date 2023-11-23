# No (file) targets are assumed for most Makefile commands.
.PHONY:
	install_dev
	build_test
	run_pre_commit
	build_latex
	compile_documentation

install_dev:
	pip install pre-commit
	pre-commit install

build_test:
	docker build \
		--file Dockerfile \
		--tag docs-test  \
		--cache-from=docs-test \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		${PWD}

run_pre_commit: build_test
	docker run --rm \
		--volume ${PWD}:/app \
		docs-test \
		-c "pre-commit run --all-files"

build_latex:
	docker build \
		--file ${PWD}/docs/LaTeX/Dockerfile \
		--tag latex \
		${PWD}

compile_documentation: build_latex
	docker run --rm --volume ${PWD}/docs/LaTeX:/docs latex
