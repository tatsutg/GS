"""List the units that have a battle sprite (Spine) for the site's Unit Info "Battle" stage.

Input : dlc/Japan/unit/animation/<unit id>.json/.atlas/.png   (Spine 3.0.12 / 3.6.53 exports, copied from the JP dlc)
Output: dlc/Japan/unit/animation/sprite_manifest.json
        {"v": 2, "units": {"<unit id>": ["idle", "attack1", ...]}, "ef": {"<unit id>": ["10001ef", "5"]},
         "trans": {"<unit id>": [["idle", "skill3", ...], "<unit id>transef", "5"]}}
        units: animation names in battle order; zero-length / helper animations are left out.
        ef: the unit's battle-effect skeleton 1<base>ef (fire, beams, rocks … drawn with the moves) and the
            prefix of its animations for this form: "<prefix>-skill2" plays with the unit's "skill2".
            prefix = unit_master.evolution_stage (Clyde 2★ 100012111 = 1 … Awoken 100016111 = 5; matches 1261
            of 1281 units); when that prefix is missing and the file has only one, that one (20 units, all
            evolution_stage 1 with only "2-" moves: NEEDS CONFIRMATION that the game does the same).
        trans: units that transform in battle (Awoken Rayas …): the transformed body <unit id>trans with its own
            moves (True Arts can live only there) and its effects <unit id>transef + prefix (same rule as ef).

The site plays the files straight from this folder with spine-ts 3.6 (js/unitsprite.js renames the 3.0-only
mesh types the same way js/battlesim.js does), so nothing is converted here.

Run: python -I tools/build_sprite_manifest.py
"""
import csv
import json
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parent.parent
ANIM = ROOT / 'dlc' / 'Japan' / 'unit' / 'animation'
OUT = ANIM / 'sprite_manifest.json'
DBS = [ROOT / 'dlc' / s / '_DATABASE' / 'others' / 'unit_master.csv' for s in ('Japan', 'Global')]

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


def stages():
    """unit id -> evolution_stage (JP DB first, Global for ids JP lacks)."""
    csv.field_size_limit(10 ** 8)
    out = {}
    for db in DBS:
        if db.exists():
            with db.open(encoding='utf-8') as fh:
                for r in csv.DictReader(fh):
                    out.setdefault(r['id'], r['evolution_stage'])
    return out


def effects(units):
    """unit id -> [effect skeleton name, animation prefix] for units whose 1<base>ef file has moves for them."""
    stage, cache, out = stages(), {}, {}
    for uid in units:
        name = f'1{uid[1:5]}ef'
        if name not in cache:
            f = ANIM / f'{name}.json'
            anims = json.loads(f.read_bytes().decode('utf-8', 'replace')).get('animations', {}) if f.exists() else {}
            cache[name] = sorted({m.group(1) for m in (re.match(r'^(\d+)-', n) for n in anims) if m})
        pre = cache[name]
        st = stage.get(uid)
        if st in pre:
            out[uid] = [name, st]
        elif len(pre) == 1:
            out[uid] = [name, pre[0]]
    return out


def anim_names(d):
    """Animation names in battle order; zero-length / helper animations are left out."""
    anims = d.get('animations') or {}
    names = [n for n, a in anims.items() if not SKIP.search(n) and (n.startswith('idle') or duration(a) > 0)]
    if 'idle' in anims and 'idle' not in names:
        names.append('idle')
    return sorted(names, key=order)


def trans_forms(units):
    """unit id -> [transformed body's moves, its effect file or None, effect prefix or None]."""
    stage, out = stages(), {}
    for uid in units:
        f = ANIM / f'{uid}trans.json'
        if not (f.exists() and (ANIM / f'{uid}trans.atlas').exists()):
            continue
        names = anim_names(json.loads(f.read_bytes().decode('utf-8', 'replace')))
        ef, pre = ANIM / f'{uid}transef.json', None
        if ef.exists():
            pres = sorted({m.group(1) for m in (re.match(r'^(\d+)-', n) for n in json.loads(ef.read_bytes().decode('utf-8', 'replace')).get('animations', {})) if m})
            pre = stage.get(uid) if stage.get(uid) in pres else (pres[0] if len(pres) == 1 else None)
        out[uid] = [names, ef.stem if pre else None, pre]
    return out


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
        names = anim_names(d)
        if names:
            units[uid] = names
    ef = effects(units)
    trans = trans_forms(units)
    OUT.write_text(json.dumps({'v': 2, 'units': units, 'ef': ef, 'trans': trans}, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'{len(units)} units, {len(ef)} with effects, {len(trans)} transform -> {OUT.relative_to(ROOT)} ({OUT.stat().st_size // 1024} KB)')
    for b in bad:
        print('  skipped', b)
    assert units.get('100016111', [None])[0] == 'idle', 'Clyde (100016111) should start with idle'
    assert 'skill3' in trans.get('101016411', [[]])[0] and trans['101016411'][1:] == ['101016411transef', '5'], 'Awoken Rayas trans'
    assert ef.get('100016111') == ['10001ef', '5'] and ef.get('100012111') == ['10001ef', '1'], 'Clyde effect prefixes'


if __name__ == '__main__':
    main()
