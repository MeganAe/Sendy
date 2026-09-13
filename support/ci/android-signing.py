"""Fork CI: configure a private release key or an explicitly temporary test key."""
import base64
import os
from pathlib import Path
import subprocess

mode = os.environ['SIGNING_MODE']
key = Path(os.environ['RUNNER_TEMP']) / 'app-signing.jks'
if mode == 'release':
    names = ['KEYSTORE_BASE64', 'KEYSTORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD']
    if any(not os.environ.get(n) for n in names):
        raise SystemExit('Release signing requires all four ANDROID_* secrets. No test-key fallback.')
    key.write_bytes(base64.b64decode(os.environ['KEYSTORE_BASE64'], validate=False))
    password, alias, keypassword = (os.environ[n] for n in names[1:])
elif mode == 'test':
    password = keypassword = 'android'
    alias = 'ci-test'
    subprocess.run(['keytool', '-genkeypair', '-noprompt', '-keystore', str(key),
                    '-storetype', 'JKS', '-storepass', password, '-keypass', keypassword,
                    '-alias', alias, '-keyalg', 'RSA', '-keysize', '2048',
                    '-validity', '365', '-dname', 'CN=Temporary CI Test'], check=True)
    print('::warning::Temporary test key: updates across builds are not guaranteed. Do not publish these APKs.')
else:
    raise SystemExit('Unsupported signing mode')
key.chmod(0o600)
def escape(value):
    return ''.join('\\u%04x' % ord(c) if ord(c) > 126 else
                   {'\\': '\\\\', '\n': '\\n', '\r': '\\r', '\t': '\\t', ' ': '\\ ', '=': '\\=', ':': '\\:'}.get(c, c)
                   for c in value)
props = {'storeFile': str(key), 'storePassword': password, 'keyAlias': alias, 'keyPassword': keypassword}
p = Path('app/android/key.properties')
p.write_text(''.join(f'{k}={escape(v)}\n' for k, v in props.items()))
p.chmod(0o600)
