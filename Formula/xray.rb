class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.2.6/Xray-macos-64.zip"
    sha256 "2baa1914c3ff93f66801e93556c9562099f469f812c9cff3dc7aff8aedda9f1b" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.2.6/Xray-macos-arm64-v8a.zip"
    sha256 "fb37ff97474d3dd7dacdc9e244bd1786b1f15ff8f2b0a5d6fd4d0f0c34dc295e" # Apple Silicon
  end
  
  version "26.2.6"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "b9544e3e04eaa911b7235bdad6f4ee8942aca5341400b62b34c6876b36fc618b" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "3a00706e0268ed8381e7a2615b5c46f6c8bae329bde77811427aa6fb4bc45cb1" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "9c65b8ca2b88a72a5a69403499d8bed7d0f2acfcf4339643600e569fd18abad1" # GeoSite
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
