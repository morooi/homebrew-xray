#!/bin/bash
set -Eeuo pipefail

TAGS_RESPONSE=$(mktemp)
trap 'rm -f "$TAGS_RESPONSE" Xray-macos-64.zip Xray-macos-arm64-v8a.zip config_client.json geoip.dat geosite.dat' EXIT

if ! curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors \
    -H 'Accept: application/vnd.github.v3+json' \
    'https://api.github.com/repos/XTLS/Xray-core/tags?per_page=100' \
    -o "$TAGS_RESPONSE"; then
    echo "failed to fetch Xray-core tags from GitHub" >&2
    exit 1
fi

V_TAG=$(jq -er 'first(.[] | .name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$")))' "$TAGS_RESPONSE") || {
    echo "failed to parse a stable Xray-core version from GitHub tags" >&2
    exit 1
}
V_VERSION="${V_TAG#v}"

echo "latest version: $V_VERSION"

if grep -q "version \"$V_VERSION\"" Formula/xray.rb; then
    COMMIT_MESSAGE="Automated update resources"
else
    COMMIT_MESSAGE="Automated update xray-core version v$V_VERSION"
fi

echo "parser xray download url"
echo ""

INTEL_DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/v${V_VERSION}/Xray-macos-64.zip"
APPLE_SILICON_DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/v${V_VERSION}/Xray-macos-arm64-v8a.zip"

echo "Intel version download url: $INTEL_DOWNLOAD_URL"
echo "Apple Silicon version download url: $APPLE_SILICON_DOWNLOAD_URL"
echo ""
echo "start downloading..."

download() {
    local url="$1"
    local output="$2"
    local description="$3"

    if ! curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors "$url" -o "$output"; then
        echo "$description download failed!" >&2
        exit 1
    fi
}

download "$INTEL_DOWNLOAD_URL" Xray-macos-64.zip "Intel version file"
download "$APPLE_SILICON_DOWNLOAD_URL" Xray-macos-arm64-v8a.zip "Apple Silicon version file"
download "https://raw.githubusercontent.com/XTLS/Xray-examples/main/VLESS-TCP-XTLS-Vision/config_client.jsonc" config_client.json "Config file"
download "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat" geoip.dat "geoip.dat"
download "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat" geosite.dat "geosite.dat"

INTEL_V_HASH256=$(sha256sum Xray-macos-64.zip | awk '{print $1}')
APPLE_SILICON_V_HASH256=$(sha256sum Xray-macos-arm64-v8a.zip | awk '{print $1}')
CONFIG_V_HASH256=$(sha256sum config_client.json | awk '{print $1}')
GEOIP_V_HASH256=$(sha256sum geoip.dat | awk '{print $1}')
GEOSITE_V_HASH256=$(sha256sum geosite.dat | awk '{print $1}')

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

if git diff --quiet -- Formula/xray.rb; then
    echo "No Formula changes detected."
    exit 0
fi

git add Formula/xray.rb
git commit -m "$COMMIT_MESSAGE"
git push

echo "update repo done."
