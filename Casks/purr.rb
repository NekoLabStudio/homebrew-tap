cask "purr" do
  version "0.3.3"
  sha256 "27a83856b23a879628c388c4278f886d2ae33eb259a45860e6c2acacbc09878c"

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
