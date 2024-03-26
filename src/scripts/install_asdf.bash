#!/bin/bash
#  Copyright (c) 2024 Greg Rynkowski. All rights reserved.
#  License: MIT License

###
# Script installs asdf.
#
# Execute:
#    DEBUG=1 VERSION=0.14.0 INSTALL_DIR=tmp-here ./src/scripts/gen/install_asdf.bash
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
# Library Sourcing
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.2.2/lib/color.bash
source "${SHELL_GR_DIR}/lib/color.bash"
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.2.2/lib/fs.bash
source "${SHELL_GR_DIR}/lib/fs.bash" # normalized_path
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.2.2/lib/install/asdf.bash
source "${SHELL_GR_DIR}/lib/install/asdf.bash" # asdf_install, asdf_is_installed, asdf_determine_install_dir
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.2.2/lib/install/asdf.bash
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

if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ "${CIRCLECI}" == "true" ]]; then
  main "$@"
else
  printf "%s\n" "Loaded: ${BASH_SOURCE[0]:-}"
fi
