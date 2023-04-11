class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.8.0/Xray-macos-64.zip"
    sha256 "533dec8374985618e7e86673f677bc8b68d462c3a870edf4635b8c42d3db7819" # Intel
  else
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.8.0/Xray-macos-arm64-v8a.zip"
    sha256 "d9ad6bd2ca14096fc6f8beb9bee0760826deb330dd8e9e8b07f285bece979972" # Apple Silicon
  end
  version "1.8.0"
  license "MPL-2.0"

  resource "config" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "c0a628104fcc8571d3fd24b38065fa9397e9ecff15e2dcc187aae5a9a0642aa8" # GeoIP
  end

  resource "geosite" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "5102b9126efeda68d1b0ad0dfdd782ba2145ca6b4bb88860f34c061ddaed6975" # GeoSite
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
