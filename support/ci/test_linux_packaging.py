"""Smoke-test DEB/TAR layout with a fixture, NOT with a compiled application."""
from pathlib import Path
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
class PackagingTests(unittest.TestCase):
    def test_deb_and_tar_layout(self):
        for arch,deb_arch in [('x64','amd64'),('arm64','arm64')]:
            with self.subTest(arch=arch), tempfile.TemporaryDirectory() as d:
                p=Path(d)
                bundle=p/f'app/build/linux/{arch}/release/bundle'
                bundle.mkdir(parents=True)
                (bundle/'sendy').write_text('#!/bin/sh\necho packaging-fixture-only\n')
                (bundle/'sendy').chmod(0o755)
                (p/'app/pubspec.yaml').write_text('version: 0.1.0+1\n')
                (p/'app/assets/img').mkdir(parents=True)
                shutil.copy(ROOT/'app/assets/img/logo-512.png',p/'app/assets/img/logo-512.png')
                for name in ['LICENSE','NOTICE']:shutil.copy(ROOT/name,p/name)
                (p/'tmp').mkdir()
                env={**os.environ,'RUNNER_TEMP':str(p/'tmp'),'BUILD_ARCH':arch,'DEB_ARCH':deb_arch}
                subprocess.run(['bash',str(ROOT/'support/ci/package-linux.sh')],cwd=p,env=env,check=True,stdout=subprocess.DEVNULL)
                deb=next((p/'artifacts').glob('*.deb'))
                for field,expected in [('Package','sendy'),('Architecture',deb_arch),('Version','0.1.0')]:
                    self.assertEqual(subprocess.check_output(['dpkg-deb','--field',str(deb),field],text=True).strip(),expected)
                content=subprocess.check_output(['dpkg-deb','--contents',str(deb)],text=True)
                self.assertIn('./opt/sendy/sendy',content)
                self.assertIn('./usr/share/applications/sendy.desktop',content)
                self.assertIn('./usr/share/doc/sendy/NOTICE',content)
                self.assertNotIn('/opt/localsend',content)
                with tarfile.open(next((p/'artifacts').glob('*.tar.gz'))) as t:
                    self.assertIn('./sendy',t.getnames())
                    self.assertIn('./NOTICE.txt',t.getnames())
if __name__=='__main__':unittest.main()
