#!/bin/bash
# Builds Meta's Muse gadget firmware for the Waveshare ESP32-S3-Touch-AMOLED-1.8
# inside WSL Ubuntu, then copies what esptool needs back to Windows.
#
# Run from Windows (cmd), in the muse-flash folder:
#     wsl -d Ubuntu-24.04 -u root -- bash build.sh
#
# The SDK checkout (branch charm) is the source of truth: edit there. By default
# it's the muse-gadget-sdk folder next to this one; set MUSE_SDK to use another.
# It's copied into Linux to build, because building on /mnt/c is very slow.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
WIN_SDK=${MUSE_SDK:-$HERE/../muse-gadget-sdk}
OUT=$HERE/firmware
SDK=/root/muse-gadget-sdk
BUILD=build-muse-waveshare-s3-18

echo "== copying the SDK into Linux"
mkdir -p "$SDK"
rsync -a --delete --exclude 'build*/' --exclude 'managed_components/' \
    --exclude '.git/' "$WIN_SDK/" "$SDK/"

echo "== adding our settings (sdkconfig.local)"
PROFILE="$SDK/esp32/devices/sdkconfig.muse-waveshare-s3-18"
{ echo; tr -d '\r' < "$HERE/sdkconfig.local"; } >> "$PROFILE"
# The TTS relay's URL and token: private, never committed (see README.md)
SECRETS=$HERE/secrets.local
if [ -f "$SECRETS" ]; then
    { echo; tr -d '\r' < "$SECRETS"; } >> "$PROFILE"
else
    echo "(no secrets.local: replies stay text-only)"
fi
# The profile only applies to a fresh sdkconfig, so drop the last build's
rm -f "$SDK/esp32/$BUILD/sdkconfig"

echo "== building (a few minutes the first time)"
. /root/esp/esp-idf-v6.0.3/export.sh >/dev/null 2>&1
cd "$SDK/esp32"
bash tools/muse/board.sh build s3-18
if grep -qE '^CONFIG_MUSE_TTS_RELAY_URL="https://' "$BUILD/sdkconfig"; then
    echo "Spoken replies: ON (TTS relay set)"
else
    echo "Spoken replies: OFF (no TTS relay URL)"
fi

echo "== copying the firmware to Windows"
rm -rf "$OUT"
mkdir -p "$OUT"
cp "$BUILD/flash_args" "$OUT/"
# flash_args lists "<address> <file>" pairs after the option lines
grep -E '^0x' "$BUILD/flash_args" | while read -r _ f; do
    mkdir -p "$OUT/$(dirname "$f")"
    cp "$BUILD/$f" "$OUT/$f"
done
echo "Firmware ready in $OUT:"
cat "$OUT/flash_args"
