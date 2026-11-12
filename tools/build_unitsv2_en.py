"""
Build dlc/Japan/_DATABASE/others/unitsv2_en.json: an English overlay for the JP Units V2 data
(the site shows it when the JP server is picked with the "English" text option). The Japanese
unitsv2_detail.json stays untouched; this file only holds English strings for the same keys.

No machine translation. Every English string comes from, in this order:
  1. Global's own text for the same thing
       same unit (base id) on GL      -> GL unitsv2_detail field (name, lore, skill text ...)
       same skill id in GL skill_master -> GL name / description
     JP and GL can share wording but not values (JP 200% vs GL 150% after a JP buff), so the GL
     sentence is kept and its numbers are swapped back to JP's (fix_nums below).
  2. Translation memory mined from the two servers: every JP/GL pair of the same skill id and the
     same unit field, cut to sentences / clauses, numbers turned into slots. A JP sentence whose
     template GL has already translated somewhere gets GL's official wording with JP's numbers.
  3. tools/unitsv2_en_glossary.json, kept by hand: names (units, skills, passives) and the lines
     the two above cannot cover, researched against GL wording / official collab names.
Whatever is still missing stays Japanese (the site shows the JP text for that field).

Output: {"built", "units": {base: {field: text, "_forms": {form: {field: text}}}}, "stats": {...}}

Manual run from the repo root:
    python tools/build_unitsv2_en.py           (add --miss to list the lines still untranslated)
"""
import collections
import json
import os
import re
import sys
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = os.path.join(GS, 'dlc')
OTH = lambda r: os.path.join(DLC, r, '_DATABASE', 'others')
OUT = os.path.join(OTH('Japan'), 'unitsv2_en.json')
GLOSS = os.path.join(HERE, 'unitsv2_en_glossary.json')

NUM = re.compile(r'\d+(?:\.\d+)?')
ZEN = str.maketrans('０１２３４５６７８９％（）：／＋－　', '0123456789%():/+- ')
DETAIL = re.compile(r'(Detail|Detail-\d)$')
NAME_FIELDS = re.compile(r'^(Skill|Arts|True Arts|Super Arts|Passives \d|D\.A \d Name-\d)$')
UNIT_NAME = re.compile(r'^(Name|\w+★ Name)$')
LORE = re.compile(r'^\w+★ Lore$')
JPCHR = re.compile(r'[ぁ-んァ-ヶ一-龯]')


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def norm(s):
    return re.sub(r'\s+', ' ', str(s or '').translate(ZEN)).strip()


def jsplit(t):
    return [s.strip() for s in re.split(r'[。\n]', norm(t)) if s.strip()]


def esplit(t):
    return [s.strip() for s in re.split(r'(?<=[.!?])\s+|\n', str(t or '').strip()) if s.strip()]


# Template slots: numbers, elements and races, so "光属性 ... 50%" reuses GL's line for "闇属性 ... 30%".
# A slot holds the English value (number as is, 光属性 -> Light, 魔族 -> Demon).
ELEM = {'炎': 'Fire', '水': 'Water', '樹': 'Earth', '光': 'Light', '闇': 'Dark'}
RACE = {'人': 'Human', '魔': 'Demon', '神': 'God', '精霊': 'Spirit', '竜': 'Dragon', '獣': 'Beast',
        '機': 'Machine', '巨人': 'Giant'}
JP_TOK = re.compile(r'(?P<n>\d+(?:\.\d+)?)|(?P<e>[炎水樹光闇])属性|(?P<r>巨人|精霊|[人魔神竜獣機])族')
EN_TOK = re.compile(r'(?P<n>\d+(?:\.\d+)?)|\b(?P<e>Fire|Water|Earth|Light|Dark)\b'
                    r'|\b(?P<r>Human|Demon|God|Spirit|Dragon|Beast|Machine|Giant)(?=s?\b)')
SLOT = {'n': '⟨n⟩', 'e': '⟨e⟩', 'r': '⟨r⟩'}
FILL = re.compile(r'⟨[ner]⟩')


def canon(s):
    """JP spelling variants that mean the same: を before an amount / 回復, アップ, spaces"""
    s = re.sub(r'(?<=[\d%])アップ', 'UP', norm(s))
    s = re.sub(r'(?<=[\d%])ダウン', 'DOWN', s)
    s = re.sub(r'を(?=\d|回復)', '', s)
    return re.sub(r'(?<=[^ -~]) | (?=[^ -~])', '', s)


def tmpl(s, jp=True):
    """text -> (template, [(slot, English value)])"""
    s = canon(s) if jp else str(s or '').strip()
    toks = []

    def sub(m):
        k = m.lastgroup
        v = m.group(k)
        toks.append((k, ELEM[v] if jp and k == 'e' else RACE[v] if jp and k == 'r' else v))
        return SLOT[k] if not jp or k == 'n' else SLOT[k] + ('属性' if k == 'e' else '族')

    return (JP_TOK if jp else EN_TOK).sub(sub, s), toks


def fill(t, toks, perm):
    it = iter(perm)
    return FILL.sub(lambda _: toks[next(it)][1], t)


def kind(text, m, jp):
    """what a number measures, from the text right after it: % / seconds / other"""
    after = text[m.end():m.end() + 4].lstrip()
    if after.startswith('%'):
        return '%'
    if (jp and after.startswith('秒')) or (not jp and re.match(r'(s\b|sec)', after)):
        return 's'
    return '#'


def fix_nums(jp, en):
    """GL wording with JP numbers, on distinct values: GL often says one number twice ("for 20s" per
    effect) or leaves one out ("Chance of Burn"), so counts differ while the values agree.
    Every GL value JP also has stays. A GL value JP lacks (JP 200% vs GL 150%) is swapped for a JP value
    GL lacks, paired by what it measures (%, seconds), then in order. None when they cannot pair."""
    jt = norm(jp)
    jv = list(dict.fromkeys(m.group() for m in NUM.finditer(jt)))
    ev = list(dict.fromkeys(m.group() for m in NUM.finditer(en)))
    eo = [v for v in ev if v not in jv]
    if not eo:
        return en
    jo = [v for v in jv if v not in ev]
    if not jo:
        return en   # GL spells out a constant JP leaves implicit (快調時 = "when HP is 90% or more")
    if len(eo) > len(jo):
        return None
    jk = {v: kind(jt, next(m for m in NUM.finditer(jt) if m.group() == v), True) for v in jo}
    ek = {v: kind(en, next(m for m in NUM.finditer(en) if m.group() == v), False) for v in eo}
    swap = {}
    for v in eo:                                    # same unit (%, s)
        j = next((j for j in jo if jk[j] == ek[v]), None)
        if j is not None:
            swap[v] = j
            jo.remove(j)
    for v in eo:                                    # what is left, in order
        if v not in swap:
            swap[v] = jo.pop(0)
    return NUM.sub(lambda m: swap.get(m.group(), m.group()), en)


class Memory:
    """JP template -> GL template (+ which JP number fills each GL slot), most common pairing wins"""
    names = subject = None   # regex of GL unit names: a GL line naming its unit ("when Empress is leader") is no template

    def __init__(self):
        self.m = collections.defaultdict(collections.Counter)
        self.best = {}

    def learn(self, a, b):
        ta, na = tmpl(a)
        if not ta or not b or JPCHR.search(b):
            return
        # GL line naming its unit where JP says 自身 (self): "when Empress is ..." is no reusable template
        if Memory.subject and (Memory.subject.search(b) or ('自身' in a and Memory.names.search(b))):
            return
        # English slots must each take a JP token; an extra English number with no JP twin is a constant
        # GL spells out (快調時 = "when HP is 90% or more") and stays literal in the template
        used, perm, out, last = set(), [], [], 0
        for m in EN_TOK.finditer(b):
            k, v = m.lastgroup, m.group(m.lastgroup)
            i = next((i for i, y in enumerate(na) if y == (k, v) and i not in used), None)
            out.append(b[last:m.start()])
            last = m.end()
            if i is None:
                if k != 'n' or 'HP' not in b[max(0, m.start() - 12):m.start()]:
                    return
                out.append(v)
                continue
            used.add(i)
            perm.append(i)
            out.append(SLOT[k])
        if len(used) != len(na):
            return
        self.m[ta][(''.join(out) + b[last:], tuple(perm))] += 1

    def pair(self, jp, en):
        """learn a JP/GL text pair: whole, per sentence, per clause"""
        if not jp or not en:
            return
        self.learn(jp, en)
        js, es = jsplit(jp), esplit(en)
        if len(js) != len(es):
            return
        for a, b in zip(js, es):
            self.piece(norm(a), b.rstrip('.'))

    SUBJ = re.compile(r'^(自身の|味方全体の|敵の|自分以外の味方の|味方全体は|自身は)')
    EFFECT = re.compile(r'(UP|DOWN|回復|上昇|無視|軽減|無効化|吸収)$')

    def piece(self, a, b, depth=0):
        """learn a sentence, then the bare effects inside it, so composed lines can reuse them:
        "N秒間、X" = "X for Ns", "X(重複なし)" = "X (Only once)", "A、B" = "A', B'", "A・B" = "A' & B'" """
        self.learn(a, b)
        if depth > 3:
            return
        m, n = re.match(r'(\d+)秒間、\s*(.+)$', a), re.match(r'(.+?) for (\d+)s\b\s*(.*)$', b)
        if m and n and m.group(1) == n.group(2):
            self.piece(m.group(2), (n.group(1) + ' ' + n.group(3)).strip(), depth + 1)
        m, n = re.match(r'(.+?)\s*\((重複なし|重複あり)\)$', a), re.match(r'(.+?)\s*\(([^)]*)\)$', b)
        if m and n:
            self.piece(m.group(1), n.group(1), depth + 1)
        ca = [c.strip() for c in a.split('、') if c.strip()]
        cb = [c.strip() for c in b.split(', ') if c.strip()]
        if len(ca) == len(cb) > 1:
            for x, y in zip(ca, cb):
                self.piece(x, y, depth + 1)
        ca = [c.strip() for c in a.split('・') if c.strip()]
        cb = [c.strip() for c in b.split(' & ') if c.strip()]
        if len(ca) == len(cb) > 1 and all(self.EFFECT.search(c) for c in ca):
            head = self.SUBJ.match(ca[0])
            for i, (x, y) in enumerate(zip(ca, cb)):
                if i and head and not self.SUBJ.match(x):
                    x = head.group(1) + x
                self.piece(x, y[:1].upper() + y[1:], depth + 1)

    def done(self):
        self.best = {t: c.most_common(1)[0][0] for t, c in self.m.items()}

    def get(self, s):
        t, n = tmpl(s)
        hit = self.best.get(t)
        return fill(hit[0], n, hit[1]) if hit else None


class Translator:
    def __init__(self, mem, gloss):
        self.mem = mem
        # hand lines. A key with # stands for any number; in the English, #N is the key's N-th number
        # (JP and English order differ: "#秒間、...#%UP" -> "... by #2% for #1s"), a bare # the next one.
        self.g = {canon(k): v for k, v in gloss.items() if not k.startswith('_')}
        self.miss = collections.Counter()

    def line(self, s):
        """one JP sentence -> EN or None"""
        s = norm(s)
        hand = self.hand(s)
        if hand:
            return hand
        return self.mem.get(s) or self.compose(s)

    def hand(self, s):
        c = canon(s)
        if c in self.g:
            return self.g[c]
        n = NUM.findall(c)
        v = self.g.get(NUM.sub('#', c))
        if not v or not n:
            return None
        it = iter(n)
        return re.sub(r'#(\d)?', lambda m: n[int(m.group(1)) - 1] if m.group(1) else next(it), v)

    VERB = re.compile(r'^(Increases|Reduces|Recovers|Auto-fills|Auto-recovers|Ignores|Heals|Nullifies|Adds|Grants|'
                      r'Inflicts|Fills|Lifesteals|Doubles|Removes|Extends|Decreases|Restores)\b')
    SUBJ = Memory.SUBJ

    def compose(self, s, depth=0):
        """GL grammar rules over pieces the memory knows: suffix note, "N秒間、X", "A、B", "A・B" """
        if depth > 3:
            return None
        sub = lambda x: self.line(x) if depth == 0 else (self.hand(x) or self.mem.get(x) or self.compose(x, depth + 1))
        m = re.match(r'(.+?)\s*\((重複なし|重複あり)\)$', s)
        if m:
            e = sub(m.group(1))
            return e and e.rstrip('.') + (' (Only once)' if m.group(2) == '重複なし' else ' (Stackable)')
        m = re.match(r'(\d+)秒間、\s*(.+)$', s)
        if m:
            e = sub(m.group(2))
            return e and f"{e.rstrip('.')} for {m.group(1)}s"
        parts = [c.strip() for c in s.split('、') if c.strip()]
        if len(parts) > 1:
            out = [sub(c) for c in parts]
            if all(out):
                return ', '.join(o.rstrip('.') for o in out)
        parts = [c.strip() for c in s.split('・') if c.strip()]
        if len(parts) > 1 and all(Memory.EFFECT.search(c) for c in parts):
            head = self.SUBJ.match(parts[0])
            out = []
            for i, c in enumerate(parts):
                e = sub(c) or (head and not self.SUBJ.match(c) and sub(head.group(1) + c))
                if not e:
                    return None
                e = e.rstrip('.')
                out.append(self.VERB.sub(lambda v: v.group(1).lower(), e) if i else e)
            return ' & '.join(out)
        return None

    def text(self, jp, hint=None, detail=True):
        """JP field -> (EN, source) or (None, 'miss'). hint = GL text of the same skill / unit field."""
        if not jp:
            return None, ''
        if self.hand(jp):
            return self.hand(jp), 'hand'
        if hint and not re.search(r'[ぁ-んァ-ヶ一-龯]', hint):
            fx = fix_nums(jp, hint)
            if fx:
                return fx, 'gl' if fx == hint else 'gl#'
        whole = self.mem.get(jp)
        if whole:
            return whole, 'tm'
        if not detail:
            self.miss[canon(jp)] += 1
            return None, 'miss'
        out, bad = [], False
        for s in jsplit(jp):
            e = self.line(s)
            if not e:
                self.miss[NUM.sub('#', canon(s))] += 1
                bad = True
            else:
                out.append(e.rstrip('.') + '.')
        return (None, 'miss') if bad else (' '.join(out), 'tm')


def main():
    J = load(os.path.join(OTH('Japan'), 'unitsv2_detail.json'))
    G = load(os.path.join(OTH('Global'), 'unitsv2_detail.json'))
    JS = {s['id']: s for s in load(os.path.join(OTH('Japan'), 'skill_master.json'))}
    GSK = {s['id']: s for s in load(os.path.join(OTH('Global'), 'skill_master.json'))}
    gloss = load(GLOSS) if os.path.exists(GLOSS) else {}

    # GL unit names (unit_master: every unit, also those Units V2 skips) + their last word ("Crackshot Merlette", "Merlette"), less words GL skills use
    skill_words = {w for s in GSK.values() for w in re.findall(r'[A-Z][a-z]+', s.get('name') or '')}
    gl_names = set()
    for u in load(os.path.join(OTH('Global'), 'unit_master.json')):
        v = u.get('name') or ''
        if v and not JPCHR.search(v):
            gl_names.add(v)
            last = re.findall(r'[A-Z][\w-]+', v)
            if last and last[-1] not in skill_words:
                gl_names.add(last[-1])
    # also any named subject: "when Empress is ...", "every time Crackshot Merlette uses ..."
    SUBJECT = r'(?:when|time|if|While) (?!HP|DMG|CRI|ATK|DEF|BE|Arts|True|Super|Skill|Equip|Break)[A-Z][A-Za-z-]+(?:,? [A-Za-z-]+){0,4} (?:is|uses|has)\b'
    Memory.subject = re.compile(SUBJECT)
    Memory.names = re.compile(r'\b(?:' + '|'.join(sorted(map(re.escape, gl_names), key=len, reverse=True)) + r')\b')
    mem = Memory()
    for i, s in JS.items():
        g = GSK.get(i)
        if g:
            mem.pair(s.get('name'), g.get('name'))
            mem.pair(s.get('description'), g.get('description'))
    for b, u in J.items():
        g = G.get(b)
        if not g:
            continue
        for k, v in u.items():
            if isinstance(v, str) and (DETAIL.search(k) or NAME_FIELDS.match(k)):
                mem.pair(v, g.get(k))
    mem.done()
    tr = Translator(mem, gloss)
    # voice actors: GL's romaji for the same JP name on any unit both servers have
    va = {u['V.A']: G[b]['V.A'] for b, u in J.items() if b in G and u.get('V.A') and G[b].get('V.A')
          and not JPCHR.search(G[b]['V.A'])}

    stats = collections.Counter()

    def field_hint(ids, field, gl_unit):
        """GL text for this field: the same skill id on GL first, then GL's unit (same base) field"""
        key = field.replace(' Detail', '').replace(' Name-', '-')
        sid = (ids or {}).get(key)
        if sid and isinstance(sid, int) and sid in GSK:
            s = GSK[sid]
            return s.get('description') if DETAIL.search(field) else s.get('name')
        # GL's unit text only when it is the same skill (a JP rework gives the field a new id)
        if gl_unit and (not sid or (gl_unit.get('_ids') or {}).get(key) == sid):
            return gl_unit.get(field)
        return None

    def do(src, gl_unit, top, top_name):
        out = {}
        for k, v in src.items():
            if not isinstance(v, str) or not v or k in ('Unit ID', 'Image', 'SERVER', 'Type', 'Race', 'Rarity'):
                continue
            if not JPCHR.search(v):
                continue
            if DETAIL.search(k) or NAME_FIELDS.match(k):
                hint = field_hint(src.get('_ids'), k, gl_unit)
                official = gl_unit and not JPCHR.search(gl_unit.get('Name') or '')
                if hint and not official and (Memory.subject.search(hint) or Memory.names.search(hint)) and DETAIL.search(k):
                    # GL reuses a skill id across units and names its first owner in the text
                    me = tr.hand(top_name) or tr.text(top_name, None, detail=False)[0]
                    hint = Memory.names.sub(me, hint) if me and not Memory.subject.search(hint) else None
                en, how = tr.text(v, hint, detail=bool(DETAIL.search(k)))
            elif UNIT_NAME.match(k) or LORE.match(k) or k == 'V.A':
                gv = (gl_unit or {}).get(k) or (top or {}).get(k)
                if gv and JPCHR.search(gv):
                    gv = None   # GL DB holds some units early with JP text (not released on GL yet)
                if k == 'V.A' and not gv:
                    gv = va.get(v) or gloss.get('_va', {}).get(v)
                if gv:
                    en, how = gv, 'gl'
                else:
                    en, how = tr.text(v, None, detail=False)
                    if not en and LORE.match(k):
                        en, how = gloss.get('_lore', {}).get(canon(v)), 'hand'
                        how = how if en else 'miss'
            else:
                continue
            stats[how] += 1
            if en:
                out[k] = re.sub(r'\s+', ' ', en).strip()
        return out

    units = {}
    for b, u in J.items():
        g = G.get(b)
        o = do(u, g, None, u.get('Name'))
        forms = {}
        for fk, fv in (u.get('_forms') or {}).items():
            gf = ((g or {}).get('_forms') or {}).get(fk)
            fo = do(fv, gf, g, u.get('Name'))
            if fo:
                forms[fk] = fo
        if forms:
            o['_forms'] = forms
        if o:
            # 'gl' = released on GL (official names), 'tl' = JP-only, English researched here
            o['_src'] = 'gl' if g and not JPCHR.search(g.get('Name') or '') else 'tl'
            units[b] = o

    data = {'built': datetime.now(timezone.utc).isoformat(timespec='seconds'), 'units': units, 'stats': dict(stats)}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print(f"{len(units)} units, {len(mem.best)} templates, {dict(stats)} -> {OUT} ({os.path.getsize(OUT) // 1024} KB)")
    if '--miss' in sys.argv:
        for s, n in tr.miss.most_common():
            print(n, s)


if __name__ == '__main__':
    main()
