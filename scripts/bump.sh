#!/bin/sh
# Point the formula or the cask at a release of Luqueee/mole.
#
#   scripts/bump.sh formula 0.7.1    needs the v0.7.1 tag (the CLI's source)
#   scripts/bump.sh cask 0.7.1       needs the desktop-v0.7.1 release (the app's .dmg)
#
# The CLI and the app are versioned by separate tags, so they move separately.
# Nothing is edited unless the lookup or the download succeeded.
set -eu

what="${1:?usage: bump.sh formula|cask VERSION}"
ver="${2:?usage: bump.sh formula|cask VERSION}"
case "${ver}" in *[!0-9.]* | "") echo "bump: bad version '${ver}'" >&2; exit 2 ;; esac
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

case "${what}" in
  formula)
    # The commit the tag points at (an annotated tag lists it as ^{}).
    refs=$(git ls-remote https://github.com/Luqueee/mole.git "refs/tags/v${ver}" "refs/tags/v${ver}^{}")
    rev=$(printf '%s\n' "${refs}" | awk '/\^\{\}$/ {r=$1} !/\^\{\}$/ && !r {r=$1} END {print r}')
    case "${rev}" in
      [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;;
      *) echo "bump: no tag v${ver} in Luqueee/mole" >&2; exit 1 ;;
    esac
    [ "${#rev}" -eq 40 ] || { echo "bump: unexpected revision '${rev}'" >&2; exit 1; }
    file="${root}/Formula/mole-tunnel.rb"
    sed -i.bak -E "s|(tag: +\")v[0-9.]+(\",)|\1v${ver}\2|; s|(revision: \")[0-9a-f]{40}|\1${rev}|" "${file}"
    detail="${rev}"
    ;;
  cask)
    curl -fsSL -o "${tmp}" "https://github.com/Luqueee/mole/releases/download/desktop-v${ver}/mole.dmg"
    [ -s "${tmp}" ] || { echo "bump: empty download" >&2; exit 1; }
    sha=$(shasum -a 256 "${tmp}" | cut -d' ' -f1)
    file="${root}/Casks/mole-tunnel.rb"
    sed -i.bak -E "s|^(  version \")[0-9.]+|\1${ver}|; s|^(  sha256 \")[0-9a-f]{64}|\1${sha}|" "${file}"
    detail="${sha}"
    ;;
  *)
    echo "usage: bump.sh formula|cask VERSION" >&2
    exit 2
    ;;
esac
rm -f "${file}.bak"
echo "${what} -> ${ver} (${detail})"
