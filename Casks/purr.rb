cask "purr" do
  version "0.2.0"
  sha256 "a7d4ddd5ff010b6f4487f5235f7747c9a6e3d2efde9c7f373356de8505babed0"

  url "https://github.com/NekoLabStudio/purr/releases/download/v#{version}/purr-#{version}-macos-editor.zip"
  name "Purr"
  desc "Game engine based on Godot"
  homepage "https://oss.nekolab.studio/purr"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Purr.app"
  binary "#{appdir}/Purr.app/Contents/MacOS/Purr", target: "purr"

  zap trash: [
    "~/Library/Application Support/Purr",
    "~/Library/Caches/Purr",
    "~/Library/Preferences/studio.nekolab.purr.plist",
    "~/Library/Saved Application State/studio.nekolab.purr.savedState",
  ]
end
