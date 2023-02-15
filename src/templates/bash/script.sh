#! /usr/bin/env bash

#set -x
set -o errexit
set -o nounset
set -o pipefail

EXEC_NAME="$(basename "$(readlink -f "$0")")"
EXEC_ROOT="$(dirname  "$(readlink -f "$0")")"
readonly EXEC_NAME
readonly EXEC_ROOT

# shellcheck source=src/main/bash/log.shlib
source "${EXEC_ROOT}/log.shlib"
# shellcheck source=src/main/bash/bash.shlib
source "${EXEC_ROOT}/bash.shlib"

# Display in-line documentation and exit program
#
# $1 - exit code when exiting program
# $2 - Additional message to send to the user
function usage() {
  local -r EXIT_CODE=$1
  local -r MESSAGE=${2:-}

  cat 2>&1 <<EOF
  $EXEC_NAME - Title

SYNOPSIS
  $EXEC_NAME

DESCRIPTION
  Description

COMMANDS
  Commands

USAGE
  Usage

OPTIONS
  --help, -h
    (Optional) Display the inline documentation, then exit with success

  --debug
    (Optional) Run the script in debug mode

  --log-level, -l [ DEBUG | INFO | WARN | ERROR | FATAL ]
    (Optional) Set the logging level

  --log-file <LOG_FILE_PATH>
    (Optional) Path to the file to log into

ENVIRONMENT
  Environment variables

$MESSAGE
EOF
  exit "$EXIT_CODE"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h) usage 0
      ;;
    --debug)
      # shellcheck disable=SC2034 # this can be useful but not necessary used 🙂
      DEBUG_MODE_ENABLED="true"
      set -x
      ;;
    --log-level|-l)
      log_set_level "$2" \
        || usage 1 "Unknown log level $2"
      shift
      ;;
    --log-file) log_set_file "$2"; shift
      ;;
    -*) usage 1 "Unknown options $1"
      ;;
    *) break
      ;;
  esac
  shift
done

function finish() {
  if bash_there_was_an_error; then
    log_e "Unexpected end of ${EXEC_NAME} with error, see previous message for details, run '${EXEC_NAME} --debug ...' to debug"
  else
    log_i "End of ${EXEC_NAME} with success"
  fi
}

bash_trap finish EXIT
