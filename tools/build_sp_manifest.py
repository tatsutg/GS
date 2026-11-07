"""
Build dlc/unit/sp_manifest.json: every SP art (Special Art) and SP art animation the repo has.

The website uses it to
  - show SP Art / SP Art 2 on any unit (Units V2 has no sheet columns for them)
  - play the SP art animation (Still | Live) for every unit that has one, without listing each by hand
  - filter Units V2 to the units with an SP animation

Files (base = the unit's base_unit_id, n = SP number):
  dlc/unit/sp_detail/unit_sp_detail_<base>_<n>.png
  dlc/unit/sp_icon/unit_sp_icon_<base>_<n>.png
  dlc/unit/sp_detail_animation/unit_sp_detail_animation_<base>_<n>.{atlas,json} (+ the .png pages the atlas names)
Names / descriptions come from the GL DB unit_sp_image_master when the art is in Global.

Output:
  {"sp": {"<base>": {"<n>": {"d": detail file, "i": icon file, "a": [atlas, json, [pages]], "name", "desc"}}},
   "units": {"<unit id>": base}}   # GL unit ids of every base that has an SP art

Runs in .github/workflows/build-unitsv2.yml. Manual run from the repo root:
    python tools/build_sp_manifest.py
"""
import glob
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
UNIT = os.path.join(GS, 'dlc', 'unit')
DB = os.path.join(GS, 'dlc', 'Global', '_DATABASE')
OUT = os.path.join(UNIT, 'sp_manifest.json')


def load(name):
    hits = glob.glob(os.path.join(DB, '*', name + '.json'))
    if not hits:
        return []
    with open(hits[0], encoding='utf-8') as f:
        return json.load(f)


def files(sub, pattern):
    d = os.path.join(UNIT, sub)
    out = {}
    for f in os.listdir(d) if os.path.isdir(d) else []:
        m = re.fullmatch(pattern, f)
        if m:
            out[(int(m.group(1)), int(m.group(2)))] = f
    return out


def atlas_pages(path):
    # page names are the lines right before a "size:" line
    with open(path, encoding='utf-8') as f:
        lines = [l.rstrip('\n') for l in f]
    return [lines[i - 1].strip() for i, l in enumerate(lines) if l.startswith('size:') and i and lines[i - 1].strip().endswith('.png')]


def main():
    detail = files('sp_detail', r'unit_sp_detail_(\d+)_(\d+)\.png')
    icon = files('sp_icon', r'unit_sp_icon_(\d+)_(\d+)\.png')
    atlas = files('sp_detail_animation', r'unit_sp_detail_animation_(\d+)_(\d+)\.atlas')
    info = {(r['base_unit_id'], r['sp_number']): r for r in load('unit_sp_image_master')}

    sp = {}
    for key in sorted(set(detail) | set(icon)):
        base, n = key
        row = {'d': detail.get(key, ''), 'i': icon.get(key, '')}
        a = atlas.get(key)
        if a:
            stem = a[:-len('.atlas')]
            if os.path.exists(os.path.join(UNIT, 'sp_detail_animation', stem + '.json')):
                pages = [p for p in atlas_pages(os.path.join(UNIT, 'sp_detail_animation', a))
                         if os.path.exists(os.path.join(UNIT, 'sp_detail_animation', p))]
                row['a'] = [a, stem + '.json', pages]
        r = info.get(key)
        if r:
            row['name'] = (r.get('name') or '').strip()
            row['desc'] = re.sub(r'\s*\n\s*', ' ', r.get('description') or '').strip()
        sp.setdefault(str(base), {})[str(n)] = row

    units = {str(u['id']): u['base_unit_id'] for u in load('unit_master') if str(u['base_unit_id']) in sp}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump({'sp': sp, 'units': units}, f, ensure_ascii=False, separators=(',', ':'))
    arts = sum(len(v) for v in sp.values())
    anims = sum(1 for v in sp.values() for x in v.values() if 'a' in x)
    print(f'{arts} SP arts ({anims} animated) on {len(sp)} units, {len(units)} unit ids -> {OUT}')


if __name__ == '__main__':
    main()
