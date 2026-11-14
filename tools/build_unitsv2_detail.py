"""
Build dlc/Global/_DATABASE/others/unitsv2_detail.json for the website's Units V2 tab.

Reads the decrypted GL DB exports in dlc/Global/_DATABASE/others/*.json and writes one
compact record per unit family (keyed by base_unit_id), shaped like a row of
the Units sheet so the site's Unit Info popup (openModal) can show it as-is.
Lower rarities go in each record's _forms. _tags = the unit's in-game tag ids
(tag_master / tag_category_master in data1; the site reads those two for names and groups).
_lim = unit_master.limited_id (standard / limited / crossover / free; see main()).

skill_master.json alone is ~22 MB, too big for the browser, so this script
does the joins offline.

Runs automatically: .github/workflows/build-unitsv2.yml (on push of the DB
files it reads). Manual run from the repo root:
    python tools/build_unitsv2_detail.py [output-path]
"""
import json
import os
import re
import sys
from datetime import date

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
REGION = os.environ.get('GS_REGION', 'Global')  # 'Global' or 'Japan'
SRC = os.path.join(GS, 'dlc', REGION, '_DATABASE', 'others')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(SRC, 'unitsv2_detail.json')

RAW = 'https://raw.githubusercontent.com/tatsutg/GS/main/dlc/'
ELEMENT = {1: 'Fire', 2: 'Water', 3: 'Earth', 4: 'Light', 5: 'Dark'}
RACE = {1: 'Human', 2: 'Beast', 3: 'Spirit', 4: 'Giant', 5: 'Machine', 6: 'Dragon', 7: 'God', 8: 'Demon'}
# unit_fantasy_evo_master.fantasy_evo_dest_type -> Dream Awaken path name
DA_PATH = {1: 'Crimson Dream', 2: 'Aqueous Dream', 3: 'Verdant Dream', 4: 'Luminous Dream', 5: 'Spectral Dream'}


def load(name):
    with open(os.path.join(SRC, name + '.json'), encoding='utf-8') as f:
        return json.load(f)


def clean(text):
    """Sheet text is one line; the site re-breaks sentences itself."""
    if not text or text == 'None':
        return ''
    return re.sub(r'\s*\n\s*', ' ', str(text)).strip()


def release_map(kind):
    """image id -> release date from release_dates.json (hand-kept, no Google Sheet):
    the 'gl' date on the Global build, the 'jp' date on the Japan build. A value may carry the time
    ('2026-11-06 15:00', the server's own clock): then 'rel' is an exact timestamp (see stamp())."""
    path = os.path.join(GS, 'release_dates.json')
    if not os.path.exists(path):
        return {}
    with open(path, encoding='utf-8') as f:
        data = json.load(f)
    section = data.get('units' if kind == 'unit' else 'equips', {})
    key = 'gl' if REGION == 'Global' else 'jp'
    out = {int(k): stamp(v[key], REGION) for k, v in section.items() if isinstance(v, dict) and v.get(key)}
    return {k: v for k, v in out.items() if v}

def stamp(v, region):
    """A release_dates.json value -> what the site gets in 'rel':
    'YYYY-MM-DD' stays a day; 'YYYY-MM-DD HH:MM' becomes 'YYYY-MM-DDTHH:MM:00+09:00' (jp: JST) or the Pacific
    offset of that day (gl: -08:00 PST / -07:00 PDT, US rule: 2nd Sunday of March to 1st Sunday of November)."""
    v = str(v or '').strip()
    m = re.match(r'^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{1,2}):(\d{2}))?$', v)
    if not m:
        return ''
    y, mo, d = int(m[1]), int(m[2]), int(m[3])
    if m[4] is None:
        return f'{y:04d}-{mo:02d}-{d:02d}'
    h, mi = int(m[4]), int(m[5])
    if region == 'Japan':
        off = '+09:00'
    else:
        def sunday(month, nth):   # day of the nth Sunday of that month
            first = date(y, month, 1)
            return 1 + (6 - first.weekday()) % 7 + 7 * (nth - 1)
        start, end = (3, sunday(3, 2), 2), (11, sunday(11, 1), 2)
        off = '-07:00' if start <= (mo, d, h) < end else '-08:00'
    return f'{y:04d}-{mo:02d}-{d:02d}T{h:02d}:{mi:02d}:00{off}'


def num(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return 0


def rarity_label(r):
    return 'Ascension' if r >= 7 else 'Awoken' if r == 6 else f'{r}★'


def form_prefix(r):
    if r >= 7:
        return 'Asc★'
    if r == 6:
        return 'Awk★'
    return f'{r}★'


def form_key(r):
    return 'asc' if r >= 7 else 'awk' if r == 6 else f'{r}★'


def main():
    units = load('unit_master')
    rel_by_id = release_map('unit')  # unit image id -> release date (GL on Global, JP on Japan)
    skills = {s['id']: s for s in load('skill_master')}
    relations = load('skill_relation_master')
    fevo = load('unit_fantasy_evo_master')
    limitbreak = load('unit_limitbreak_master')
    # effect rows per skill (skill_effect_master.skill_id), for the admin id tags
    fx = {}
    for row in load('skill_effect_master'):
        if row.get('skill_id'):
            fx.setdefault(row['skill_id'], []).append(row['id'])
    for v in fx.values():
        v.sort()

    # same filter as js/unitsv2.js
    units = [u for u in units if u and u.get('is_material') != 1 and u.get('element') in ELEMENT
             and u.get('name') and u.get('base_unit_id', 0) < 40000]
    fam = {}
    for u in units:
        fam.setdefault(u['base_unit_id'], []).append(u)

    # passives: relation_type 0, relation_id = base_unit_id, need_level = unit level that unlocks it
    passives_by_base = {}
    for r in relations:
        if r['relation_type'] == 0:
            passives_by_base.setdefault(r['relation_id'], []).append(r)

    da_by_unit = {}
    for row in fevo:
        da_by_unit.setdefault(row['unit_id'], []).append(row)

    enh = {}
    for row in limitbreak:
        b = row['base_unit_id']
        cur = enh.get(b)
        if cur is None or row['limit_break_level'] > cur['limit_break_level']:
            enh[b] = row

    def form_data(u, base, e, with_da):
        """Everything that changes between rarities: stats, max level, abilities, passives (and D.A on the top form).
        _ids holds the DB ids, shown in the popup only when SHOW_UNITSV2_DB_IDS (js/core.js, = ENABLE_ADMIN_EDITOR) is on."""
        d = {
            'Rarity': rarity_label(u['rarity']),
            'Max Lv': num(u.get('level_max')),
            'HP': u.get('hitpoint_max') or 0,
            'ATK': u.get('offence_max') or 0,
            'DEF': u.get('defence_max') or 0,
            'Unit ID': f"unit_thumbnail_{u['id']}.png",
            '_ids': {'unit': u['id'], 'base': base},
        }
        ids = d['_ids']
        if e:
            # limit break bonus at the highest limit break level; the table is per unit family
            # (unit_limitbreak_master has no rarity), so every form shows the same bonus
            ids['LB'] = e.get('id')
            d['HP Enhance'] = e.get('buff_hp') or 0
            d['ATK Enhance'] = e.get('buff_attack') or 0
            d['DEF Enhance'] = e.get('buff_defence') or 0

        def put(prefix, sid, ct=False):
            s = skills.get(sid) if sid else None
            if not s:
                return
            d[prefix] = s['name']
            ids[prefix] = s['id']
            if fx.get(s['id']):
                ids[prefix + ' FX'] = fx[s['id']]
            d[prefix + ' Detail'] = clean(s.get('description'))
            d[prefix + ' BREAK'] = num(s.get('break_value'))
            if ct and num(s.get('cooltime')):
                ctv = num(s.get('cooltime')) / 100
                d['Skill CT'] = int(ctv) if ctv == int(ctv) else ctv

        put('Skill', u.get('chargearts_skill_id'), ct=True)
        put('Arts', u.get('full_chargearts_skill_id'))
        put('True Arts', u.get('full_chargearts_skill_id2'))
        put('Super Arts', u.get('super_full_chargearts_skill_id'))

        # passives: per family (name without "Lv N"), keep the highest one this form's max level unlocks
        lvmax = num(u.get('level_max')) or 999
        best = {}
        order = []
        for r in sorted(passives_by_base.get(base, []), key=lambda x: (x['need_level'], x['id'])):
            if r['need_level'] > lvmax:
                continue
            s = skills.get(r['skill_id'])
            if not s or not s.get('name'):
                continue
            key = re.sub(r'\s*Lv\s*\d+\s*$', '', s['name']).strip().lower()
            if key not in best:
                order.append(key)
            best[key] = s
        for i, key in enumerate(order[:6], 1):
            s = best[key]
            d[f'Passives {i}'] = s['name']
            ids[f'Passives {i}'] = s['id']
            if fx.get(s['id']):
                ids[f'Passives {i} FX'] = fx[s['id']]
            d[f'Passives {i} Detail'] = clean(s.get('description'))
            if s.get('tumbnail_name1'):
                d[f'Passives {i} Icon'] = f"{RAW}ability/thumbnail/{s['tumbnail_name1']}"

        if with_da:
            # Dream Awaken paths (unit_fantasy_evo_master, on the top form)
            for n, row in enumerate(sorted(da_by_unit.get(u['id'], []), key=lambda x: x['id']), 1):
                ids[f'D.A {n}'] = row['id']
                d[f'D.A {n}-Path'] = DA_PATH.get(row['fantasy_evo_dest_type'], f"Dream {row['fantasy_evo_dest_type']}")
                sub = 0
                for k in ('skill1_id', 'skill2_id', 'skill3_id'):
                    s = skills.get(row.get(k))
                    if not s:
                        continue
                    sub += 1
                    d[f'D.A {n} Name-{sub}'] = s['name']
                    ids[f'D.A {n}-{sub}'] = s['id']
                    if fx.get(s['id']):
                        ids[f'D.A {n}-{sub} FX'] = fx[s['id']]
                    d[f'D.A {n} Detail-{sub}'] = clean(s.get('description'))
                    if s.get('tumbnail_name1'):
                        d[f'D.A {n} Icon-{sub}'] = f"{RAW}ability/thumbnail/{s['tumbnail_name1']}"
        return d

    out = {}
    for base, forms in fam.items():
        forms.sort(key=lambda x: (x['rarity'], x['id']))
        top = forms[-1]
        item = {
            'Name': forms[0]['name'] if top['rarity'] < 6 else top['name'],
            '_ids': {'unit': top['id'], 'base': base},
            'Unit ID': f"unit_thumbnail_{top['id']}.png",
            'Image': f"{RAW}unit/thumbnail/unit_thumbnail_{top['id']}.png",
            'Type': ELEMENT.get(top['element'], ''),
            'Race': RACE.get(top['race'], 'Unknown'),
            'V.A': top.get('seiyu') or '',
            'SERVER': REGION,
            '_v2': 1,
        }
        # in-game Tag Search tags (tag_master ids), every form's, top form first
        tags = []
        for u in [top] + forms[::-1]:
            try:
                ids_ = json.loads(u.get('tags') or '[]') if u.get('tags') not in (None, 'None', '') else []
            except ValueError:
                ids_ = []
            tags += [t for t in ids_ if t not in tags]
        if tags:
            item['_tags'] = tags
        # unit_master.limited_id: 0 standard summon pool, 1 / 2 / 3 / 5 banner-only (limited), 4 crossover,
        # 11 / 12 / 13 not summonable (story / event / free units)
        lim = max(num(u.get('limited_id')) for u in forms)
        if lim:
            item['_lim'] = lim
        # release date from the sheet: earliest dated form of the family (GL date on Global, JP on Japan)
        rels = [rel_by_id[u['id']] for u in forms if u['id'] in rel_by_id]
        if rels:
            item['rel'] = min(rels)
        e = enh.get(base) or {}
        top_fields = form_data(top, base, e, with_da=True)
        item.update(top_fields)
        # every lower form, keyed like the popup's form selector (2★..5★, awk, asc); the top form ('default') is the item itself
        item['_forms'] = {}
        for u in forms:
            if u is top or u['rarity'] < 2:
                continue
            item['_forms'][form_key(u['rarity'])] = form_data(u, base, e, with_da=False)

        # forms row (thumb + art + lore per rarity)
        for u in forms:
            p = form_prefix(u['rarity'])
            item[f'{p} Name'] = u['name']
            item[f'{p} Thumb'] = f"{RAW}unit/thumbnail/unit_thumbnail_{u['id']}.png"
            item[f'{p} Art'] = f"{RAW}unit/detail/unit_detail_{u['id']}.png"
            if u.get('description'):
                item[f'{p} Lore'] = u['description']

        out[str(base)] = item

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, separators=(',', ':'))
    print(f'{len(out)} families -> {OUT} ({os.path.getsize(OUT) // 1024} KB)')


if __name__ == '__main__':
    main()
    # which bases exist on only one server (the site's EN | JP switch reads it)
    import build_v2_servers
    build_v2_servers.main()
