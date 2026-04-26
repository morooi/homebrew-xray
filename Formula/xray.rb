class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.4.25/Xray-macos-64.zip"
    sha256 "fde231da0e7edd29d7a7b51fee13cae2fa05dfc6583f31a15945d5c3302aedf5" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.4.25/Xray-macos-arm64-v8a.zip"
    sha256 "b9d5df9f37e482f17289b105341218aaa614363a29ebb2b6054805e5396d50fe" # Apple Silicon
  end
  
  version "26.4.25"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "652593778fff4e27404b56a9edab57fe2842ae86555727fe80e33712f69da99a" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "b4120c887f2c812e5f57551c83417ec6f668ee16999cb2c620221d0c063ccdf4" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "27f9ddad030a1cddda4505badff25b6a27356ea0cb4451ebf0d79c172e96a24d" # GeoSite
  end

  def install
    libexec.install "xray"

    execpath = libexec/name
    (bin/"xray").write_env_script execpath,
      XRAY_LOCATION_ASSET: "${XRAY_LOCATION_ASSET:-#{pkgshare}}"

    resource("config").stage do
      pkgetc.install "config_client.jsonc" => "config.jsonc"
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
      Create your config at #{etc}/xray/config.jsonc
      You can get some example configs at https://github.com/XTLS/Xray-examples
    EOS
  end

  service do
    run [opt_bin/"xray", "run", "--config", "#{etc}/xray/config.jsonc"]
    run_type :immediate
    keep_alive true
  end

  test do
    system "#{bin}/xray", "version"
  end
end
