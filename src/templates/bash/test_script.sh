#! /usr/bin/env bash

EXEC_NAME="$(basename "$(readlink -f "$0")")"
EXEC_ROOT="$(dirname  "$(readlink -f "$0")")"
readonly EXEC_NAME
readonly EXEC_ROOT

# shellcheck source=src/test/bash/test.shlib
source "${EXEC_ROOT}/test.shlib"

# TODO: Start coding here!
