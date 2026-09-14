"""Fast standard-library checks: active packaging must not install as LocalSend."""
import json
from pathlib import Path
import re
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
brand = json.loads((ROOT / 'support/branding/sendy.json').read_text())
errors = []
def check(condition, message):
    if not condition: errors.append(message)
def text(path): return (ROOT/path).read_text()

check(f'applicationId "{brand["application_id"]}"' in text('app/android/app/build.gradle'), 'Android applicationId mismatch')
check('android:label="LocalSend"' not in text('app/android/app/src/main/AndroidManifest.xml'), 'Android still uses upstream display name')
for platform in ['windows','linux']:
    check('set(BINARY_NAME "sendy")' in text(f'app/{platform}/CMakeLists.txt'), f'{platform} binary name mismatch')
check(f'set(APPLICATION_ID "{brand["application_id"]}")' in text('app/linux/CMakeLists.txt'), 'Linux GTK ID mismatch')
check('"localsend_msix_helper.msix"' not in text('app/windows/CMakeLists.txt'), 'Do not ship upstream MSIX helper')
check('PRODUCT_NAME = Sendy' in text('app/macos/Runner/Configs/AppInfo.xcconfig'), 'macOS product mismatch')
check(f'PRODUCT_BUNDLE_IDENTIFIER = {brand["application_id"]}' in text('app/macos/Runner/Configs/AppInfo.xcconfig'), 'macOS bundle mismatch')
check('AppId={{'+brand['inno_app_id']+'}' in text('support/ci/sendy.iss'), 'Installer GUID mismatch')
check('DefaultDirName={localappdata}\\Programs\\Sendy' in text('support/ci/sendy.iss'), 'Installer directory mismatch')
check('app.sendy.transfer.installer' in text('support/ci/package-macos.sh'), 'PKG ID mismatch')
check('Package: sendy' in text('support/ci/package-linux.sh'), 'DEB package mismatch')
check("_windowsRegistryKeyValue = 'Sendy'" in text('app/lib/util/native/autostart_helper.dart'), 'Autostart would conflict with upstream')
check("_windowsFileName = 'Sendy'" in text('app/lib/util/native/context_menu_helper.dart'), 'SendTo would conflict with upstream')
for p in (ROOT/'app/assets/i18n').glob('*.json'):
    data=json.loads(p.read_text())
    if 'appName' in data: check(data['appName']=='Sendy',f'Unbranded locale: {p.name}')
for p in (ROOT/'app/android/app/src').rglob('*.xml'):
    ET.parse(p)
version=re.search(r'^version: ([^+]+)',text('app/pubspec.yaml'),re.M).group(1)
check(f'#define MyAppVersion "{version}"' in text('support/ci/sendy.iss'), 'Default Inno version differs from pubspec')
for relative,size in [('app/assets/img/logo-512.png',512),('app/assets/img/logo-128.png',128)]:
    png=(ROOT/relative).read_bytes()
    check(png[:8]==b'\x89PNG\r\n\x1a\n',f'Invalid PNG: {relative}')
    check(struct.unpack('>II',png[16:24])==(size,size),f'Wrong PNG dimensions: {relative}')
for relative in ['app/windows/runner/resources/app_icon.ico','app/assets/packaging/logo.ico']:
    check((ROOT/relative).read_bytes()[:4]==b'\0\0\1\0',f'Invalid ICO: {relative}')
check('Apache License' in text('LICENSE'),'Original license missing')
check('independent derivative' in text('NOTICE'),'Attribution notice missing')
check("'Sendy', 'settings.json'" in text('app/lib/config/sendy/sendy_identity.dart'), 'Settings must belong to Sendy')
check('_windowsLegacyFile' not in text('app/lib/provider/persistence_provider.dart'), 'Do not read upstream legacy settings')
check('deleteSync' not in text('app/lib/provider/persistence_provider_migrations.dart'), 'Migrations must not delete legacy directories')
check("'sendy-settings.json'" in text('app/lib/util/shared_preferences/shared_preferences_portable.dart'), 'Portable settings must be isolated')
check('port: localsend::multicast::DEFAULT_PORT,' in text('packages/localsend_isolates/rust/src/api/discovery.rs'), 'Discovery and HTTP must not share a configurable port')
check('AppPublisher=Metoushela Walker' in text('support/ci/sendy.iss'), 'Publisher must be Metoushela Walker')
check("defaultColorMode = 'yaru'" in text('app/lib/config/sendy/sendy_identity.dart'), 'Yaru must be the default')
if errors:
    raise SystemExit('\n'.join(errors))
print(f'Sendy {version}: application IDs, active installers, localizations, XML, icons and license checks passed.')
