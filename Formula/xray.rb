class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v24.9.30/Xray-macos-64.zip"
    sha256 "1407dd2e2e4c916a033bf5eda60f5e3f541ae70fe4b90e7275d15ffc6ad18fcb" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v24.9.30/Xray-macos-arm64-v8a.zip"
    sha256 "06ba2ad4918d61f09583cb9ec6083e5fbf3b27a62da2103c96e6c7e3c0a142ee" # Apple Silicon
  end
  version "24.9.30"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "805b7fd9f5d0a6ea1870a5cafbaf6ab7e6a1f9ebb735b35a8d9ff3863d6f5f3d" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "eda4392cd829a7dcb017e7b8f1ff20290408f04058aca31a7bae541549aae799" # GeoSite
  end

  def install
    bin.install "xray"

    resource("config").stage do
      pkgetc.install "config_client.json" => "config.json"
    end

    resource("geoip").stage do
      pkgshare.install "geoip.dat"
    end

    resource("geosite").stage do
      pkgshare.install "geosite.dat"
    end
  end

  def caveats
    <<~EOS
      Create your config at #{etc}/xray/config.json
      You can get some example configs at https://github.com/XTLS/Xray-examples
    EOS
  end

  service do
    run [opt_bin/"xray", "run", "--config", "#{etc}/xray/config.json"]
    run_type :immediate
    keep_alive true
  end

  test do
    system "#{bin}/xray", "version"
  end
end
