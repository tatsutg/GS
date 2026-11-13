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
from build_unitsv2_en import (Memory, Translator, load, norm, canon, JPCHR, OTH)

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
    tr = Translator(mem, gloss)
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
