class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.5.3/Xray-macos-64.zip"
    sha256 "16f5e4ac0c6d9c34478300a7ba80a196f2ab3f75a3cd3c68cd3c5fac67a652a0" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.5.3/Xray-macos-arm64-v8a.zip"
    sha256 "acd4e716b635e57dc43d13f98a08d08cf5fb39708b473457d7c401fd6b156631" # Apple Silicon
  end
  version "1.5.3"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-WHATEVER/config_client/vless_tcp_xtls.json"
    sha256 "1926e7e9bc7d84d8ef5783aec1dcd5c386b9c3e6cb36ad7adf880564d2ad7a77" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "1fc3066e5ae02b7bcf1fcd34314ef8212acc98492cbd5453eda6edf12fe37e6a" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "cd975af961ae8f13e3aeb2ad388f7f0b0f2201e3250bbe6bf1e66a20bc27372d" # GeoSite
  end

  def install
    bin.install "xray"

    resource("config").stage do
      pkgetc.install "vless_tcp_xtls.json" => "config.json"
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

  plist_options manual: "xray run -c #{HOMEBREW_PREFIX}/etc/xray/config.json"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>KeepAlive</key>
          <true/>
          <key>RunAtLoad</key>
          <true/>
          <key>ProgramArguments</key>
          <array>
            <string>#{bin}/xray</string>
            <string>run</string>
            <string>-c</string>
            <string>#{etc}/xray/config.json</string>
          </array>
        </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/xray", "version"
  end
end
