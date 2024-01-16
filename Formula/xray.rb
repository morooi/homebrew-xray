class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.7/Xray-macos-64.zip"
    sha256 "f4bb203eac32d203bdf7b4576bd7a29fdece38b653379ae6b6cf456dea8bb1f1" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.7/Xray-macos-arm64-v8a.zip"
    sha256 "95ae44b16907c8f9f8a123d454b92caf04a4686ac950d422f3909545a79f2149" # Apple Silicon
  end
  version "1.8.7"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "0fa8fba8668701bf2a1e7d6baec817899a6dc2ec8f7976d3cfd836263236319d" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "e2747c9943877035e3fa2954d8d7ae12a352e266f0d5c603ff73d9a0872b4052" # GeoSite
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
