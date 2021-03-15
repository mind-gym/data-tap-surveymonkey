SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

PKG := data-tap-surveymonkey
VENV := .venv
PYTHON := python3.7
VERSION := 1.0.1.1

OBJS := $(shell find . -type f -name "*.py" -not -path "*$(VENV)/*" -not -path "*build/*" -not -path "*dist/*")

## help: provides help
help : Makefile
	@sed -n 's/^##//p' $<
.PHONY : help

## all                                                 : PHONY, dist/$(PKG)-$(VERSION).tar.gz
all: dist/$(PKG)-$(VERSION).tar.gz
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
	rm -rf $(PKG).egg-info
.PHONY: clean

## tmp/.sentinel.install-venv                        : installs virtual env
tmp/.sentinel.install-venv: requirements.txt setup.py
	@mkdir -p $(@D)
	test -d $(VENV) && rm -rf $(VENV)
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install .[test]
	$(VENV)/bin/pip install pylint
	$(VENV)/bin/pip install setuptools wheel twine
	touch $@

## tmp/.sentinel.lint                                  : lint
tmp/.sentinel.lint: tmp/.sentinel.install-venv $(OBJS)
	@mkdir -p $(@D)
	#TODO need to fix the violations for linting rules
	# ticket is https://themindgym.atlassian.net/browse/DB-196
	#$(VENV)/bin/pylint tap_surveymonkey -d C,W,unexpected-keyword-arg,duplicate-code
	touch $@

## tmp/.sentinel.unit-tests                            : runs unit tests
tmp/.sentinel.unit-tests: tmp/.sentinel.install-venv $(OBJS)
	@mkdir -p $(@D)
	#$(VENV)/bin/nosetests --where=tests/unit
	echo "unit tests not implemented yet"
	touch $@

## tmp/.sentinel.integration-tests                     : runs integration tests
tmp/.sentinel.integration-tests: tmp/.sentinel.install-venv $(OBJS)
	@mkdir -p $(@D)
	#$(VENV)/bin/nosetests --where=tests/integration
	echo "integration tests not implemented yet"
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


