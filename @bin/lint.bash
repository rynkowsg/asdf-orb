#!/usr/bin/env bash

set -uo pipefail

find . -type f \( -name '*.bash' -o -name '*.sh' \) | \
  grep -v -E '(.shellpack_deps|/gen/)' | \
  while IFS= read -r file; do
    echo "Processing file: $file"
    shellcheck \
    --shell=bash \
    --external-sources \
      "${file}"
  done

find . -type f -name '*.bats' -exec \
  shellcheck \
  --shell=bats \
  --external-sources \
  {} +
