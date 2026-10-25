class MoleTunnel < Formula
  desc "Hit localhost:3000 as if it were always running, even when the service lives on another machine"
  homepage "https://github.com/Luqueee/mole"
  # A git checkout pinned by tag and commit, not a GitHub tarball: GitHub does
  # not promise byte-identical archives, and a changed checksum breaks installs.
  url "https://github.com/Luqueee/mole.git",
      tag:      "v0.8.0",
      revision: "0c8de49cc5336998f21d42a07fe68c68c10c7a01"
  license "MIT"
  head "https://github.com/Luqueee/mole.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  # homebrew-core has an unrelated `mole` (a Mac cleaner) that installs the same binary.
  conflicts_with "mole", because: "both install a `mole` binary"

  def install
    # The release is stamped like the installers do, so `mole version` says
    # which tag this binary came from.
    ldflags = "-s -w -X main.buildRef=v#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/mole"
  end

  def caveats
    <<~EOS
      Update mole with Homebrew (`brew upgrade mole-tunnel`), not `mole update`.
    EOS
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/mole version")
    # A config that parses is the cheapest end-to-end check without an SSH host.
    (testpath/"mole.yaml").write <<~YAML
      remote: example
      domains: [dev.lan]
      routes:
        web: 3000
    YAML
    assert_match "web.dev.lan -> 127.0.0.1:3000", shell_output("#{bin}/mole route ls -config #{testpath}/mole.yaml")
  end
end
