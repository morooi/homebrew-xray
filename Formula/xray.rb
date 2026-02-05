class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.2.4/Xray-macos-64.zip"
    sha256 "410030cec7aee65c40cf32d632bfc1853b1107aa61cef2f94e497bc770968517" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.2.4/Xray-macos-arm64-v8a.zip"
    sha256 "e3997d6151fd868ac887c22694f758b00e949ecf517120715c2618f263a6458f" # Apple Silicon
  end
  
  version "26.2.4"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "b9544e3e04eaa911b7235bdad6f4ee8942aca5341400b62b34c6876b36fc618b" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "8cf3dac7d99e428a380bd3aa1330f57718a794d45fe4f9dd20077c010dc0bcdb" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "1cef268aba784cf84196b6576698c0308e6e8bde8bc27a3e7d5b7c4983e06bf8" # GeoSite
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
