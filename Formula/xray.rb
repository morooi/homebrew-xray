class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.11.9/Xray-macos-64.zip"
    sha256 "488963e676e06f5e48547f9dd38116aaca8de4234959b4272ae8f284e658dfd0" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.11.9/Xray-macos-arm64-v8a.zip"
    sha256 "233f0c66681cd0726f81a6b2b6ed6a5710869e312047b522e46ed53035bebd26" # Apple Silicon
  end
  
  version "26.11.9"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "652593778fff4e27404b56a9edab57fe2842ae86555727fe80e33712f69da99a" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "304ac8a1cbcc8166e4f5a4f32955e4d0fb77a1bd713583e371b30ee27f3659d8" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "6206c215d45f1acb663336b17a77ad5be62709680dc1ac2b2194121d6a1680f5" # GeoSite
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
