SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

PKG := data-tap-surveymonkey
VENV := venv
PYTHON := python3.7

OBJS := $(shell find . -type f -name "*.py" -not -path "*$(VENV)/*" -not -path "*build/*" -not -path "*dist/*")

.PHONY: help clean clean-hard check build upload

## help      : provides help
help: Makefile
	@sed -n 's/^##//p' $<

## clean     : removes sentinel files
clean:
	rm -f .sentinel*

## clean-hard: removes sentinel files, venv, dist, build and egg dirs
clean-hard: clean
	rm -rf $(VENV)
	rm -rf dist
	rm -rf build
	rm -rf $(PKG).egg-info

## check     : runs checks
check: .sentinel.unit-tests .sentinel.integration-tests

## discover  : runs the tap in discovery mode
discover: build catalog-discovered.json

## build     : builds the package
build: .sentinel.build

## upload    : uploads the package to a remote pypi server
upload: .sentinel.upload

# private
catalog-discovered.json: sample_config.json
	@PYTHONPATH=./build/lib $(VENV)/bin/python tap_surveymonkey/__init__.py -d -c $< > $@

.sentinel.venv: requirements.txt setup.py
	@mkdir -p $(@D)
	test -d $(VENV) && rm -rf $(VENV)
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install .[test]
	$(VENV)/bin/pip install setuptools wheel twine
	touch $@

.sentinel.unit-tests: .sentinel.venv $(OBJS)
	@mkdir -p $(@D)
	#$(VENV)/bin/nosetests --where=tests/unit
	echo "unit tests not implemented yet"
	touch $@

.sentinel.integration-tests: .sentinel.venv $(OBJS)
	@mkdir -p $(@D)
	#$(VENV)/bin/nosetests --where=tests/integration
	echo "integration tests not implemented yet"
	touch $@

.sentinel.build: .sentinel.unit-tests .sentinel.integration-tests
	@mkdir -p $(@D)
	$(VENV)/bin/python setup.py sdist bdist_wheel

.sentinel.upload: .sentinel.build
	@mkdir -p $(@D)
	$(VENV)/bin/twine upload \
		--non-interactive \
		--verbose \
		--username . \
		--password . \
		--repository-url $(PYPISERVER_URL) \
		dist/*
	touch $@

