#!/bin/bash

loop_parser(){
    while true
    do
        result=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/xtls/xray-core/releases/latest | grep "$1" | cut -d '"' -f 4)
        if [ -n "$result" ]; then
            echo "$result"
            break
        fi
    done
}

V_VERSION=$( loop_parser "tag_name" )
V_VERSION="${V_VERSION:1}"

echo "latest version: $V_VERSION"

if grep -q "version \"$V_VERSION\"" xray.rb; then
    exit 0
fi

echo "parser xray download url"
echo ""

INTEL_DOWNLOAD_URL=$( loop_parser 'browser_download_url.*macos-64.zip"$' )
APPLE_SILICON_DOWNLOAD_URL=$( loop_parser 'browser_download_url.*macos-arm64-v8a.zip"$' )

echo "Intel version download url: $INTEL_DOWNLOAD_URL"
echo "Apple Silicon version download url: $APPLE_SILICON_DOWNLOAD_URL"
echo ""
echo "start downloading..."

curl -s -L "$INTEL_DOWNLOAD_URL" > Xray-macos-64.zip || { echo 'Intel version file download failed!' ; exit 1; }
curl -s -L "$APPLE_SILICON_DOWNLOAD_URL" > Xray-macos-arm64-v8a.zip || { echo 'Apple Silicon version file download failed!' ; exit 1; }

if [ ! -e Xray-macos-64.zip ]; then
    echo "Intel version file download failed!"
    exit 1
fi

if [ ! -e Xray-macos-arm64-v8a.zip ]; then
    echo "Apple Silicon version file download failed!"
    exit 1
fi

INTEL_V_HASH256=$(sha256sum Xray-macos-64.zip |cut  -d ' ' -f 1)
APPLE_SILICON_V_HASH256=$(sha256sum Xray-macos-arm64-v8a.zip |cut  -d ' ' -f 1)

echo "update xray.rb...."

sed -i "s#^\s*url.*-64.*#    url \"$INTEL_DOWNLOAD_URL\"#g" Formula/xray.rb
sed -i "s#^\s*sha256.*Intel#    sha256 \"$INTEL_V_HASH256\" \# Intel#g" Formula/xray.rb

sed -i "s#^\s*url.*-arm64.*#    url \"$APPLE_SILICON_DOWNLOAD_URL\"#g" Formula/xray.rb
sed -i "s#^\s*sha256.*Silicon#    sha256 \"$APPLE_SILICON_V_HASH256\" \# Apple Silicon#g" Formula/xray.rb

sed -i "s#^\s*version.*#  version \"$V_VERSION\"#g" Formula/xray.rb

echo "update config done. start update repo..."
echo ""

git config --local user.name "actions"
git config --local user.email "action@github.com"
git commit -am "Automated update xray-core version v$V_VERSION"
git push

echo "update repo done."