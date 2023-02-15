#! /usr/bin/env bash

EXEC_NAME="$(basename "$(readlink -f "$0")")"
EXEC_ROOT="$(dirname  "$(readlink -f "$0")")"
readonly EXEC_NAME
readonly EXEC_ROOT

source "src/test/bash/test.shlib"

test_ok "this is a test success"
