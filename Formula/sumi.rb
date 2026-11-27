class Sumi < Formula
  desc "Launcher for a static site generator for personal websites"
  homepage "https://oss.nekolab.studio/sumi"
  url "https://github.com/NekoLabStudio/sumi/releases/download/v2.4.1/sumi-v2.4.1",
      using: :nounzip
  version "2.4.1"
  sha256 "ba60fa547b6a486a0803486a576b30e8e657e8b0bcf2e74b2f904bf8a3776853"
  license "MIT"

  def install
    bin.install cached_download => "sumi"
  end

  test do
    assert_match "Sumi launcher", shell_output("#{bin}/sumi --help")
  end
end
