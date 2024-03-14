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
SHELL_GR_DIR="${SHELL_GR_DIR:-"${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@e0642bd1a0b42b9bbd5b83de9f2d9eebf2edf80f"}"
# shellcheck source=.github_deps/rynkowsg/shell-gr@e0642bd1a0b42b9bbd5b83de9f2d9eebf2edf80f/lib/color.bash
# source "${SHELL_GR_DIR}/lib/color.bash" # BEGIN
#!/usr/bin/env bash

#################################################
#                    COLORS                     #
#################################################

# shellcheck disable=SC2034
GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')
# source "${SHELL_GR_DIR}/lib/color.bash" # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@e0642bd1a0b42b9bbd5b83de9f2d9eebf2edf80f/lib/fs.bash
# source "${SHELL_GR_DIR}/lib/fs.bash" # normalized_path # BEGIN
#!/usr/bin/env bash

HOME="${HOME:-"$(eval echo ~)"}"

# $1 - path
normalized_path() {
  local path=$1
  # expand tilde (~) with eval
  eval path="${path}"
  # save prefix that otherwise we would loose in the next step
  local prefix=
  if [[ "${path}" == /* ]]; then
    prefix="/"
  elif [[ "${path}" == ./* ]]; then
    prefix="./"
  fi
  # remove all redundant /, . and ..
  local old_IFS=$IFS
  IFS='/'
  local -a path_array
  for segment in ${path}; do
    case ${segment} in
      "" | ".")
        :
        ;;
      "..")
        # Remove the last segment for parent directory
        [ ${#path_array[@]} -gt 0 ] && unset 'path_array[-1]'
        ;;
      *)
        path_array+=("${segment}")
        ;;
    esac
  done
  # compose path
  local result
  result="${prefix}$(IFS='/' && echo "${path_array[*]}")"
  IFS=${old_IFS}
  echo "${result}"
}

# $1 - path
absolute_path() {
  local path="${1}"
  local normalized
  normalized="$(normalized_path "${path}")"
  cd "${normalized}" || exit 1
  pwd -P
}
# source "${SHELL_GR_DIR}/lib/fs.bash" # normalized_path # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@e0642bd1a0b42b9bbd5b83de9f2d9eebf2edf80f/lib/install/asdf.bash
# source "${SHELL_GR_DIR}/lib/install/asdf.bash" # asdf_install, asdf_is_installed, asdf_determine_install_dir # BEGIN
#!/usr/bin/env bash

# Path Initialization
_GR_INSTALL_ASDF__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P || exit 1)"
_GR_INSTALL_ASDF__ROOT_DIR="$(cd "${_GR_INSTALL_ASDF__SCRIPT_DIR}/../.." && pwd -P || exit 1)"
# Library Sourcing
_SHELL_GR_DIR="${SHELL_GR_DIR:-"${_GR_INSTALL_ASDF__ROOT_DIR}"}"
# source "${_SHELL_GR_DIR}/lib/install_common.bash" # is_installed # BEGIN
#!/usr/bin/env bash

# $1 - expected path
path_in_path() {
  local dir="$1"
  if echo "${PATH}" | tr ':' '\n' | grep -qx "${dir}"; then
    return 0 # true
  else
    return 1 # false
  fi
}

# $1 - command name
is_installed() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null; then
    return 0 # true
  else
    return 1 # false
  fi
}
# source "${_SHELL_GR_DIR}/lib/install_common.bash" # is_installed # END

_ASDF_NAME="asdf"
_ASDF_CMD_NAME="${_ASDF_NAME}"

_ASDF_REPO="${ASDF_REPO:-"https://github.com/asdf-vm/asdf.git"}"
_ASDF_VERSION_REGEX="[0-9]+\.[0-9]+\.[0-9]+"

# $1 - version
asdf_validate_version() {
  local version="$1"
  local version_regex="^${_ASDF_VERSION_REGEX}$"
  if [[ $version =~ $version_regex ]]; then
    : # version matches regex
  elif [ -z "${version}" ]; then
    : # version is empty
  else
    printf "${RED}%s${NC}\n" "The version ${version} is invalid."
    exit 1
  fi
}

# $1 - install dir
asdf_validate_install_dir() {
  local install_dir="${1}"
  if [ -d "${install_dir}" ]; then
    :
    # todo: check whether is empty
  else
    if [ -z "${install_dir}" ]; then
      printf "${RED}%s${NC}\n" "The install_dir can't be empty."
      exit 1
    fi
  fi
}

asdf_version() {
  asdf --version | sed "s|v\(${_ASDF_VERSION_REGEX}\)-.*|\1|"
}

# $1 - expected version
asdf_is_version() {
  local expected_ver="$1"
  if [ "$(asdf_version)" = "${expected_ver}" ]; then
    return 0 # true
  else
    return 1 # false
  fi
}

asdf_is_installed() {
  is_installed "${_ASDF_CMD_NAME}"
}

# $1 - install dir
asdf_determine_install_dir() {
  local install_dir_default="${HOME}/.asdf"
  local install_dir="${1:-"${install_dir_default}"}"
  echo "${install_dir}"
}

# $1 - version
# $2 - install_dir
asdf_install() {
  local version="${1}"
  local install_dir_default="${HOME}/.asdf"
  local install_dir="${2}"
  asdf_validate_version "${version}"
  asdf_validate_install_dir "${install_dir}"
  mkdir -p "${install_dir}"
  local install_dir_absolute
  install_dir_absolute="$(absolute_path "${install_dir}")"
  # Installation by cloning repo. More:
  # https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
  local git_params=()
  git_params+=(-C "${HOME}")
  git_params+=(-c advice.detachedHead=false)
  local git_clone_params=()
  if [ -n "${version}" ]; then
    git_clone_params+=(--branch "v${version}")
  fi
  git_clone_params+=(--depth 1)
  git "${git_params[@]}" clone "${git_clone_params[@]}" "${_ASDF_REPO}" "${install_dir_absolute}"
}
# source "${SHELL_GR_DIR}/lib/install/asdf.bash" # asdf_install, asdf_is_installed, asdf_determine_install_dir # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@e0642bd1a0b42b9bbd5b83de9f2d9eebf2edf80f/lib/install/asdf.bash
# source "${SHELL_GR_DIR}/lib/install/asdf_circleci.bash" # ASDF_CIRCLECI_asdf_install # BEGIN
#!/usr/bin/env bash

# Path Initialization
_GR_INSTALL_ASDF_CIRCLECI__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P || exit 1)"
_GR_INSTALL_ASDF_CIRCLECI__ROOT_DIR="$(cd "${_GR_INSTALL_ASDF_CIRCLECI__SCRIPT_DIR}/../.." && pwd -P || exit 1)"
# Library Sourcing
_SHELL_GR_DIR="${SHELL_GR_DIR:-"${_GR_INSTALL_ASDF_CIRCLECI__ROOT_DIR}"}"
# source "${_SHELL_GR_DIR}/lib/color.bash"        # YELLOW, NC # BEGIN
#!/usr/bin/env bash

#################################################
#                    COLORS                     #
#################################################

# shellcheck disable=SC2034
GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')
# source "${_SHELL_GR_DIR}/lib/color.bash"        # YELLOW, NC # END
# source "${_SHELL_GR_DIR}/lib/install/asdf.bash" # asdf_determine_install_dir, asdf_validate_install_dir, asdf_is_installed, asdf_is_version, asdf_version, _ASDF_NAME # BEGIN
#!/usr/bin/env bash

# Path Initialization
_GR_INSTALL_ASDF__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P || exit 1)"
_GR_INSTALL_ASDF__ROOT_DIR="$(cd "${_GR_INSTALL_ASDF__SCRIPT_DIR}/../.." && pwd -P || exit 1)"
# Library Sourcing
_SHELL_GR_DIR="${SHELL_GR_DIR:-"${_GR_INSTALL_ASDF__ROOT_DIR}"}"
# source "${_SHELL_GR_DIR}/lib/install_common.bash" # is_installed # BEGIN
#!/usr/bin/env bash

# $1 - expected path
path_in_path() {
  local dir="$1"
  if echo "${PATH}" | tr ':' '\n' | grep -qx "${dir}"; then
    return 0 # true
  else
    return 1 # false
  fi
}

# $1 - command name
is_installed() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null; then
    return 0 # true
  else
    return 1 # false
  fi
}
# source "${_SHELL_GR_DIR}/lib/install_common.bash" # is_installed # END

_ASDF_NAME="asdf"
_ASDF_CMD_NAME="${_ASDF_NAME}"

_ASDF_REPO="${ASDF_REPO:-"https://github.com/asdf-vm/asdf.git"}"
_ASDF_VERSION_REGEX="[0-9]+\.[0-9]+\.[0-9]+"

# $1 - version
asdf_validate_version() {
  local version="$1"
  local version_regex="^${_ASDF_VERSION_REGEX}$"
  if [[ $version =~ $version_regex ]]; then
    : # version matches regex
  elif [ -z "${version}" ]; then
    : # version is empty
  else
    printf "${RED}%s${NC}\n" "The version ${version} is invalid."
    exit 1
  fi
}

# $1 - install dir
asdf_validate_install_dir() {
  local install_dir="${1}"
  if [ -d "${install_dir}" ]; then
    :
    # todo: check whether is empty
  else
    if [ -z "${install_dir}" ]; then
      printf "${RED}%s${NC}\n" "The install_dir can't be empty."
      exit 1
    fi
  fi
}

asdf_version() {
  asdf --version | sed "s|v\(${_ASDF_VERSION_REGEX}\)-.*|\1|"
}

# $1 - expected version
asdf_is_version() {
  local expected_ver="$1"
  if [ "$(asdf_version)" = "${expected_ver}" ]; then
    return 0 # true
  else
    return 1 # false
  fi
}

asdf_is_installed() {
  is_installed "${_ASDF_CMD_NAME}"
}

# $1 - install dir
asdf_determine_install_dir() {
  local install_dir_default="${HOME}/.asdf"
  local install_dir="${1:-"${install_dir_default}"}"
  echo "${install_dir}"
}

# $1 - version
# $2 - install_dir
asdf_install() {
  local version="${1}"
  local install_dir_default="${HOME}/.asdf"
  local install_dir="${2}"
  asdf_validate_version "${version}"
  asdf_validate_install_dir "${install_dir}"
  mkdir -p "${install_dir}"
  local install_dir_absolute
  install_dir_absolute="$(absolute_path "${install_dir}")"
  # Installation by cloning repo. More:
  # https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
  local git_params=()
  git_params+=(-C "${HOME}")
  git_params+=(-c advice.detachedHead=false)
  local git_clone_params=()
  if [ -n "${version}" ]; then
    git_clone_params+=(--branch "v${version}")
  fi
  git_clone_params+=(--depth 1)
  git "${git_params[@]}" clone "${git_clone_params[@]}" "${_ASDF_REPO}" "${install_dir_absolute}"
}
# source "${_SHELL_GR_DIR}/lib/install/asdf.bash" # asdf_determine_install_dir, asdf_validate_install_dir, asdf_is_installed, asdf_is_version, asdf_version, _ASDF_NAME # END
# source "${_SHELL_GR_DIR}/lib/text.bash"         # append_if_not_exists # BEGIN
#!/usr/bin/env bash

append_if_not_exists() {
  local -r line="$1"
  local -r file="$2"
  if ! grep -qxF -- "${line}" "${file}"; then
    echo "${line}" >>"${file}"
  fi
}
# source "${_SHELL_GR_DIR}/lib/text.bash"         # append_if_not_exists # END

# $1 - install_dir
ASDF_CIRCLECI_post_install() {
  if [ "${CIRCLECI:-}" = "true" ]; then
    local -r install_dir="${1}"
    asdf_validate_install_dir "${install_dir}"
    # needed for following jobs
    if [ -n "${BASH_ENV:-}" ]; then
      append_if_not_exists ". ${install_dir}/asdf.sh" "${BASH_ENV}"
    fi
    # needed when we SSH to machine for debugging
    append_if_not_exists ". ${install_dir}/asdf.sh" ~/.bashrc
  fi
}

ASDF_CIRCLECI_asdf_install() {
  local -r input_version="$1"
  local -r input_install_dir="$2"
  local -r version="${input_version}"
  local install_dir
  install_dir="$(asdf_determine_install_dir "${input_install_dir}")"
  if ! asdf_is_installed; then
    printf "${YELLOW}%s${NC}\n" "${_ASDF_NAME} is not yet installed."
    asdf_install "${version}" "${install_dir}"
    ASDF_CIRCLECI_post_install "${install_dir}"
  elif ! asdf_is_version "${version}"; then
    printf "${YELLOW}%s${NC}\n" "The installed version of ${_ASDF_NAME} ($(asdf_version)) is different then expected (${version})."
    asdf_install "${version}" "${install_dir}"
    ASDF_CIRCLECI_post_install "${install_dir}"
  else
    printf "${YELLOW}%s${NC}\n" "${_ASDF_NAME} is already installed in $(which "${_ASDF_CMD_NAME}")."
  fi
}
# source "${SHELL_GR_DIR}/lib/install/asdf_circleci.bash" # ASDF_CIRCLECI_asdf_install # END

# shellcheck source=src/scripts/internal/asdf_orb_common_start.bash
# source "${SCRIPT_DIR}/internal/asdf_orb_common_start.bash" # BEGIN
echo "BASH_ENV=${BASH_ENV:-}"
echo "CIRCLECI=${CIRCLECI:-}"
echo "DEBUG=${DEBUG:-}"
# source "${SCRIPT_DIR}/internal/asdf_orb_common_start.bash" # END
# shellcheck source=src/scripts/internal/asdf_orb_common_input.bash
# source "${SCRIPT_DIR}/internal/asdf_orb_common_input.bash" # BEGIN
#!/bin/bash

ASDF_DIR="${PARAM_ASDF_DIR:-${ASDF_DIR:-~/.asdf}}"
eval ASDF_DIR="${ASDF_DIR}"
# eval to resolve possible ~
# source "${SCRIPT_DIR}/internal/asdf_orb_common_input.bash" # END

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
