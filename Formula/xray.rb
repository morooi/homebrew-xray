class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.8.3/Xray-macos-64.zip"
    sha256 "924b2c314691ca0e5727ba08833b7114f9b0fed72aaefbfdc983d4019fcb9098" # Intel
  else
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.8.3/Xray-macos-arm64-v8a.zip"
    sha256 "7b51481061906293757cebbe4aa5393de43a25c4f2006ba2f0759b4789842bdd" # Apple Silicon
  end
  version "1.8.3"
  license "MPL-2.0"

  resource "config" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "75f23f19e2e8f5aa23a0b1c8fdd3024119b0e94acf8c66ddef8aa6aeb2c986de" # GeoIP
  end

  resource "geosite" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "8cbe5aa1e46a2908fd0ef3b95c77d6f3170818f22dcf21647f308e777e481393" # GeoSite
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
