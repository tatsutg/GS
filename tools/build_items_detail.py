"""
Build dlc/Global/_DATABASE/others/items_detail.json for the website's Items tab.

Reads the decrypted GL DB exports in dlc/Global/_DATABASE/*/ and writes one row per item:
  - Materials        (material_master)                  image: material/material_thumbnail_<id>.png
  - Crest Materials  (ci_generic_ / ci_unique_material)  image: material/generic_<id>.png, unique_<id>.png
  - Event Items      (event_item_master)                 image: event/event_icon_<id>.png (when the game has one)
  - Food             (food_master + cooking_recipe)      image: cook/thumbnail/cook_thumbnail_<id>.png
  - Runes            (rune_master + rune_type_master)    image: rune/thumbnail/runestone_middle_<image>.png
  - Raid Tickets     (raid_ticket_master)                no image in the game files
  - Tools & Tickets  (tool_master: potions, summon tickets, ...)  no image in the game files
For each item: where to get it (quest drops, quest rewards, event / Arca shops, cooking) and what it is
used for (equip enhance + crafting, unit evolution + Dream Awakening, cooking, event shop exchanges).

Runs automatically: .github/workflows/build-items.yml. Manual run from the repo root:
    python tools/build_items_detail.py [output-path]
"""
import glob
import json
import os
import re
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = os.path.join(GS, 'dlc')
DB = os.path.join(DLC, 'Global', '_DATABASE')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(DB, 'others', 'items_detail.json')

JP = re.compile(r'[぀-ヿ一-鿿]')
MAT_TYPE = {1: 'Evolution', 9: 'Special', 10: 'Gems', 20: 'Refine Stones',
            31: 'Kilmon', 32: 'Defmon', 33: 'Tufmon', 34: 'Eggs & Chickens'}
SHOP = {1: 'Arca Shop', 2: 'Alchemist', 3: 'Material exchange', 6: 'Exchange'}
CAP = 40          # longest list of sources / uses kept per item (the count keeps the full number)


def load(name):
    hits = glob.glob(os.path.join(DB, '*', name + '.json'))
    if not hits:
        return []
    with open(hits[0], encoding='utf-8') as f:
        return json.load(f)


def clean(text):
    if not text or text == 'None':
        return ''
    return re.sub(r'[ \t]*\n[ \t]*', '\n', str(text)).strip()


def num(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return 0


def img(rel):
    return rel if os.path.exists(os.path.join(DLC, rel)) else ''


def english(name):
    return bool(name) and not JP.search(name)


def main():
    mats = load('material_master')
    events = load('event_item_master')
    foods = load('food_master')
    runes = load('rune_master')
    rune_type = {t['id']: clean(t['name']) for t in load('rune_type_master')}
    skills = {s['id']: s for s in load('skill_master')}
    dungeons = load('dungeon_master')
    dname = {d['id']: clean(d['name']) for d in dungeons}
    ev_name = {}
    for d in sorted(dungeons, key=lambda d: d['id']):
        if d['event_id'] and english(d['name']):
            ev_name.setdefault(d['event_id'], clean(d['name']))
    ev_items = {e['id']: clean(e['name']) for e in events}
    items = load('item_master')
    item_name = {x['id']: clean(x['name']) for x in items}
    base_of = {x['id']: x['base_item_id'] for x in items}
    base_name = {}
    for x in sorted(items, key=lambda x: (x['evolution_stage'] if x['evolution_stage'] != 99 else -1)):
        if english(x['name']):
            base_name[x['base_item_id']] = clean(x['name'])   # highest stage name wins
    unit_name = {u['id']: clean(u['name']) for u in load('unit_master')}
    food_name = {f['id']: clean(f['name']) for f in foods}

    src = defaultdict(list)    # (kind, id) -> [[type, name, detail]]
    use = defaultdict(list)
    seen = set()

    def add(box, key, kind, name, detail=''):
        k = (id(box), key, kind, name, detail)
        if name and k not in seen:
            seen.add(k)
            box[key].append([kind, name, detail])

    # ---- where to get materials ----
    drop_q = defaultdict(lambda: defaultdict(int))   # material -> dungeon name -> quests
    for q in load('quest_master'):
        place = dname.get(num(q.get('dungeon_id')), '')
        try:
            shown = json.loads(q.get('display_item_list') or '[]')
        except (TypeError, ValueError):
            shown = []
        for d in shown if isinstance(shown, list) else []:
            if d.get('type') == 5 and english(place):
                drop_q[d.get('id')][place] += 1
        for k in ('questmission1', 'questmission2', 'questmission3', 'complete'):
            rt = q.get(k + '_reward_type')
            if rt in (22, 24):   # event item / tool
                n = num(q.get(k + '_reward_value'))
                where = f"{place} > {clean(q['name'])}" if english(place) and place != clean(q['name']) else clean(q['name'])
                if english(where):
                    add(src, ('event' if rt == 22 else 'tool', num(q.get(k + '_reward_id'))), 'quest', where,
                        ('Clear reward' if k == 'complete' else 'Mission reward') + (f' ×{n:,}' if n else ''))
            if rt == 5:
                what = 'Clear reward' if k == 'complete' else 'Mission reward'
                n = num(q.get(k + '_reward_value'))
                where = f"{place} > {clean(q['name'])}" if english(place) and place != clean(q['name']) else clean(q['name'])
                if english(where):
                    add(src, ('mat', num(q.get(k + '_reward_id'))), 'quest', where, f'{what} ×{n:,}' if n else what)
    for mid, places in drop_q.items():
        for place, n in sorted(places.items(), key=lambda p: -p[1]):
            add(src, ('mat', mid), 'drop', place, f'Drops in {n} quest{"s" if n > 1 else ""}')
    for s in load('event_shop_master'):
        cur = ev_items.get(s['need_item_id'], '')
        where = ev_name.get(s['event_id']) or (f'{cur} exchange' if cur else 'Event shop')
        if s['object_type'] in (5, 24):
            add(src, ('mat' if s['object_type'] == 5 else 'tool', s['object_id']), 'shop', where, f"{s['need_count']:,} × {cur}" if cur else '')
        # event items: what they buy
        if cur:
            add(use, ('event', s['need_item_id']), 'shop', clean(s['name']) or 'Exchange', f"{s['need_count']:,} each")
    for s in load('orb_shop_master'):
        if s['object_type'] == 5:
            cost = f"{s['need_value1']:,} Arca" if s['need_type1'] == 18 else (f"{s['need_value1']:,} Rainbow Gems" if s['need_type1'] == 25 else '')
            add(src, ('mat', s['object_id']), 'shop', SHOP.get(s['shop_type'], 'Shop'), cost)

    # ---- what materials are used for ----
    equip_use = defaultdict(lambda: defaultdict(int))   # material -> equip base -> total count
    for e in load('item_evolution_master'):
        b = base_of.get(e['base_item_id'], e['base_item_id'])
        for i in range(1, 6):
            mid, val = num(e.get(f'material_{i}_item_id')), num(e.get(f'material_{i}_item_value'))
            if mid and val and e.get(f'material_{i}_type') in (5, None):
                equip_use[mid][b] += val
    for mid, bases in equip_use.items():
        for b, n in sorted(bases.items(), key=lambda p: -p[1]):
            if base_name.get(b):
                add(use, ('mat', mid), 'equip', base_name[b], f'Enhance: {n:,} in total')
    for r in load('item_recipe_master'):
        made = item_name.get(r['created_item_id']) or clean(r['name'])
        for i in range(1, 6):
            mid, val = num(r.get(f'material_{i}_item_id')), num(r.get(f'material_{i}_item_value'))
            if mid and val and english(made):
                add(use, ('mat', mid), 'craft', made, f'Crafting ×{val:,}')
    for u in load('unit_evolution_master'):
        name = unit_name.get(u['next_unit_id'], '')
        for i in range(1, 6):
            mid, val = num(u.get(f'material_{i}_id')), num(u.get(f'material_{i}_value'))
            if mid and val and u.get(f'material_{i}_type') == 5 and english(name):
                add(use, ('mat', mid), 'unit', name, f'Evolution ×{val:,}')
    for u in load('unit_fantasy_evo_master'):
        name = unit_name.get(u['unit_id'], '')
        for i in range(1, 9):
            mid, val = num(u.get(f'evo_need_material{i}_id')), num(u.get(f'evo_need_material{i}_value'))
            if mid and val and english(name):
                add(use, ('mat', mid), 'unit', name, f'Dream Awakening ×{val:,}')

    # ---- food: cooking ----
    for r in load('cooking_recipe_master'):
        made = food_name.get(num(r['created_food_id']), '')
        parts = []
        for i in range(1, 6):
            fid, val = num(r.get(f'material_{i}_id')), num(r.get(f'material_{i}_value'))
            if fid and val:
                parts.append(f"{food_name.get(fid, fid)} ×{val}")
                if made:
                    add(use, ('food', fid), 'craft', made, f'Cooking ×{val}')
        if made:
            add(src, ('food', num(r['created_food_id'])), 'craft', 'Cooking', ', '.join(parts) + f" ({r['success_rate']}% success)")

    out = []

    def row(kind, i, name, rarity, desc, picture, sub='', extra=None):
        order = {'drop': 0, 'shop': 1, 'craft': 2, 'quest': 3}
        s = sorted(src.get((kind, i), []), key=lambda x: order.get(x[0], 9))
        u = use.get((kind, i), [])
        r = {'k': kind, 'id': i, 'n': name, 'r': rarity, 'd': desc, 'img': picture, 'sub': sub,
             'src': s[:CAP], 'use': u[:CAP]}
        if len(s) > CAP:
            r['srcN'] = len(s)
        if len(u) > CAP:
            r['useN'] = len(u)
        if extra:
            r.update(extra)
        out.append(r)

    for m in mats:
        if english(m['name']):
            row('mat', m['id'], clean(m['name']), num(m['rarity']), clean(m['description']),
                img(f"material/material_thumbnail_{m['id']}.png"), MAT_TYPE.get(m['type'], 'Other'))
    for c in load('ci_generic_material_master'):
        row('crest', c['id'], clean(c['name']), num(c['material_rarity']), clean(c['description']),
            img(f"material/generic_{c['id']}.png"), 'Mystika')
    for c in load('ci_unique_material_master'):
        row('crest', c['id'], clean(c['name']), 0, clean(c['description']), img(f"material/unique_{c['id']}.png"), 'Catalyst')
    for e in events:
        if english(e['name']):
            row('event', e['id'], clean(e['name']), num(e['rarity']), '', img(f"event/event_icon_{e['id']}.png"),
                ev_name.get(e['event_id'], ''), {'max': num(e['limit_value'])})
    for f in foods:
        row('food', f['id'], clean(f['name']), num(f['rarity']), clean(f['description']),
            img(f"cook/thumbnail/cook_thumbnail_{f['id']}.png"), clean(f.get('summary')), {'sell': num(f.get('coin'))})
    for r in runes:
        sk = skills.get(r['skill_id']) or {}
        pic = img(f"rune/thumbnail/runestone_middle_{r['image']}.png") if r.get('image') else ''
        row('rune', r['id'], clean(r['name']), num(r['level']), clean(sk.get('description')), pic,
            rune_type.get(r['type_id'], ''))
    for t in load('raid_ticket_master'):
        row('ticket', t['id'], clean(t['name']), 0, clean(t['description']), '', 'Raid')
    tool_kind = {1: 'Energy', 5: 'Summon Tickets'}
    for t in load('tool_master'):
        if english(t['name']):
            row('tool', t['id'], clean(t['name']), 0, clean(t['description']), '', tool_kind.get(t['type'], 'Other'),
                {'max': num(t.get('count_limit'))})

    data = {'cats': {'mat': 'Materials', 'crest': 'Crest Materials', 'event': 'Event Items',
                     'food': 'Food', 'rune': 'Runes', 'tool': 'Tools & Tickets', 'ticket': 'Raid Tickets'},
            'items': out}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    by = defaultdict(int)
    for r in out:
        by[r['k']] += 1
    print(dict(by), f"-> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
