"""Battle sound effects for the site's Unit Info "Battle" stage (sword swings, hits, explosions …).

The unit / effect sprites (dlc/Japan/unit/animation/*.json) carry Spine events that name the game's sound cues:
    Sound*  "cri_se_battle_jump"                 -> play se_battle_jump now
    Sound*  "setHitSound(se_battle_sword_hit)"   -> the sound each following hit makes (Hit events)
This tool extracts every cue those sprites use from the battle SE bank (se.acb + se.awb, same on JP / GL) to
small .m4a files in the GS-voice repo and writes the name -> file list the site reads:

    GS-voice/se/<file>.m4a
    GS-voice/se/se.json   {"<cue name lower case>": "<file>", ...}   (several cue names can share one stream)

Cue names in the sprites are matched case-insensitively; names the bank does not have (typos like
"se_bettle_charge_long", cues from other banks) are listed in the output and stay silent on the site.

Run: python -I tools/build_battle_se.py [--acb "F:/game data/GL GRAND SUMMONERS/dlc/audio/adx2/se.acb"] [--jobs 8]
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parent.parent
ANIM = ROOT / 'dlc' / 'Japan' / 'unit' / 'animation'
OUT = ROOT.parent / 'GS-voice' / 'se'
VGM = os.environ.get('VGMSTREAM', r'C:\Users\noora\Downloads\Compressed\vgmstream-win64\vgmstream-cli.exe')
ACB = r'F:\game data\GL GRAND SUMMONERS\dlc\audio\adx2\se.acb'


def cue_of(event_string):
    """Spine Sound event string -> SE cue name (lower case) or None."""
    s = (event_string or '').strip()
    m = re.match(r'(?i)^(?:cri_)?(se_[^()]+?)(?:\.wav)?$', s) or re.match(r'(?i)^setHit\w*\(s?(se_[^()]+)\)$', s)
    return m.group(1).lower() if m else None


def used_cues():
    """Every SE cue the sprites name, with how often."""
    use = Counter()
    for f in glob.glob(str(ANIM / '*.json')):
        if f.endswith('sprite_manifest.json'):
            continue
        try:
            d = json.loads(Path(f).read_bytes().decode('utf-8', 'replace'))
        except ValueError:
            continue
        for a in (d.get('animations') or {}).values():
            for e in a.get('events') or []:
                if re.match(r'(?i)sound|se', e.get('name', '')):
                    c = cue_of(e.get('string'))
                    if c:
                        use[c] += 1
    return use


def streams(acb):
    """stream index -> cue names (vgmstream joins the names of cues sharing a stream with '; ')."""
    meta = subprocess.run([VGM, '-m', acb], capture_output=True, text=True, encoding='utf-8', errors='replace').stdout
    count = int(re.search(r'stream count: (\d+)', meta).group(1))

    def name(i):
        out = subprocess.run([VGM, '-m', '-s', str(i), acb], capture_output=True, text=True, encoding='utf-8', errors='replace').stdout
        m = re.search(r'stream name: (.*)', out)
        return i, [x.strip() for x in (m.group(1) if m else '').split(';') if x.strip()]
    with ThreadPoolExecutor(8) as ex:
        return dict(ex.map(name, range(1, count + 1)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--acb', default=ACB)
    ap.add_argument('--jobs', type=int, default=8)
    a = ap.parse_args()
    use = used_cues()
    by_name = {}
    for i, names in streams(a.acb).items():
        for n in names:
            by_name.setdefault(n.lower(), i)   # first stream wins for a repeated name
            by_name.setdefault('se_' + n.lower(), i)   # sprites say se_swish_normalsword, the bank swish_normalsword
    want = {c: by_name[c] for c in use if c in by_name}
    files = {}   # stream -> file stem (its first used cue name, a safe file name)
    for c, i in sorted(want.items()):
        files.setdefault(i, re.sub(r'[^a-z0-9_]+', '_', c))
    OUT.mkdir(parents=True, exist_ok=True)

    def extract(item):
        i, stem = item
        dst = OUT / f'{stem}.m4a'
        if dst.exists():
            return
        with tempfile.TemporaryDirectory() as t:
            wav = os.path.join(t, 'a.wav')
            subprocess.run([VGM, '-s', str(i), '-o', wav, a.acb], check=True, capture_output=True)
            subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', wav, '-ac', '1', '-ar', '48000', '-c:a', 'aac', '-b:a', '64k',
                            '-movflags', '+faststart', str(dst)], check=True)
    with ThreadPoolExecutor(a.jobs) as ex:
        list(ex.map(extract, files.items()))
    manifest = {c: files[i] for c, i in sorted(want.items())}
    (OUT / 'se.json').write_text(json.dumps(manifest, separators=(',', ':')), encoding='utf-8')
    miss = sorted((c for c in use if c not in by_name), key=lambda c: -use[c])
    size = sum(p.stat().st_size for p in OUT.glob('*.m4a'))
    print(f'{len(use)} cues used, {len(manifest)} found -> {len(files)} files ({size // 1024} KB) in {OUT}')
    print(f'{len(miss)} not in the bank ({sum(use[c] for c in miss)} of {sum(use.values())} uses):', ', '.join(miss[:40]))
    assert manifest.get('se_battle_jump') and manifest.get('se_battle_019_sword_hit_03'), 'common battle sounds'


if __name__ == '__main__':
    main()
