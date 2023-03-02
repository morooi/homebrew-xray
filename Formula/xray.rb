class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v/Xray-macos-64.zip"
    sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5" # Intel
  else
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v/Xray-macos-arm64-v8a.zip"
    sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5" # Apple Silicon
  end
  version ""
  license "MPL-2.0"

  resource "config" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "82eeed3f5622f68ead92854f132631a02c7829b6e7e07ec3482dd077c55e41df" # Config
  end

  resource "geoip" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "357e374f16e336c749516566ba9f0bdeef24eccc013769699fe41cfad149711f" # GeoIP
  end

  resource "geosite" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "d83d373324f3d2e2385e5a0dd6fc97117bfff792c36bad274aecaa148138e7c3" # GeoSite
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
