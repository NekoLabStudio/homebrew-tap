cask "purr" do
  version "0.3.1"
  sha256 "0dc4a78eb9da6e868bc28f53c828754cc55fd5e370293ceeef496df578d35911"

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
