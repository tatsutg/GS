"""
Copy the game's battle effect spines into dlc/ASSETS/battle/effect/ for the Simulator > Battle tab.

  HitEffect, BattleEffect, BattleUIEffect, SkillEffect, cutin_line   (shared hit sparks, break, death, buffs)
  itemskill/itemskill<n>                                              (equip attacks; only the files equips use)

Equip effects point to an animation with skill_effect_master.animation_id:
  < 1000  -> SkillEffect animation '<id>' (heal, barrier, ailments ...)
  >= 1000 -> itemskill<id // 10>, animation 'attack<id % 10>'
Pages are copied as they are (the game's png are already smaller than webp); json is minified.

Run from the repo root:
    python tools/copy_battle_effects.py [game effect folder]
"""
import json
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
SRC = sys.argv[1] if len(sys.argv) > 1 else r'G:\game data\GL GRAND SUMMONERS\dlc\effect'
DST = os.path.join(GS, 'dlc', 'ASSETS', 'battle', 'effect')
BASE = ['HitEffect', 'BattleEffect', 'BattleUIEffect', 'SkillEffect', 'cutin_line']


def used_itemskill():
    files = set()
    for region in ('Global', 'Japan'):
        others = os.path.join(GS, 'dlc', region, '_DATABASE', 'others')
        try:
            with open(os.path.join(others, 'item_master.json'), encoding='utf-8') as f:
                eq = {str(r.get('item_skill_id')) for r in json.load(f)}
            with open(os.path.join(others, 'skill_effect_master.json'), encoding='utf-8') as f:
                fx = json.load(f)
        except OSError:
            continue
        for e in fx:
            try:
                a = int(e.get('animation_id'))
            except (TypeError, ValueError):
                continue
            if a >= 1000 and str(e.get('skill_id')) in eq:
                files.add(a // 10)
    return files


def copy(src_dir, name, dst_dir):
    atlas = os.path.join(src_dir, name + '.atlas')
    if not os.path.exists(atlas):
        return 0
    os.makedirs(dst_dir, exist_ok=True)
    out = 0
    with open(atlas, encoding='utf-8') as f:
        pages = [ln.strip() for ln in f if ln.strip().endswith('.png')]
    for page in pages + [name + '.atlas']:
        shutil.copyfile(os.path.join(src_dir, page), os.path.join(dst_dir, page))
        out += os.path.getsize(os.path.join(dst_dir, page))
    with open(os.path.join(src_dir, name + '.json'), encoding='utf-8') as f:
        data = json.load(f)
    with open(os.path.join(dst_dir, name + '.json'), 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    return out + os.path.getsize(os.path.join(dst_dir, name + '.json'))


total = sum(copy(SRC, n, DST) for n in BASE)
items = sorted(used_itemskill())
missing = 0
for n in items:
    got = copy(os.path.join(SRC, 'itemskill'), f'itemskill{n}', os.path.join(DST, 'itemskill'))
    missing += not got
    total += got
print(len(BASE), 'base +', len(items) - missing, 'itemskill files,', missing, 'missing,', round(total / 1e6, 1), 'MB ->', DST)
