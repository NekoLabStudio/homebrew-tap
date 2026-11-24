cask "purr" do
  version "0.3.2"
  sha256 "2d32f0777fcedc3b46fb954e574d862f41281fbc1b0c7ee20399adf457716bdb"

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
