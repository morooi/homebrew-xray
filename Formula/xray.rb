class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.7.3/Xray-macos-64.zip"
    sha256 "80bab2290da7841ee499287954f9383abc4771bd4e1f7c81060d14e7af5ed9d1" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.7.3/Xray-macos-arm64-v8a.zip"
    sha256 "cad06e5a3029671d79178d8954055e6d27a6a95bda525b99d00175a86a0fc743" # Apple Silicon
  end
  version "1.7.3"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-WHATEVER/config_client/vless_tcp_xtls.json"
    sha256 "1926e7e9bc7d84d8ef5783aec1dcd5c386b9c3e6cb36ad7adf880564d2ad7a77" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "b76839ef53aa05e000bad8efa78ddf433eea8df427c0bafac42c8a6e7f2ac821" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "87848a020c48ca5c7489b323fdb78654b23485ed7e467d257671405d0891ec76" # GeoSite
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
