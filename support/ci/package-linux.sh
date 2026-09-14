#!/usr/bin/env bash
# New fork packaging script. Keep upstream source and license notices.
set -euo pipefail
version=$(sed -n 's/^version: \([^+]*\).*/\1/p' app/pubspec.yaml)
bundle="app/build/linux/${BUILD_ARCH}/release/bundle"
test -x "$bundle/sendy"
mkdir -p artifacts
cp LICENSE "$bundle/LICENSE.txt"
cp NOTICE "$bundle/NOTICE.txt"
tar -C "$bundle" -czf "artifacts/Sendy-${version}-linux-${BUILD_ARCH}.tar.gz" .
root="$RUNNER_TEMP/deb-root"
mkdir -p "$root/DEBIAN" "$root/opt/sendy" "$root/usr/bin" "$root/usr/share/applications" "$root/usr/share/icons/hicolor/512x512/apps" "$root/usr/share/doc/sendy"
cp -a "$bundle/." "$root/opt/sendy/"
ln -s /opt/sendy/sendy "$root/usr/bin/sendy"
cp app/assets/img/logo-512.png "$root/usr/share/icons/hicolor/512x512/apps/sendy.png"
cp LICENSE "$root/usr/share/doc/sendy/copyright"
cp NOTICE "$root/usr/share/doc/sendy/NOTICE"
cat > "$root/DEBIAN/control" <<EOF
Package: sendy
Version: $version
Architecture: $DEB_ARCH
Maintainer: Metoushela Walker <noreply@example.invalid>
Section: net
Priority: optional
Installed-Size: $(du -sk "$root/opt/sendy" | cut -f1)
Depends: libc6 (>= 2.35), libstdc++6, libgtk-3-0, libayatana-appindicator3-1, libsecret-1-0, xdg-user-dirs
Description: Local network file sharing application
 Independent Sendy build based on the LocalSend open-source project.
EOF
cat > "$root/usr/share/applications/sendy.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Sendy
Exec=sendy
Icon=sendy
Terminal=false
Categories=Network;FileTransfer;
EOF
chmod 0755 "$root/DEBIAN"
dpkg-deb --root-owner-group --build "$root" "artifacts/Sendy-${version}-linux-${BUILD_ARCH}.deb"
dpkg-deb --info "artifacts/Sendy-${version}-linux-${BUILD_ARCH}.deb"
