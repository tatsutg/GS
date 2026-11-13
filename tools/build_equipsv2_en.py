"""
Build dlc/Japan/_DATABASE/others/equipsv2_en.json: an English overlay for the JP Equips V2 data,
the exact counterpart of tools/build_unitsv2_en.py for equips. The Japanese equipsv2_detail.json
stays untouched; this file only holds English strings for the same keys, shown when the JP server
is picked with the "English" text option.

No machine translation. Every English string comes from, in this order (same as the unit builder):
  1. Global's own text for the same thing — same equip (base_item_id) on GL -> GL equipsv2_detail
     name / lore; same skill id in GL -> GL skill name / description. JP and GL share wording but
     not values (JP 200% vs GL 150% after a JP buff), so GL's sentence is kept and its numbers are
     swapped back to JP's (fix_nums, reused from the unit builder).
  2. Translation memory mined from both servers' skill texts (the Memory class, reused).
  3. tools/equipsv2_en_glossary.json, kept by hand, for the rest.
Whatever is still missing stays Japanese.

Output: {"built", "equips": {base: {n, lore, _src}}, "skills": {id: {"0": name, "1": desc}},
         "tagNames": {id: text}, "mats": {id: text}, "stats": {...}}

Manual run from the repo root (JP has no workflow, build by hand):
    python tools/build_equipsv2_en.py           (add --miss to list the lines still untranslated)
The translation engine lives in build_unitsv2_en.py and is imported, not copied.
"""
import collections
import json
import os
import re
import sys
from datetime import datetime, timezone

# Reuse the unit builder's translation engine. Importing it runs only module-level defs (its main()
# is guarded by __main__), so nothing is built and no file is read on import.
from build_unitsv2_en import (Memory, Translator, load, norm, canon, JPCHR, OTH, ELEM, RACE)


def _merge(a, b):
    """two English lines that differ in one middle part -> one line with "A & B" there:
    "Increases own Magic DMG by 20%" + "Increases own ATK by 20%" -> "Increases own Magic DMG & ATK by 20%" """
    wa, wb = a.rstrip('.').split(' '), b.rstrip('.').split(' ')
    p = 0
    while p < min(len(wa), len(wb)) and wa[p] == wb[p]:
        p += 1
    s = 0
    while s < min(len(wa), len(wb)) - p and wa[-1 - s] == wb[-1 - s]:
        s += 1
    ma, mb = wa[p:len(wa) - s], wb[p:len(wb) - s]
    if not ma or not mb or not s:
        return None
    return ' '.join(wa[:p] + ma + ['&'] + mb + wa[len(wa) - s:])


def _low(e):
    """first word lower case after a lead-in ("If Fire unit, increases ..."); names / stat words keep caps"""
    if re.match(r'(?:[A-Z]{2,}|Arts|True|Break|Fire|Water|Earth|Light|Dark|Skill|Equip)\b', e):
        return e
    return e[:1].lower() + e[1:]


def _elems(s):
    """"樹・光" -> "Earth & Light" (None when a part is not an element)"""
    parts = s.split('・')
    return ' & '.join(ELEM[p] for p in parts) if all(p in ELEM for p in parts) else None


def _races(s):
    """"人・竜" / "人族・神族" -> "Human or Dragon" (None when a part is not a race)"""
    parts = [p[:-1] if p.endswith('族') and len(p) > 1 else p for p in s.split('・')]
    return ' or '.join(RACE[p] for p in parts) if all(p in RACE for p in parts) else None


class EqTranslator(Translator):
    """The unit engine plus joins equip skills use a lot (rules only: the unit builder is not changed).
    A rule translates the parts with the normal engine and only rearranges them, the way GL words it:
    a lead-in condition becomes a trailing clause ("... when this attack is CRI", "(First time only)")."""
    TAIL = re.compile(r'^(.*?)(\d+(?:\.\d+)?%?(?:UP|DOWN|軽減|回復|自然上昇))$')
    # lead-in -> (template with {e} = the rest in English, lower-case the rest?)
    LEAD = [
        (r'クリティカル時、\s*(.+)$', '{e} when this attack is CRI', False),
        (r'初回使用時(?:のみ)?、\s*(.+)$', '{e} (First time only)', False),
        (r'(\d+)回目使用以降は、\s*(.+)$', '{e} from the {1}th use onward', False),
        (r'(?:自身|使用者)のHPが(\d+)%以上の時、\s*(.+)$', '{e} when own HP is {1}% or more', False),
        (r'(?:自身|使用者)のHPが(\d+)%未満の時、\s*(.+)$', '{e} when own HP is below {1}%', False),
        (r'ブレイク中の大型ボスがいる時、\s*(.+)$', '{e} while a large boss is in Break', False),
        (r'ブレイク中の敵に対して、\s*(.+)$', '{e} against enemies in Break', False),
        (r'攻撃モード[:：]\s*(.+)$', 'Attack Mode: {e}', False),
        (r'防御モード[:：]\s*(.+)$', 'Defense Mode: {e}', False),
        (r'さらに、?\s*(.+)$', '{e}', False),   # GL drops "additionally" ("さらに樹属性ダメージ28%軽減")
    ]

    def __init__(self, mem, gloss):
        super().__init__(mem, gloss)
        self.units = gloss.get('_units', {})   # JP unit name in "X装備時" -> GL-style English name
        # the Units V2 overlay's names win: an equip must name its unit exactly as the unit's own page does
        try:
            ud = load(os.path.join(OTH('Japan'), 'unitsv2_detail.json'))
            ue = load(os.path.join(OTH('Japan'), 'unitsv2_en.json'))['units']
            names = {norm(v['Name']): ue[k]['Name'] for k, v in ud.items() if ue.get(k, {}).get('Name')}
            self.units = {j: names.get(norm(j), e) for j, e in self.units.items()}
        except (OSError, KeyError, ValueError):
            pass

    def compose(self, s, depth=0):
        e = self.eq(s, depth)
        return e if e else super().compose(s, depth)

    def effects(self, x, sub):
        """A・B・C at top level (not inside brackets) -> A & b & c"""
        parts, buf, lvl = [], '', 0
        for ch in x:
            lvl += ch in '(（[' 
            lvl -= ch in ')）]'
            if ch == '・' and lvl == 0:
                parts.append(buf); buf = ''
            else:
                buf += ch
        parts.append(buf)
        out = []
        for i, c in enumerate(p.strip() for p in parts):
            e = sub(c)
            if not e:
                return None
            e = e.rstrip('.')
            out.append(self.VERB.sub(lambda v: v.group(1).lower(), e) if i else e)
        return ' & '.join(out)

    def eq(self, s, depth):
        if depth > 4:
            return None
        sub = lambda x: self.line(x) if depth == 0 else (self.hand(x) or self.mem.get(x) or self.compose(x, depth + 1))
        # "<unit>装備時、A・B(重複なし)" -> "When equipped by <unit>, A & B (Only once)" (GL's own wording)
        m = re.match(r'(.+?)装備時、\s*(.+?)\s*(?:\((重複なし|重複あり)\))?$', s)
        if m and m.group(1) in self.units:
            e = self.effects(m.group(2), sub)
            if e:
                note = {'重複なし': ' (Only once)', '重複あり': ' (Stackable)'}.get(m.group(3), '')
                return f'When equipped by {self.units[m.group(1)]}, {_low(e)}{note}'
        if s in ('(重複あり)', '重複あり'):
            return '(Stackable)'
        if s in ('(重複なし)', '重複なし'):
            return '(Only once)'
        for rx, tpl, low in self.LEAD:
            m = re.match(rx, s)
            if m:
                e = sub(m.groups()[-1])
                if e:
                    e = e.rstrip('.')
                    return tpl.replace('{e}', _low(e) if low else e).replace('{1}', m.group(1))
                break
        # "使用者が炎属性の場合、X" / "使用者が人・竜族の場合、X" / "敵が樹属性の場合、X"
        m = re.match(r'(使用者|敵)が(.+?)(属性|族)の場合、\s*(.+)$', s)
        if m:
            who = _elems(m.group(2)) if m.group(3) == '属性' else _races(m.group(2))
            e = sub(m.group(4))
            if who and e:
                art = 'an' if who[:1] in 'AEIOU' else 'a'
                head = f'If the user is {art} {who} unit' if m.group(1) == '使用者' else f'If enemy is {who}'
                return f'{head}, {_low(e.rstrip("."))}'
        # "自身のX・Y<n>%UP" (one value for both): each with the shared tail, then merged
        m = self.TAIL.match(s)
        if m and '・' in m.group(1):
            head = Translator.SUBJ.match(m.group(1))
            pre = head.group(1) if head else ''
            parts = m.group(1)[len(pre):].split('・')
            if len(parts) == 2 and all(parts):
                a, b = sub(pre + parts[0] + m.group(2)), sub(pre + parts[1] + m.group(2))
                if a and b:
                    return _merge(a, b)
        return None

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(OTH('Japan'), 'equipsv2_en.json')
GLOSS = os.path.join(HERE, 'equipsv2_en_glossary.json')


def main():
    J = load(os.path.join(OTH('Japan'), 'equipsv2_detail.json'))
    G = load(os.path.join(OTH('Global'), 'equipsv2_detail.json'))
    JSK = {s['id']: s for s in load(os.path.join(OTH('Japan'), 'skill_master.json'))}
    GSK = {s['id']: s for s in load(os.path.join(OTH('Global'), 'skill_master.json'))}
    gloss = load(GLOSS) if os.path.exists(GLOSS) else {}

    GSKILLS = G.get('skills', {})   # shared skill map in the detail file: id -> [name, text, break, fx]
    JSKILLS = J.get('skills', {})
    GEQ = {e['b']: e for e in G['equips']}

    # GL names for the Memory "named subject" filter: equip names + unit names (abilities say
    # "when Engine is equipped"), so a GL line naming its owner is not learned as a reusable template.
    skill_words = {w for s in GSK.values() for w in re.findall(r'[A-Z][a-z]+', s.get('name') or '')}
    gl_names = set()
    for e in G['equips']:
        v = e.get('n') or ''
        if v and not JPCHR.search(v):
            gl_names.add(v)
    for u in load(os.path.join(OTH('Global'), 'unit_master.json')):
        v = u.get('name') or ''
        if v and not JPCHR.search(v):
            gl_names.add(v)
            last = re.findall(r'[A-Z][\w-]+', v)
            if last and last[-1] not in skill_words:
                gl_names.add(last[-1])
    Memory.subject = re.compile(
        r'(?:when|time|if|While) (?!HP|DMG|CRI|ATK|DEF|BE|Arts|True|Super|Skill|Equip|Break)'
        r'[A-Z][A-Za-z-]+(?:,? [A-Za-z-]+){0,4} (?:is|uses|has|equipped)\b')
    Memory.names = re.compile(r'\b(?:' + '|'.join(sorted(map(re.escape, gl_names), key=len, reverse=True)) + r')\b')

    mem = Memory()
    for i, s in JSK.items():
        g = GSK.get(i)
        if g:
            mem.pair(s.get('name'), g.get('name'))
            mem.pair(s.get('description'), g.get('description'))
    for sid, js in JSKILLS.items():
        gs = GSKILLS.get(sid)
        if gs:
            mem.pair(js[0], gs[0])
            mem.pair(js[1], gs[1])
    mem.done()
    tr = EqTranslator(mem, gloss)
    stats = collections.Counter()

    def gl_skill(sid):
        gs = GSKILLS.get(sid)
        if gs:
            return gs[0], gs[1]
        gm = GSK.get(int(sid)) if str(sid).lstrip('-').isdigit() else None
        return (gm.get('name'), gm.get('description')) if gm else (None, None)

    # ---- shared skill map (stages reference it by id) ----
    out_skills = {}
    for sid, js in JSKILLS.items():
        gn, gd = gl_skill(sid)
        o = {}
        if js[0] and JPCHR.search(js[0]):
            en, how = tr.text(js[0], gn, detail=False)
            stats['name:' + how] += 1
            if en:
                o['0'] = re.sub(r'\s+', ' ', en).strip()
        if js[1] and JPCHR.search(js[1]):
            en, how = tr.text(js[1], gd, detail=True)
            stats['desc:' + how] += 1
            if en:
                o['1'] = re.sub(r'\s+', ' ', en).strip()
        if o:
            out_skills[sid] = o

    # ---- tag names + material names (short labels) ----
    def map_names(jmap, gmap):
        out = {}
        for k, jn in (jmap or {}).items():
            gn = (gmap or {}).get(k)
            if gn and not JPCHR.search(gn):
                out[k] = gn
            elif jn and JPCHR.search(jn):
                en, _ = tr.text(jn, gn, detail=False)
                if en:
                    out[k] = re.sub(r'\s+', ' ', en).strip()
        return out
    out_tags = map_names(J.get('tagNames'), G.get('tagNames'))
    out_mats = map_names(J.get('mats'), G.get('mats'))

    # ---- per-equip: name + lore ----
    equips = {}
    for e in J['equips']:
        g = GEQ.get(e['b'])
        o = {}
        gn = (g or {}).get('n')
        if gn and JPCHR.search(gn):
            gn = None
        if e.get('n') and JPCHR.search(e['n']):
            if gn:
                o['n'] = gn
            else:
                en, _ = tr.text(e['n'], None, detail=False)
                if en:
                    o['n'] = en
        gl = (g or {}).get('lore')
        if gl and JPCHR.search(gl):
            gl = None
        if e.get('lore') and JPCHR.search(e['lore']):
            if gl:
                o['lore'] = gl
            else:
                en, _ = tr.text(e['lore'], None, detail=False)
                if not en:
                    en = gloss.get('_lore', {}).get(canon(e['lore']))
                if en:
                    o['lore'] = en
        if o:
            o['_src'] = 'gl' if g and not JPCHR.search(g.get('n') or '') else 'tl'
            equips[str(e['b'])] = o

    # GL writes an equip's 『』 part in double quotes (True "Regracia", Crimson Machina Blade "Asvelt"):
    # researched JP-only names follow it. 'X' -> "X" only as a quote pair; apostrophes (Heaven's) stay.
    dq = lambda t: re.sub(r"(^|\s)'(.+?)'(?=\s|$)", lambda m: f'{m.group(1)}"{m.group(2)}"', t)
    renamed = {}
    for o in equips.values():
        if o.get('_src') == 'tl' and o.get('n') and dq(o['n']) != o['n']:
            renamed[o['n']] = o['n'] = dq(o['n'])
    for sk in out_skills.values():
        if sk.get('0') in renamed:
            sk['0'] = renamed[sk['0']]
    stats['names_dq'] = len(renamed)

    data = {'built': datetime.now(timezone.utc).isoformat(timespec='seconds'),
            'equips': equips, 'skills': out_skills, 'tagNames': out_tags, 'mats': out_mats,
            'stats': dict(stats)}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print(f"{len(equips)} equips, {len(out_skills)} skills, {len(out_tags)} tags, {len(out_mats)} mats "
          f"-> {OUT} ({os.path.getsize(OUT) // 1024} KB)")
    if '--miss' in sys.argv:
        for s, n in tr.miss.most_common(60):
            print(n, s)


if __name__ == '__main__':
    main()
