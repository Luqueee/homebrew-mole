cask "mole-tunnel" do
  version "0.8.4"
  sha256 "ed9b3ed62b19f46f8a34c52aad63f1ae0456d4699005f6667c51938d7ae56d20"

  url "https://github.com/Luqueee/mole/releases/download/desktop-v#{version}/mole.dmg"
  name "mole"
  desc "Forward ports and name remote services over one SSH connection"
  homepage "https://github.com/Luqueee/mole"

  livecheck do
    url :url
    regex(/^desktop-v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  # The app checks for and installs its own updates.
  auto_updates true
  depends_on macos: ">= :monterey"

  # homebrew-core has an unrelated Mole app; both would land in /Applications.
  conflicts_with cask: "mole-app"

  app "mole.app"

  # The app is signed ad hoc (no Apple Developer ID), so Gatekeeper refuses a
  # quarantined copy. Dropping the quarantine flag is what lets it open.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/mole.app"],
                   sudo: false
  end

  zap trash: [
    "~/.config/mole",
    "~/.local/state/mole",
  ]

  caveats <<~EOS
    mole.app is not notarized (it has no Apple Developer ID). This cask removes
    the quarantine flag after installing so macOS will open it.
  EOS
end
