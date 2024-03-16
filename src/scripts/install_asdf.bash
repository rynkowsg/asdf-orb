#!/bin/bash

###
# Script installs asdf.
#
# Execute:
#    DEBUG=1 VERSION=0.14.0 INSTALL_DIR=tmp-here ./src/scripts/gen/install_asdf.bash
###

# Path Initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P || exit 1)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd -P || exit 1)"
# Library Sourcing
SHELL_GR_DIR="${SHELL_GR_DIR:-"${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@v0.1.0"}"
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.1.0/lib/color.bash
source "${SHELL_GR_DIR}/lib/color.bash"
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.1.0/lib/fs.bash
source "${SHELL_GR_DIR}/lib/fs.bash" # normalized_path
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.1.0/lib/install/asdf.bash
source "${SHELL_GR_DIR}/lib/install/asdf.bash" # asdf_install, asdf_is_installed, asdf_determine_install_dir
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.1.0/lib/install/asdf.bash
source "${SHELL_GR_DIR}/lib/install/asdf_circleci.bash" # ASDF_CIRCLECI_asdf_install

# shellcheck source=src/scripts/internal/asdf_orb_common_start.bash
source "${SCRIPT_DIR}/internal/asdf_orb_common_start.bash"
# shellcheck source=src/scripts/internal/asdf_orb_common_input.bash
source "${SCRIPT_DIR}/internal/asdf_orb_common_input.bash"

DEBUG=${PARAM_DEBUG:-${DEBUG:-0}}
if [ "${DEBUG}" = 1 ]; then
  set -x
fi

VERSION="${PARAM_VERSION:-${VERSION:-}}"
INSTALL_DIR="$(normalized_path "${PARAM_INSTALL_DIR:-${INSTALL_DIR:-}}")"

main() {
  ASDF_CIRCLECI_asdf_install "${VERSION}" "${INSTALL_DIR}"
}

# shellcheck disable=SC2199
# to disable warning about concatenation of BASH_SOURCE[@]
# It is not a problem. This part pf condition is only to prevent `unbound variable` error.
if [[ -n "${BASH_SOURCE[@]}" && "${BASH_SOURCE[0]}" != "${0}" ]]; then
  [[ -n "${BASH_SOURCE[0]}" ]] && printf "%s\n" "Loaded: ${BASH_SOURCE[0]}"
else
  main "$@"
fi
