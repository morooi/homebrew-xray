#!/bin/bash

V_VERSION=$(curl -s -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/XTLS/Xray-core/tags | grep -Eom 1 'v[0-9]+\.[0-9]+\.[0-9]+')
V_VERSION="${V_VERSION:1}"

echo "latest version: $V_VERSION"

if grep -q "version \"$V_VERSION\"" Formula/xray.rb; then
    echo "It is already the latest version!"
    ALREADY_LATEST="true"
fi

echo "parser xray download url"
echo ""

INTEL_DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/v${V_VERSION}/Xray-macos-64.zip"
APPLE_SILICON_DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/v${V_VERSION}/Xray-macos-arm64-v8a.zip"

echo "Intel version download url: $INTEL_DOWNLOAD_URL"
echo "Apple Silicon version download url: $APPLE_SILICON_DOWNLOAD_URL"
echo ""
echo "start downloading..."

curl -s -L "$INTEL_DOWNLOAD_URL" > Xray-macos-64.zip || { echo 'Intel version file download failed!' ; exit 1; }
curl -s -L "$APPLE_SILICON_DOWNLOAD_URL" > Xray-macos-arm64-v8a.zip || { echo 'Apple Silicon version file download failed!' ; exit 1; }
curl -s -L "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-WHATEVER/config_client/vless_tcp_xtls.json" > vless_tcp_xtls.json || { echo 'Config file download failed!' ; exit 1; }
curl -s -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat" > geoip.dat || { echo 'geoip.dat download failed!' ; exit 1; }
curl -s -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat" > geosite.dat || { echo 'geosite.dat download failed!' ; exit 1; }

if [ ! -e Xray-macos-64.zip ]; then
    echo "Intel version file download failed!"
    exit 1
fi

if [ ! -e Xray-macos-arm64-v8a.zip ]; then
    echo "Apple Silicon version file download failed!"
    exit 1
fi

if [ ! -e vless_tcp_xtls.json ]; then
    echo "Config file download failed!"
    exit 1
fi

if [ ! -e geoip.dat ]; then
    echo "geoip.dat download failed!"
    exit 1
fi

if [ ! -e geosite.dat ]; then
    echo "geosite.dat download failed!"
    exit 1
fi

INTEL_V_HASH256=$(sha256sum Xray-macos-64.zip | cut  -d ' ' -f 1)
APPLE_SILICON_V_HASH256=$(sha256sum Xray-macos-arm64-v8a.zip | cut  -d ' ' -f 1)
CONFIG_V_HASH256=$(sha256sum vless_tcp_xtls.json | cut  -d ' ' -f 1)
GEOIP_V_HASH256=$(sha256sum geoip.dat | cut  -d ' ' -f 1)
GEOSITE_V_HASH256=$(sha256sum geosite.dat | cut  -d ' ' -f 1)

echo "update xray.rb...."

sed -i "s#^\s*url.*-64.*#    url \"$INTEL_DOWNLOAD_URL\"#g" Formula/xray.rb
sed -i "s#^\s*sha256.*Intel#    sha256 \"$INTEL_V_HASH256\" \# Intel#g" Formula/xray.rb

sed -i "s#^\s*url.*-arm64.*#    url \"$APPLE_SILICON_DOWNLOAD_URL\"#g" Formula/xray.rb
sed -i "s#^\s*sha256.*Silicon#    sha256 \"$APPLE_SILICON_V_HASH256\" \# Apple Silicon#g" Formula/xray.rb

sed -i "s#^\s*sha256.*Config#    sha256 \"$CONFIG_V_HASH256\" \# Config#g" Formula/xray.rb
sed -i "s#^\s*sha256.*GeoIP#    sha256 \"$GEOIP_V_HASH256\" \# GeoIP#g" Formula/xray.rb
sed -i "s#^\s*sha256.*GeoSite#    sha256 \"$GEOSITE_V_HASH256\" \# GeoSite#g" Formula/xray.rb

sed -i "s#^\s*version.*#  version \"$V_VERSION\"#g" Formula/xray.rb

echo "update config done. start update repo..."
echo ""

git config --local user.name "actions"
git config --local user.email "action@github.com"

if [ $ALREADY_LATEST ]; then
    git commit -am "Automated update resources"
else
    git commit -am "Automated update xray-core version v$V_VERSION"
fi
git push

echo "update repo done."
