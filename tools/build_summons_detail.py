"""
Build dlc/Global/_DATABASE/others/summons_detail.json for the website's Summon tab (banner list + summon simulator).

From the decrypted GL DB:
  gacha_master       banners: name, type, dates, banner picture (dlc/Global/summon/banner/...)
                     param.information_image_list names the featured units / equips:
                       unit/unit_summon_<base>_p.png, unit/with_animation_<unit id>_..., item/item_summon_<base>_p.png
                     (numbers >= 10000 there are banner ids, not units)
  gacha_step_up_master  the same image lists for each step of a STEP-UP banner
  gacha_button_master   summon buttons: a "ticket" button image marks a ticket banner (no free first multi)
  unit_master        unit names, rarity, thumbnails (dlc/unit/thumbnail/unit_thumbnail_<id>.png, top form)
  item_master        equip names, rarity, thumbnails (item/thumbnail/item_thumbnail_1<base:04>1.png)
The DB has no summon rates or crystal costs (those live on the server): the website asks for them.

Pools for the simulator:
  units 5★ / 4★  the standard Hero Summon pool (STD_U5 / STD_U4 below, from the in-game rates page), no 3★
  equips 5★  every equip featured on an Equip Summon (gacha_type 2) at least once

Output: {"built", "banners": [{id, n, t: 'unit'|'equip', s, e, img, feat: [key], su: 1 STEP-UP, tk: 1 ticket summon}],
         "units": {base: [summoned form name, its thumb, top rarity, summoned rarity, top form name]}, "equips": {base: [name, thumb]},
         "pool": {"u5": [...], "u4": [...], "u3": [...], "e5": [...]}}

Runs in .github/workflows/build-summons.yml. Manual run from the repo root:
    python tools/build_summons_detail.py
"""
import glob
import json
import os
import re
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = os.path.join(GS, 'dlc')
DB = os.path.join(DLC, 'Global', '_DATABASE')
OUT = os.path.join(DB, 'others', 'summons_detail.json')
TYPES = {1: 'unit', 6: 'unit', 10: 'unit', 2: 'equip', 7: 'equip'}

# The units a Hero Summon can give besides its featured ones (in-game rates page of a Crossover Hero Summon, Nov 2026).
# NOT every unit: only these. Names as the rates page lists them (any form of the family).
# 5★: each 0.09% per pull (1.29% on the guaranteed 5★ slot); 4★: each 6.20%; no 3★.
STD_U5 = [
    'Number 2', 'Sword Princess Lian', 'Twin Spear Princess Daisy', 'Clairvoyante Maiden End', 'Machina Agent Jack',
    'Sorcery Apprentice Valentia', 'Grand Swordmaster Luda', 'Roy', 'Mira', 'Fen', 'Zeorg', 'Melia', 'Ragsherum',
    'Liese', 'Est', 'Rem', 'Dracostic Arosdea', 'Frostmaiden Selia', 'Forest Bow Ashe Toto',
    'Knight Protector Duran', 'Soulhunter Zenon', 'Flame Raiment Soleil', 'Bestial Fist Saar', 'Funereal Bloom Pola',
    'Yearning Darkness Leon', 'Mace Master Zoroas', 'Divine Knight Zechsia', 'Dark Gunslinger Zecht',
    'Annihilation Witch Aristela', 'Flame Giant Zoldes', 'Dragonsmith Rhodia', 'Tranquil Giant Olgeth',
    'Magical Beast Hunter Shadie', 'Forest Mage Rhiothis', 'Unending Inferno Teriodos', 'Bullseye Keiones',
    'Tempest Warrior Elmessio', 'Lion Fire Mercenary Lione', 'Flashspear Reyon', 'Jade Protector Nerim',
    'Dragon Retainer Feld', 'Primeval Defender Favelle', 'Twinhammer Maverick Catilou', 'Swordsman Rasaou',
    'Mad Genius Keit', 'Smiling Observer Cathemilla', 'Magical Knight Mizyna', 'God Knight Nies',
    'Divine Guardian Sanstone', 'Goddess General Platina', 'Divine Officer Parlot', 'Magical Assassin Dahlia',
    'Magi Spy Millenia', 'Dragon Healer Alche', 'Blademaster Gran Brave', 'Magical Blossom Musse',
    'Infernowyrm Dargeon', 'Sea Lord Herck', 'Creator Tree Valhalla', 'EDEN-typeα', 'Oblivion Blade Abaddon',
    'Searing Knight Ragna', 'Torrent Slasher Yomi', 'Heavy Unit Vaid', 'Holy Beast Soldier Elfalla',
    'Dark Princess Lily', 'Inferno Blade Clyde', 'Frostedge Corsair', 'Blade Savant Arth', 'Radiant Knight Feena',
    'Dread Knight Regulus',
]
STD_U4 = [
    'Golemic Princess Faron', 'Water Slasher Noa', 'Beast Princess Ren', 'Roaring Blade Rizer',
    'Beautiful Death Meira', 'Phoenixion', 'Ongordo', 'Grangarrod', 'Spinicios', 'Afra-Dragim',
    'Crimson Cleaver Fiana', 'Pirate Emperor Grafl', 'Illusion Master Zechs', 'Demolition Girl Ameru',
    'Blade Master Orochi',
]


def load(name):
    hits = glob.glob(os.path.join(DB, '*', name + '.json'))
    if not hits:
        return []
    with open(hits[0], encoding='utf-8') as f:
        return json.load(f)


def main():
    uthumb = set(os.listdir(os.path.join(DLC, 'unit', 'thumbnail')))
    ithumb = set(os.listdir(os.path.join(DLC, 'Japan', 'item', 'thumbnail')))

    # unit families: name + thumbnail of the top form
    fam = {}
    for u in load('unit_master'):
        b = u['base_unit_id']
        if b >= 10000 or u.get('is_material'):
            continue
        cur = fam.get(b)
        if not cur or (u['rarity'], u['evolution_stage']) > (cur['rarity'], cur['evolution_stage']):
            fam[b] = u
    # a summon gives the family's first form (lowest rarity / stage): 5★ and 6★ units come as 5★ / 6★,
    # the others at a lower rarity (Roy 4★, Clyde 2★ ...) and evolve later
    first = {}
    for u in load('unit_master'):
        bb = u['base_unit_id']
        if bb >= 10000 or u.get('is_material'):
            continue
        k = (u['rarity'], u['evolution_stage'], u['id'])
        if bb not in first or k < (first[bb]['rarity'], first[bb]['evolution_stage'], first[bb]['id']):
            first[bb] = u
    units = {}
    for b, u in fam.items():
        f = first.get(b, u)
        t = f"unit_thumbnail_{f['id']}.png"
        tt = f"unit_thumbnail_{u['id']}.png"
        img = f'unit/thumbnail/{t}' if t in uthumb else (f'unit/thumbnail/{tt}' if tt in uthumb else '')
        # [summoned form name, its thumbnail, top rarity, summoned rarity, top form name]
        units[b] = [f['name'], img, u['rarity'], f['rarity'], u['name']]
    by_unit_id = {u['id']: u['base_unit_id'] for u in load('unit_master')}

    equips = {}
    for it in load('item_master'):
        b = it['base_item_id']
        if it['rarity'] != 5 or b in equips or not it.get('name'):
            continue
        thumb = next((f for f in (f'item_thumbnail_1{b:04d}1.png', f'item_thumbnail_1{b:04d}0.png') if f in ithumb), '')
        equips[b] = [it['name'], f'item/thumbnail/{thumb}' if thumb else '']

    # STEP-UP banners list their featured units per step
    step_imgs = {}
    for st in load('gacha_step_up_master'):
        try:
            step_imgs.setdefault(st['gacha_id'], []).extend(json.loads(st.get('param') or '{}').get('information_image_list', []))
        except (TypeError, ValueError):
            pass

    # ticket banners: a summon button paid with tickets (button image ticket_summon_button_*, button_crossoverticket_* ...)
    buttons = {b['id']: str(b.get('button_image') or '') for b in load('gacha_button_master')}

    banners, u5, e5 = [], set(), set()
    for g in load('gacha_master'):
        kind = TYPES.get(g['gacha_type'])
        if not kind:
            continue
        try:
            imgs = json.loads(g.get('param') or '{}').get('information_image_list', [])
        except (TypeError, ValueError):
            imgs = []
        imgs = imgs + step_imgs.get(g['id'], [])
        feat = []
        for p in imgs:
            m = re.search(r'unit_summon_(\d+)_', p) if kind == 'unit' else re.search(r'item_summon_(\d+)_', p)
            b = int(m.group(1)) if m else 0
            if not b and kind == 'unit':
                m = re.search(r'with_animation_(\d{9})_', p)
                b = by_unit_id.get(int(m.group(1)), 0) if m else 0
            ok = (b in units and units[b][2] >= 5) if kind == 'unit' else b in equips
            if b and b < 10000 and ok and b not in feat:
                feat.append(b)
        if kind == 'unit' and g['gacha_type'] == 1:
            u5.update(feat)
        if kind == 'equip' and g['gacha_type'] == 2:
            e5.update(feat)
        bg = os.path.basename(g.get('bg_name') or '')
        banners.append({'id': g['id'], 'n': g['name'], 't': kind, 's': g['start_at'], 'e': g['end_at'],
                        'img': f'Global/summon/banner/{bg}' if bg and os.path.exists(os.path.join(DLC, 'Global', 'summon', 'banner', bg)) else '',
                        'feat': feat})
        # no free first multi on STEP-UP (gacha_system_type 1) or ticket banners
        if g.get('gacha_system_type') == 1 or 'STEP-UP' in (g['name'] or ''):
            banners[-1]['su'] = 1
        if any('ticket' in buttons.get(g.get(f'gacha_button_id{i}'), '').lower() for i in (1, 2, 3)):
            banners[-1]['tk'] = 1
    banners.sort(key=lambda b: (b['s'], b['id']), reverse=True)

    # standard Hero Summon pool by name (lowest base id when a name repeats, e.g. Rem 116 vs the Re:ZERO collab Rem)
    norm = lambda t: re.sub(r'[^a-z0-9]', '', str(t).lower().replace('α', 'a'))
    by_name = {}
    for u in sorted(load('unit_master'), key=lambda u: u['id']):
        b = u['base_unit_id']
        if b < 10000 and not u.get('is_material') and b in units:
            k = norm(u['name'])
            if k not in by_name or b < by_name[k]:
                by_name[k] = b
    def std(names):
        got = [by_name.get(norm(n)) for n in names]
        miss = [n for n, b in zip(names, got) if not b]
        if miss:
            print('standard pool: not in unit_master:', miss)
        return sorted({b for b in got if b})
    u5_std, u4 = std(STD_U5), std(STD_U4)
    u3 = []
    used_u = u5 | set(u5_std) | {b for x in banners if x['t'] == 'unit' for b in x['feat']}
    keep_u = used_u | set(u4) | set(u3)
    used_e = e5 | {b for x in banners if x['t'] == 'equip' for b in x['feat']}
    data = {'built': datetime.now(timezone.utc).isoformat(timespec='seconds'), 'banners': banners,
            'units': {str(b): units[b] for b in sorted(keep_u)}, 'equips': {str(b): equips[b] for b in sorted(used_e)},
            'pool': {'u5': u5_std, 'u4': u4, 'u3': u3, 'e5': sorted(e5)}}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print(f"{len(banners)} banners, pools u5 {len(u5_std)} u4 {len(u4)} u3 {len(u3)} e5 {len(e5)} -> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
