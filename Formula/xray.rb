class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration"
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.4.5/Xray-macos-64.zip"
    sha256 "9ee1074559ae4e8b54d22c4dfab502982482b0915d5f73b5bda9c201c1d127b3" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.4.5/Xray-macos-arm64-v8a.zip"
    sha256 "e9464eca14fad3c728d474fd890f1fb8b45a52fac4e4e01cfc6bf0a56a77251f" # Apple Silicon
  end
  version "1.4.5"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-WHATEVER/config_client/vless_tcp_xtls.json"
    sha256 "1926e7e9bc7d84d8ef5783aec1dcd5c386b9c3e6cb36ad7adf880564d2ad7a77" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "23f3da8013a3411635227440addcdb817960d3de8128ea6925894d58104aca97" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "96a203454dcd9ce271a95c384a9afcc01ab8b8cd363ae3bf37faa163af844923" # GeoSite
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
