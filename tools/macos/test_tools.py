#!/usr/bin/env python3
"""v0.67.1 · CodexAI. Release identity, preservation and idempotent Mac supplements."""
import configparser,hashlib,json,pathlib,tempfile,unittest
from prepare import prepare
from release_files import prepare as release_files
class MacTools(unittest.TestCase):
    def test_preset_preserves_other_platforms_and_rejects_wrong_tag(self):
        with tempfile.TemporaryDirectory() as folder:
            p=pathlib.Path(folder);(p/'project.godot').write_text('config/version="0.67.1"\n')
            original='[preset.0]\nname="Linux"\nplatform="Linux"\ninclude_filter="a.json"\nexclude_filter="docs/*,tests/*"\n\n[preset.0.options]\nbinary_format/architecture="x86_64"\n'
            (p/'export_presets.cfg').write_text(original)
            with self.assertRaises(ValueError):prepare(p,'v0.67.2')
            self.assertEqual((p/'export_presets.cfg').read_text(),original)
            prepare(p,'v0.67.1');first=(p/'export_presets.cfg').read_text();prepare(p,'v0.67.1')
            self.assertEqual((p/'export_presets.cfg').read_text(),first)
            self.assertTrue(first.startswith(original.rstrip()))
            cfg=configparser.ConfigParser(interpolation=None);cfg.read_string(first)
            self.assertEqual(cfg['preset.1']['exclude_filter'],'"docs/*,tests/*"')
            self.assertEqual(cfg['preset.1.options']['binary_format/architecture'],'"universal"')
    def test_supplement_preserves_prior_downloads_and_notes(self):
        with tempfile.TemporaryDirectory() as folder:
            p=pathlib.Path(folder);data=b'test-only-Mac-package';(p/'ShadepiRPG-macOS.zip').write_bytes(data)
            report={'version':'0.67.1','sha256':hashlib.sha256(data).hexdigest(),'native_start_tested':True,'native_signature_verified':True,'native_architecture':'test-fixture'}
            (p/'macos-verification.json').write_text(json.dumps(report));body='Original release notes\nwith a custom user paragraph.\n';(p/'previous-notes.md').write_text(body)
            names=['ShadepiRPG-Windows.zip','ShadepiRPG-Linux.zip','ShadepiRPG-Android-Test.apk','ShadepiRPG-Godot-Projekt.zip'];old=''.join('a'*64+'  '+n+'\n' for n in names);(p/'previous-SHA256SUMS.txt').write_text(old)
            release_files(p,'v0.67.1','Inrouder/ShadepiRPG');notes=(p/'release-notes.md').read_text();sums=(p/'SHA256SUMS.txt').read_text()
            self.assertTrue(notes.startswith(body.rstrip()));self.assertTrue(sums.startswith(old));self.assertEqual(len(sums.splitlines()),5)
            self.assertIn('CodexAI',notes);self.assertIn('nicht von Apple notarisiert',notes)
            (p/'previous-notes.md').write_text(notes);(p/'previous-SHA256SUMS.txt').write_text(sums)
            release_files(p,'v0.67.1','Inrouder/ShadepiRPG');self.assertEqual((p/'release-notes.md').read_text(),notes)
            with self.assertRaises(AssertionError):release_files(p,'v0.67.2','Inrouder/ShadepiRPG')
            report['native_start_tested']=False;(p/'macos-verification.json').write_text(json.dumps(report))
            with self.assertRaises(AssertionError):release_files(p,'v0.67.1','Inrouder/ShadepiRPG')
if __name__=='__main__':unittest.main()
