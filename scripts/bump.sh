#!/bin/sh
# Point the formula and the cask at a release: scripts/bump.sh 0.7.1
# Needs the v<ver> tag (CLI) and the desktop-v<ver> release (app) to exist.
set -eu
ver="${1:?usage: bump.sh VERSION}"
root="$(cd "$(dirname "$0")/.." && pwd)"
src_sha=$(curl -fsSL "https://github.com/Luqueee/mole/archive/refs/tags/v${ver}.tar.gz" | shasum -a 256 | cut -d' ' -f1)
dmg_sha=$(curl -fsSL "https://github.com/Luqueee/mole/releases/download/desktop-v${ver}/mole.dmg" | shasum -a 256 | cut -d' ' -f1)
sed -i.bak -E "s|(refs/tags/v)[0-9.]+(\.tar\.gz)|\1${ver}\2|; s|^(  sha256 \")[0-9a-f]{64}|\1${src_sha}|" "${root}/Formula/mole-tunnel.rb"
sed -i.bak -E "s|^(  version \")[0-9.]+|\1${ver}|; s|^(  sha256 \")[0-9a-f]{64}|\1${dmg_sha}|" "${root}/Casks/mole-tunnel.rb"
rm -f "${root}"/Formula/*.bak "${root}"/Casks/*.bak
echo "formula -> v${ver} (${src_sha})"; echo "cask    -> ${ver} (${dmg_sha})"
