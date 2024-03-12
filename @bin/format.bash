#!/usr/bin/env bash

set -uo pipefail

# detect ROOT_DIR - BEGIN
SCRIPT_PATH="$([ -L "$0" ] && readlink "$0" || echo "$0")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd -P || exit 1)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P || exit 1)"
# detect ROOT_DIR - END

# inputs
DEBUG=${DEBUG:-0}
APPLY_PATCHES=${APPLY_PATCHES:-1}
APPLY=${APPLY:-0}

if [ "${DEBUG}" = 1 ]; then
  echo "SCRIPT_DIR: ${SCRIPT_DIR}"
  echo "ROOT_DIR: ${ROOT_DIR}"
  echo "APPLY_PATCHES: ${APPLY_PATCHES}"
  echo "APPLY: ${APPLY}"
fi

main() {
  # apply patches (shfmt workaround)
  if [ "${APPLY_PATCHES}" = 1 ]; then
    git apply "${SCRIPT_DIR}/res/pre-format.patch"
    res=$?
    if [ $res -ne 0 ]; then
      echo "Failed to apply pre-format.patch"
      exit $res
    fi
  fi
  # apply shfmt - define error_codes
  declare -A error_codes
  # workaround to fix unbound error
  error_codes["key1"]="value1"
  unset error_codes["key1"]
  # apply shfmt - process
  shfmt_params=()
  shfmt_params+=(--indent 2)
  shfmt_params+=(--case-indent)
  shfmt_params+=(--binary-next-line)
  if [ "${APPLY}" = 1 ]; then
    shfmt_params+=(--write)
  else
    shfmt_params+=(--diff)
  fi
  while IFS= read -r file; do
    echo "Processing file: $file"
    shfmt --language-dialect bash "${shfmt_params[@]}" "${file}"
    res=$?
    if [ $res -ne 0 ]; then
      error_codes["$file"]=$res
    fi
  done < <(
    find "${ROOT_DIR}" -type f \( -name '*.bash' -o -name '*.sh' \) \
      | grep -v -E '(.shellpack_deps|/gen/)'
  )
  while IFS= read -r file; do
    echo "Processing file: $file"
    shfmt --language-dialect bats "${shfmt_params[@]}" "${file}"
    res=$?
    if [ $res -ne 0 ]; then
      error_codes["${file}"]=$res
    fi
  done < <(find "${ROOT_DIR}" -type f -name '*.bats')
  # revert patches (shfmt workaround)
  if [ "${APPLY_PATCHES}" = 1 ]; then
    git apply "${SCRIPT_DIR}/res/post-format.patch"
    res=$?
    if [ $res -ne 0 ]; then
      echo "Failed to apply pre-format.patch"
      exit $res
    fi
  fi
  # report errors
  local errors_count=${#error_codes[@]}
  if [ $errors_count -ne 0 ]; then
    # Print error codes before exiting
    printf "\n%s\n" "Error codes per file:"
    for file in "${!error_codes[@]}"; do
      echo "$file: ${error_codes[$file]}"
    done
    exit $errors_count
  fi
}

main
