"""Crest Palace campaigns per server (dlc/crest_campaigns.json).

The site's Items > Crests tab shows the crest campaign running on the selected server (e.g. event 702
"紋章クエストスタミナ半分キャンペーン": half stamina on the Crest Palace quests) with its period and a
countdown. event_master.json is 0.7 MB (GL) / 2.9 MB (JP), too big to load for one line, so this
keeps only the events whose param.quest_id_list has Crest Palace quests (dungeons 4000000-4099999).

    {"built": "...", "Global": [{"id", "type", "n", "rate", "s", "e"}, ...], "Japan": [...]}

s / e keep the DB's offset ("2026-11-12 00:00:00+09:00"), so the site's new Date() is exact.
Only campaigns that end within the last 30 days or later are kept (current + upcoming + just ended).
Run after a DB update (build_items_detail.py calls it at the end).
"""
import json
import os
from datetime import datetime, timedelta, timezone

GS = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(GS, 'dlc', 'crest_campaigns.json')


def _palace(qid):
    # quest id = dungeon id + 2-digit quest no. (4000101 = dungeon 4000100, quest 1)
    return 40000 <= int(qid) // 100 < 41000


def _parse(s):
    try:
        return datetime.fromisoformat(str(s))
    except ValueError:
        return None


def campaigns(region, since):
    path = os.path.join(GS, 'dlc', region, '_DATABASE', 'others', 'event_master.json')
    if not os.path.exists(path):
        return None
    with open(path, encoding='utf-8') as f:
        events = json.load(f)
    out = []
    for e in events:
        try:
            p = json.loads(e.get('param') or '{}')
        except (TypeError, ValueError):
            continue
        if not isinstance(p, dict):
            continue
        qs = p.get('quest_id_list') or []
        if not any(_palace(q) for q in qs if str(q).isdigit() or isinstance(q, int)):
            continue
        end = _parse(e.get('end_at'))
        if not end or end < since:
            continue
        row = {'id': e['id'], 'type': e.get('type'), 'n': e.get('name') or '', 's': e.get('start_at'), 'e': e.get('end_at')}
        if 'rate' in p:
            row['rate'] = p['rate']
        out.append(row)
    out.sort(key=lambda r: r['s'] or '')
    return out


def main():
    now = datetime.now(timezone.utc)
    data = {'built': now.isoformat(timespec='seconds')}
    for region in ('Global', 'Japan'):
        rows = campaigns(region, now - timedelta(days=30))
        if rows is None:
            print(f'crest_campaigns: {region} event_master missing, skipped')
            return
        data[region] = rows
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print('crest_campaigns: ' + ', '.join(f'{r} {len(data[r])}' for r in ('Global', 'Japan')) + f' -> {OUT}')


if __name__ == '__main__':
    main()
