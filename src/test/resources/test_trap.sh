#! /usr/bin/env bash

#set -x
set -o errexit
set -o nounset
set -o pipefail

source "src/main/bash/bash.shlib"

bash_trap 'echo "[EXIT] This is trap 1"' EXIT
bash_trap 'echo "[ERR ] This is trap 1"' ERR

bash_trap 'echo "[EXIT] This is trap 2"' EXIT
bash_trap 'echo "[ERR ] This is trap 2"' ERR

bash_trap 'echo "[EXIT] This is Sparta ... euh trap 3"' EXIT
bash_trap 'echo "[ERR ] This is Sparta ... euh trap 3"' ERR

function check_exit_status() {
  if bash_there_was_an_error; then
    echo "There was an error! 🙁"
  else
    echo "Everything went fine! 🙂"
  fi
}

bash_trap 'check_exit_status "$?"' EXIT ERR

if [ "$1" == "FAIL" ]; then
  false
else
  true
fi
