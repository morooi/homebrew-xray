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
    sha256 "29a42845fc17040cec8e073bbaeb201c128c5e15f7732ede0804e298dae92b24" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "599928c8b4884851f8ffe99ad3d6b1741c6831558b8e33b1cfe847ce39888d2c" # GeoSite
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
