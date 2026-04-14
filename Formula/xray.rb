class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  
  on_intel do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.4.13/Xray-macos-64.zip"
    sha256 "83b05b71b71b5ec32fb4c6bd6226b52ac7f79a9f24ec36034259203aa1ce2682" # Intel
  end

  on_arm do
    url "https://github.com/XTLS/Xray-core/releases/download/v26.4.13/Xray-macos-arm64-v8a.zip"
    sha256 "cc43878bac43620f1f93482db1e9b12eacdfa2d9a76938465e7eb66286bd618c" # Apple Silicon
  end
  
  version "26.4.13"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc"
    sha256 "b9544e3e04eaa911b7235bdad6f4ee8942aca5341400b62b34c6876b36fc618b" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "de99b639b3c9c9ec585cbb20c340c06d28580548aecf7c231f58d6cc2b101405" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "d751373c879ab44e8d60d3c7f49334e868816e428a6950d94068ae69cdfcdef8" # GeoSite
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
