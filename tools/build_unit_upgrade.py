# Builds unit_upgrade.json for the site's unit modal: per-unit evolution/awaken chain
# (with materials + Gran cost) and the shared limit-break tables (stat buffs + equip slots).
# Ascension materials are not in the exported masters, so only evolution (awaken) is covered.
import os, json, glob, sys

sys.stdout.reconfigure(encoding='utf-8')
REGION = os.environ.get('GS_REGION', 'Global')
HERE = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(HERE, '..', 'dlc', REGION, '_DATABASE', 'others')
OUT = os.path.join(HERE, '..', 'dlc', REGION, '_DATABASE', 'others', 'unit_upgrade.json')


def load(name):
    p = os.path.join(DB, name + '.json')
    d = json.load(open(p, encoding='utf-8'))
    return d if isinstance(d, list) else d.get('data', d)


def num(x):
    try:
        return int(x)
    except (TypeError, ValueError):
        return 0


um = load('unit_master')
ev = load('unit_evolution_master')
mat = load('material_master')
lb = load('unit_limitbreak_master')

uname = {str(r['id']): r.get('name') for r in um if isinstance(r, dict)}
mname = {str(r['id']): r.get('name') for r in mat if isinstance(r, dict)}
ubase = {str(r['id']): num(r.get('base_unit_id')) for r in um if isinstance(r, dict)}  # LB table is keyed by the unit's base_unit_id


def matname(mid):
    s = str(mid)
    return mname.get(s) or uname.get(s) or ('#' + s)


DLC_ROOT = os.path.join(HERE, '..', 'dlc')


def icon_rel(t, i):
    # repo-relative art path the site's getCdnUrl serves (material -> jsdelivr, unit/item -> pages.dev)
    tpl = {5: 'material/material_thumbnail_%s.png', 9: 'unit/thumbnail/unit_thumbnail_%s.png',
           7: 'item/thumbnail/item_thumbnail_%s.png', 8: 'item/thumbnail/item_thumbnail_%s.png'}.get(t)
    if not tpl:
        return ''
    for reg in (REGION, 'Japan', 'Global'):
        rel = '%s/%s' % (reg, tpl % i)
        if os.path.exists(os.path.join(DLC_ROOT, rel)):
            return rel
    return ''


# evolution map: base_unit_id -> row
nexts = {r['base_unit_id']: r for r in ev if isinstance(r, dict)}
allnext = {r['next_unit_id'] for r in ev if isinstance(r, dict)}
roots = [b for b in nexts if b not in allnext]

# build the full chain for each root, and the per-step materials
chains = []
for root in roots:
    forms = [root]
    steps = []
    cur = root
    seen = {root}
    while cur in nexts and nexts[cur]['next_unit_id'] not in seen:
        r = nexts[cur]
        mats = []
        for k in range(1, 6):
            t = num(r.get('material_%d_type' % k))
            mid = r.get('material_%d_id' % k)
            v = num(r.get('material_%d_value' % k))
            if mid and v:
                mats.append([matname(mid), v, icon_rel(t, mid)])
        steps.append({'to': r['next_unit_id'], 'coin': num(r.get('need_coin')), 'mats': mats})
        cur = r['next_unit_id']
        forms.append(cur)
        seen.add(cur)
    chains.append((forms, steps))

# LB tables keyed by limit_break_exp_id: [level, +hp, +atk, +def, luck, [slot rarities r1..r4]]
lb_tables = {}
for r in lb:
    if not isinstance(r, dict):
        continue
    key = str(r.get('base_unit_id'))
    slots = [num(r.get(s + '_rarity')) if num(r.get(s + '_type')) != -1 else -1
             for s in ('equipped1', 'equipped2', 'equipped3', 'equipped3_2')]
    types = [num(r.get(s + '_type')) for s in ('equipped1', 'equipped2', 'equipped3', 'equipped3_2')]
    e = lb_tables.setdefault(key, {'rows': [], 'types': [-1, -1, -1, -1]})
    e['types'] = [max(a, b) for a, b in zip(e['types'], types)]   # slot3_2 type is -1 until it unlocks; keep the real one
    lb_tables[key]['rows'].append([num(r.get('limit_break_level')), num(r.get('buff_hp')),
                                   num(r.get('buff_attack')), num(r.get('buff_defence')),
                                   num(r.get('buff_fortune_level')), slots])
for v in lb_tables.values():
    v['rows'].sort(key=lambda x: x[0])

# per-form lookup: each form id -> {chain forms+rarity+name, steps, lbId}
# rank comes from the form id's rarity digit (position 5): 1-5 = N★, 6 = AWK, 7 = ASC
RK_DIGIT = {'1': '1★', '2': '2★', '3': '3★', '4': '4★', '5': '5★', '6': 'AWK', '7': 'ASC', '8': 'ASC2'}
def rank_of(fid):
    s = str(fid)
    return RK_DIGIT.get(s[5], 'EX') if len(s) >= 6 else 'EX'
units = {}
for forms, steps in chains:
    formmeta = [{'id': f, 'n': uname.get(str(f), str(f)), 'rk': rank_of(f)} for f in forms]
    entry = {'forms': formmeta, 'steps': steps, 'lb': ubase.get(str(forms[-1]), 0)}
    for f in forms:
        units[str(f)] = entry

EQ_TYPE = {1: 'Phys Atk', 2: 'Mag Atk', 3: 'Defense', 4: 'Heal', 5: 'Support', -1: 'Locked'}
out = {'u': units, 'lb': lb_tables, 'eqType': EQ_TYPE}
json.dump(out, open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('%s units, %s LB tables -> %s (%d KB)' % (len(units), len(lb_tables), OUT, os.path.getsize(OUT) // 1024))
