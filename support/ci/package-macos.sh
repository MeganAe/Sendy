#!/usr/bin/env bash
# New fork packaging script. Ad-hoc signing is NOT Developer ID/notarization.
set -euo pipefail
version=$(sed -n 's/^version: \([^+]*\).*/\1/p' app/pubspec.yaml)
app=$(find app/build/macos/Build/Products/Release -maxdepth 1 -name '*.app' -type d -print -quit)
test -n "$app"
executable=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "$app/Contents/Info.plist")
lipo -verify_arch "$BUILD_ARCH" "$app/Contents/MacOS/$executable"
# For this unsigned fork, remove the team-dependent app group entitlement.
# Keep network and file-access sandbox entitlements for local transfers.
python3 - "$RUNNER_TEMP/entitlements.plist" <<'PY'
import plistlib, sys
with open('app/macos/Runner/Release.entitlements','rb') as f:
    data=plistlib.load(f)
data.pop('com.apple.security.application-groups', None)
with open(sys.argv[1], 'wb') as f:
    plistlib.dump(data,f)
PY
# The upstream share extension requires the original team's application group.
# Exclude it from unsigned test packages; restore after configuring our own team.
rm -rf "$app/Contents/PlugIns"
cp LICENSE "$app/Contents/Resources/LICENSE.txt"
cp NOTICE "$app/Contents/Resources/NOTICE.txt"
codesign --force --deep --sign - --entitlements "$RUNNER_TEMP/entitlements.plist" "$app"
codesign --verify --deep --strict "$app"
mkdir -p artifacts "$RUNNER_TEMP/dmg-root"
ditto "$app" "$RUNNER_TEMP/dmg-root/$(basename "$app")"
ln -s /Applications "$RUNNER_TEMP/dmg-root/Applications"
hdiutil create -volname Sendy -srcfolder "$RUNNER_TEMP/dmg-root" -ov -format UDZO "artifacts/Sendy-${version}-macos-${BUILD_ARCH}.dmg"
pkgbuild --component "$app" --install-location /Applications --identifier app.sendy.transfer.installer --version "$version" "artifacts/Sendy-${version}-macos-${BUILD_ARCH}.pkg"
hdiutil verify "artifacts/Sendy-${version}-macos-${BUILD_ARCH}.dmg"
