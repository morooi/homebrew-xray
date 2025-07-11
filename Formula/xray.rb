class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v25.6.8/Xray-macos-64.zip"
    sha256 "9e0e06914616700fc371cfb4f1978d697d943fc533e6e42dcfd498b5cde65fcd" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v25.6.8/Xray-macos-arm64-v8a.zip"
    sha256 "c0b4a420073a6e969c47f5ec843b0162db9eb85f37cb3f49ba905d8ae722a8d4" # Apple Silicon
  end
  version "25.6.8"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "842327f852ce0d1154bfad8d8c42ed27083fb252af83319028e632aa110c7b36" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "d71c33a6dc4cdef418e0a84ebd5e96f6cafdeb1ee80512347680395c0a6382c9" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "1670237c3065d4243fef52cd1efc4f96ca2eaf2b78a21a649e8fcbf3d13b2241" # GeoSite
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
