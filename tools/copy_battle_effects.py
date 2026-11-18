"""
Copy the game's battle effect spines into dlc/ASSETS/battle/effect/ for the Simulator > Battle tab.

  HitEffect, BattleEffect, BattleUIEffect, SkillEffect, cutin_line   (shared hit sparks, break, death, buffs)
  itemskill/itemskill<n>                                              (equip attacks; only the files equips use)

Equip effects point to an animation with skill_effect_master.animation_id:
  < 1000  -> SkillEffect animation '<id>' (heal, barrier, ailments ...)
  >= 1000 -> itemskill<id // 10>, animation 'attack<id % 10>'
Pages are copied as they are (the game's png are already smaller than webp); json is minified.

Also cuts the Arts swipe guide and cut-in backgrounds out of CocoStudio/Battle/resource/Battle_UI.plist into
dlc/ASSETS/battle/ui (burst_guide / shin_ougi_guid / tyou_ougi_guid = Arts / True Arts / Super Arts guide,
burst_arrow, burst_destration, UI_cutin_bg1_00000 = Arts cut-in streaks, bg_02 = True Arts cut-in streaks).

Run from the repo root:
    python tools/copy_battle_effects.py [game effect folder]
"""
import json
import os
import plistlib
import re
import shutil
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
SRC = sys.argv[1] if len(sys.argv) > 1 else r'G:\game data\GL GRAND SUMMONERS\dlc\effect'
DST = os.path.join(GS, 'dlc', 'ASSETS', 'battle', 'effect')
UI_SRC = os.path.join(os.path.dirname(SRC), 'CocoStudio', 'Battle', 'resource')
UI_DST = os.path.join(GS, 'dlc', 'ASSETS', 'battle', 'ui')
UI_FRAMES = ['burst_guide', 'shin_ougi_guid', 'tyou_ougi_guid', 'burst_arrow', 'burst_destration', 'UI_cutin_bg1_00000']
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


def plist_frames(plist, names, dst):
    """cut named frames (at their source size) out of a cocos2d plist sprite sheet"""
    with open(plist, 'rb') as f:
        d = plistlib.load(f)
    img = Image.open(os.path.join(os.path.dirname(plist), d['metadata']['textureFileName'])).convert('RGBA')
    nums = lambda v: [int(float(n)) for n in re.findall(r'-?[\d.]+', v)]
    for key, fr in d['frames'].items():
        if key[:-4] not in names:
            continue
        x, y, w, h = nums(fr.get('frame') or fr['textureRect'])
        rot = fr.get('rotated', fr.get('textureRotated', False))
        ox, oy = nums(fr.get('offset') or fr.get('spriteOffset') or '{0,0}')
        sw, sh = nums(fr.get('sourceSize') or fr.get('spriteSourceSize'))
        c = img.crop((x, y, x + (h if rot else w), y + (w if rot else h)))
        if rot:
            c = c.rotate(90, expand=True)
        full = Image.new('RGBA', (sw, sh))
        full.paste(c, ((sw - w) // 2 + ox, (sh - h) // 2 - oy))
        full.save(os.path.join(dst, key))


if os.path.isdir(UI_SRC):
    os.makedirs(UI_DST, exist_ok=True)
    plist_frames(os.path.join(UI_SRC, 'Battle_UI.plist'), UI_FRAMES, UI_DST)
    shutil.copyfile(os.path.join(UI_SRC, 'bg_02.png'), os.path.join(UI_DST, 'bg_02.png'))
    print(len(UI_FRAMES) + 1, 'ui pictures ->', UI_DST)
