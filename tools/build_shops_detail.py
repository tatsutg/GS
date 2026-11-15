"""
Build dlc/Global/_DATABASE/others/shops_detail.json for the website's Exchange tab.

The game's Exchange screen is a list of shop banners (shop_banner_master):
  - town shops (shop_type 1 Alch Shop, 2 Alchemist / True Equips for Rainbow Gems, 3 Material exchange,
    6 / 7 other exchanges): items in orb_shop_master (by shop_type)
  - event exchange shops (event_id): items in event_shop_master (by event_id), paid with the event's item
Each shop: banner picture (dlc/Global/alchemyExchange/<bg_name> when the repo has it), the currency it takes
(name + icon), the exchange window (event_master item_start_at / item_end_at; town shops are permanent)
and its items: what you get (name, kind, icon), how many, the price and the exchange limit.

Item icons, by reward type (each picture is looked up in the build's region folder, then the other one:
most unit / equip thumbnails only exist under dlc/Japan/, so a Global build must not look in Global/ alone):
  8 / 7 equip / recipe  <region>/item/thumbnail/item_thumbnail_1<base:04><1|0>.png
  9 unit                <region>/unit/thumbnail/unit_thumbnail_<id>.png
  5 material, 13 food, 24 tool: the image items_detail.json has for it
  22 event item         event/event_item_<id>.png (128 px; event_icon_<id> is the 32 px list icon, so last)
  18 Alch               town/.../orb_thumbnail.png
  25 Rainbow Gem        town/.../ball_thumbnail.png (128 px; the old ASSETS icon is 38 px)
  16 Equip LB Stone     town/.../stone_item_thumbnail_<id:02>.png (1 Phys, 2 Mag, 3 Def, 4 Heal, 5 Sup, ...)
  33 SP Art             unit/sp_icon/unit_sp_icon_<id // 10>_<id % 10>.png
  35 Mystika / 36 craft material  material/generic_<id>.png / material/unique_<id>.png
A reward still without a picture borrows one from an item of the same name (or Material family: "Insignia", ...).
Others (stamps, collab SP arts, ...) have no icon in the repo: the site shows a badge.

Output: {"built", "shops": [{id, k: 'town'|'event', n, img, imgs, cur: [name, icon], s, e, f, gone, items: [[name, kind,
         icon, amount, price, limit, note, old]]}]}  (s / e empty for permanent shops; limit -1 = no limit)

Old data is kept (the game reuses ids and names, and the DB only has what is on sale now):
  - banner versions: the user keeps each new banner next to the original as <name>-N.png (alchemy_exchange_banner_2.png,
    -1, -2, ...). img = the newest (highest N), imgs = every version, newest first (the shop's past rotations).
  - the previous shops_detail.json is read first: a shop no longer in the DB stays in, with gone = the build time it
    went missing (the site lists it as past); an item no longer in a shop stays in, with old = 1.
  - f = the build time the shop was first seen.
So pushing new DB files over the old ones loses nothing on the site.

Runs in .github/workflows/build-shops.yml. Manual run from the repo root:
    python tools/build_shops_detail.py
"""
import glob
import json
import os
import re
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = os.path.join(GS, 'dlc')
REGION = os.environ.get('GS_REGION', 'Global')  # 'Global' or 'Japan'
DB = os.path.join(DLC, REGION, '_DATABASE')
OUT = os.path.join(DB, 'others', 'shops_detail.json')

JP = re.compile(r'[぀-ヿ一-鿿]') if REGION == 'Global' else re.compile(r'(?!)')
TOWN = {1: 'Alch Shop', 2: 'Alchemist (True Equips)', 3: 'Material Exchange', 6: 'Exchange', 7: 'Exchange'}
KIND = {5: 'Material', 7: 'Recipe', 8: 'Equip', 9: 'Unit', 12: 'Stamp', 13: 'Food', 15: 'Unit LB Stone',
        16: 'Equip LB Stone', 17: 'Key', 18: 'Alch', 22: 'Event item', 24: 'Item', 25: 'Rainbow Gem',
        33: 'SP Art', 35: 'Mystika', 36: 'Material'}
# currency (need_type) of the town shops
NEED = {18: 'Alch', 25: 'Rainbow Gems', 29: 'Medals', 17: 'Keys'}


def load(name):
    hits = glob.glob(os.path.join(DB, '*', name + '.json'))
    if not hits:
        return []
    with open(hits[0], encoding='utf-8') as f:
        return json.load(f)


def clean(t):
    if not t or t == 'None':
        return ''
    return re.sub(r'\s+', ' ', str(t)).strip()


def num(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return 0


def has(rel):
    """Repo path of a picture, or ''. Since the dlc restructure pictures live under dlc/<region>/: a bare
    'material/...' is looked up in the build's region folder first, then flat (old layout). Orb shop
    (town/) art is shared UI, so Japan falls back to the Global copy."""
    if not rel:
        return ''
    other = 'Japan' if REGION == 'Global' else 'Global'
    if rel.startswith(('Global/', 'Japan/')):
        reg, bare = rel.split('/', 1)
        cands = [rel, ('Japan' if reg == 'Global' else 'Global') + '/' + bare]
    else:
        cands = [f'{REGION}/{rel}', f'{other}/{rel}', rel]
    return next((c for c in cands if os.path.exists(os.path.join(DLC, c))), '')


def versions(rel):
    """[rel, rel-1, rel-2, ...] that exist, oldest first ("<name>-N.png" = the user's newer copies of a reused name)"""
    if not rel:
        return []
    d, f = os.path.split(rel)
    stem, ext = os.path.splitext(f)
    full = os.path.join(DLC, d)
    if not os.path.isdir(full):
        return []
    pat = re.compile(re.escape(stem) + r'-(\d+)' + re.escape(ext) + '$')
    out = [(0, f)] if os.path.exists(os.path.join(full, f)) else []
    out += [(int(m.group(1)), x) for x in os.listdir(full) for m in [pat.match(x)] if m]
    return [f'{d}/{x}' for _, x in sorted(out)]


def merge_old(shops, now):
    """keep shops / items of the previous build that are no longer in the DB"""
    try:
        with open(OUT, encoding='utf-8') as f:
            prev = {s['id']: s for s in json.load(f)['shops']}
    except (OSError, ValueError, KeyError):
        return shops
    ids = {s['id'] for s in shops}
    for s in shops:
        p = prev.get(s['id'])
        if not p:
            continue
        s['f'] = p.get('f') or s['f']
        have = {(x[0], x[4]) for x in s['items']}
        icons = {(x[0], x[1]): x[2] for x in s['items'] if x[2]}
        for x in p['items']:
            if (x[0], x[4]) not in have:
                x = (x + [''] * 8)[:7] + [1]
                # an old row keeps its icon; an empty one (or one whose file is gone) takes the current row's
                if not (x[2] and os.path.exists(os.path.join(DLC, x[2]))):
                    x[2] = icons.get((x[0], x[1]), '')
                s['items'].append(x)
    for sid, p in prev.items():
        if sid not in ids:
            p['gone'] = p.get('gone') or now
            if not p.get('e'):
                p['s'], p['e'] = p.get('s') or p.get('f') or '', p['gone']
            shops.append(p)
    shops.sort(key=lambda s: s['id'])
    return shops


def main():
    regions = [REGION] + [r for r in ('Japan', 'Global') if r != REGION]

    def thumbs(sub):
        """file name -> region-prefixed path, the build's region winning over the other one"""
        out = {}
        for r in reversed(regions):
            d = os.path.join(DLC, r, sub)
            if os.path.isdir(d):
                out.update({f: f'{r}/{sub}/{f}' for f in os.listdir(d)})
        return out
    ithumb = thumbs('item/thumbnail')
    uthumb = thumbs('unit/thumbnail')
    # icons the Items tab already resolved: (kind key, id) -> image
    try:
        with open(os.path.join(DB, 'others', 'items_detail.json'), encoding='utf-8') as f:
            idet = json.load(f)
        item_img = {(x['k'], x['id']): x.get('img', '') for x in idet['items']}
    except (OSError, ValueError, KeyError):
        idet, item_img = {'items': []}, {}
    ev_item = {e['id']: clean(e['name']) for e in load('event_item_master')}

    def equip_icon(oid):
        s = str(oid)
        if len(s) < 9:
            return ''
        b = int(s[1:5])
        for t in (f'item_thumbnail_1{b:04d}1.png', f'item_thumbnail_1{b:04d}0.png'):
            if t in ithumb:
                return ithumb[t]
        return ''

    def icon(otype, oid):
        if otype in (7, 8):
            return equip_icon(oid)
        if otype == 9:
            return uthumb.get(f'unit_thumbnail_{oid}.png', '')
        if otype == 5:
            return item_img.get(('mat', oid)) or has(f'material/material_thumbnail_{oid}.png')
        if otype == 13:
            return item_img.get(('food', oid)) or has(f'cook/thumbnail/cook_thumbnail_{oid}.png')
        if otype == 22:
            return has(f'event/event_item_{oid}.png') or item_img.get(('event', oid)) or has(f'event/event_icon_{oid}.png')
        if otype == 24:
            return item_img.get(('tool', oid), '')
        if otype == 18:
            return has(f'{REGION}/town/alchemy/orb_shop/thumbnail/orb_thumbnail.png')
        if otype == 25:
            return has(f'{REGION}/town/alchemy/orb_shop/thumbnail/ball_thumbnail.png') or 'ASSETS/icon_rainbow_gem.png'
        if otype == 16:
            return has(f'{REGION}/town/alchemy/orb_shop/thumbnail/stone_item_thumbnail_{oid:02d}.png')
        if otype == 33:
            return has(f'unit/sp_icon/unit_sp_icon_{oid // 10}_{oid % 10}.png') if oid >= 100 else ''
        if otype == 17:
            return has(f'{REGION}/town/alchemy/orb_shop/thumbnail/dungeon_key_thumbnail_{oid}.png')
        if otype == 35:  # Mystika (craft generic material)
            return has(f'material/generic_{oid}.png')
        if otype == 36:  # craft unique material (Kraken Skull, Stable Drop, ...)
            return has(f'material/unique_{oid}.png')
        if otype == 15:
            return has(f'{REGION}/town/alchemy/orb_shop/thumbnail/stone_unit_thumbnail.png')
        return ''

    def limit(v):
        v = num(v)
        return -1 if v <= 0 else v

    events = {e['id']: e for e in load('event_master')}
    by_event, by_town = {}, {}
    for s in load('event_shop_master'):
        if num(s.get('status')) != 1:
            continue
        by_event.setdefault(s['event_id'], []).append(s)
    for s in load('orb_shop_master'):
        by_town.setdefault(s['shop_type'], []).append(s)

    now = datetime.now(timezone.utc).isoformat(timespec='seconds')
    shops = []
    for b in sorted(load('shop_banner_master'), key=lambda x: x['id']):
        bg = b.get('bg_name') or ''
        vers = versions(f'{REGION}/alchemyExchange/{bg}') if bg else []
        img = vers[-1] if vers else ''
        imgs = vers[::-1] if len(vers) > 1 else []
        st = b.get('shop_type')
        if st != 'None' and st is not None and num(st) in by_town:
            # newest first: a new True equip / unit is added with a later start date and a higher priority,
            # so the latest additions sit at the top and the 2016 ones at the bottom
            rows = sorted(by_town[num(st)], key=lambda r: (str(r.get('start_at') or ''), num(r.get('priority')) if 'priority' in r else 0, r['id']),
                          reverse=True)
            items = []
            for r in rows:
                cost = [f"{num(r[f'need_value{i}']):,} {NEED.get(r[f'need_type{i}'], 'items')}"
                        for i in range(1, 6) if num(r.get(f'need_type{i}'))]
                items.append([clean(r['name']), KIND.get(r['object_type'], 'Item'), icon(r['object_type'], num(r['object_id'])),
                              num(r['value']), ' + '.join(cost), limit(r.get('max_purchase_value')),
                              clean(r.get('description'))[:120]])
            cur_n = NEED.get(b.get('consume_type'), '')
            cur_i = {18: 'ASSETS/icon_alchemy_stone.png', 25: 'ASSETS/icon_rainbow_gem.png'}.get(b.get('consume_type'), '')
            shops.append({'id': b['id'], 'k': 'town', 'n': TOWN.get(num(st), 'Exchange'), 'img': img, 'imgs': imgs,
                          'cur': [cur_n, cur_i], 's': '', 'e': '', 'f': now, 'items': items})
            continue
        eid = num(b.get('event_id'))
        rows = by_event.get(eid)
        if not rows:
            continue
        ev = events.get(eid, {})
        cid = num(b.get('consume_id'))
        cur_n = ev_item.get(cid, '')
        en = clean(ev.get('name'))
        # the currency's name says which shop it is ("... Exchange Ticket" already reads as a shop name)
        name = en if en and not JP.search(en) else (
            (cur_n if 'exchange' in cur_n.lower() else f'{cur_n} Exchange') if cur_n else f'Event shop {eid}')
        items = []
        rows = sorted(rows, key=lambda r: (num(r.get('priority')), r['id']))
        # catalog shops (the redeem ticket exchanges: mostly units / equips, a new one added each banner)
        # list the newest first, like the town shops; a normal event shop keeps the game's order.
        # The row id grows with each addition in both regions (JP's priority runs the other way in some shops).
        if len(rows) >= 20 and sum(num(r['object_type']) in (7, 8, 9) for r in rows) >= .8 * len(rows):
            rows.sort(key=lambda r: num(r['id']), reverse=True)
        for r in rows:
            need = ev_item.get(r['need_item_id'], cur_n) or 'event items'
            items.append([clean(r['name']), KIND.get(r['object_type'], 'Item'), icon(r['object_type'], num(r['object_id'])),
                          num(r['value']), f"{num(r['need_count']):,} {need}", limit(r.get('max_purchase_value')),
                          clean(r.get('description'))[:120]])
        s = ev.get('item_start_at') or ev.get('start_at') or ''
        e = ev.get('item_end_at') or ev.get('end_at') or ''
        shops.append({'id': b['id'], 'k': 'event', 'n': name, 'img': img, 'imgs': imgs, 'f': now,
                      'cur': [cur_n, has(b.get('consume_image') or '') or icon(22, cid)], 's': '' if s == 'None' else s, 'e': '' if e == 'None' else e,
                      'items': items})

    # A reward whose own picture is not in the repo (a new Crossover Gem / Insignia id, ...) borrows the picture
    # of an item with the same name, then of one of the same family (last word: "Insignia", "Gem", ...).
    by_name, by_word = {}, {}
    for x in idet['items']:
        p, n = x.get('img') or '', (x.get('n') or '').strip()
        if p and n and os.path.exists(os.path.join(DLC, p)):
            by_name.setdefault(n.lower(), p)
            by_word.setdefault((x['k'], n.split()[-1].lower()), p)
    kind_key = {'Material': 'mat', 'Food': 'food', 'Event item': 'event', 'Item': 'tool'}
    for sh in shops:
        for x in sh['items']:
            if x[2] or x[1] not in kind_key:
                continue
            n = re.sub(r'\s+EX$', '', x[0]).lower()
            x[2] = by_name.get(x[0].lower()) or by_name.get(n) or (
                by_word.get((kind_key[x[1]], n.split()[-1])) if x[1] == 'Material' and n else '') or ''

    shops = merge_old(shops, now)
    data = {'built': now, 'shops': shops}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    n = sum(len(s['items']) for s in shops)
    print(f"{len(shops)} shops ({sum(s['k'] == 'town' for s in shops)} town, {sum(bool(s.get('gone')) for s in shops)} gone), "
          f"{n} items ({sum(1 for s in shops for i in s['items'] if len(i) > 7 and i[7])} old) -> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
