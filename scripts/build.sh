#!/usr/bin/env bash
# Build the site with Hugo extended.
#
# The theme compiles SCSS with resources.ToCSS, which needs the extended
# edition of Hugo. Workers Builds installs the standard edition, so this
# script fetches the pinned extended release, verifies it, and runs it.
set -euo pipefail

HUGO_VERSION="0.108.0"
HUGO_SHA256="e44680f508621f600d7c6e148a7da6c42a3b2e152369b7c74421287040f4318a"
HUGO_ARCHIVE="hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_ARCHIVE}"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin_dir="${root}/.hugo-bin/${HUGO_VERSION}"
hugo="${bin_dir}/hugo"

if [[ ! -x "${hugo}" ]]; then
  mkdir -p "${bin_dir}"
  archive="${bin_dir}/${HUGO_ARCHIVE}"
  curl -fsSL -o "${archive}" "${HUGO_URL}"
  echo "${HUGO_SHA256}  ${archive}" | sha256sum -c -
  tar -xzf "${archive}" -C "${bin_dir}" hugo
  rm -f "${archive}"
fi

cd "${root}"
"${hugo}" version
"${hugo}" --minify "$@"
