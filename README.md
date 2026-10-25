# homebrew-mole

```sh
brew tap luqueee/mole
brew trust luqueee/mole           # Homebrew 7+ refuses to load third-party taps until you trust them

brew install mole-tunnel          # the CLI (builds from the release tag; needs Go, which brew installs)
brew install --cask mole-tunnel   # the desktop app (macOS)
```

The app is signed ad hoc, not notarized, so the cask removes the quarantine
flag after installing. Update with `brew upgrade`.

The formula is `mole-tunnel` because homebrew-core already has an unrelated
`mole`; the binary is still `mole`, so the two cannot be installed together.

Maintainers: `scripts/bump.sh X.Y.Z` after a release exists.
