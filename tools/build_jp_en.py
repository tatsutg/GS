"""
Build dlc/Japan/_DATABASE/others/jp_en.json: English for the Japanese names and texts shown on the
JP server's Summon, Quests and Exchange tabs and in Equip Info's quest drops (the site shows them
when the JP server is picked with the "English" text option). The JP files stay untouched; this file
is a flat dictionary {Japanese text: English text}, applied by js/jpen.js on the site.

No machine translation. Every English string comes from, in this order:
  1. Global's own text for the same row: JP and GL master tables joined on id (dungeon, quest, gacha,
     items, materials, event items, enemies, missions, boss info ...), every text column.
     Units also come from unitsv2_en.json (GL names + researched names of JP-only units).
     JP and GL can share wording but not values (JP 30% vs GL 50%): the GL sentence is kept with
     JP's numbers (fix_nums from build_unitsv2_en.py).
  2. Translation memory mined from those pairs: a JP line whose template (numbers as slots) GL has
     already translated somewhere gets GL's wording with JP's numbers.
  3. tools/jp_en_glossary.json, kept by hand, only where GL has no text for that id (GL's own English
     replaces a hand name on the next build once GL ships it): JP-only banners, events, quests and items, researched
     against GL wording / official collab names.
Only strings that the JP site files really contain are kept (the file stays small).
Composite strings the site builds ("<item> exchange", "20 × <item>", "【EX】<quest>", "<name> 前編")
are split the same way js/jpen.js splits them, so their parts get looked up too.

Manual run from the repo root:
    python tools/build_jp_en.py           (add --miss to list the strings still untranslated)
"""
import json
import os
import re
import sys
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_unitsv2_en as U   # noqa: E402  (fix_nums / translation memory shared with the units overlay)

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
OTH = lambda r: os.path.join(GS, 'dlc', r, '_DATABASE', 'others')
OUT = os.path.join(OTH('Japan'), 'jp_en.json')
GLOSS = os.path.join(HERE, 'jp_en_glossary.json')
JPCHR = re.compile(r'[ぁ-んァ-ヶ一-龯々〆ヵヶ]')
# master tables joined on id between the two servers. Not event_master / event_shop_master: the servers reuse
# those ids for different events (JP "1/15 KOB復刻交換所" is GL's Ten-Sura New Year shop)
TABLES = ['dungeon_master', 'quest_master', 'gacha_master', 'item_master', 'material_master', 'event_item_master',
          'enemy_master', 'dungeon_mission_master', 'boss_info_master',
          'unit_master', 'shop_banner_master', 'challenge_master', 'mini_game_master', 'orb_shop_master',
          'skin_master', 'wallpaper_master', 'help_master', 'season_pass_master', 'login_bonus_master']
# joins whose ids are not the same thing on both servers often enough to trust a generic GL text
LOOSE = {'enemy_master', 'boss_info_master', 'dungeon_mission_master'}
# site files whose strings get English (JP server)
SITE = ['summons_detail.json', 'quests_detail.json', 'shops_detail.json', 'equipsv2_detail.json']


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def has_jp(s):
    return isinstance(s, str) and bool(JPCHR.search(s))


# composite strings: the same rules js/jpen.js applies when a whole string has no entry.
# (regex, template): {n} = group n kept as is, {tn} = group n looked up (recursively)
RULES = [
    (r'^「(.+)」の性能を\s*大幅に強化する真装備\s*[（(](\d+)回まで交換可[）)]$', 'True Equip that greatly boosts {t1} (exchangeable up to {2} times)'),
    (r'^「(.+)」の真装備\s*[（(](\d+)回まで交換可[）)]\s*※(\d{1,2}/\d{1,2})までの期間限定交換$', 'True Equip of {t1} (exchangeable up to {2} times) *Limited-time exchange until {3}'),
    (r'^「(.+)」の真装備\s*※(\d{1,2}/\d{1,2})までの期間限定交換$', 'True Equip of {t1} *Limited-time exchange until {2}'),
    (r'^★(\d)\s*(物理|魔法|防御|回復|援護)タイプの装備\s*(.+)$', '★{1} {t2} Equip {t3}'),
    (r'^使用期限[：:]\s*(.+?)まで$', 'Expires: {1}'),
    (r'^(\d{1,2}/\d{1,2}(?: \d{1,2}:\d{2})?)まで$', 'Until {1}'),
    (r'^(.+?)。\s*(.+)$', '{t1}. {t2}'),
    (r'^(.+?)。$', '{t1}.'),
    (r'^(.+) > (.+)$', '{t1} > {t2}'),
    (r'^× (.+)$', '× {t1}'),
    (r'^(.+?)\s+(\d{1,2}/\d{1,2} \d{1,2}:\d{2})まで\s+(.+)$', '{t1} Until {2}. {t3}'),
    (r'^(\d{1,2}/\d{1,2} \d{1,2}:\d{2})まで\s+(.+)$', 'Until {1}. {t2}'),
    (r'^(.+?)\s*(\d+)周目$', '{t1} Round {2}'),
    (r'^(.+?)\s*Lv(\d+)$', '{t1} Lv{2}'),
    (r'^(\d[\d,]*) × (.+)$', '{1} × {t2}'),
    (r'^(\d[\d,]*) (.+)$', '{1} {t2}'),
    (r'^(\d{1,2}/\d{1,2}) (.+)$', '{1} {t2}'),
    (r'^(.+) exchange$', '{t1} exchange'),
    (r'^(.+?)交換所$', '{t1} Exchange'),
    (r'^【(.+?)】\s*(.+)$', '【{1}】{t2}'),   # tier tags stay (the Quests tab reads them)
    (r'^(.+?)\s*前編$', '{t1} Part 1'),
    (r'^(.+?)\s*中編$', '{t1} Part 2'),
    (r'^(.+?)\s*後編$', '{t1} Part 2'),
    (r'^(.+?)\s*[（(](.+?)専用[）)]$', '{t1} ({t2} only)'),
    (r'^(.+?)\s*[（(](.+?)[）)]$', '{t1} ({t2})'),
    (r'^復刻(.+)$', '{t1} (Rerun)'),
    (r'^「(.+?)」(.+)$', '"{t1}" {t2}'),
    (r'^人懐っこい(.+?)。\s*※編成可能ユニット/売却・強化使用不可$', 'A friendly {t1}. *Can join parties / cannot be sold or used for enhancement'),
    (r'^(\d{1,2}/\d{1,2})\s*(\S.*)$', '{1} {t2}'),
    (r'^(.+?)\s*宝具石$', '{t1} Equipment Gem'),
    (r'^(.+?)\s*英雄石$', '{t1} Hero Gem'),
    (r'^(.+?)\s*真装備交換チケット$', '{t1} True Equip Exchange Ticket'),
    (r'^(.+?)\s*真装備$', '{t1} True Equip'),
    (r'^(.+?)\s*装備ガチャ$', '{t1} Equip Summon'),
    (r'^(.+?)\s*ガチャ$', '{t1} Summon'),
    (r'^(.+?)\s*コラボ$', '{t1} Crossover'),
    (r'^(.+?)\s*復刻$', '{t1} Rerun'),
    (r'^(.+?)\s*イベント$', '{t1} Event'),
    (r'^(.+?)\s*降臨祭$', '{t1} Advent'),
    (r'^(.+?)\s*(前半|後半)$', '{t1} {t2}'),
]
RULES = [(re.compile(r), t) for r, t in RULES]


def translate(s, d, miss=None, depth=0):
    """English for s from dictionary d (+ RULES); leaves that stay Japanese go to miss"""
    if not has_jp(s):
        return s
    if s in d:
        return d[s]
    hit = False
    if depth < 6:
        for rx, tpl in RULES:
            m = rx.match(s)
            if not m:
                continue
            hit = True
            sub = {}
            for i, g in enumerate(m.groups(), 1):
                sub[str(i)] = g
                sub['t' + str(i)] = translate(g.strip(), d, miss, depth + 1)
            out = re.sub(r'\{(t?\d)\}', lambda x: sub[x.group(1)], tpl)
            if not has_jp(re.sub(r'【[^】]*】', '', out)):
                return out
    if miss is not None and not hit:   # a leaf: no rule splits it
        miss[s] = miss.get(s, 0) + 1
    return s


def parts(s):
    """the pieces RULES may look up, so the dictionary keeps them too"""
    out = []
    for rx, tpl in RULES:
        m = rx.match(s)
        if m:
            out += [m.group(int(k)).strip() for k in re.findall(r'\{t(\d)\}', tpl)]
    return [p for p in out if p and p != s]


def site_strings():
    """the JP strings the site shows on those tabs (not every text in the files: equip skills / lore stay out)"""
    seen = set()

    def add(v):
        if has_jp(v) and v not in seen:
            seen.add(v)
            for p in parts(v):
                add(p)
    j = lambda f: load(os.path.join(OTH('Japan'), f))
    s = j('summons_detail.json')
    for b in s.get('banners', []):
        add(b.get('n'))
    for k in ('units', 'equips'):
        for row in s.get(k, {}).values():
            add(row[0])
            if k == 'units' and len(row) > 4:
                add(row[4])
    q = j('quests_detail.json')
    for d in q.get('dungeons', []):
        add(d.get('n'))
        for b in d.get('boss', []) or []:
            add(b.get('n'))
        for f in d.get('foes', []) or []:
            add(f[0])
        for x in d.get('q', []) or []:
            add(x.get('n'))
            for r in x.get('rew', []) or []:
                add(r[3])
            for r in x.get('drops', []) or []:
                add(r[2])
            for b in (x.get('boss', []) or []) + (x.get('bossX', []) or []):
                add(b.get('n'))
    for v in q.get('bossInfo', {}).values():
        add(v.get('desc'))
    for sh in j('shops_detail.json').get('shops', []):
        add(sh.get('n'))
        add((sh.get('cur') or [None])[0])
        for it in sh.get('items', []) or []:
            add(it[0])
            add(it[4])
            add(it[6] if len(it) > 6 else None)
    for e in j('equipsv2_detail.json').get('equips', []):
        for r in e.get('src', []) or []:
            add(r.get('n'))
            add(r.get('d'))
    return seen


def same_pic(a, b):
    """same banner picture on both servers (file name, the art's own id; the text on it is per server).
    None when one side has no picture"""
    a, b = os.path.basename(str(a or '')), os.path.basename(str(b or ''))
    if not a or not b or a in ('0', 'None') or b in ('0', 'None'):
        return None
    return a == b


class Pairs(dict):
    """JP text -> GL text, by vote. A JP text GL names several ways keeps its most common English only
    when that is at least 60% of the votes ("英雄石交換所" = many GL shops, "Hero Gem (<event> Exclusive)
    Exchange": no clear winner, dropped). A GL text that 3+ different JP texts map to is a generic label
    from a loose join (enemy display names by unit id, shop notes by icon): dropped too, never a guess.
    Trusted pairs (same row id: dungeon, quest, item, unit, banner with the same picture) keep GL's own
    text even when it is generic: the JP page in English then reads like the GL page"""
    key = staticmethod(lambda v: re.sub(r'\W+', '', v).lower())

    def __init__(self):
        super().__init__()
        self.votes = {}
        self.trusted = set()

    def setdefault(self, k, v, trusted=False):
        # GL names carry stray spaces / line breaks: one line, unless JP has breaks too
        v = v.strip() if chr(10) in k else re.sub(r'\s+', ' ', v).strip()
        if not v:
            return v
        if trusted:
            self.trusted.add(k)
        c = self.votes.setdefault(k, {})
        c[v] = c.get(v, 0) + 1
        return v

    def done(self):
        self.clear()
        by_en = {}
        for k, c in self.votes.items():
            tot = sum(c.values())
            grp = {}
            for v, n in c.items():
                grp.setdefault(self.key(v), [v, 0])[1] += n
            v, n = max(grp.values(), key=lambda x: x[1])
            if n / tot >= 0.6:
                self[k] = v
                by_en.setdefault(self.key(v), set()).add(k)
        for en, ks in by_en.items():
            if len(ks) >= 3:
                for k in ks - self.trusted:
                    del self[k]
        return self


def join_tables():
    pairs = Pairs()
    for t in TABLES:
        pj, pg = os.path.join(OTH('Japan'), t + '.json'), os.path.join(OTH('Global'), t + '.json')
        if not (os.path.exists(pj) and os.path.exists(pg)):
            continue
        gl = {r.get('id'): r for r in load(pg) if isinstance(r, dict)}
        for r in load(pj):
            g = gl.get(r.get('id')) if isinstance(r, dict) else None
            if not g:
                continue
            # a summon id is only the same banner when its picture is the same one
            if t == 'gacha_master' and same_pic(r.get('bg_name'), g.get('bg_name')) is False:
                continue
            for k, v in r.items():
                e = g.get(k)
                if has_jp(v) and isinstance(e, str) and e.strip() and e not in ('0', 'None') and not has_jp(e):
                    pairs.setdefault(v, e, t not in LOOSE)
                    # status_json etc. are skipped (not shown); descriptions keep their line breaks
    return pairs


def unit_names(pairs):
    # summons_detail units: base id -> [name, thumb, rar, summonRar, topName]
    sj = load(os.path.join(OTH('Japan'), 'summons_detail.json'))
    sg = load(os.path.join(OTH('Global'), 'summons_detail.json'))
    en = load(os.path.join(OTH('Japan'), 'unitsv2_en.json')).get('units', {})
    for b, row in sj.get('units', {}).items():
        g = sg.get('units', {}).get(b)
        e = en.get(b, {})
        for i in (0, 4):
            if i >= len(row) or not has_jp(row[i]):
                continue
            n = (g[i] if g and i < len(g) and g[i] and not has_jp(g[i]) else None) or e.get('Name')
            if n and not has_jp(n):
                pairs.setdefault(row[i], n, True)
    for b, row in sj.get('equips', {}).items():
        g = sg.get('equips', {}).get(b)
        if g and has_jp(row[0]) and g[0] and not has_jp(g[0]):
            pairs.setdefault(row[0], g[0], True)
    # every form name of every unit (2★ .. Awk★): JP unitsv2_detail -> unitsv2_en (GL text / researched)
    ud = load(os.path.join(OTH('Japan'), 'unitsv2_detail.json'))
    for b, rec in ud.items():
        e = en.get(b, {})
        for k, v in rec.items():
            if (k == 'Name' or k.endswith('★ Name')) and isinstance(v, str) and has_jp(v):
                n = e.get(k)
                if n and not has_jp(n):
                    pairs.setdefault(v, n, True)
    # banners by id
    gb = {b['id']: b for b in sg.get('banners', [])}
    for b in sj.get('banners', []):
        g = gb.get(b['id'])
        n = g and same_pic(b.get('img'), g.get('img')) is not False and g['n']
        if n and has_jp(b['n']) and not has_jp(n):
            pairs.setdefault(b['n'], n, True)


def site_joins(pairs):
    """the GL copies of the same site files, joined on ids (dungeon / quest / reward / enemy / shop / item)"""
    j = lambda r, f: load(os.path.join(OTH(r), f)) if os.path.exists(os.path.join(OTH(r), f)) else {}

    def put(a, b, trusted=False):
        if has_jp(a) and isinstance(b, str) and b.strip() and not has_jp(b):
            pairs.setdefault(a, b, trusted)
    icon = lambda p: re.sub(r'^(Japan|Global)/', '', str(p or ''))
    qg = j('Global', 'quests_detail.json')
    gd, gq, grew, gunit = {}, {}, {}, {}
    for d in qg.get('dungeons', []):
        gd[d['id']] = d.get('n')
        for b in (d.get('boss') or []):
            gunit[b.get('u')] = b.get('n')
        for f in (d.get('foes') or []):
            gunit[f[1]] = f[0]
        for x in d.get('q', []) or []:
            gq[x['id']] = x.get('n')
            for r in x.get('rew', []) or []:
                grew[(r[1], r[2])] = r[3]
            for r in x.get('drops', []) or []:
                grew[(r[0], r[1])] = r[2]
            for b in (x.get('boss') or []) + (x.get('bossX') or []):
                gunit[b.get('u')] = b.get('n')
    gdesc = {k: v.get('desc') for k, v in qg.get('bossInfo', {}).items()}
    qj = j('Japan', 'quests_detail.json')
    for d in qj.get('dungeons', []):
        put(d.get('n'), gd.get(d['id']), True)
        for b in (d.get('boss') or []):
            put(b.get('n'), gunit.get(b.get('u')))
        for f in (d.get('foes') or []):
            put(f[0], gunit.get(f[1]))
        for x in d.get('q', []) or []:
            put(x.get('n'), gq.get(x['id']), True)
            for r in x.get('rew', []) or []:
                put(r[3], grew.get((r[1], r[2])), True)
            for r in x.get('drops', []) or []:
                put(r[2], grew.get((r[0], r[1])), True)
            for b in (x.get('boss') or []) + (x.get('bossX') or []):
                put(b.get('n'), gunit.get(b.get('u')))
    for k, v in qj.get('bossInfo', {}).items():
        put(v.get('desc'), gdesc.get(k))
    # shops by id, shop items by icon (the same picture is the same item)
    sg = j('Global', 'shops_detail.json')
    gs, gi = {}, {}
    for sh in sg.get('shops', []):
        gs[sh['id']] = sh
        for it in sh.get('items', []) or []:
            gi.setdefault(icon(it[2]), it)
    for sh in j('Japan', 'shops_detail.json').get('shops', []):
        g = gs.get(sh['id'])
        if g and same_pic(sh.get('img'), g.get('img')):   # same shop id + same banner = the same shop
            put(sh.get('n'), g.get('n'), True)
            put((sh.get('cur') or [None])[0], (g.get('cur') or [None])[0])
        for it in sh.get('items', []) or []:
            g = gi.get(icon(it[2]))
            if g:
                put(it[0], g[0])
                if len(it) > 6 and len(g) > 6:
                    put(it[6], g[6])
    # items tab names by kind + id
    gitems = {(i.get('k'), i.get('id')): i.get('n') for i in j('Global', 'items_detail.json').get('items', [])}
    for i in j('Japan', 'items_detail.json').get('items', []):
        put(i.get('n'), gitems.get((i.get('k'), i.get('id'))), True)


def main():
    need = site_strings()
    pairs = join_tables()
    unit_names(pairs)
    site_joins(pairs)
    pairs.done()
    # GL wording, JP numbers; pairs whose numbers cannot be lined up are dropped
    mem = U.Memory()
    d = {}
    for jp, en in pairs.items():
        mem.pair(jp, en)
        fixed = U.fix_nums_aligned(jp, en) if re.search(r'\d', jp + en) else en
        if fixed:
            d[jp] = fixed
    mem.done()
    # hand list only fills what GL lacks: once GL ships that id, its own English takes over on the next build
    gloss = load(GLOSS) if os.path.exists(GLOSS) else {}
    for k, v in gloss.items():
        if not k.startswith('_') and k not in d:
            d[k] = v
    # whole strings (and the pieces RULES look up) that only the memory knows
    todo = list(need)
    while todo:
        s = todo.pop()
        if s in d or not has_jp(s):
            continue
        m = mem.get(s)
        if m and not has_jp(m):
            d[s] = m
        else:
            todo += parts(s)
    out = {s: d[s] for s in sorted(need) if s in d}
    # what is still Japanese after the rules: the whole strings (stats) and their leaves (to research)
    miss, whole = {}, 0
    for s in need:
        if has_jp(translate(s, out)):
            whole += 1
            translate(s, out, miss)
    # same dictionary as last time: keep its date, so the Action has nothing to commit
    built = datetime.now(timezone.utc).isoformat(timespec='seconds')
    if os.path.exists(OUT):
        old = load(OUT)
        if old.get('t') == out:
            built = old.get('built', built)
    data = {'built': built, 't': out,
            'stats': {'strings': len(need), 'entries': len(out), 'stillJapanese': whole}}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print(f'jp_en.json: {len(out)} entries; {len(need) - whole}/{len(need)} strings in English, {whole} still Japanese')
    if '--miss' in sys.argv:
        for s, c in sorted(miss.items(), key=lambda x: -x[1]):
            print(c, json.dumps(s, ensure_ascii=False))


if __name__ == '__main__':
    main()
