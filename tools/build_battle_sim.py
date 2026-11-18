"""
Build dlc/<Region>/_DATABASE/others/battle_sim.json for the website's Simulator > Battle tab (js/battlesim.js).

{
  "u": {unit_id: base}                       every form's unit id -> unitsv2 base (sprite + face use the unit id)
  "s": {base: {"n": name, "el": element, "hp", "atk", "def", "r": rarity, "id": top unit id,
               "dl": attack delay s, "bp": break power, "at": attribute,
               "sk": [skill, arts, true_arts, super_arts],
               "m": [mode name, seconds, icon id, activated by 1 arts / 2 true arts / 3 super arts] or 0}}
  "e": {image_id: [name, type, hp, atk, def, ct_s, skill]}   equips by picture id (the site's equip ID)
  "q": [[quest_id, dungeon, quest, difficulty, [boss, ...]], ...]
       boss = [unit_id, name, element, lv, hp, atk, def, break, attack delay s, skill %, skill chance %,
               arts %, arts gauge cost, arts per hit for units, attribute, [ailment resist % x9], size]
       ailment order: faint, poison, paralysis, seal, blind, disease, curse, freeze, burn
       size: enemy_master size, 1 unit-sized, 3 big boss (dragons, birds, fortresses)
}
rarity: 2 Ascension, 1 Awoken, 0 lower. element: 1 fire, 2 water, 3 earth, 4 light, 5 dark.
attribute: 1 physical, 2 magic. type (equips): 1 physical, 2 magical, 3 defense, 4 healing, 5 support.

A skill is 0 (none) or [damage %, break, element, attribute, CT s, arts cost, effects, flags, name]
  effects = [[type, target, seconds, value, chance %, icon, script, mode, animation,
              script_value_1, script_value_2, script_value_3, group, priority, buff_type], ...] from skill_effect_master
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

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
REGION = os.environ.get('GS_REGION', 'Global')
OTHERS = os.path.join(GS, 'dlc', REGION, '_DATABASE', 'others')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(OTHERS, 'battle_sim.json')
# mode icons (ai_cond_icon_<id>.png) are copied from the game dump when it is present
ICON_SRC = os.environ.get('GS_AI_COND_ICONS', r'G:\game data\GL GRAND SUMMONERS\dlc\ai_cond_icon')
ICON_DST = os.path.join(GS, 'dlc', 'ASSETS', 'battle', 'mode')


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
            num(e.get('priority')), num(e.get('buff_type'))]


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
                   'lv': num(u.get('level_max')), 'p': passives}
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

# quest bosses with their enemy_master row
enemies = {}
for e in load('enemy_master.json'):
    enemies.setdefault((num(e['unit_id']), num(e['hp'])), e)
RES = ['stun', 'poison', 'paralyze', 'silent', 'darkness', 'sickness', 'injury', 'freeze', 'burn']


def boss_row(b):
    uid, hp = num(b.get('u')), num(b.get('hp'))
    e = enemies.get((uid, hp)) or {}
    u = um.get(uid) or {}
    res = [num(e.get(f'resistant_{k}_base')) for k in RES]
    return [uid, b.get('n') or '', num(b.get('el')), num(b.get('lv')), hp, num(b.get('atk')), num(b.get('def')),
            num(b.get('brk')), round(num(u.get('attack_delay'), 300) / 100, 2), num(e.get('skill1_damage_value'), 300),
            num(e.get('skill_invocation_weight'), 20), num(e.get('full_skill_damage_value'), 300),
            num(e.get('need_sp'), 100), num(e.get('drop_sp'), 4), num(u.get('attribute'), 1), res,
            num(e.get('size'), 1)]


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

# game constants (initial/setting_master): damage formula, crit, break, element, Battle Ether
consts = {}
try:
    with open(os.path.join(os.path.dirname(OTHERS), 'initial', 'setting_master.json'), encoding='utf-8') as f:
        for r in json.load(f):
            if r['key'] in CONST_KEYS:
                consts[r['key']] = float(r['value'])
except OSError:
    pass

out = {'u': uid_base, 's': stats, 'e': equips, 'q': quests, 'c': consts,
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
      len(quests), 'quests ->', OUT)
