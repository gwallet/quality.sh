#! /usr/bin/env bash

EXEC_NAME="$(basename "$(readlink -f "$0")")"
EXEC_ROOT="$(dirname  "$(readlink -f "$0")")"
readonly EXEC_NAME
readonly EXEC_ROOT

# shellcheck source=src/test/bash/test.shlib
source "${EXEC_ROOT}/test.shlib"

source "src/main/bash/bash.shlib"

# Test bash_is_integer
if bash_is_integer "42"; then
  test_ok "bash_is_integer can guess that 42 is an integer"
else
  test_not_ok "bash_is_integer must guess that 42 is an integer"
fi
if bash_is_integer "forty-two"; then
  test_not_ok "bash_is_integer must guess that forty-two is not an integer"
else
  test_ok "bash_is_integer can guess that forty-two is not an integer"
fi

# Test required bash version OK
declare expected
expected="$(head -c 3 <<<"${BASH_VERSION}")"
if bash_version_required "${expected}"; then
  test_ok "Current version of bash is greater than or equal to ${expected}"
else
  test_not_ok "Current version of bash must be greater than or equal to ${expected}" "${expected}" "${BASH_VERSION}"
fi
unset expected

# Test required bash version KO
declare expected
expected="$(head -c 1 <<<"${BASH_VERSION}")"
expected=$(( expected + 1 ))
if bash_version_required "${expected}"; then
  test_not_ok "Current version of bash must be lower than ${expected}" "${expected}" "${BASH_VERSION}"
else
  test_ok "Current version of bash is lower than ${expected}"
fi
unset expected

# Test bash_array_index_of
declare -a values=( One Two Three )
declare -i expected=2
declare -i actual
if bash_version_required "4.4"; then
  actual="$(bash_array_index_of "Three" values)"
else
  actual="$(bash_array_index_of "Three" "$(declare -p values)")"
fi
if [ "${expected}" -eq "${actual}" ]; then
  test_ok "Can retrieve index of a value in an array"
else
  test_not_ok "Must retrieve index of a value in an array" "${expected}" "${actual}"
fi
expected=0
if bash_version_required "4.4"; then
  actual="$(bash_array_index_of "One" values)"
else
  actual="$(bash_array_index_of "One" "$(declare -p values)")"
fi
if [ "${expected}" -eq "${actual}" ]; then
  test_ok "Index of the first value in an array is 0"
else
  test_not_ok "Index of the first value in an array must be 0" "${expected}" "${actual}"
fi
expected=-1
if bash_version_required "4.4"; then
  actual="$(bash_array_index_of "Zero" values)"
else
  actual="$(bash_array_index_of "Zero" "$(declare -p values)")"
fi
if [ "${expected}" -eq "${actual}" ]; then
  test_ok "Index of a missing value in an array is -1"
else
  test_not_ok "Index of a missing value in an array must be -1" "${expected}" "${actual}"
fi
unset values
unset expected
unset actual

# Test bash_trap with an external script
declare expected="[ERR ] This is trap 1
[ERR ] This is trap 2
[ERR ] This is Sparta ... euh trap 3
There was an error! 🙁
[EXIT] This is trap 1
[EXIT] This is trap 2
[EXIT] This is Sparta ... euh trap 3
There was an error! 🙁"
declare actual
actual="$(src/test/resources/test_trap.sh FAIL || true)"
if [ "${expected}" == "${actual}" ]; then
  test_ok "Trap can be chained"
else
  test_not_ok "Trap must be chained" "${expected}" "${actual}"
fi

# Test bash_trap with an external script
declare expected="[EXIT] This is trap 1
[EXIT] This is trap 2
[EXIT] This is Sparta ... euh trap 3
Everything went fine! 🙂"
declare actual
actual="$(src/test/resources/test_trap.sh SUCCESS || true)"
if [ "${expected}" == "${actual}" ]; then
  test_ok "Trap can be chained"
else
  test_not_ok "Trap must be chained" "${expected}" "${actual}"
fi
