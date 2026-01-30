class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.1.23/Xray-macos-64.zip"
    sha256 "2e88e9043c8d890f34c9aad165ec31e6622578aa3915410eef2da9260a17531a" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.1.23/Xray-macos-arm64-v8a.zip"
    sha256 "fe485185961202507fa6750da0aa453075349adf11569e658bbce2ee0f385d94" # Apple Silicon
  end
  
  version "26.1.23"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "b9544e3e04eaa911b7235bdad6f4ee8942aca5341400b62b34c6876b36fc618b" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "84d9b4d8e6e01b815e2f9a7dcb950d30aeb73adc0c7383188f48c34b740ad1ae" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "918ee40cd99620eb69e1ef805e3bdf6b9fca59e7f597c42480001be861e46ddb" # GeoSite
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
