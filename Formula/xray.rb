class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v24.10.16/Xray-macos-64.zip"
    sha256 "1df2d1fd50c386d51ba36825dd19fc976c74f76d392d0da4b247f8018216be39" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v24.10.16/Xray-macos-arm64-v8a.zip"
    sha256 "25c0f5a7a907edae6fe287387a55f9d7c5ce42cf0739b8c6bdf086b9770d9341" # Apple Silicon
  end
  version "24.10.16"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.json"
    sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "349b0189bb2c79a24eb1df48da85255152b8c21af74485aa4582b7e34ea59ea8" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "7200ff26f0ac928520ad1dd2f108989cfd249d57c19c180e0b4f7f81b86c4338" # GeoSite
  end

  def install
    libexec.install "xray"

    execpath = libexec/name
    (bin/"xray").write_env_script execpath,
      XRAY_LOCATION_ASSET: "${XRAY_LOCATION_ASSET:-#{pkgshare}}"

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
