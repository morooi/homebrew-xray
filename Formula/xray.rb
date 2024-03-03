class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.8/Xray-macos-64.zip"
    sha256 "c7f47b28a63300f44f513ee674f41d3d7e54616fa3e8933839c810e0b66929bf" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.8/Xray-macos-arm64-v8a.zip"
    sha256 "7e43142d6f0e8eb0f7b28a4e7aaf5f59a09f87facf2efc59a27fee0d22cb9ec3" # Apple Silicon
  end
  version "1.8.8"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "e57ec338292df5d00fdb33cf10a255c1d3c7f2d296cc7366ecac98ec94c5d376" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "351c9cd648239ac87b61868fae45f3fdc14c83db6c2ba9e3c71467dbb7fe3bc3" # GeoSite
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
