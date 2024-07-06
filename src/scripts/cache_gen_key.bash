#!/bin/bash
#  Copyright (c) 2024 Greg Rynkowski. All rights reserved.
#  License: MIT License

###
# Script generates seed file for ASDF caching.
#
# Example:
#
#   PARAM_FIND_ARGS='. -name ".tool-versions" -o -name ".plugin-versions"' \
#     CACHE_SEED=/tmp/asdf_cache_seed \
#     ./src/scripts/gen/cache_gen_key.bash
#
###

# Bash Strict Mode Settings
set -euo pipefail
# Path Initialization
if [ -z "${SHELL_GR_DIR:-}" ]; then
  SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  SCRIPT_PATH="$([[ ! "${SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${SCRIPT_PATH_1}" || echo "")"
  SCRIPT_DIR="$([ -n "${SCRIPT_PATH}" ] && (cd "$(dirname "${SCRIPT_PATH}")" && pwd -P) || echo "")"
  ROOT_DIR="$([ -n "${SCRIPT_DIR}" ] && (cd "${SCRIPT_DIR}/../.." && pwd -P) || echo "/tmp")"
  SHELL_GR_DIR="${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@v0.2.2"
fi

init_input_vars_debug() {
  DEBUG=${PARAM_DEBUG:-${DEBUG:-0}}
  if [ "${DEBUG}" = 1 ]; then
    set -x
  fi
}

init_input_main() {
  CACHE_SEED=${CACHE_SEED:-}
  if [ -z "${CACHE_SEED}" ]; then
    printf "${RED}%s${NC}\n" "Missing CACHE_SEED." >&2
    exit 1
  fi
  PARAM_FIND_ARGS=${PARAM_FIND_ARGS:-}
  if [ -z "${PARAM_FIND_ARGS}" ]; then
    printf "${RED}%s${NC}\n" "Missing PARAM_FIND_ARGS to compose cache key." >&2
    exit 1
  fi
}

main() {
  init_input_vars_debug
  init_input_main

  echo "The following are the files used to generate the cache checksum:"
  eval find "${PARAM_FIND_ARGS}"
  eval find "${PARAM_FIND_ARGS}" | sort | xargs cat | shasum | awk '{print $1}' >"${CACHE_SEED}"
  echo "Seed file saved at ${CACHE_SEED}."
}

if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ "${CIRCLECI}" == "true" ]]; then
  main "$@"
else
  printf "%s\n" "Loaded: ${BASH_SOURCE[0]:-}" >&2
fi
