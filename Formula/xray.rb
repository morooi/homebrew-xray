class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.16/Xray-macos-64.zip"
    sha256 "1f0a9c7c7c30fe5f49a5385f28f9bf627c277672a9fbb37362fb70e70525d67b" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.16/Xray-macos-arm64-v8a.zip"
    sha256 "b0773f91bda8445571ab0d7ce04993c2759b046787359bee7c481695d6f6ff6e" # Apple Silicon
  end
  version "1.8.16"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "7cdf7331e9875e8d015b3f9d784dfb61444c35bf6198063d91be2798a2bf9639" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "b1be46d6a1ff8e078dd6ef27c55debd2a34b0baad7928eb2114bbb954c5eb4f9" # GeoSite
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
