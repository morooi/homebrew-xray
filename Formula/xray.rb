class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.10.31/Xray-macos-64.zip"
    sha256 "37c60b63c77ef5edcfb46a0d70349f7d96e0c132e6a356ead4fd20aeeacc5c75" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.10.31/Xray-macos-arm64-v8a.zip"
    sha256 "0a05dca3bd311b0bc5a89c7ce56350cab1e829e131e4b2bcd48eb304fac07e9a" # Apple Silicon
  end
  
  version "26.10.31"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "652593778fff4e27404b56a9edab57fe2842ae86555727fe80e33712f69da99a" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "90b78ab861c1cdc3f871f305f9ceedfb8d6d6329e3a40295e6773e057297384c" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "975ed7bfec972ed42cc9aaf36edbd25e247cfc0d75e05663162d03e613bd8095" # GeoSite
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
