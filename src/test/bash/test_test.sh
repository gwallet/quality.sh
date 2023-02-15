#! /usr/bin/env bash

EXEC_NAME="$(basename "$(readlink -f "$0")")"
EXEC_ROOT="$(dirname  "$(readlink -f "$0")")"
readonly EXEC_NAME
readonly EXEC_ROOT

# shellcheck source=src/test/bash/test.shlib
source "${EXEC_ROOT}/test.shlib"

# Test `test_ok`
declare expected='TAP version 14
ok 1 - test_success.sh:10 - this is a test success
1..1'
declare actual
actual=$(src/test/resources/test_success.sh)
if [ "${expected}" == "${actual}" ]; then
  test_ok "Can run successful tests"
else
  test_not_ok "test.shlib MUST output successful test result" "${expected}" "${actual}"
fi
unset expected
unset actual

# Test `test_not_ok`
declare expected_out="TAP version 14
not ok 1 - test_failure.sh:10 - this is a test failure
  ---
  expecting: 'true'
  got: 'false'
  ...
1..1"
declare -i expected_exit_code=1
declare actual_out
set +o errexit
actual_out=$(src/test/resources/test_failure.sh)
declare -i actual_exit_code=$?
set -o errexit
if [ "${expected_out}" == "${actual_out}" ]; then
  test_ok "Can run failed tests and display failed result"
else
  test_not_ok "test.shlib MUST output failed test result" "${expected_out}" "${actual_out}"
fi
if [ "${expected_exit_code}" -eq ${actual_exit_code} ]; then
  test_ok "Failing test exits in error"
else
  test_not_ok "Failing test MUST exits in error" "${expected_exit_code}" "${actual_exit_code}"
fi
unset expected_out
unset expected_exit_code
unset actual_out
unset actual_exit_code
