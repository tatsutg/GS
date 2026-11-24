"""List the units that have a battle sprite (Spine) for the site's Unit Info "Battle" stage.

Input : dlc/Japan/unit/animation/<unit id>.json/.atlas/.png   (Spine 3.0.12 / 3.6.53 exports, copied from the JP dlc)
Output: dlc/Japan/unit/animation/sprite_manifest.json
        {"v": 1, "units": {"<unit id>": ["idle", "attack1", ...]}}
        animation names in the skeleton's own order; zero-length / helper animations are left out.

The site plays the files straight from this folder with spine-ts 3.6 (js/unitsprite.js renames the 3.0-only
mesh types the same way js/battlesim.js does), so nothing is converted here.

Run: python -I tools/build_sprite_manifest.py
"""
import json
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parent.parent
ANIM = ROOT / 'dlc' / 'Japan' / 'unit' / 'animation'
OUT = ANIM / 'sprite_manifest.json'

# helper / clone / gallery animations nobody wants as a button
SKIP = re.compile(r'^(empty|enpty|none)$|^zclone|library|origin', re.I)


def order(name):
    """Battle order for the buttons: idle, attacks, skill1..5 (Skill, Arts, True Arts, ...), then the rest A-Z."""
    m = re.match(r'^(idle|attack|skill)(\d*)(.*)$', name)
    if not m:
        return (3, 0, name)
    rank = {'idle': 0, 'attack': 1, 'skill': 2}[m.group(1)]
    return (rank, int(m.group(2) or 0), m.group(3))


def duration(anim):
    """Last key time of an animation (0 = a single pose)."""
    t = 0.0

    def walk(x):
        nonlocal t
        if isinstance(x, dict):
            if isinstance(x.get('time'), (int, float)):
                t = max(t, x['time'])
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for v in x:
                walk(v)
    walk(anim)
    return t


def main():
    units, bad = {}, []
    for f in sorted(ANIM.glob('1' + '[0-9]' * 8 + '.json')):
        uid = f.stem
        if not (ANIM / f'{uid}.atlas').exists() or not (ANIM / f'{uid}.png').exists():
            bad.append(f'{uid} (missing atlas/png)')
            continue
        try:
            d = json.loads(f.read_bytes().decode('utf-8'))
        except Exception as e:  # noqa: BLE001 - report and skip a broken export
            bad.append(f'{uid} ({e.__class__.__name__})')
            continue
        anims = d.get('animations') or {}
        names = [n for n, a in anims.items() if not SKIP.search(n) and (n.startswith('idle') or duration(a) > 0)]
        if 'idle' in anims and 'idle' not in names:
            names.append('idle')
        names.sort(key=order)
        if names:
            units[uid] = names
    OUT.write_text(json.dumps({'v': 1, 'units': units}, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'{len(units)} units -> {OUT.relative_to(ROOT)} ({OUT.stat().st_size // 1024} KB)')
    for b in bad:
        print('  skipped', b)
    assert units.get('100016111', [None])[0] == 'idle', 'Clyde (100016111) should start with idle'


if __name__ == '__main__':
    main()
