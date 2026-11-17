"""
Build dlc/<Region>/_DATABASE/others/battle_sim.json for the website's Simulator > Battle tab (js/battlesim.js).

{
  "u": {unit_id: base}                       every form's unit id -> unitsv2 base (sprite + face use the unit id)
  "s": {base: [name, element, hp, atk, def, rarity, top_unit_id,
               attack_delay_s, break_power, attribute, skill, arts, true_arts, super_arts]}
  "e": {image_id: [name, type, hp, atk, def, ct_s, skill]}   equips by picture id (the site's equip ID)
  "q": [[quest_id, dungeon, quest, difficulty, [[unit_id, name, element, lv, hp, atk, def, break], ...]], ...]
}
rarity: 2 Ascension, 1 Awoken, 0 lower. element: 1 fire, 2 water, 3 earth, 4 light, 5 dark.
attribute: 1 physical, 2 magic. type (equips): 1 physical, 2 magical, 3 defense, 4 healing, 5 support.
A skill is 0 (none) or [damage %, break, element, attribute, CT s, arts cost, effects],
effects = [[effect_type, target, seconds, value], ...] from skill_effect_master (target 1 self, 2 allies, 4 enemy).
Equip CT: item_master min_limitbreak_cooltime (the MLB value), centiseconds.

Manual run from the repo root (GS_REGION=Global or Japan):
    python tools/build_battle_sim.py [output-path]
"""
import ast
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
REGION = os.environ.get('GS_REGION', 'Global')
OTHERS = os.path.join(GS, 'dlc', REGION, '_DATABASE', 'others')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(OTHERS, 'battle_sim.json')


def load(name):
    with open(os.path.join(OTHERS, name), encoding='utf-8') as f:
        return json.load(f)


def num(v, d=0):
    try:
        return int(float(v))
    except (TypeError, ValueError):
        return d


def obj(v):
    """unitsv2_detail keeps some dicts as Python-literal strings"""
    if isinstance(v, str):
        try:
            return ast.literal_eval(v)
        except (ValueError, SyntaxError):
            return {}
    return v or {}


units = load('unitsv2_detail.json')
um = {r['id']: r for r in load('unit_master.json')}
sm = {r['id']: r for r in load('skill_master.json')}
fx = {}
for e in load('skill_effect_master.json'):
    fx.setdefault(e['skill_id'], []).append(e)


def skill(sid):
    r = sm.get(num(sid))
    if not r:
        return 0
    effects = [[num(e['effect_type']), num(e['target']), num(e['effect_time']), num(e['effect_value'])]
               for e in sorted(fx.get(r['id'], []), key=lambda e: e['id'])]
    return [num(r['damage_value']), num(r['break_value']), num(r['element']), num(r['attribute']),
            round(num(r['cooltime']) / 100, 2), num(r['need_sp']), effects]


EL = {'fire': 1, 'water': 2, 'earth': 3, 'light': 4, 'dark': 5}
uid_base, stats = {}, {}
for base, rec in units.items():
    ids = obj(rec.get('_ids'))
    top = num(ids.get('unit'))
    u = um.get(top)
    if not u:
        continue
    rar = str(rec.get('Rarity') or '').lower()
    stats[base] = [rec.get('Name') or '', EL.get(str(rec.get('Type') or '').lower(), num(u['element'])),
                   num(rec.get('HP')), num(rec.get('ATK')), num(rec.get('DEF')),
                   2 if 'ascension' in rar else 1 if 'awoken' in rar else 0, top,
                   round(num(u['attack_delay'], 300) / 100, 2), num(u['break_power']), num(u['attribute']),
                   skill(ids.get('Skill')), skill(ids.get('Arts')), skill(ids.get('True Arts')), skill(ids.get('Super Arts'))]
    uid_base[str(top)] = base
    for form in obj(rec.get('_forms')).values():
        fid = ''.join(c for c in str(obj(form).get('Unit ID') or '') if c.isdigit())
        if fid:
            uid_base.setdefault(fid, base)

# equips: the top evolution of each picture id (highest stats), CT at MLB
equips = {}
for r in load('item_master.json'):
    if num(r.get('is_material')) or not num(r.get('item_skill_id')):
        continue
    img = str(num(r['image_id']))
    row = [r.get('name') or '', num(r['type']), num(r['hitpoint']), num(r['offence']), num(r['defence']),
           round(num(r.get('min_limitbreak_cooltime') or r.get('max_limitbreak_cooltime')) / 100, 2),
           skill(r['item_skill_id'])]
    old = equips.get(img)
    if not old or row[2] + row[3] + row[4] >= old[2] + old[3] + old[4]:
        equips[img] = row

quests = []
qd = load('quests_detail.json')
for d in qd.get('dungeons', []):
    for q in d.get('q', []):
        bosses = q.get('boss')
        if isinstance(bosses, str):
            bosses = obj(bosses)
        if not bosses:
            continue
        quests.append([num(q['id']), d.get('n') or '', q.get('n') or '', num(q.get('dif')),
                       [[num(b.get('u')), b.get('n') or '', num(b.get('el')), num(b.get('lv')), num(b.get('hp')),
                         num(b.get('atk')), num(b.get('def')), num(b.get('brk'))] for b in bosses]])

out = {'u': uid_base, 's': stats, 'e': equips, 'q': quests}
with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))
print(REGION, len(stats), 'units', len(uid_base), 'ids', len(equips), 'equips', len(quests), 'quests ->', OUT)
