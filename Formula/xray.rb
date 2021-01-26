class Xray < Formula
  desc "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration."
  homepage "https://xtls.github.io/"
  if Hardware::CPU.intel?
    url "https://github.com/XTLS/Xray-core/releases/download/v1.2.3/Xray-macos-64.zip"
    sha256 "247a5a84c3aecd5b880108c1f7879d7795ad3dedb14eb9fd171dfa9637ba739c" # Intel
  else
    url "https://github.com/XTLS/Xray-core/releases/download/v1.2.3/Xray-macos-arm64-v8a.zip"
    sha256 "20959a819672f4f712f39906e041caf4e60c90bee2a0279d6cac6587d798dbed" # Apple Silicon
  end
  version "1.2.3"
  license "MPL-2.0"

  resource "config" do
    url "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-WHATEVER/config_client/vless_tcp_xtls.json"
    sha256 "1926e7e9bc7d84d8ef5783aec1dcd5c386b9c3e6cb36ad7adf880564d2ad7a77" # Config
  end

  resource "geoip" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat"
    sha256 "22d2e36eab00dde2346ecf9c9cff328d69e1084bf8157323126d64be84787d41" # GeoIP
  end

  resource "geosite" do
    url "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat"
    sha256 "6963ea663412768f4b9dcdb8d928e525ab6b7894ba2cf5de80241f8535e29bfd" # GeoSite
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

  plist_options manual: "xray run -c #{HOMEBREW_PREFIX}/etc/xray/config.json"

  def plist; 

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

  def caveats
  <<~EOS
    Create your config at #{etc}/xray/config.json
    You can get some example configs at https://github.com/XTLS/Xray-examples
  EOS
  end
end