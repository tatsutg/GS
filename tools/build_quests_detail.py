"""
Build dlc/Global/_DATABASE/others/quests_detail.json for the website's Quests tab.

Reads the decrypted GL DB exports in dlc/Global/_DATABASE/*/ and writes one row per dungeon:
  - name, category, banner pictures (dlc/Global/banner/dungeon_banner[_top]_<id>.png)
  - schedule: the open windows from dungeon_launcher_master (start, end; times are PT, "-08:00" written
    as the game does), only those that end after (build time - 2 days), plus the weekday of the
    Crest Palaces (dungeon_type 8001..8007 = Monday..Sunday)
  - quests: name, summary, solo / multi, stamina, difficulty, the drops the game shows (display_item_list) and the rewards;
    a mission reward row ends with its condition [type, value(, unit names)] from quest_mission_master: the site
    words it with the game's own strings (commonstring TXT_QUEST_MISSION_<type>, e.g. 8 = "Clear within {0} seconds.")
  - bosses: per quest (HP / ATK / DEF / break, art from dlc/unit/thumbnail) and boss_info_master notes
  - stages: per quest the stage count and each stage's spawn variants (chance %), from battle_relation_master
    (the enemy placement per stage is not in the export); per dungeon the enemy roster ('foes') from enemy_master
  - icons: "<type>:<id>" -> picture of each drop / reward
Categories:
  8001-8007 / 7 Crest Palace, 3002 Boss & Trial events (1 h windows = Rotating Boss), 8 Summoners Road,
  1001-1006 / 4001 Material quests, 2002 Exploring, 0 Story, 2 Events, 6 Side Stories.

Runs automatically: .github/workflows/build-quests.yml. Manual run from the repo root:
    python tools/build_quests_detail.py [output-path]
"""
import glob
import json
import os
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = os.path.join(GS, 'dlc')
REGION = os.environ.get('GS_REGION', 'Global')  # 'Global' or 'Japan'
DB = os.path.join(DLC, REGION, '_DATABASE')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(DB, 'others', 'quests_detail.json')

sys.path.insert(0, HERE)
from lua_boss_text import Texts  # noqa: E402
# the game's battle-message mechanics for each boss (immunities, "only crit", ...), same source as battle_sim field 20
TEXTS = Texts([os.path.join(DLC, 'Global', 'additional_lua'), os.path.join(DLC, REGION, 'additional_lua')],
              [os.path.join(DLC, REGION, 'additional_lua'), os.path.join(DLC, 'Japan', 'additional_lua')])

JP = re.compile(r'[぀-ヿ一-鿿]') if REGION == 'Global' else re.compile(r'(?!)')  # on Japan, names ARE Japanese
# GL ships a placeholder name for some dungeons (only the banner has the real title): (region, dungeon id) -> name
NAME_FIX = {
    ('Global', 6010): 'Awakening Power',   # dungeon_master says "Side Story Dungeon"; Rayas' side story, banner title
}
WEEKDAY = {8001: 'Monday', 8002: 'Tuesday', 8003: 'Wednesday', 8004: 'Thursday', 8005: 'Friday', 8006: 'Saturday', 8007: 'Sunday'}
CAT = {0: 'Story', 2: 'Events', 6: 'Side Stories', 8: 'Summoners Road', 2002: 'Exploring', 7: 'Crest Palace', 4001: 'Material Quests'}
# reward / drop "type" codes used by quest_master and display_item_list
# (checked against the tables the ids belong to: 7 item_recipe, 8 item, 9 unit, 13 food, 22 event_item, 24 tool)
RTYPE = {2: 'Gren', 5: 'Material', 7: 'Equip recipe', 8: 'Equip', 9: 'Unit', 11: 'Crystals', 13: 'Food',
         17: 'Key', 18: 'Alch', 22: 'Event item', 24: 'Item', 25: 'Rainbow Gems'}
# some boss_info_master rows still carry the JP resistance names
RES_EN = {'毒耐性': 'Poison Res.', '暗闇耐性': 'Blind Res.', '封印耐性': 'Seal Res.', '麻痺耐性': 'Paralysis Res.', '病気耐性': 'Disease Res.',
          '気絶耐性': 'Faint Res.', '氷結耐性': 'Freeze Res.', '燃焼耐性': 'Burn Res.', '凍結耐性': 'Freeze Res.', '呪い耐性': 'Curse Res.'}
MAX_WIN = 200     # open windows kept per dungeon
# dungeons whose enemy ids do not follow their quests, so the id rule in bosses_of() puts bosses in the wrong quest:
# only the quests that name their boss (quest_master succession_enemy_id) get one; the rest stay in the dungeon roster
# (Training: 13 enemies for 12 tutorial quests, e.g. Takedown Battle's Valzandeth had landed in "Faster Arts")
NO_ID_RULE = {1001500}
# quests the id rule places on the wrong boss: quest_id -> [enemy_id, ...] (is_boss rows), set by hand from
# enemy_master. Mankind Ruins: the heuristic put Sealed God Auge on Area 9 (it is Area 8) and dropped the real
# Area 9 (Insect Princess Radachne + Wyrm). These override the quest's boss list.
BOSS_FIX = {
    2061111: [2061160],             # Area 8: Sealed God Auge
    2061112: [2061165, 2061166],    # [Challenge] Area 8: Auge + Demented Scientist Keit
    2061113: [2061170, 2061177],    # Area 9: Insect Princess Radachne + Wyrm
    2061114: [2061180, 2061187],    # [Challenge] Area 9: Radachne + Wyrm
    # Glowing Sanctuary / 光耀竜の強襲 (Radiant Dragon Fosradius): daily-dungeon tiers the id rule mis-mapped.
    # HP matches Altema (rinkounoseiiki): INT/中級 400k, ADV/上級 630k, PRO/超級 1M, AWK/覚醒 3M.
    5000501: [500144109],
    5000502: [500144209],
    5000503: [500144409],
    5000504: [50123],
    # Cross Battle β (MEGA Goldola β) and Awakening Cursed Armor X (Phantom Ragsherum): 6 boss rows in the dungeon's
    # id range (stats rise with the id) for 5 quests; battle_relation_master gives the top quest 2 battles and the
    # others 1, so ids in order = BGN, INT, ADV, PRO, top battle 1, top battle 2 (Ragsherum's battle 2 has its own
    # BGM GS506_EVENT_03 and the long 227-line script 2027007).
    2001201: [2001201],
    2001202: [2001202],
    2001203: [2001203],
    2001204: [2001204],
    2001205: [2001205, 2001206],
    2027001: [2027002],
    2027002: [2027003],
    2027003: [2027004],
    2027004: [2027005],
    2027005: [2027006, 2027007],
}


def load(name):
    hits = glob.glob(os.path.join(DB, '*', name + '.json'))
    if not hits:
        return []
    with open(hits[0], encoding='utf-8') as f:
        return json.load(f)


def clean(text):
    if not text or text in ('None', '0'):
        return ''
    return re.sub(r'[ \t]*\n[ \t]*', '\n', str(text)).strip()


def num(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return 0


def when(s):
    try:
        return datetime.fromisoformat(str(s).replace(' ', 'T'))
    except ValueError:
        return None


def img(rel):
    """Repo path of a picture, or ''. Since the dlc restructure pictures live under dlc/<region>/: a bare
    'event/...' is looked up in the build's region folder first, then flat (old layout). Orb shop (town/)
    art is shared UI, so Japan falls back to the Global copy."""
    if not rel:
        return ''
    other = 'Japan' if REGION == 'Global' else 'Global'
    # GL ships only part of the material / item art: the other region's copy of the same id is the same picture
    cands = [rel] if rel.startswith(('Global/', 'Japan/')) else [f'{REGION}/{rel}', rel, f'{other}/{rel}']
    if rel.startswith('Japan/town/'):
        cands.append('Global/' + rel[len('Japan/'):])
    return next((c for c in cands if os.path.exists(os.path.join(DLC, c))), '')


def main():
    dungeons = load('dungeon_master')
    # map_master: map_id -> region/chapter name (the world-map chapter a Story dungeon belongs to)
    maps = {num(r.get('id')): clean(r.get('name')) for r in load('map_master')}
    quests = load('quest_master')
    launch = defaultdict(list)
    for x in load('dungeon_launcher_master'):
        a, b = when(x['start_at']), when(x['end_at'])
        if a and b:
            launch[x['dungeon_id']].append((a, b))

    # names for drops / rewards
    names = {5: {m['id']: clean(m['name']) for m in load('material_master')},
             13: {f['id']: clean(f['name']) for f in load('food_master')},
             22: {e['id']: clean(e['name']) for e in load('event_item_master')},
             24: {t['id']: clean(t['name']) for t in load('tool_master')},
             17: {k['id']: clean(k['name']) for k in load('key_master')}}
    eq = {}
    for x in sorted(load('item_master'), key=lambda x: x['evolution_stage'] if x['evolution_stage'] != 99 else -1):
        eq[x['id']] = clean(x['name'])
    names[7] = names[8] = eq
    units = {u['id']: clean(u['name']) for u in load('unit_master')}
    # unit pictures: the build's region first, then the other region (GL ships no dlc/Global/unit/thumbnail,
    # and enemy / unit ids are the same on both servers)
    def thumb_dir(reg):
        d = os.path.join(DLC, reg, 'unit', 'thumbnail')
        return set(os.listdir(d)) if os.path.isdir(d) else set()
    thumb_sets = [(reg, thumb_dir(reg)) for reg in (REGION, 'Japan' if REGION == 'Global' else 'Global')]

    # enemies the game ships no thumbnail for: a picture drawn from their battle sprite (tools/make_enemy_sprites.py)
    sprites = set(os.listdir(os.path.join(DLC, 'ASSETS', 'enemy_sprite'))) if os.path.isdir(os.path.join(DLC, 'ASSETS', 'enemy_sprite')) else set()

    def unit_thumb(uid):
        f = f'unit_thumbnail_{uid}.png'
        return next((f'{reg}/unit/thumbnail/{f}' for reg, s in thumb_sets if f in s),
                    f'ASSETS/enemy_sprite/enemy_sprite_{uid}.png' if f'enemy_sprite_{uid}.png' in sprites else '')
    names[9] = units
    # mission conditions: id -> [type, value] (+ unit names for type 13 "Clear with {0} in party", value_list = base unit ids)
    base_name = {}
    for u in sorted(load('unit_master'), key=lambda u: u['id']):
        nm = clean(u['name'])
        b = num(u.get('base_unit_id'))
        if b and nm and not nm.startswith('[') and b not in base_name:
            base_name[b] = nm
    missions = {}
    for m in load('quest_mission_master'):
        spec = [num(m.get('type')), num(m.get('value'))]
        try:
            ids = json.loads(m.get('value_list') or '[]')
        except (TypeError, ValueError):
            ids = []
        if spec[0] == 13 and isinstance(ids, list) and ids:
            spec.append([base_name.get(num(i), '') for i in ids])
        missions[num(m['id'])] = spec

    # icons for drops / rewards: data['icons']["<type>:<id>"] = repo path (the site shows a badge when there is none)
    ithumb = set((os.listdir(os.path.join(DLC, 'Japan', 'item', 'thumbnail')) if os.path.isdir(os.path.join(DLC, 'Japan', 'item', 'thumbnail')) else []))   # the full set lives in Japan/
    try:
        with open(os.path.join(DB, 'others', 'items_detail.json'), encoding='utf-8') as f:
            item_img = {(x['k'], x['id']): x.get('img', '') for x in json.load(f)['items']}
    except (OSError, ValueError, KeyError):
        item_img = {}
    # currencies: the game's orb shop thumbnails (big, framed like the item tiles)
    FIXED = {2: f'{REGION}/town/alchemy/orb_shop/thumbnail/gran_thumbnail.png', 11: f'{REGION}/town/alchemy/orb_shop/thumbnail/crystal_thumbnail.png', 18: f'{REGION}/town/alchemy/orb_shop/thumbnail/orb_thumbnail.png',
             25: 'ASSETS/icon_rainbow_gem.png', 15: f'{REGION}/town/alchemy/orb_shop/thumbnail/stone_unit_thumbnail.png'}
    icons = {}

    def icon_of(t, i):
        if t in FIXED:
            return img(FIXED[t])
        if t == 17:   # dungeon keys (key_master): the game's orb shop key pictures
            return img(f'{REGION}/town/alchemy/orb_shop/thumbnail/dungeon_key_thumbnail_{i}.png')
        if t in (7, 8):
            s = str(i)
            if len(s) >= 9:
                b = int(s[1:5])
                for f in (f'item_thumbnail_1{b:04d}1.png', f'item_thumbnail_1{b:04d}0.png'):
                    if f in ithumb:
                        return f'Japan/item/thumbnail/{f}'
            return ''
        if t == 9:
            return unit_thumb(i)
        key = {5: 'mat', 13: 'food', 22: 'event', 24: 'tool'}.get(t)
        if not key:
            return ''
        own = {5: f'material/material_thumbnail_{i}.png', 13: f'cook/thumbnail/cook_thumbnail_{i}.png', 22: f'event/event_icon_{i}.png'}.get(t)
        return item_img.get((key, i)) or img(own)

    def thing(t, i, n=0):
        t, i = num(t), num(i)
        if not t:
            return None
        label = RTYPE.get(t, f'Type {t}')
        name = names.get(t, {}).get(i, '') or label
        k = f'{t}:{i}'
        if k not in icons:
            icons[k] = icon_of(t, i)
        return [t, i, name, label, num(n)]

    # ---- bosses ----
    # The export has no battle (enemy placement) table, but boss enemy ids follow the dungeon id:
    #   dungeon D < 1000000: D*100 + 20*(quest index) + k   (488 -> 48800, 48820, 48840, 48863)
    #   dungeon D >= 1000000: D + k                          (5040900 -> 5040900, 5040905, ...)
    # Art: the enemy's unit thumbnail (dlc/<region>/unit/thumbnail, see unit_thumb) when the repo has it.
    # boss_info_master adds a description and status resistances for some bosses (Summoners Road etc.).
    unit_rows = {u['id']: u for u in load('unit_master')}
    boss_enemies = {e['id']: e for e in load('enemy_master') if num(e.get('is_boss')) == 1}
    boss_info = {}
    for b in load('boss_info_master'):
        try:
            res = [[RES_EN.get(s['name'], s['name']).replace('Paralyze', 'Paralysis'), s['value']] for s in json.loads(b.get('status_json') or '{}').get('status', [])]
        except (TypeError, ValueError):
            res = []
        e = boss_enemies.get(b['enemy_id'])
        key = str(e['unit_id']) if e else str(b['enemy_id'])
        boss_info.setdefault(key, {'desc': clean(b['description']), 'res': res})

    def boss_row(e):
        u = unit_rows.get(e['unit_id'], {})
        name = clean(e.get('name')) or clean(u.get('name')) or f"Enemy {e['unit_id']}"
        row = {'n': name, 'u': e['unit_id'], 'img': unit_thumb(e['unit_id']),
               'el': num(u.get('element')), 'lv': num(e.get('level')), 'hp': num(e.get('hp')), 'atk': num(e.get('attack')),
               'def': num(e.get('deffence')), 'brk': num(e.get('break_capacity'))}
        mech = TEXTS.mechanics([num(e.get('id')), num(e['unit_id'])], name)
        if mech:
            row['mech'] = mech
        # exact per-enemy ailment resistance % (enemy_master.resistant_*_base), the values Altema lists;
        # order: poison, blind(darkness), seal(silent), paralysis(paralyze), disease(sickness), faint(stun), freeze, burn
        row['ail'] = [num(e.get(f'resistant_{k}_base')) for k in
                      ('poison', 'darkness', 'silent', 'paralyze', 'sickness', 'stun', 'freeze', 'burn')]
        return row

    def bosses_of(did, names):
        """[[quest index or -1, boss row, enemy id], ...] for a dungeon (names = its quest names in order)"""
        nq = len(names)
        base, stride = (did * 100, 20) if did < 1000000 else (did, 5)
        ids = [i for i in range(base, base + 100) if i in boss_enemies]
        # A boss with one row per difficulty (or an even share per quest) sits in its quests in id order,
        # whatever the id spacing (e.g. Shrine of Oblivion: 4000217/227/237/247). Others keep the stride rule.
        by_unit = defaultdict(list)
        for i in ids:
            by_unit[boss_enemies[i]['unit_id']].append(i)
        qi = {}
        if nq > 1:
            for rows in by_unit.values():
                if len(rows) % nq == 0:
                    per = len(rows) // nq
                    qi.update({i: k // per for k, i in enumerate(rows)})
        place = {i: qi.get(i, (i - base) // stride) for i in ids}
        # Bosses of the first k quests sit at the stride (+0, +5, ... for k quests); after a gap, the last quests
        # (EX1 / EX2 / true EX / true EX extreme) take the remaining ids in order at a wider spacing
        # (e.g. Cybermancy;Lostpia: 10 quests at +0..+45, then 4 EX quests at +60/+70/+80/+90).
        # A Daily EX quest is listed first but was added last: its boss has the last id (+75 after +60/+65/+70).
        have = set(ids)
        k = 0
        while base + k * stride in have:
            k += 1
        tail = [i for i in ids if i - base >= k * stride and i not in qi]
        slots = sorted(range(k, nq), key=lambda n: bool(re.search(r'Daily EX|デイリーEX', names[n])))
        if 0 < k < nq and len(tail) == nq - k and any(place[i] != n for n, i in zip(slots, tail)):
            place.update(dict(zip(tail, slots)))
        if nq == 1:
            place = dict.fromkeys(ids, 0)  # one quest: every boss is in it
        elif len({q for q in place.values() if q < nq}) < nq and len(ids) == nq                 and all(num(boss_enemies[a].get('hp')) <= num(boss_enemies[b].get('hp')) for a, b in zip(ids, ids[1:])):
            # quests left empty, one boss per quest whose HP rises in id order (e.g. EX1 / SPEX / AWK at +1/+5/+9)
            place = {i: k for k, i in enumerate(ids)}
        return [(place[i] if place[i] < nq else -1, boss_row(boss_enemies[i]), i) for i in ids]

    # stages: battle_relation_master = quest -> battle_no (stage 1, 2, ...) -> spawn variants with a weight (of 10000).
    # The enemy placement of each variant (battlemaster) is not in the export, so per quest the site shows the stage
    # count and each stage's variant chances (rare spawns), and per dungeon the enemy roster below.
    stages = defaultdict(lambda: defaultdict(list))
    for r in load('battle_relation_master'):
        stages[num(r['quest_id'])][num(r['battle_no'])].append(num(r['weight']))
    all_enemies = {e['id']: e for e in load('enemy_master')}

    def roster(did):
        """every enemy of a dungeon (enemy ids follow the dungeon id, as for the bosses): weakest first, bosses last"""
        rng = range(did * 100, did * 100 + 100) if did < 1000000 else range(did, did + 100)
        seen, out = set(), []
        for i in rng:
            e = all_enemies.get(i)
            if not e or (e['unit_id'], num(e.get('hp'))) in seen:
                continue
            seen.add((e['unit_id'], num(e.get('hp'))))
            b = boss_row(e)
            out.append([b['n'], b['u'], b['img'], b['el'], b['lv'], b['hp'], 1 if num(e.get('is_boss')) == 1 else 0])
        return sorted(out, key=lambda x: (x[6], x[5]))

    by_dungeon = defaultdict(list)
    for q in quests:
        if num(q.get('dungeon_id')):
            by_dungeon[num(q['dungeon_id'])].append(q)

    now = datetime.now(timezone.utc)
    keep_from = now - timedelta(days=2)
    out = []
    used_info = set()
    for d in dungeons:
        name = clean(d['name'])
        if not name or JP.search(name):
            continue
        name = NAME_FIX.get((REGION, d['id']), name)
        t = d['dungeon_type']
        wins = sorted(launch.get(d['id'], []))
        spans = [(b - a).total_seconds() for a, b in wins[-20:]]
        if t in WEEKDAY:
            cat = 'Crest Palace'
        elif 1001 <= t <= 1006 or t == 4001:
            cat = 'Material Quests'
        elif t == 3002:
            if spans and max(spans) <= 3600:
                cat = 'Rotating Boss'
            elif '【Ultra】' in name or 'Ultra' in name:
                cat = 'Ultra Boss & Trials'
            else:
                cat = 'Boss & Trials'
        else:
            cat = CAT.get(t, 'Other')
        up = [(a, b) for a, b in wins if b >= keep_from]
        qs = []
        for q in sorted(by_dungeon.get(d['id'], []), key=lambda q: (num(q.get('quest_no')), q['id'])):
            if not clean(q['name']):
                continue
            try:
                shown = json.loads(q.get('display_item_list') or '[]')
            except (TypeError, ValueError):
                shown = []
            drops = [x for x in (thing(s.get('type'), s.get('id')) for s in (shown if isinstance(shown, list) else [])) if x]
            rewards = []
            for k, label in (('questmission1', 'Mission 1'), ('questmission2', 'Mission 2'), ('questmission3', 'Mission 3'), ('complete', 'Clear')):
                r = thing(q.get(k + '_reward_type'), q.get(k + '_reward_id'), q.get(k + '_reward_value'))
                if r:
                    cond = missions.get(num(q.get(k + '_id'))) if k != 'complete' else None
                    rewards.append([label] + r + ([cond] if cond else []))
            qs.append({'id': q['id'], 'n': clean(q['name']), 'sta': num(q.get('stamina')), 'dif': num(q.get('difficulty')),
                       'rank': num(q.get('need_rank')), 'gren': num(q.get('drop_coin')), 'drops': drops, 'rew': rewards,
                       # summary (the game breaks its lines by hand: joined), multi = co-op quest (0 = solo only)
                       'desc': re.sub(r'\s*\n\s*', ' ', clean(q.get('description'))), 'multi': num(q.get('is_multi')),
                       # stages: per stage the spawn variants' chances in % (one entry = always the same battle)
                       'st': [[round(w / max(1, sum(ws)) * 100, 2) for w in ws] for _, ws in sorted(stages.get(q['id'], {}).items())]})
        # bosses: per quest when the id says which, and the dungeon's distinct bosses (strongest copy)
        uniq = {}
        # a quest that names its boss (succession_enemy_id: the boss whose HP carries over between tries) gets it
        idx = {q['id']: k for k, q in enumerate(qs)}
        named = {num(q.get('succession_enemy_id')): idx[q['id']] for q in by_dungeon.get(d['id'], [])
                 if q['id'] in idx and num(q.get('succession_enemy_id'))}
        # (RUSH quests may reuse a quest's own boss, so elsewhere the id rule's place is kept as well)
        for i, b, eid in bosses_of(d['id'], [q['n'] for q in qs]):
            if d['id'] in NO_ID_RULE:
                i = -1
            if eid in named and named[eid] != i:
                qs[named[eid]].setdefault('boss', []).append(b)
            if i >= 0:
                qs[i].setdefault('boss', []).append(b)
            if b['u'] not in uniq or b['hp'] > uniq[b['u']]['hp']:
                uniq[b['u']] = b
            if str(b['u']) in boss_info:
                used_info.add(str(b['u']))
        # manual boss fixes: replace the quest's boss list with the hand-mapped enemies (Mankind Ruins Area 8 / 9)
        for q in qs:
            ov = BOSS_FIX.get(q['id'])
            if not ov:
                continue
            rows = [boss_row(boss_enemies[e]) for e in ov if e in boss_enemies]
            if rows:
                q['boss'] = rows
                for b in rows:
                    if b['u'] not in uniq or b['hp'] > uniq[b['u']]['hp']:
                        uniq[b['u']] = b
                    if str(b['u']) in boss_info:
                        used_info.add(str(b['u']))
        # the final stage is the boss fight in every difficulty, but the enemy ids only tie some quests to the boss:
        # when the dungeon has one boss, give it to the other quests too ('bossX': portrait only, the stats of that
        # difficulty are not in the DB)
        if len({b['u'] for b in uniq.values()}) == 1:
            only = [{k: v for k, v in b.items() if k in ('n', 'u', 'img', 'el')} for b in uniq.values()]
            for q in qs:
                if not q.get('boss') and q.get('st'):
                    q['bossX'] = only
        row = {'id': d['id'], 'n': name, 'cat': cat, 'type': t, 'ev': num(d.get('event_id')), 'rank': num(d.get('need_rank')),
               'img': img(f"{REGION}/banner/dungeon_banner_{d['id']}.png"), 'top': img(f"{REGION}/banner/dungeon_banner_top_{d['id']}.png"),
               'win': [[a.isoformat(), b.isoformat()] for a, b in up[:MAX_WIN]], 'winN': len(wins),
               'first': wins[0][0].isoformat() if wins else '', 'last': wins[-1][1].isoformat() if wins else '',
               'q': qs}
        if t in WEEKDAY:
            row['day'] = WEEKDAY[t]
        # Story chapters: group the Story tab by its world-map chapter (map_id -> chapter no + name, dungeon_no = order)
        if cat == 'Story':
            mid = num(d.get('map_id'))
            if mid in maps and mid % 10000 == 0 and 0 < mid < 1000000:
                row['ch'] = mid // 10000
                row['cn'] = maps[mid]
                row['cord'] = num(d.get('dungeon_no'))
                row['cimg'] = img(f"{REGION}/worldmap/icon/map_icon_{mid // 10000:03d}.png")
        foes = roster(d['id'])
        if foes:
            row['foes'] = foes   # [name, unit id, thumb, element, level, HP, is boss]
        if uniq:
            row['boss'] = [{k: v for k, v in b.items() if k in ('n', 'u', 'img', 'el')} for b in uniq.values()]
        # Boss & Trials sub-type, for the site's chip filter (dungeon_master view_type / count_timing)
        if cat == 'Boss & Trials':
            row['sub'] = 'Daily' if num(d.get('count_timing')) == 2 else \
                {6: 'Giant Boss', 5: 'Super god-rank', 3: 'Assault', 2: 'Invasion', 1: 'Event', 0: 'Other'}.get(num(d.get('view_type')), 'Other')
        out.append(row)
    out.sort(key=lambda r: r['id'])
    data = {'built': now.isoformat(timespec='seconds'), 'dungeons': out,
            'bossInfo': {k: v for k, v in boss_info.items() if k in used_info},
            'icons': {k: v for k, v in icons.items() if v}}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    by = defaultdict(int)
    for r in out:
        by[r['cat']] += 1
    print(dict(by), f"-> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
