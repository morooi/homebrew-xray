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

  def install
    bin.install "xray"    
    pkgshare.install "geoip.dat"
    pkgshare.install "geosite.dat"
    (etc/"xray").mkpath
  end

  plist_options manual: "xray run -c #{HOMEBREW_PREFIX}/etc/xray/config.json"

  def plist; 

  <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
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