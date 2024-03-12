#!/usr/bin/env bash

set -uo pipefail

# detect ROOT_DIR - BEGIN
SCRIPT_PATH="$([ -L "$0" ] && readlink "$0" || echo "$0")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd -P || exit 1)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P || exit 1)"
# detect ROOT_DIR - END

main() {
  # DEFINE ERROR_CODES
  declare -A error_codes
  # workaround to fix unbound error
  error_codes["key1"]="value1"
  unset 'error_codes["key1"]'

  # PROCESS
  while IFS= read -r file; do
    echo "Processing file: $file"
    shellcheck --shell=bash --external-sources "${file}"
    res=$?
    if [ "${res}" -ne 0 ]; then
      error_codes["${file}"]=$res
    fi
  done < <(
    find "${ROOT_DIR}" -type f \( -name '*.bash' -o -name '*.sh' \) \
      | grep -v -E '(.shellpack_deps|/gen/)'
  )
  while IFS= read -r file; do
    echo "Processing file: $file"
    shellcheck --shell=bats --external-sources "${file}"
    res=$?
    if [ $res -ne 0 ]; then
      error_codes["${file}"]=$res
    fi
  done < <(find . -type f -name '*.bats')

  # REPORT ERRORS
  local errors_count=${#error_codes[@]}
  if [ "${errors_count}" -ne 0 ]; then
    # Print error codes before exiting
    printf "\n%s\n" "Error codes per file:"
    for file in "${!error_codes[@]}"; do
      echo "$file: ${error_codes[$file]}"
    done
    exit "${errors_count}"
  fi
}

main
