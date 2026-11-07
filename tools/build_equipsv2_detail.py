"""
Build dlc/#Global/others/equipsv2_detail.json for the website's Equips V2 tab.

Reads the decrypted GL DB exports in dlc/#Global/{others,data1}/*.json and
writes one record per equip family (keyed by base_item_id). Each record has a
row shaped like the Equips sheet (so the site's Equip Info popup can show it
as-is) plus the extra data the sheet does not have:
  - every enhance stage (+0 .. +10): stats, skill, abilities, enhance cost
  - limit break: copies needed per LB and CT per LB
  - sell price (coin / orb)
  - where to get it (event drops, quest rewards, event shops, crafting)

Runs automatically: .github/workflows/build-equipsv2.yml (on push of the DB
files it reads). Manual run from the repo root:
    python tools/build_equipsv2_detail.py [output-path]
"""
import json
import os
import re
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
GL = os.path.join(GS, 'dlc', '#Global')
SRC = os.path.join(GL, 'others')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(SRC, 'equipsv2_detail.json')

RAW = 'https://raw.githubusercontent.com/tatsutg/GS/main/dlc/'
TYPE = {1: 'Physical', 2: 'Magical', 3: 'Defense', 4: 'Healing', 5: 'Support'}
# orb_shop_master.shop_type
SHOP = {1: 'Arca Shop', 2: 'Alchemist (True Equip exchange)', 3: 'Material exchange', 6: 'Exchange'}
JP = re.compile(r'[぀-ヿ一-鿿]')


def load(name, folder='others'):
    with open(os.path.join(GL, folder, name + '.json'), encoding='utf-8') as f:
        return json.load(f)


def clean(text):
    """Sheet text is one line; the site re-breaks sentences itself."""
    if not text or text == 'None':
        return ''
    return re.sub(r'\s*\n\s*', ' ', str(text)).strip()


def num(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return 0


def secs(ms):
    v = num(ms) / 100
    return int(v) if v == int(v) else round(v, 1)


def main():
    items = load('item_master')
    skills = {s['id']: s for s in load('skill_master')}
    fx = defaultdict(list)
    for row in load('skill_effect_master'):
        if row.get('skill_id'):
            fx[row['skill_id']].append(row['id'])
    for v in fx.values():
        v.sort()
    rel = defaultdict(list)          # item id -> [relation rows]
    for r in load('skill_relation_master'):
        if r.get('relation_type') == 1:
            rel[r['relation_id']].append(r)
    mats = {m['id']: m for m in load('material_master')}
    evo = {e['base_item_id']: e for e in load('item_evolution_master')}
    lbexp = defaultdict(dict)
    for r in load('item_limitbreak_exp_master', 'data1'):
        lbexp[r['exp_id']][r['level']] = r['exp']
    tag_name = {t['id']: t['name'] for t in load('tag_master', 'data1')}

    # ---- sources ----
    dungeons = load('dungeon_master')
    dname = {d['id']: d['name'] for d in dungeons}
    ev_name = {}
    for d in sorted(dungeons, key=lambda d: d['id']):
        if d['event_id'] and d['name'] and not JP.search(d['name']):
            ev_name.setdefault(d['event_id'], d['name'])
    ev_items = {e['id']: e['name'] for e in load('event_item_master')}
    src = defaultdict(list)          # base_item_id -> [source]
    seen = set()

    def add(base, kind, name, detail=''):
        key = (base, kind, name, detail)
        if base and name and key not in seen:
            seen.add(key)
            src[base].append({'t': kind, 'n': name, 'd': detail})

    id2base = {x['id']: x['base_item_id'] for x in items}
    for d in dungeons:
        try:
            dd = json.loads(d['drop_up_item_dict'] or '{}')
        except (TypeError, ValueError):
            dd = {}
        for b in dd:
            add(num(b), 'drop', d['name'], 'Event quest drop')
    for q in load('quest_master'):
        place = dname.get(num(q.get('dungeon_id')), '')
        for k in ('questmission1', 'questmission2', 'questmission3', 'complete'):
            if q.get(k + '_reward_type') in (7, 8):
                b = id2base.get(num(q.get(k + '_reward_id')))
                what = 'Clear reward' if k == 'complete' else 'Mission reward'
                add(b, 'quest', f"{place} > {q['name']}" if place and place != q['name'] else q['name'], what)
    for s in load('event_shop_master'):
        if s['object_type'] in (7, 8):
            b = id2base.get(s['object_id'])
            cur = ev_items.get(s['need_item_id'], '')
            where = ev_name.get(s['event_id']) or 'Event shop'
            add(b, 'shop', where, f"{s['need_count']:,} × {cur}" if cur else f"{s['need_count']:,} event items")
    for s in load('orb_shop_master'):
        if s['object_type'] in (7, 8):
            b = id2base.get(s['object_id'])
            shop = SHOP.get(s['shop_type'], 'Shop')
            cost = ''
            if s['need_type1'] == 18:
                cost = f"{s['need_value1']:,} Arca"
            elif s['need_type1'] == 25:
                cost = f"{s['need_value1']:,} Rainbow Gems"
            add(b, 'craft' if s['shop_type'] == 2 else 'shop', shop, cost)

    # ---- families ----
    fam = defaultdict(list)
    for x in items:
        if x['is_material'] == 0 and x['type'] in TYPE and x['evolution_stage'] != 99:
            fam[x['base_item_id']].append(x)

    # Shared tables keep the file small: many equips use the same abilities / materials.
    S = {}     # skill id -> [name, text, break, fx ids]
    M = {}     # material id -> name

    def skill_ref(sid):
        if sid and sid not in S:
            s = skills.get(sid) or {}
            S[sid] = [clean(s.get('name')), clean(s.get('description')), num(s.get('break_value')), fx.get(sid, [])]
        return sid

    def passives_of(iid):
        """Abilities of one stage's item row: one per name (highest Lv), in the game's order."""
        best = {}
        for r in sorted(rel.get(iid, []), key=lambda r: r['id']):
            s = skills.get(r['skill_id'])
            if not s or not s.get('name'):
                continue
            key = re.sub(r'\s*Lv\.?\s*\d+$', '', s['name'])
            if key not in best or r['skill_id'] > best[key]:
                best[key] = r['skill_id']
        return [skill_ref(v) for v in best.values()]

    out = []
    for base, xs in fam.items():
        xs.sort(key=lambda r: (r['evolution_stage'], r['id']))
        by_stage = {}
        for x in xs:
            by_stage.setdefault(x['evolution_stage'], x)
        top = by_stage[max(by_stage)]
        first = by_stage[min(by_stage)]
        name = clean(top['name'])
        if not name or JP.search(name) or max(by_stage) < 5:
            continue   # enemy-only / test items
        # stage row: [stage, item id, image id, HP, ATK, DEF, skill id, [ability ids], sell coin, sell orb, enhance cost]
        # enhance cost (to reach the next stage): [coin, [[material id, count], ...]] or 0 at max
        stages = []
        for s, x in sorted(by_stage.items()):
            e = evo.get(x['id'])
            cost = 0
            if e and e.get('next_item_id'):
                m = []
                for i in range(1, 6):
                    mid, val = num(e.get(f'material_{i}_item_id')), num(e.get(f'material_{i}_item_value'))
                    if mid and val:
                        M[mid] = clean(mats.get(mid, {}).get('name')) or str(mid)
                        m.append([mid, val])
                cost = [num(e.get('need_coin')), m]
            stages.append([s, x['id'], x['image_id'], num(x['hitpoint']), num(x['offence']), num(x['defence']),
                           skill_ref(x['item_skill_id']), passives_of(x['id']), num(x['coin']), num(x['orb']), cost])
        exp = lbexp.get(top['limit_break_exp_id'], {})
        per = max(1, num(top['for_limit_break_exp']))
        copies = [-(-exp[l] // per) for l in sorted(exp)] if len(exp) > 1 else []
        ct_max, ct_min = num(top['max_limitbreak_cooltime']), num(top['min_limitbreak_cooltime'])
        n = max(1, len(copies) - 1)
        cts = [secs(ct_max - (ct_max - ct_min) * i / n) for i in range(len(copies))] if copies else [secs(ct_min or ct_max)]
        try:
            tags = json.loads(top['tags'] or '[]')
        except (TypeError, ValueError):
            tags = []
        try:
            true_units = json.loads(top['true_unit_ids'] or '[]')
        except (TypeError, ValueError):
            true_units = []
        out.append({
            'b': base, 'n': name, 'r': top['rarity'], 't': TYPE[top['type']],
            'lore': clean(first['description']) or clean(top['description']),
            'tags': tags, 'true': true_units,
            'st': stages,
            'lb': [copies, cts],
            'src': src.get(base, []),
        })
    out.sort(key=lambda r: r['b'])
    data = {
        'raw': RAW, 'types': TYPE,
        'skills': {str(k): v for k, v in S.items()},
        'mats': {str(k): v for k, v in M.items()},
        'tagNames': {str(k): v for k, v in tag_name.items()},
        'equips': out,
    }
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print(f'{len(out)} equips, {len(S)} skills -> {OUT} ({os.path.getsize(OUT) // 1024} KB)')

    # Equip ability icons for every equip popup (sheet and V2): ability name -> file in dlc/ability/thumbnail
    # (skill_master.tumbnail_name1 of every ability that an equip item has). Small, so the site loads it at start.
    icons = {}
    item_ids = {x['id'] for x in items}
    for iid, rows in rel.items():
        if iid not in item_ids:
            continue
        for r in rows:
            s = skills.get(r['skill_id']) or {}
            name, pic = clean(s.get('name')), s.get('tumbnail_name1')
            if name and pic and pic != 'None':
                icons.setdefault(name, pic)
    icon_out = os.path.join(os.path.dirname(OUT), 'ability_icons.json')
    with open(icon_out, 'w', encoding='utf-8') as f:
        json.dump(dict(sorted(icons.items())), f, ensure_ascii=False, separators=(',', ':'))
    print(f'{len(icons)} ability icons -> {icon_out}')


if __name__ == '__main__':
    main()
