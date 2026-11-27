"""
Build dlc/<Region>/_DATABASE/others/battle_sim.json for the website's Simulator > Battle tab (js/battlesim.js).

{
  "u": {unit_id: base}                       every form's unit id -> unitsv2 base (sprite + face use the unit id)
  "s": {base: {"n": name, "el": element, "hp", "atk", "def", "r": rarity, "id": top unit id,
               "dl": attack delay s, "bp": break power, "at": attribute,
               "nh": hits in one normal attack from the attack1 animation (resetHitList + 1), 0 = unknown,
               "lb": [[hp, atk, def] Limit Break "+" stats at the top LB without Dream Awakening, same with it or null],
               "rg": [range_min, range_max] unit_master attack range: the unit walks in until its target's HITBOX is this close,
               "sk": [skill, arts, true_arts, super_arts],
               "m": [mode name, seconds, icon id, activated by 1 arts / 2 true arts / 3 super arts] or 0}}
  "cr": [[type id, name, stone image (dlc path) or '', [[level label, rune id, effects], ...]], ...]  crests with a
        damage effect (type 12 / 13 / 17 / 80 / 22 / 142 / boss 14 / 15 / 21 / 61-65)
  "e": {image_id: [name, type, hp, atk, def, ct_s, skill, [[passive name, effects], ...]]}   equips by picture id
       (the site's equip ID); passive effects as a skill's, script 35 = only on the unit whose base is value 1
  "q": [[quest_id, dungeon, quest, difficulty, [boss, ...]], ...]
       boss = [unit_id, name, element, lv, hp, atk, def, break, attack delay s, skill %, skill chance %,
               arts %, arts gauge cost, arts per hit for units, attribute, [ailment resist % x9], size, race, [[hp %, skip], ...],
               look, mechanics, resist, [range_min, range_max, weight]]
       ailment order: faint, poison, paralysis, seal, blind, disease, curse, freeze, burn
       size: enemy_master size, 1 unit-sized, 3 big boss (dragons, birds, fortresses)
       look: [[[sub skeleton, z order], ...], skin, setup animation] from the enemy / unit Lua start (0 none)
       hp markers: the diamonds on the HP bar, from the enemy Lua (addNumHpMarker); skip 1 = cyan marker
       mechanics: [[message, from the start 1 / later 0, [[rule, value], ...]], ...] the game's battle messages for the
                  enemy (tools/lua_boss_text.py: immunities to physical / magic / an element / critical ...), 0 none
       range / weight (field 22): unit_master range_min / range_max (how close it gets to its target's HITBOX to attack)
                  and enemy_master weight (10000 for big bosses: never pushed back)
       race: unit_master race, 1 Human, 2 Beast, 3 Spirit, 4 Giant, 5 Machine, 6 Dragon, 7 God, 8 Demon (0 none)
       resist (field 21): [[passive name, effects], ...] the enemy's passives (skill_relation_master relation_type 4)
                  with a damage-taken effect: 14 / 15 DEF, 21 DMG taken (script 2 physical, 3 magic, 14 attacker element,
                  70 move element, 75 in Break, 192 attacker race), 23 CRI resist (negative = fewer crits), 61-65 element
  "x": [[quest_id, dungeon, quest, difficulty, [enemy, ...]], ...] quests with an enemy whose rules change damage, with
       every enemy of the quest (same rows as a boss), e.g. event waves before the boss
}
rarity: 2 Ascension, 1 Awoken, 0 lower. element: 1 fire, 2 water, 3 earth, 4 light, 5 dark.
attribute: 1 physical, 2 magic. type (equips): 1 physical, 2 magical, 3 defense, 4 healing, 5 support.

A skill is 0 (none) or [damage %, break, element, attribute, CT s, arts cost, effects, flags, name]
  effects = [[type, target, seconds, value, chance %, icon, script, mode, animation,
              script_value_1, script_value_2, script_value_3, group, priority, buff_type, script_value_4, script_value_5], ...] from skill_effect_master
    (what each script id checks: dlc/<Region>/additional_lua/other/skill_effect.lua, see js/battle-engine.js):
    target 1 self, 2 allies, 4 enemy, 5 one ally, 6 on hit; icon = condition_icon_<n>.png (0 none);
    mode: 0 always, 1 only during the unit's mode, -1 only outside it, k>=2 time x k/10 during the mode
    type 67 / 69 on equips is the equip's physical / magic hit (value = damage %), not a buff
    animation: < 1000 SkillEffect animation '<n>', >= 1000 effect/itemskill/itemskill<n // 10> 'attack<n % 10>'
      (dlc/ASSETS/battle/effect, copied by tools/copy_battle_effects.py)
  flags: 1 damage only during the unit's mode, 2 damage x2 during the mode
Some Arts (modes, "Increases ATK & DMG ...") are scripted in the game, not in skill_effect_master:
those effects are read from the English skill text.
Units also carry "race" (unit_master), "lv" (level_max) and "p": [[passive name, effects], ...].
"c": game constants from initial/setting_master; "o": tools/battle_overrides.json (Lua-only unit rules by base).
Equip CT: item_master min_limitbreak_cooltime (the MLB value), centiseconds.
Boss stats: enemy_master row of the quest boss (unit id + HP), attack delay from unit_master.

Manual run from the repo root (GS_REGION=Global or Japan):
    python tools/build_battle_sim.py [output-path]
"""
import ast
import json
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lua_hp_markers import markers as lua_markers  # noqa: E402
from lua_boss_look import look as lua_look  # noqa: E402
from lua_boss_text import Texts  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
REGION = os.environ.get('GS_REGION', 'Global')
OTHERS = os.path.join(GS, 'dlc', REGION, '_DATABASE', 'others')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(OTHERS, 'battle_sim.json')
# mode icons (ai_cond_icon_<id>.png) are copied from the game dump when it is present
ICON_SRC = os.environ.get('GS_AI_COND_ICONS', r'G:\game data\GL GRAND SUMMONERS\dlc\ai_cond_icon')
ICON_DST = os.path.join(GS, 'dlc', 'ASSETS', 'battle', 'mode')


ANIM_DIR = os.path.join(GS, 'dlc', 'Japan', 'unit', 'animation')


def normal_hits(uid):
    """hits in one normal attack, read from the unit's attack1 animation: each "Hit" event "resetHitList" lets the
    hitbox hit again, so hits = resets + 1. 0 = not readable this way (no resets, other Hit events, shots):
    the calculator then shows the swing total only. Checked in game for Awoken Vox only (2 resets, 3 hits)."""
    f = os.path.join(ANIM_DIR, f'{uid}.json')
    if not os.path.exists(f):
        return 0
    try:
        with open(f, encoding='utf-8') as h:
            a = json.load(h).get('animations', {}).get('attack1') or {}
    except (OSError, ValueError):
        return 0
    ev = [e for e in a.get('events', []) if e.get('name') == 'Hit']
    if not ev or any(str(e.get('string') or '').lower() != 'resethitlist' for e in ev):
        return 0
    return len(ev) + 1


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
# hand-written unit rules read from the game's Lua (dlc/<Region>/additional_lua/unit/<unit id>.lua)
with open(os.path.join(HERE, 'battle_overrides.json'), encoding='utf-8') as f:
    overrides = {k: v for k, v in json.load(f).items() if not k.startswith('_')}
CONST_KEYS = {'CONF_DAMAGE_CAP', 'CONF_DAMAGE_CRITICALPOINT', 'CONF_DEFENCE_CRITICALPOINT', 'CONF_DAMAGE_OFFSET_PvE',
              'CONF_DAMAGE_OFFSET_EvP', 'CONF_CRITICAL_RATE', 'CONF_SUPER_CRITICAL_RATE', 'CONF_BREAK_RATE',
              'CONF_ELEMENT_WEAK', 'CONF_ELEMENT_RESIST', 'CONF_SPDROP_VALUE', 'CONF_SPDROP_DIV_ITEMDAMAGE',
              'CONF_DoT_OFFSET_PvE', 'CONF_BOSS_RESISTCONDITION_REDUCE_PER_SEC'}
um = {r['id']: r for r in load('unit_master.json')}
# Limit Break "+" stats (unit_limitbreak_master buff_hp / buff_attack / buff_defence per base unit and LB level).
# LB levels whose unit_limitbreak_exp_master rarity is 7 need Dream Awakening (is_fantasy_evo_max marks the first)
lb_buff = {}
for r in load('unit_limitbreak_master.json'):
    lb_buff[(str(r['base_unit_id']), num(r['limit_break_level']))] = [num(r['buff_hp']), num(r['buff_attack']), num(r['buff_defence'])]
lb_levels = {}
for r in load('../data1/unit_limitbreak_exp_master.json'):
    lb_levels.setdefault(str(r['exp_id']), []).append((num(r['level']), num(r['rarity'])))
dream_units = {str(r['unit_id']) for r in load('unit_fantasy_evo_master.json')}


def lb_stats(u, top):
    """[[hp, atk, def] at the top LB without Dream Awakening, same with it (or None)]"""
    base, lv = str(u.get('base_unit_id')), lb_levels.get(str(u.get('limit_break_exp_id')), [])
    def at(n):
        ks = [k for (b, k) in lb_buff if b == base and k <= n]
        return lb_buff[(base, max(ks))] if ks else None
    plain = [k for k, r in lv if r < 7]
    nd = at(max(plain)) if plain else at(99)
    dm = at(max(k for k, _ in lv)) if lv and str(top) in dream_units else None
    return [nd, dm if dm != nd else None]
sm = {r['id']: r for r in load('skill_master.json')}
fx = {}
for e in load('skill_effect_master.json'):
    fx.setdefault(e['skill_id'], []).append(e)

# 305: only during the mode, 328: only outside it, 327: effect time x value_2 / 10 during it
MODE_SCRIPT = {305: 1, 328: -1}


def effect(e):
    sv1 = num(e.get('script_value_1'))
    script = num(e.get('script_id'))
    mode = 0
    if sv1 > 10 ** 9:            # a unit's mode id (unit id + digit)
        mode = MODE_SCRIPT.get(script, max(2, num(e.get('script_value_2'))) if script == 327 else 0)
    return [num(e['effect_type']), num(e['target']), num(e['effect_time']), num(e['effect_value']),
            num(e.get('weight'), 100), num(e.get('tumbnail_name')), script, mode, num(e.get('animation_id')),
            sv1, num(e.get('script_value_2')), num(e.get('script_value_3')), num(e.get('group_id')),
            num(e.get('priority')), num(e.get('buff_type')), num(e.get('script_value_4')), num(e.get('script_value_5'))]


def skill(sid, text='', lua=False):
    r = sm.get(num(sid))
    if not r:
        return 0
    effects = [effect(e) for e in sorted(fx.get(r['id'], []), key=lambda e: e['id'])]
    flags = 0
    t = '' if lua else (text or '')       # units in battle_overrides.json: the Lua rules replace the text guesses
    if re.search(r'DMG when used during|状態のとき使用すると', t):
        flags |= 1
    if re.search(r'Doubles (?:Super |True )?Arts DMG during|ダメージ倍率を2倍', t):
        flags |= 2
    # scripted buffs only in the text: "Increases (own) ATK & DMG by 200% for 35s"
    if not effects:
        m = re.search(r'Increases (?:own |all allies\' )?ATK (?:& DMG )?by (\d+)% for (\d+)s', t)
        j = re.search(r'(\d+)秒間、(自身|味方全体)の攻撃力(・ダメージ)?(\d+)%UP', t)
        if m:
            tg, secs, val, dmg = (2 if 'all allies' in m.group(0) else 1), num(m.group(2)), num(m.group(1)), '& DMG' in m.group(0)
        elif j:
            tg, secs, val, dmg = (2 if j.group(2) == '味方全体' else 1), num(j.group(1)), num(j.group(4)), bool(j.group(3))
        if m or j:
            effects.append([13, tg, secs, val, 100, 3, 0, 0, 0])
            if dmg:
                effects.append([17, tg, secs, val, 100, 26, 0, 0, 0])
    return [num(r['damage_value']), num(r['break_value']), num(r['element']), num(r['attribute']),
            round(num(r['cooltime']) / 100, 2), num(r['need_sp']), effects, flags, r.get('name') or '']


# modes with their own battle icon (ai_cond_master, icon type 101, by unit base)
mode_icon = {}
for c in load('ai_cond_master.json'):
    if num(c.get('icon_type')) != 101 or not c.get('base_unit_ids'):
        continue
    try:
        bases = json.loads(c['base_unit_ids'])
    except ValueError:
        continue
    for b in bases:
        mode_icon.setdefault(str(b), num(c['id']))

EL = {'fire': 1, 'water': 2, 'earth': 3, 'light': 4, 'dark': 5}
uid_base, stats, icons_used = {}, {}, set()
for base, rec in units.items():
    ids = obj(rec.get('_ids'))
    top = num(ids.get('unit'))
    u = um.get(top)
    if not u:
        continue
    rar = str(rec.get('Rarity') or '').lower()
    keys = ['Skill', 'Arts', 'True Arts', 'Super Arts']
    lua = base in overrides
    sks = [skill(ids.get(k), rec.get(k + ' Detail'), lua) for k in keys]
    passives = []
    for k in sorted(x for x in ids if re.fullmatch(r'Passives \d+', x)):
        p = skill(ids.get(k))
        if p:
            passives.append([p[8], p[6]])
    mode = 0
    for i, k in enumerate(keys[1:], 1):
        txt = str(rec.get(k + ' Detail') or '')
        m = re.search(r'Activates ([^.]+?) for (\d+)s', txt)
        j = re.search(r'(\d+)秒間、([^、。]+?)状態になる', txt)
        if m or j:
            icon = mode_icon.get(base, 0)
            mode = [m.group(1).strip(), num(m.group(2)), icon, i] if m else [j.group(2).strip(), num(j.group(1)), icon, i]
            if icon:
                icons_used.add(icon)
    stats[base] = {'n': rec.get('Name') or '', 'el': EL.get(str(rec.get('Type') or '').lower(), num(u['element'])),
                   'hp': num(rec.get('HP')), 'atk': num(rec.get('ATK')), 'def': num(rec.get('DEF')),
                   'r': 2 if 'ascension' in rar else 1 if 'awoken' in rar else 0, 'id': top,
                   'dl': round(num(u['attack_delay'], 300) / 100, 2), 'bp': num(u['break_power']),
                   'at': num(u['attribute']), 'sk': sks, 'm': mode, 'race': num(u.get('race')),
                   'lv': num(u.get('level_max')), 'p': passives, 'nh': normal_hits(top),
                   'rg': [num(u.get('range_min')), num(u.get('range_max'))], 'lb': lb_stats(u, top)}
    uid_base[str(top)] = base
    for form in obj(rec.get('_forms')).values():
        fid = ''.join(c for c in str(obj(form).get('Unit ID') or '') if c.isdigit())
        if fid:
            uid_base.setdefault(fid, base)

# equips: the top evolution of each picture id (highest stats), CT at MLB
# passives: the item's abilities (skill_relation_master relation_type 1), one per name (highest Lv), with their
# effects; script 35 = only when equipped by the unit whose base is script_value_1 (e.g. True "ZANKETSU" on Vox)
ability_rel, enemy_rel = {}, {}
for rr in load('skill_relation_master.json'):
    if num(rr.get('relation_type')) == 1:
        ability_rel.setdefault(num(rr['relation_id']), []).append(num(rr['skill_id']))
    elif num(rr.get('relation_type')) == 4:          # an enemy's passives, by enemy id
        enemy_rel.setdefault(num(rr['relation_id']), []).append(num(rr['skill_id']))

# boss resistances: the enemy's passives (relation_type 4) that change the damage it takes, e.g.
# "Physical resistance 80%" (type 21 -80, script 2) or "Dark resistance 80%" (type 65 80)
RES_T = {14, 15, 21, 23, 61, 62, 63, 64, 65}


def enemy_passives(eid):
    out = []
    for sid in enemy_rel.get(eid, []):
        eff = [effect(e) for e in sorted(fx.get(sid, []), key=lambda e: e['id']) if num(e['effect_type']) in RES_T and num(e['target']) == 1]
        if eff:
            out.append([(sm.get(sid) or {}).get('name') or '', eff])
    return out


def equip_passives(iid):
    best = {}
    for sid in sorted(ability_rel.get(iid, [])):
        r = sm.get(sid)
        if not r or not r.get('name'):
            continue
        key = re.sub(r'\s*Lv\.?\s*\d+$', '', r['name'])
        if key not in best or sid > best[key]:
            best[key] = sid
    out = []
    for sid in best.values():
        eff = [effect(e) for e in sorted(fx.get(sid, []), key=lambda e: e['id'])]
        if eff:
            out.append([sm[sid].get('name') or '', eff])
    return out


equips = {}
for r in load('item_master.json'):
    if num(r.get('is_material')) or not num(r.get('item_skill_id')):
        continue
    img = str(num(r['image_id']))
    row = [r.get('name') or '', num(r['type']), num(r['hitpoint']), num(r['offence']), num(r['defence']),
           round(num(r.get('min_limitbreak_cooltime') or r.get('max_limitbreak_cooltime')) / 100, 2),
           skill(r['item_skill_id']), equip_passives(num(r['id']))]
    old = equips.get(img)
    if not old or row[2] + row[3] + row[4] >= old[2] + old[3] + old[4]:
        equips[img] = row

# quest bosses with their enemy_master row
enemies = {}
for e in load('enemy_master.json'):
    enemies.setdefault((num(e['unit_id']), num(e['hp'])), e)
RES = ['stun', 'poison', 'paralyze', 'silent', 'darkness', 'sickness', 'injury', 'freeze', 'burn']


LUA_DIRS = [os.path.join(GS, 'dlc', r, 'additional_lua', 'enemy') for r in (REGION, 'Japan')]


def hp_markers(eid):
    for d in LUA_DIRS:
        f = os.path.join(d, f'{eid}.lua')
        if os.path.exists(f):
            with open(f, encoding='utf-8', errors='replace') as h:
                return lua_markers(h.read()) or []
    return []


UNIT_LUA_DIRS = [os.path.join(GS, 'dlc', r, 'additional_lua', 'unit') for r in (REGION, 'Japan')]


def boss_look(eid, uid):
    """the enemy's own script, else its unit's script: [[[sub skeleton, z], ...], skin, setup animation] or 0"""
    for name, dirs in ((eid, LUA_DIRS), (uid, UNIT_LUA_DIRS)):
        for d in dirs:
            f = os.path.join(d, f'{name}.lua')
            if os.path.exists(f):
                with open(f, encoding='utf-8', errors='replace') as h:
                    return lua_look(h.read())
    return 0


LUA = lambda r: os.path.join(GS, 'dlc', r, 'additional_lua')
TEXTS = Texts([LUA('Global'), LUA(REGION)], [LUA(REGION), LUA('Japan')])


def boss_row(b):
    uid, hp = num(b.get('u')), num(b.get('hp'))
    e = enemies.get((uid, hp)) or {}
    u = um.get(uid) or {}
    res = [num(e.get(f'resistant_{k}_base')) for k in RES]
    return [uid, b.get('n') or '', num(b.get('el')), num(b.get('lv')), hp, num(b.get('atk')), num(b.get('def')),
            num(b.get('brk')), round(num(u.get('attack_delay'), 300) / 100, 2), num(e.get('skill1_damage_value'), 300),
            num(e.get('skill_invocation_weight'), 20), num(e.get('full_skill_damage_value'), 300),
            num(e.get('need_sp'), 100), num(e.get('drop_sp'), 4), num(u.get('attribute'), 1), res,
            num(e.get('size'), 1), num(u.get('race')), hp_markers(num(e.get('id'))) if e else [],
            boss_look(num(e.get('id')) if e else 0, uid),
            TEXTS.mechanics([num(e.get('id')) if e else 0, uid], b.get('n') or '') or 0,
            enemy_passives(num(e.get('id'))) if e else [],
            [num(u.get('range_min')), num(u.get('range_max')), num(e.get('weight'))]]


quests = []
qd = load('quests_detail.json')
for d in qd.get('dungeons', []):
    for q in d.get('q', []):
        bosses = q.get('boss')
        if isinstance(bosses, str):
            bosses = obj(bosses)
        if not bosses:
            continue
        quests.append([num(q['id']), d.get('n') or '', q.get('n') or '', num(q.get('dif')), [boss_row(b) for b in bosses]])

# quests with an enemy whose rules change damage (immunities), every enemy of the quest as a wave: the enemy ids
# of a quest follow its id (quest 2000209 -> enemies 200020900..99); bosses that are not tied to their quest
# above (e.g. event waves before the boss) are found this way
names = {num(q['id']): (d.get('n') or '', q.get('n') or '', num(q.get('dif'))) for d in qd.get('dungeons', []) for q in d.get('q', [])}
by_id = {num(e['id']): e for e in load('enemy_master.json')}


def enemy_row(e):
    """an enemy_master row as a boss row"""
    u = um.get(num(e['unit_id'])) or {}
    return boss_row({'u': e['unit_id'], 'n': (e.get('name') if e.get('name') not in (None, 'None') else '') or u.get('name') or '',
                     'el': u.get('element'), 'lv': e.get('level'), 'hp': e.get('hp'), 'atk': e.get('attack'),
                     'def': e.get('deffence'), 'brk': e.get('break_capacity')})


# quests that name their boss (quest_master succession_enemy_id: the boss whose HP carries over between tries, e.g.
# Training > Takedown Battle, RUSH, Ultra) but got none above: that enemy is the boss
have = {q[0] for q in quests}
for q in load('quest_master.json'):
    qid, sid = num(q['id']), num(q.get('succession_enemy_id'))
    if sid in by_id and qid in names and qid not in have:
        dn, qn, dif = names[qid]
        quests.append([qid, dn, qn, dif, [enemy_row(by_id[sid])]])

extra = []
for qid, (dn, qn, dif) in sorted(names.items()):
    rows, seen = [], set()
    for i in range(qid * 100, qid * 100 + 100):
        e = by_id.get(i)
        if not e or (num(e['unit_id']), num(e['hp'])) in seen:
            continue
        seen.add((num(e['unit_id']), num(e['hp'])))
        rows.append(enemy_row(e))
    if any(r[20] and any(m[1] and m[2] for m in r[20]) for r in rows):
        extra.append([qid, dn, qn, dif, rows])

# game constants (initial/setting_master): damage formula, crit, break, element, Battle Ether
consts = {}
try:
    with open(os.path.join(os.path.dirname(OTHERS), 'initial', 'setting_master.json'), encoding='utf-8') as f:
        for r in json.load(f):
            if r['key'] in CONST_KEYS:
                consts[r['key']] = float(r['value'])
except OSError:
    pass

# crests (rune_master, the game's name for runes): families with an effect the damage calculator reads, every level
# with its effects; img = a special crest's own stone (region path), '' = the plain level stone (rune_level_<n>.png)
def db_rows(name):
    for root, _, files in os.walk(os.path.join(GS, 'dlc', REGION, '_DATABASE')):
        if name in files:
            with open(os.path.join(root, name), encoding='utf-8') as f:
                d = json.load(f)
            return d if isinstance(d, list) else next(iter(d.values()))
    return []


ALLY_DMG, FOE_DMG = {12, 13, 17, 80, 22, 142}, {14, 15, 21, 61, 62, 63, 64, 65}   # as js/dmgcalc.js reads them
dmg_eff = lambda e: (e[0] in ALLY_DMG and e[1] in (1, 2, 5, 8)) or (e[0] in FOE_DMG and e[1] == 4)
rune_type = {num(r['id']): (r.get('name') or '').strip() for r in db_rows('rune_type_master.json')}
fam = {}
for r in sorted(db_rows('rune_master.json'), key=lambda r: (num(r['type_id']), num(r['level']), num(r['is_plus']))):
    eff = [effect(e) for e in sorted(fx.get(num(r['skill_id']), []), key=lambda e: e['id'])]
    t = num(r['type_id'])
    f = fam.setdefault(t, [t, rune_type.get(t) or re.sub(r'\s*Lv\d\+?$', '', r.get('name') or ''), '', []])
    if r.get('image') and not f[2]:
        for reg in (REGION, 'Japan'):
            rel = f"{reg}/rune/thumbnail/runestone_middle_{r['image']}.png"
            if os.path.exists(os.path.join(GS, 'dlc', rel)):
                f[2] = rel
                break
    f[3].append([f"Lv{num(r['level'])}{'+' if num(r['is_plus']) else ''}", num(r['id']), eff])
crests = [f for f in fam.values() if any(dmg_eff(e) for lv in f[3] for e in lv[2])]

out = {'u': uid_base, 's': stats, 'e': equips, 'q': quests, 'x': extra, 'c': consts, 'cr': crests,
       'o': {b: {k: v for k, v in o.items() if not k.startswith('_')} for b, o in overrides.items()}}
with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))

if os.path.isdir(ICON_SRC):
    os.makedirs(ICON_DST, exist_ok=True)
    for i in icons_used:
        src = os.path.join(ICON_SRC, f'ai_cond_icon_{i}.png')
        if os.path.exists(src):
            shutil.copyfile(src, os.path.join(ICON_DST, f'ai_cond_icon_{i}.png'))
print(REGION, len(stats), 'units', sum(1 for s in stats.values() if s['m']), 'modes', len(equips), 'equips',
      len(quests), 'quests', len(extra), 'quests with immune enemies ->', OUT)
