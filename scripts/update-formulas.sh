#!/bin/sh
set -eu

root="${HOMEBREW_TAP_ROOT:-$(CDPATH= cd "$(dirname "$0")/.." && pwd)}"
formula_dir="$root/Formula"
cask_dir="$root/Casks"
mkdir -p "$formula_dir" "$cask_dir"

github_get() {
    url="$1"
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        curl -fsSL \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $GITHUB_TOKEN" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "$url"
    else
        curl -fsSL \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "$url"
    fi
}

latest_tag() {
    repo="$1"
    if [ -n "${HOMEBREW_TAP_FIXTURES_DIR:-}" ]; then
        owner="${repo%%/*}"
        name="${repo#*/}"
        tag_file="$HOMEBREW_TAP_FIXTURES_DIR/$owner/$name/tag"
        [ -f "$tag_file" ] || return 0
        sed -n '1p' "$tag_file"
        return
    fi

    response="$(github_get "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null || true)"
    printf '%s\n' "$response" |
        sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
        sed -n '1p'
}

# The newest published release, pre-releases included.
latest_release_tag() {
    repo="$1"
    if [ -n "${HOMEBREW_TAP_FIXTURES_DIR:-}" ]; then
        latest_tag "$repo"
        return
    fi

    github_get "https://api.github.com/repos/$repo/releases?per_page=20" 2>/dev/null |
        jq -r '[.[] | select(.draft | not)][0].tag_name // empty' || true
}

download_checksums() {
    repo="$1"
    tag="$2"
    output="$3"
    checksum_asset="$4"
    if [ -n "${HOMEBREW_TAP_FIXTURES_DIR:-}" ]; then
        owner="${repo%%/*}"
        name="${repo#*/}"
        cp "$HOMEBREW_TAP_FIXTURES_DIR/$owner/$name/$checksum_asset" "$output"
        return
    fi

    github_get "https://github.com/$repo/releases/download/$tag/$checksum_asset" > "$output"
}

checksum_for() {
    file="$1"
    name="$2"
    awk -v name="$name" '$2 == name { print $1 }' "$file"
}

require_checksum() {
    checksum="$1"
    asset="$2"
    [ -n "$checksum" ] || {
        echo "Missing checksum for $asset" >&2
        exit 1
    }
}

render_sumi_formula() {
    repo="NekoLabStudio/sumi"
    tag="$(latest_tag "$repo")"
    if [ -z "$tag" ]; then
        echo "No Sumi release found; leaving formula unchanged."
        return
    fi

    checksums="$(mktemp "${TMPDIR:-/tmp}/sumi-checksums.XXXXXX")"
    trap 'rm -f "$checksums"' EXIT HUP INT TERM
    # Releases from before the rename to Sumi publish inkstead-writer-* assets,
    # so there is no sumi-*-SHA256SUMS to build from yet. Skip rather than fail.
    if ! download_checksums "$repo" "$tag" "$checksums" "sumi-$tag-SHA256SUMS"; then
        echo "No sumi-named assets for $tag yet; leaving formula unchanged."
        rm -f "$checksums"; trap - EXIT HUP INT TERM
        return
    fi

    launcher="sumi-$tag"
    launcher_sha="$(checksum_for "$checksums" "$launcher")"
    require_checksum "$launcher_sha" "$launcher"
    version="${tag#v}"

    cat > "$formula_dir/sumi.rb" <<FORMULA
class Sumi < Formula
  desc "Launcher for a static site generator for personal websites"
  homepage "https://oss.nekolab.studio/sumi"
  url "https://github.com/$repo/releases/download/$tag/$launcher",
      using: :nounzip
  version "$version"
  sha256 "$launcher_sha"
  license "MIT"

  def install
    bin.install cached_download => "sumi"
  end

  test do
    assert_match "Sumi launcher", shell_output("#{bin}/sumi --help")
  end
end
FORMULA

    rm -f "$checksums"
    trap - EXIT HUP INT TERM
    echo "Updated Formula/sumi.rb to $tag"
}

render_purr_cask() {
    repo="NekoLabStudio/purr"
    tag="$(latest_release_tag "$repo")"
    if [ -z "$tag" ]; then
        echo "No Purr release found; leaving cask unchanged."
        return
    fi

    version="${tag#v}"
    checksums="$(mktemp "${TMPDIR:-/tmp}/purr-checksums.XXXXXX")"
    trap 'rm -f "$checksums"' EXIT HUP INT TERM
    download_checksums "$repo" "$tag" "$checksums" "purr-$version-SHA256SUMS"

    editor="purr-$version-macos-editor.zip"
    editor_sha="$(checksum_for "$checksums" "$editor")"
    require_checksum "$editor_sha" "$editor"

    cat > "$cask_dir/purr.rb" <<CASK
cask "purr" do
  version "$version"
  sha256 "$editor_sha"

  url "https://github.com/$repo/releases/download/v#{version}/purr-#{version}-macos-editor.zip"
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
CASK

    rm -f "$checksums"
    trap - EXIT HUP INT TERM
    echo "Updated Casks/purr.rb to $tag"
}

render_sumi_formula
render_purr_cask
