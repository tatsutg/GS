"""
Build dlc/<Region>/_DATABASE/others/battle_units.json for the website's Battle Sim tab.

One row per unit base id (same keys as unitsv2_detail.json), from the unit's top form:
    base: [attack_delay_s, normal_break, attribute, element, skill, arts, true_arts, super_arts]
attribute: 1 physical, 2 magic. element: 1 fire, 2 water, 3 earth, 4 light, 5 dark.
Each skill is 0 (none) or [damage %, break, element, attribute, CT s, arts cost, effects],
effects = [[effect_type, target, seconds, value], ...] from skill_effect_master
(target 1 self, 2 allies, 4 enemy). The site's battle engine knows the common effect types.

Manual run from the repo root (GS_REGION=Global or Japan):
    python tools/build_battle_units.py [output-path]
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
REGION = os.environ.get('GS_REGION', 'Global')
OTHERS = os.path.join(GS, 'dlc', REGION, '_DATABASE', 'others')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(OTHERS, 'battle_units.json')


def load(name):
    with open(os.path.join(OTHERS, name), encoding='utf-8') as f:
        return json.load(f)


def num(v, d=0):
    try:
        return int(float(v))
    except (TypeError, ValueError):
        return d


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


out = {}
for base, rec in units.items():
    ids = rec.get('_ids') or {}
    u = um.get(num(ids.get('unit')))
    if not u:
        continue
    out[base] = [round(num(u['attack_delay'], 300) / 100, 2), num(u['break_power']), num(u['attribute']),
                 num(u['element']), skill(ids.get('Skill')), skill(ids.get('Arts')),
                 skill(ids.get('True Arts')), skill(ids.get('Super Arts'))]

with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))
print(REGION, len(out), 'units ->', OUT)
