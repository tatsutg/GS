"""
Build dlc/Global/_DATABASE/others/summons_detail.json for the website's Summon tab (banner list + summon simulator).

From the decrypted GL DB:
  gacha_master       banners: name, type, dates, banner picture (dlc/Global/summon/banner/...)
                     param.information_image_list names the featured units / equips:
                       unit/unit_summon_<base>_p.png, unit/with_animation_<unit id>_..., item/item_summon_<base>_p.png
                     (numbers >= 10000 there are banner ids, not units)
  gacha_step_up_master  the same image lists for each step of a STEP-UP banner
  unit_master        unit names, rarity, thumbnails (dlc/unit/thumbnail/unit_thumbnail_<id>.png, top form)
  item_master        equip names, rarity, thumbnails (item/thumbnail/item_thumbnail_1<base:04>1.png)
The DB has no summon rates or crystal costs (those live on the server): the website asks for them.

Pools for the simulator:
  units 5★  every unit family featured on a Hero Summon (gacha_type 1) at least once
  units 4★ / 3★  families whose top form is 4★ / 3★ (not materials)
  equips 5★  every equip featured on an Equip Summon (gacha_type 2) at least once

Output: {"built", "banners": [{id, n, t: 'unit'|'equip', s, e, img, feat: [key]}],
         "units": {base: [name, thumb, top rarity]}, "equips": {base: [name, thumb]},
         "pool": {"u5": [...], "u4": [...], "u3": [...], "e5": [...]}}

Runs in .github/workflows/build-summons.yml. Manual run from the repo root:
    python tools/build_summons_detail.py
"""
import glob
import json
import os
import re
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = os.path.join(GS, 'dlc')
DB = os.path.join(DLC, 'Global', '_DATABASE')
OUT = os.path.join(DB, 'others', 'summons_detail.json')
TYPES = {1: 'unit', 6: 'unit', 10: 'unit', 2: 'equip', 7: 'equip'}


def load(name):
    hits = glob.glob(os.path.join(DB, '*', name + '.json'))
    if not hits:
        return []
    with open(hits[0], encoding='utf-8') as f:
        return json.load(f)


def main():
    uthumb = set(os.listdir(os.path.join(DLC, 'unit', 'thumbnail')))
    ithumb = set(os.listdir(os.path.join(DLC, 'Japan', 'item', 'thumbnail')))

    # unit families: name + thumbnail of the top form
    fam = {}
    for u in load('unit_master'):
        b = u['base_unit_id']
        if b >= 10000 or u.get('is_material'):
            continue
        cur = fam.get(b)
        if not cur or (u['rarity'], u['evolution_stage']) > (cur['rarity'], cur['evolution_stage']):
            fam[b] = u
    units = {}
    for b, u in fam.items():
        t = f"unit_thumbnail_{u['id']}.png"
        units[b] = [u['name'], f'unit/thumbnail/{t}' if t in uthumb else '', u['rarity']]
    by_unit_id = {u['id']: u['base_unit_id'] for u in load('unit_master')}

    equips = {}
    for it in load('item_master'):
        b = it['base_item_id']
        if it['rarity'] != 5 or b in equips or not it.get('name'):
            continue
        thumb = next((f for f in (f'item_thumbnail_1{b:04d}1.png', f'item_thumbnail_1{b:04d}0.png') if f in ithumb), '')
        equips[b] = [it['name'], f'item/thumbnail/{thumb}' if thumb else '']

    # STEP-UP banners list their featured units per step
    step_imgs = {}
    for st in load('gacha_step_up_master'):
        try:
            step_imgs.setdefault(st['gacha_id'], []).extend(json.loads(st.get('param') or '{}').get('information_image_list', []))
        except (TypeError, ValueError):
            pass

    banners, u5, e5 = [], set(), set()
    for g in load('gacha_master'):
        kind = TYPES.get(g['gacha_type'])
        if not kind:
            continue
        try:
            imgs = json.loads(g.get('param') or '{}').get('information_image_list', [])
        except (TypeError, ValueError):
            imgs = []
        imgs = imgs + step_imgs.get(g['id'], [])
        feat = []
        for p in imgs:
            m = re.search(r'unit_summon_(\d+)_', p) if kind == 'unit' else re.search(r'item_summon_(\d+)_', p)
            b = int(m.group(1)) if m else 0
            if not b and kind == 'unit':
                m = re.search(r'with_animation_(\d{9})_', p)
                b = by_unit_id.get(int(m.group(1)), 0) if m else 0
            ok = (b in units and units[b][2] >= 5) if kind == 'unit' else b in equips
            if b and b < 10000 and ok and b not in feat:
                feat.append(b)
        if kind == 'unit' and g['gacha_type'] == 1:
            u5.update(feat)
        if kind == 'equip' and g['gacha_type'] == 2:
            e5.update(feat)
        bg = os.path.basename(g.get('bg_name') or '')
        banners.append({'id': g['id'], 'n': g['name'], 't': kind, 's': g['start_at'], 'e': g['end_at'],
                        'img': f'Global/summon/banner/{bg}' if bg and os.path.exists(os.path.join(DLC, 'Global', 'summon', 'banner', bg)) else '',
                        'feat': feat})
    banners.sort(key=lambda b: (b['s'], b['id']), reverse=True)

    used_u = u5 | {b for x in banners if x['t'] == 'unit' for b in x['feat']}
    u4 = sorted(b for b, u in units.items() if u[2] == 4)
    u3 = sorted(b for b, u in units.items() if u[2] == 3)
    keep_u = used_u | set(u4) | set(u3)
    used_e = e5 | {b for x in banners if x['t'] == 'equip' for b in x['feat']}
    data = {'built': datetime.now(timezone.utc).isoformat(timespec='seconds'), 'banners': banners,
            'units': {str(b): units[b] for b in sorted(keep_u)}, 'equips': {str(b): equips[b] for b in sorted(used_e)},
            'pool': {'u5': sorted(u5), 'u4': u4, 'u3': u3, 'e5': sorted(e5)}}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print(f"{len(banners)} banners, pools u5 {len(u5)} u4 {len(u4)} u3 {len(u3)} e5 {len(e5)} -> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
