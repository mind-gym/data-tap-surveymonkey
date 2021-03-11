SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

PKG := mindgym-target-snowflake
VENV := .venv
PYTHON := python3.7
VERSION := 1.10.0

OBJS := $(shell find . -type f -name "*.py" -not -path "*$(VENV)/*" -not -path "*build/*" -not -path "*dist/*")

## all                                                 : PHONY, dist/pipelinewise-target-snowflake-$(VERSION).tar.gz
all: dist/pipelinewise-target-snowflake-$(VERSION).tar.gz
.PHONY: all

## upload                                              : PHONY, tmp/.sentinel.twine-upload-to-pypi
upload: tmp/.sentinel.twine-upload-to-pypi
.PHONY:upload

## clean                                               : PHONY, removes venv, dist, build, tmp and egg dirs
clean:
	rm -rf $(VENV)
	rm -rf dist
	rm -rf build
	rm -rf tmp
	rm -rf pipelinewise_target_snowflake.egg-info
.PHONY: clean

## tmp/.sentinel.installed-venv                        : installs virtual env
tmp/.sentinel.installed-venv: requirements.txt setup.py
	@mkdir -p $(@D)
	test -d $(VENV) && rm -rf $(VENV)
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install .[test]
	$(VENV)/bin/pip install pylint
	$(VENV)/bin/pip install setuptools wheel twine
	touch $@

## tmp/.sentinel.lint                                  : lint
tmp/.sentinel.lint: tmp/.sentinel.installed-venv $(OBJS)
	@mkdir -p $(@D)
	$(VENV)/bin/pylint target_snowflake -d C,W,unexpected-keyword-arg,duplicate-code
	touch $@

## tmp/.sentinel.unit-tests                            : runs unit tests
tmp/.sentinel.unit-tests: tmp/.sentinel.installed-venv $(OBJS)
	@mkdir -p $(@D)
	$(VENV)/bin/nosetests --where=tests/unit
	touch $@

## tmp/.sentinel.integration-tests                     : runs integration tests
tmp/.sentinel.integration-tests: tmp/.sentinel.installed-venv $(OBJS)
	@mkdir -p $(@D)
	$(VENV)/bin/nosetests --where=tests/integration
	touch $@

## dist/$(PKG)-$(VERSION).tar.gz: builds package
dist/$(PKG)-$(VERSION).tar.gz: tmp/.sentinel.lint tmp/.sentinel.unit-tests tmp/.sentinel.integration-tests
	@mkdir -p $(@D)
	$(VENV)/bin/python setup.py sdist bdist_wheel

## tmp/.sentinel.twine-upload-to-pypi                  : twine uploads to Pypi server
tmp/.sentinel.twine-upload-to-pypi: dist/$(PKG)-$(VERSION).tar.gz
	@mkdir -p $(@D)
	$(VENV)/bin/twine upload \
		--non-interactive \
		--verbose \
		--username . \
		--password . \
		--repository-url $(PYPISERVER_URL) \
		dist/*
	touch $@

## help: provides help
help : Makefile
	@sed -n 's/^##//p' $<
.PHONY : help
