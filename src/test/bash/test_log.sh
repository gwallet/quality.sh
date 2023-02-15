#! /usr/bin/env bash

EXEC_NAME="$(basename "$(readlink -f "$0")")"
EXEC_ROOT="$(dirname  "$(readlink -f "$0")")"
readonly EXEC_NAME
readonly EXEC_ROOT

# shellcheck source=src/test/bash/test.shlib
source "${EXEC_ROOT}/test.shlib"

source src/main/bash/log.shlib

# Default log level is DEBUG
if log_is_level_enabled "DEBUG"; then
  test_ok "Default log level is DEBUG"
else
  test_not_ok "Default log level must be DEBUG" "DEBUG" "$( log_get_level )"
fi

# test set_log_level with unknown logging level
if log_set_level "UNKNOWN"; then
  test_not_ok "must fail on unknown log level"
else
  test_ok "log_set_level only supports known level (${_LOG_LEVELS[*]})"
fi

# test log_is_level_enabled with unknown logging level
if log_is_level_enabled "UNKNOWN"; then
  test_not_ok "unknown logging level must always be disabled"
else
  test_ok "unknown logging level are disabled"
fi

# test set_log_level with known logging level and check that this level is enabled
for level in "${_LOG_LEVELS[@]}"; do
  log_set_level "$level"
  if log_is_level_enabled "$level"; then
    test_ok "'$level' level is enabled after log_set_level '$level'"
  else
    test_not_ok "'$level' level must be enabled after log_set_level '$level'" "$level" "$( log_get_level )"
  fi
done

# test set_log_level with known logging level and check that lower levels are disabled and higher levels are enabled
log_set_level "DEBUG"
if log_is_level_enabled "DEBUG" || log_is_level_enabled "INFO" || log_is_level_enabled "WARN" || log_is_level_enabled "ERROR" || log_is_level_enabled "FATAL"; then
  test_ok "DEBUG, INFO, WARN, ERROR & FATAL levels are enabled after log_set_level 'DEBUG'"
else
  test_not_ok "DEBUG, INFO, WARN, ERROR & FATAL levels must be enabled after log_set_level 'DEBUG'"
fi
log_set_level "INFO"
if log_is_level_enabled "INFO" || log_is_level_enabled "WARN" || log_is_level_enabled "ERROR" || log_is_level_enabled "FATAL"; then
  test_ok "INFO, WARN, ERROR & FATAL levels are enabled after log_set_level 'INFO'"
else
  test_not_ok "INFO, WARN, ERROR & FATAL levels must be enabled after log_set_level 'INFO'"
fi
if log_is_level_enabled "DEBUG"; then
  test_not_ok "DEBUG level must be disabled after log_set_level 'INFO'"
else
  test_ok "DEBUG level is disabled after log_set_level 'INFO'"
fi
log_set_level "WARN"
if log_is_level_enabled "WARN" || log_is_level_enabled "ERROR" || log_is_level_enabled "FATAL"; then
  test_ok "WARN, ERROR & FATAL levels are enabled after log_set_level 'WARN'"
else
  test_not_ok "WARN, ERROR & FATAL levels must be enabled after log_set_level 'WARN'"
fi
if log_is_level_enabled "DEBUG" || log_is_level_enabled "INFO"; then
  test_not_ok "DEBUG & INFO levels must be disabled after log_set_level 'WARN'"
else
  test_ok "DEBUG & INFO levels are disabled after log_set_level 'WARN'"
fi
log_set_level "ERROR"
if log_is_level_enabled "ERROR" || log_is_level_enabled "FATAL"; then
  test_ok "ERROR & FATAL levels are enabled after log_set_level 'ERROR'"
else
  test_not_ok "ERROR & FATAL levels must be enabled after log_set_level 'ERROR'"
fi
if log_is_level_enabled "DEBUG" || log_is_level_enabled "INFO" || log_is_level_enabled "WARN"; then
  test_not_ok "DEBUG, INFO & WARN levels must be disabled after log_set_level 'ERROR'"
else
  test_ok "DEBUG, INFO & WARN levels are disabled after log_set_level 'ERROR'"
fi
log_set_level "FATAL"
if log_is_level_enabled "FATAL"; then
  test_ok "FATAL level is enabled after log_set_level 'FATAL'"
else
  test_not_ok "FATAL level must be enabled after log_set_level 'FATAL'"
fi
if log_is_level_enabled "DEBUG" || log_is_level_enabled "INFO" || log_is_level_enabled "WARN" || log_is_level_enabled "ERROR"; then
  test_not_ok "DEBUG, INFO, WARN & ERROR levels must be disabled after log_set_level 'FATAL'"
else
  test_ok "DEBUG, INFO, WARN & ERROR levels are disabled after log_set_level 'FATAL'"
fi

# test set_log_level with known logging level and check that higher level is enabled
log_set_level "INFO"
if log_is_level_enabled "DEBUG"; then
  test_not_ok "'DEBUG' level must be disabled after log_set_level 'INFO'"
else
  test_ok "'DEBUG' level id disabled after log_set_level 'INFO'"
fi

# test log_d
# we mock date as it's used in logging
function date() {
  echo "[1955/11/05 01:35:07 -0700]"
}
export -f date
log_set_level "DEBUG"
declare expected="[1955/11/05 01:35:07 -0700] [DEBUG] This is a DEBUG output"
declare actual
actual=$( log_d "This is a DEBUG output" )
if [ "${actual}" == "${expected}" ]; then
  test_ok "log_d display debug messages"
else
  test_not_ok "log_d must display debug messages" "${expected}" "${actual}"
fi
# Don't forget to unset the mock
unset -f date
unset expected
unset actual

# test log_d
log_set_level "INFO"
declare expected=""
declare actual
actual=$( log_d "This is a DEBUG output" )
if [ "${actual}" == "${expected}" ]; then
  test_ok "log_d is muted in level 'INFO'"
else
  test_not_ok "log_d must be muted in level 'INFO'" "${expected}" "${actual}"
fi
unset expected
unset actual

# test log_e
log_set_level "DEBUG"
# we mock date as it's used in logging
function date() {
  echo "[1970/01/01 00:00:00 +0000]"
}
export -f date
declare expected="[1970/01/01 00:00:00 +0000] [ERROR] This is an ERROR output at EPOC"
declare actual
actual=$( log_e "This is an ERROR output at EPOC" )
if [ "${actual}" == "${expected}" ]; then
  test_ok "log_e display error messages"
else
  test_not_ok "log_e must display error messages" "${expected}" "${actual}"
fi
# Don't forget to unset the mock
unset -f date
unset expected
unset actual

# test log_set_file
# ⚠ This test should be the last one ⚠
log_set_level "DEBUG"
log_set_file "-"
if [ "-" == "$(log_get_file)" ]; then
  test_ok "log_get_file returns '-' when no log file is configured"
else
  test_not_ok "log_get_file must return '-' when no log file is configured" "-" "$(log_get_file)"
fi
# we mock date as it's used in logging
function date() {
  echo "[1970/01/01 00:00:00 +0000]"
}
export -f date
declare text="Testing log output to file"
declare log_file
log_file=$(mktemp -t "${EXEC_NAME%*.sh}_XXXX.log")
log_set_file "${log_file}"
declare expected="[1970/01/01 00:00:00 +0000] [DEBUG] ${text}"
declare actual
log_d "${text}"
actual="$(cat "${log_file}")"
if [ "${actual}" == "${expected}" ]; then
  test_ok "When calling 'log_set_file', the log is written in the file"
else
  test_not_ok "When calling 'log_set_file', the log should be written in the file" "${expected}" "${actual}"
fi
rm -f "${log_file}"
unset text
unset log_file
unset -f date
unset expected
unset actual
