"""
Build dlc/Global/_DATABASE/others/quests_detail.json for the website's Quests tab.

Reads the decrypted GL DB exports in dlc/Global/_DATABASE/*/ and writes one row per dungeon:
  - name, category, banner pictures (dlc/Global/banner/dungeon_banner[_top]_<id>.png)
  - schedule: the open windows from dungeon_launcher_master (start, end; times are PT, "-08:00" written
    as the game does), only those that end after (build time - 2 days), plus the weekday of the
    Crest Palaces (dungeon_type 8001..8007 = Monday..Sunday)
  - quests: name, stamina, difficulty, the drops the game shows (display_item_list) and the rewards
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
DB = os.path.join(DLC, 'Global', '_DATABASE')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(DB, 'others', 'quests_detail.json')

JP = re.compile(r'[぀-ヿ一-鿿]')
WEEKDAY = {8001: 'Monday', 8002: 'Tuesday', 8003: 'Wednesday', 8004: 'Thursday', 8005: 'Friday', 8006: 'Saturday', 8007: 'Sunday'}
CAT = {0: 'Story', 2: 'Events', 6: 'Side Stories', 8: 'Summoners Road', 2002: 'Exploring', 7: 'Crest Palace', 4001: 'Material Quests'}
# reward / drop "type" codes used by quest_master and display_item_list
# (checked against the tables the ids belong to: 7 item_recipe, 8 item, 9 unit, 13 food, 22 event_item, 24 tool)
RTYPE = {2: 'Gren', 5: 'Material', 7: 'Equip recipe', 8: 'Equip', 9: 'Unit', 11: 'Crystals', 13: 'Food',
         17: 'Stamina', 18: 'Arca', 22: 'Event item', 24: 'Item', 25: 'Rainbow Gems'}
MAX_WIN = 200     # open windows kept per dungeon


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
    return rel if os.path.exists(os.path.join(DLC, rel)) else ''


def main():
    dungeons = load('dungeon_master')
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
             24: {t['id']: clean(t['name']) for t in load('tool_master')}}
    eq = {}
    for x in sorted(load('item_master'), key=lambda x: x['evolution_stage'] if x['evolution_stage'] != 99 else -1):
        eq[x['id']] = clean(x['name'])
    names[7] = names[8] = eq
    units = {u['id']: clean(u['name']) for u in load('unit_master')}
    names[9] = units

    def thing(t, i, n=0):
        t, i = num(t), num(i)
        if not t:
            return None
        label = RTYPE.get(t, f'Type {t}')
        name = names.get(t, {}).get(i, '') or label
        return [t, i, name, label, num(n)]

    by_dungeon = defaultdict(list)
    for q in quests:
        if num(q.get('dungeon_id')):
            by_dungeon[num(q['dungeon_id'])].append(q)

    now = datetime.now(timezone.utc)
    keep_from = now - timedelta(days=2)
    out = []
    for d in dungeons:
        name = clean(d['name'])
        if not name or JP.search(name):
            continue
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
                    rewards.append([label] + r)
            qs.append({'id': q['id'], 'n': clean(q['name']), 'sta': num(q.get('stamina')), 'dif': num(q.get('difficulty')),
                       'rank': num(q.get('need_rank')), 'gren': num(q.get('drop_coin')), 'drops': drops, 'rew': rewards})
        row = {'id': d['id'], 'n': name, 'cat': cat, 'type': t, 'ev': num(d.get('event_id')), 'rank': num(d.get('need_rank')),
               'img': img(f"Global/banner/dungeon_banner_{d['id']}.png"), 'top': img(f"Global/banner/dungeon_banner_top_{d['id']}.png"),
               'win': [[a.isoformat(), b.isoformat()] for a, b in up[:MAX_WIN]], 'winN': len(wins),
               'first': wins[0][0].isoformat() if wins else '', 'last': wins[-1][1].isoformat() if wins else '',
               'q': qs}
        if t in WEEKDAY:
            row['day'] = WEEKDAY[t]
        out.append(row)
    out.sort(key=lambda r: r['id'])
    data = {'built': now.isoformat(timespec='seconds'), 'dungeons': out}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    by = defaultdict(int)
    for r in out:
        by[r['cat']] += 1
    print(dict(by), f"-> {OUT} ({os.path.getsize(OUT) // 1024} KB)")


if __name__ == '__main__':
    main()
