#!/bin/bash

###
# Script installs asdf.
#
# Execute:
#    DEBUG=1 VERSION=0.14.0 INSTALL_DIR=tmp-here ./src/scripts/gen/install_asdf.bash
###

SCRIPT_PATH="$([ -L "$0" ] && readlink "$0" || echo "$0")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" || exit 1; pwd -P)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SHELLPACK_DEPS_DIR="${SHELLPACK_DEPS_DIR:-"${ROOT_DIR}/.shellpack_deps"}"
SHELL_GR_DIR="${SHELL_GR_DIR:-"${SHELLPACK_DEPS_DIR}/@github/rynkowsg/shell-gr@02965b2cbbe4707c052f26eb90aac9308816c94b"}"
export SHELL_GR_DIR

########################################################################################################################
## common library (shared)
########################################################################################################################

# shellcheck source=.shellpack_deps/@github/rynkowsg/shell-gr@02965b2cbbe4707c052f26eb90aac9308816c94b/lib/color.bash
source "${SHELL_GR_DIR}/lib/color.bash"
# shellcheck source=.shellpack_deps/@github/rynkowsg/shell-gr@02965b2cbbe4707c052f26eb90aac9308816c94b/lib/fs.bash
source "${SHELL_GR_DIR}/lib/fs.bash" # normalized_path

########################################################################################################################
## asdf-orb-specific
########################################################################################################################
# in this section I we can convert orb input to the script intput

DEBUG=${PARAM_DEBUG:-${DEBUG:-0}}
if [ "${DEBUG}" = 1 ]; then
  set -x
fi

VERSION="${PARAM_VERSION:-${VERSION:-}}"
INSTALL_DIR="$(normalized_path "${PARAM_INSTALL_DIR:-${INSTALL_DIR:-}}")"

# shellcheck source=src/scripts/internal/asdf_orb_common_start.bash
source ./internal/asdf_orb_common_start.bash
# shellcheck source=src/scripts/internal/asdf_orb_common_input.bash
source ./internal/asdf_orb_common_input.bash

########################################################################################################################
## asdf-specific (shared)
########################################################################################################################

# shellcheck source=src/scripts/internal/asdf_common.bash
source ./internal/asdf_common.bash

########################################################################################################################
## asdf-orb-specific
########################################################################################################################

# $1 - install_dir
ci_post_asdf_install() {
  if [ "${CIRCLECI}" = "true" ]; then
    local install_dir="${1}"
    asdf_validate_install_dir "${install_dir}"
    # needed for following jobs
    echo ". ${install_dir}/asdf.sh" >>"${BASH_ENV}"
    # needed when we SSH to machine for debugging
    echo ". ${install_dir}/asdf.sh" >>~/.bashrc
  fi
}

main() {
  local version install_dir
  version="${VERSION}"
  install_dir="$(asdf_determine_install_dir "${INSTALL_DIR}")"
  if ! asdf_is_installed; then
    printf "${YELLOW}%s${NC}\n" "${NAME} is not yet installed."
    asdf_install "${version}" "${install_dir}"
    ci_post_asdf_install "${install_dir}"
  elif ! asdf_is_version "${version}"; then
    printf "${YELLOW}%s${NC}\n" "The installed version of ${NAME} ($(asdf_version)) is different then expected (${version})."
    asdf_install "${version}" "${install_dir}"
    ci_post_asdf_install "${install_dir}"
  else
    printf "${YELLOW}%s${NC}\n" "${NAME} is already installed in $(which "${CMD_NAME}")."
  fi
}

# shellcheck disable=SC2199
# to disable warning about concatenation of BASH_SOURCE[@]
# It is not a problem. This part pf condition is only to prevent `unbound variable` error.
if [[ -n "${BASH_SOURCE[@]}" && "${BASH_SOURCE[0]}" != "${0}" ]]; then
  [[ -n "${BASH_SOURCE[0]}" ]] && printf "%s\n" "Loaded: ${BASH_SOURCE[0]}"
else
  main "$@"
fi
