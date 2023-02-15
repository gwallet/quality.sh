SHELL=/bin/bash

PACKAGE_NAME       := $(shell basename $(shell pwd))
SRC_MAIN_BASH      := src/main/bash
SRC_MAIN_RESOURCES := src/main/resources
SRC_TEST_BASH      := src/test/bash
SRC_TEMPLATES_BASH := src/templates/bash
MAIN_SH_LIBS       := $(wildcard $(SRC_MAIN_BASH)/*.shlib)
MAIN_SCRIPTS       := $(wildcard $(SRC_MAIN_BASH)/*.sh)
MAIN_RESOURCES     := $(wildcard $(SRC_MAIN_RESOURCES)/*.*)
TEST_SH_LIBS       := $(wildcard $(SRC_TEST_BASH)/*.shlib)
TEST_SCRIPTS       := $(wildcard $(SRC_TEST_BASH)/*.sh)
TEMPLATES_SH_LIBS  := $(wildcard $(SRC_TEMPLATES_BASH)/*.shlib)
TEMPLATES_SCRIPTS  := $(wildcard $(SRC_TEMPLATES_BASH)/*.sh)
GIT                := $(shell command -v git 2>/dev/null)
ifdef GIT
GIT_TREE_STATE     := $(shell git status --porcelain --untracked-files=no | grep -q . && echo "DIRTY" || echo "CLEAN" )
VERSION            := $(shell git describe 2>/dev/null | grep '^[[:digit:]]\+\.[[:digit:]]\+\(\.[[:digit:]]\+\)\?$$' || date +"%Y%m%d_%H%M")_$(shell git rev-parse --short HEAD)
else
VERSION            := $(shell date +"%Y%m%d_%H%M")
endif

ifeq ($(VERBOSE),TRUE)
	HIDE =
	TEST_ARGS =
	TAR_OPTS = v
else
	HIDE = @
	TEST_ARGS = --quiet
	TAR_OPTS =
endif

.PHONY: clean ci help lint package test

default: help

##	This help screen
help:
	$(HIDE)printf "Available targets:\n\n"
	$(HIDE)awk '/^[a-zA-Z\-_0-9%:\\]+/ { \
				helpMessage = match(lastLine, /^##\s(.*)/); \
				if (helpMessage) { \
						helpCommand = $$1; \
						helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
						gsub("\\\\", "", helpCommand); \
						gsub(":+$$", "", helpCommand); \
						printf "  \x1b[32;01m%-15s\x1b[0m %s\n", helpCommand, helpMessage; \
				} \
		} \
		{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
	$(HIDE)printf "\n"

##	Check all source files statically, requires ShellCheck (https://www.shellcheck.net/)
lint: $(MAIN_SH_LIBS) $(MAIN_SCRIPTS) $(TEST_SH_LIBS) $(TEST_SCRIPTS) $(TEMPLATES_SH_LIBS) $(TEMPLATES_SCRIPTS)
	$(HIDE)shellcheck -x $^

##	Execute all tests, set VERBOSE=TRUE to see test outputs
test: $(TEST_SCRIPTS)
	$(HIDE)for test in $^; do $$test $(TEST_ARGS) || { echo "There are test failures"; exit 1; }; done

##	Helper for continuous integration, shortcut for `$ make lint test`
ci: lint test

##	Create a distribution package
package: ci
	$(HIDE)test -d ./dist && rm -rf ./dist; mkdir ./dist
	$(HIDE)cp $(MAIN_SCRIPTS) $(MAIN_SH_LIBS) $(MAIN_RESOURCES) ./dist/
	$(HIDE)tar -c$(TAR_OPTS)zf ./dist/$(PACKAGE_NAME)_$(VERSION).tar.gz     --directory "dist" $(notdir $(MAIN_SH_LIBS) $(MAIN_SCRIPTS) $(MAIN_RESOURCES) )
	$(HIDE)tar -c$(TAR_OPTS)zf ./dist/$(PACKAGE_NAME)_$(VERSION)-src.tar.gz --directory "$(shell pwd)" --exclude="dist" --exclude-vcs *

##	Some housekeeping
clean:
	$(HIDE)$(RM) -r ./dist
