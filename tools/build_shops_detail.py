"""
Build dlc/Global/_DATABASE/others/shops_detail.json for the website's Exchange tab.

The game's Exchange screen is a list of shop banners (shop_banner_master):
  - town shops (shop_type 1 Alch Shop, 2 Alchemist / True Equips for Rainbow Gems, 3 Material exchange,
    6 / 7 other exchanges): items in orb_shop_master (by shop_type)
  - event exchange shops (event_id): items in event_shop_master (by event_id), paid with the event's item
Each shop: banner picture (dlc/Global/alchemyExchange/<bg_name> when the repo has it), the currency it takes
(name + icon), the exchange window (event_master item_start_at / item_end_at; town shops are permanent)
and its items: what you get (name, kind, icon), how many, the price and the exchange limit.

Item icons, by reward type:
  8 / 7 equip / recipe  Japan/item/thumbnail/item_thumbnail_1<base:04><1|0>.png
  9 unit                unit/thumbnail/unit_thumbnail_<id>.png
  5 material, 13 food, 22 event item, 24 tool: the image items_detail.json has for it
  18 Alch               ASSETS/icon_alchemy_stone.png
  25 Rainbow Gem        ASSETS/icon_rainbow_gem.png (the game's icon/material_icon/alchemy_rainbow_stone.png)
Others (stamps, LB stones, keys, SP arts, ...) have no icon in the repo: the site shows a badge.

Output: {"built", "shops": [{id, k: 'town'|'event', n, img, cur: [name, icon], s, e, items: [[name, kind, icon,
         amount, price, limit, note]]}]}  (s / e empty for permanent shops; limit -1 = no limit)

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
DB = os.path.join(DLC, 'Global', '_DATABASE')
OUT = os.path.join(DB, 'others', 'shops_detail.json')

JP = re.compile(r'[぀-ヿ一-鿿]')
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
    return rel if rel and os.path.exists(os.path.join(DLC, rel)) else ''


def main():
    ithumb = set(os.listdir(os.path.join(DLC, 'Japan', 'item', 'thumbnail')))
    uthumb = set(os.listdir(os.path.join(DLC, 'unit', 'thumbnail')))
    # icons the Items tab already resolved: (kind key, id) -> image
    try:
        with open(os.path.join(DB, 'others', 'items_detail.json'), encoding='utf-8') as f:
            idet = json.load(f)
        item_img = {(x['k'], x['id']): x.get('img', '') for x in idet['items']}
    except (OSError, ValueError, KeyError):
        item_img = {}
    ev_item = {e['id']: clean(e['name']) for e in load('event_item_master')}

    def equip_icon(oid):
        s = str(oid)
        if len(s) < 9:
            return ''
        b = int(s[1:5])
        for t in (f'item_thumbnail_1{b:04d}1.png', f'item_thumbnail_1{b:04d}0.png'):
            if t in ithumb:
                return f'Japan/item/thumbnail/{t}'
        return ''

    def icon(otype, oid):
        if otype in (7, 8):
            return equip_icon(oid)
        if otype == 9:
            t = f'unit_thumbnail_{oid}.png'
            return f'unit/thumbnail/{t}' if t in uthumb else ''
        if otype == 5:
            return item_img.get(('mat', oid)) or has(f'material/material_thumbnail_{oid}.png')
        if otype == 13:
            return item_img.get(('food', oid)) or has(f'cook/thumbnail/cook_thumbnail_{oid}.png')
        if otype == 22:
            return item_img.get(('event', oid)) or has(f'event/event_icon_{oid}.png')
        if otype == 24:
            return item_img.get(('tool', oid), '')
        if otype == 18:
            return 'ASSETS/icon_alchemy_stone.png'
        if otype == 25:
            return 'ASSETS/icon_rainbow_gem.png'
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

    shops = []
    for b in sorted(load('shop_banner_master'), key=lambda x: x['id']):
        bg = b.get('bg_name') or ''
        img = has(f'Global/alchemyExchange/{bg}') if bg else ''
        st = b.get('shop_type')
        if st != 'None' and st is not None and num(st) in by_town:
            rows = sorted(by_town[num(st)], key=lambda r: (num(r.get('priority')) if 'priority' in r else 0, r['id']))
            items = []
            for r in rows:
                cost = [f"{num(r[f'need_value{i}']):,} {NEED.get(r[f'need_type{i}'], 'items')}"
                        for i in range(1, 6) if num(r.get(f'need_type{i}'))]
                items.append([clean(r['name']), KIND.get(r['object_type'], 'Item'), icon(r['object_type'], num(r['object_id'])),
                              num(r['value']), ' + '.join(cost), limit(r.get('max_purchase_value')),
                              clean(r.get('description'))[:120]])
            cur_n = NEED.get(b.get('consume_type'), '')
            cur_i = {18: 'ASSETS/icon_alchemy_stone.png', 25: 'ASSETS/icon_rainbow_gem.png'}.get(b.get('consume_type'), '')
            shops.append({'id': b['id'], 'k': 'town', 'n': TOWN.get(num(st), 'Exchange'), 'img': img,
                          'cur': [cur_n, cur_i], 's': '', 'e': '', 'items': items})
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
        for r in sorted(rows, key=lambda r: (num(r.get('priority')), r['id'])):
            need = ev_item.get(r['need_item_id'], cur_n) or 'event items'
            items.append([clean(r['name']), KIND.get(r['object_type'], 'Item'), icon(r['object_type'], num(r['object_id'])),
                          num(r['value']), f"{num(r['need_count']):,} {need}", limit(r.get('max_purchase_value')),
                          clean(r.get('description'))[:120]])
        s = ev.get('item_start_at') or ev.get('start_at') or ''
        e = ev.get('item_end_at') or ev.get('end_at') or ''
        shops.append({'id': b['id'], 'k': 'event', 'n': name, 'img': img,
                      'cur': [cur_n, has(b.get('consume_image') or '') or icon(22, cid)], 's': '' if s == 'None' else s, 'e': '' if e == 'None' else e,
                      'items': items})

    data = {'built': datetime.now(timezone.utc).isoformat(timespec='seconds'), 'shops': shops}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    n = sum(len(s['items']) for s in shops)
    print(f"{len(shops)} shops ({sum(s['k'] == 'town' for s in shops)} town), {n} items -> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
