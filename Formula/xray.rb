class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-macos-64.zip"
    sha256 "251c9455fd2793072d534e180eae60844d3ec05566c22009e7a7b8abf93371fc" # Intel
  else
    url "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-macos-arm64-v8a.zip"
    sha256 "3e060b08368c7739c71f27a9cc75e589953ebb7c5c729d85b4d99bcb9f8e7f34" # Apple Silicon
  end
  version "1.8.4"
  license "MPL-2.0"

  resource "config" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "3498e4b8b9b60e1019dfc62df6cfa3aaaef010712a4a56d788c0f11eda417791" # GeoIP
  end

  resource "geosite" do
    url "https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "9a2b8a7daa64d2d06663762492d4b5dd99a1790c0fa9d43f51e6db969180c0b0" # GeoSite
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
