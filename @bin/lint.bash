#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Lint bash source files
#
# Example:
#
#     @bin/lint.bash
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Bash Strict Mode Settings
set -euo pipefail
# Path Initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P || exit 1)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P || exit 1)"
# Library Sourcing
SHELLPACK_DEPS_DIR="${SHELLPACK_DEPS_DIR:-"${ROOT_DIR}/.shellpack_deps"}"
SHELL_GR_DIR="${SHELL_GR_DIR:-"${SHELLPACK_DEPS_DIR}/@github/rynkowsg/shell-gr@81b70c3da598456200d9c63fda779a04012ff256"}"
# shellcheck source=.shellpack_deps/@github/rynkowsg/shell-gr@81b70c3da598456200d9c63fda779a04012ff256/lib/tool/lint.bash
source "${SHELL_GR_DIR}/lib/tool/lint.bash" # lint

main() {
  local error=0
  find "${ROOT_DIR}" -type f \( -name '*.bash' -o -name '*.sh' \) | grep -v -E '(.shellpack_deps|/gen/)' | lint bash || ((error += $?))
  find "${ROOT_DIR}" -type f -name '*.bats' | lint bats || ((error += $?))
  if ((error > 0)); then
    exit "$error"
  fi
}

main
