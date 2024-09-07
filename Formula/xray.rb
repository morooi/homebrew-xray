class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v24.9.7/Xray-macos-64.zip"
    sha256 "c3fc924eadfe558de87d668094a94df939d60facc2caab4aaa6d087b1d3672b9" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v24.9.7/Xray-macos-arm64-v8a.zip"
    sha256 "3eb5cf4c4b801fed2d383bf7db9efad7df393ee30b7a66645c3589db3fd67863" # Apple Silicon
  end
  version "24.9.7"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "5f1aa31e6f620dd5b02589a6d41900894c05c32b880591640e36a51ca8e561ef" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "e38b9a06f26ef9113883f833232921c31f856d1816c7117a9b5f8f83d9bd698e" # GeoSite
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
