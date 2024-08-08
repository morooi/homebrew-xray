class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.23/Xray-macos-64.zip"
    sha256 "b79ab58edd1a68e6ad49995a7bff9ce06b827868272c75c25cca809ea626ec11" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.8.23/Xray-macos-arm64-v8a.zip"
    sha256 "2e32455826a3be797cfa589a0a63760ef0090a61fde05b9bd76f744d6e05064c" # Apple Silicon
  end
  version "1.8.23"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "6c617c0fae4200f4df241cc184d0de15e9845e448aa6b27bbfe807daef6498e6" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "0f3e92e8b7877c1957f57ecc46bef5926dddbb35f24642967c786517d0d924d9" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "469ec89f2f10cd769f43c9d20b98064ef34a743a0feaf9a814887688d3dbf3e0" # GeoSite
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
