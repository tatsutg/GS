"""Voice clips + manifest for EVERY unit on the site (Unit Info Voice tab, WEB-DEV js/voices.js).

Usage: python -I tools/build_all_voices.py [--out DIR] [--only 342,380] [--jobs 8] [--dry]

Per base unit (all bases in unitsv2_detail, Global + Japan):
  sheets   every form's battle sheet (forms can differ: Kyuon / King Kyuon, Coroc / Corogran) + the menu sheet 3<base>
  cues     sound_master cues of those sheets + any stream name in the bank sound_master doesn't list
  lines    every stream of a cue (the game picks one at random); a stream already used by an earlier button is
           dropped, so pooled cues (ATTACK_RANDOM, SKILL_ALL) only keep lines no named button has
  labels   1. the unit's own album_voice_master rows (Global English; Japan-only rows -> "JP:..." to translate)
              an own row with no name hides the cue, as in game
           2. generic album rows (regex) for the unit's star levels, then for any star level
           3. variant cues (_01 / _A / _VER2 / _XP ...): the generic label of the plain cue
           4. FALLBACK table below (stamps, emotion lines, Link / Regalia ...)
           5. else the cue name itself (listed in the report for a hand label)
  order    album priority (in-game menu order), then sheet, then cue id; repeats numbered (Skill 1, Skill 2 ...),
           star-keyed rows tagged (Enhance (5★)), a lower form's own sheet tagged with that form's name
Banks: JP voice folder, Global folder for banks only Global has (Crunchyroll-Hime).
Output: <out>/<base>/<slug>.m4a (AAC mono 48 kHz 96k), <out>/voices.json {units, subs}, <out>/_report.txt
Bases in SKIP_BASES (hand-made entries in js/voices.js) are built only into the report, not the manifest.
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANKS = [os.environ.get('GS_VOICE_DIR', r'G:\game data\JP GRAND SUMMONERS\dlc\audio\adx2\voice'),
         r'G:\game data\GL GRAND SUMMONERS\dlc\audio\adx2\voice']
VGM = os.environ.get('VGMSTREAM', r'C:\Users\noora\Downloads\Compressed\vgmstream-win64\vgmstream-cli.exe')
META_CACHE = os.path.join(tempfile.gettempdir(), 'gs_voice_meta.json')

# cue name typos in the game data -> the spelling the album regexes expect
TYPOS = [('DAMADE', 'DAMAGE'), ('DANAGE', 'DAMAGE'), ('RANODM', 'RANDOM'), ('RANNDOM', 'RANDOM'), ('SKILL_AL$', 'SKILL_ALL'), ('_B0(\d)$', '_B_0\1')]
# variant tails stripped to find the plain cue's label (order: longest first)
VARIANT = re.compile(r'_(VER\d+|XP|RIN|0?\d+|[A-F])$')
# variant tails that mean a different mode, shown as a tag instead of a number
TAGS = [(r'_XP(?:_|$)', 'Ex'), (r'_VER(\d+)$', 'ver. {}'), (r'_RIN$', 'Rin')]
# (regex on the part after _VOICE_, label, priority) for cues no album row names
FALLBACK = [
    (r'ATTACK_RANDOM', 'Attack', 35), (r'ATTACK_ALL', 'Attack', 35), (r'ATTACK_?[D-G]$', 'Attack', 35), (r'ATTACK\d', 'Attack', 35),
    (r'ATTACK$', 'Attack', 35),
    (r'SKILL_ALL', 'Skill', 85), (r'SKILL\d', 'Skill', 85),
    (r'DAMAGE(_RANDOM)?$', 'Damage', 75), (r'DAMAGE\d', 'Damage', 75),
    (r'FULLARTS_CUTIN_HERO', 'Hero cut in', 137),
    # Cross Arts = the game's name for LINKBURST / LINK cues (Cestina 298, 302 unit rows)
    (r'FULLARTS_LINK_CUTIN', 'Cross Arts cut in', 136), (r'FULLARTS_LINK_NOW', 'Cross Arts', 136), (r'LINKBURST', 'Cross Arts', 136),
    # FB = Origin Bullet (Simon the Eradicator 430 unit rows; Awoken Simon 330 has the same cues unnamed)
    (r'FULLARTS_CUTIN_FB', 'Origin Bullet cut in', 101), (r'FULLARTS_NOW_FB', 'During Origin Bullet', 121),
    (r'FULLARTS_FB', 'Name of Origin Bullet', 131),
    # SP: no name in the game data (Divine Form Miyu 848): NEEDS CONFIRMATION
    (r'FULLARTS_CUTIN_SP', 'SP Arts cut in', 102), (r'FULLARTS_SP', 'SP Arts', 132),
    (r'FULLARTS_REGALIA', 'Regalia', 136),
    (r'FULLARTS_RANDOM', 'Name of Arts', 130),
    (r'BATTLESTART', 'Start Battle', 140), (r'BATTLE_[A-F]', 'Battle', 145),
    (r'STRENGTH$', 'Enhance', 210), (r'DROP$', 'Summon', 230), (r'FULLARTS_[A-Z]$', 'Arts', 131),
    (r'STAMP_[A-Z]', 'Stamp', 310),
    (r'TITTLE|TITLE', 'Title Call', 320),
    (r'GACHA', 'Summon', 230),
    (r'SELF', 'Self-introduction', 330),
    (r'LOGIN', 'Title Call', 320), (r'LOADING', 'Loading', 341), (r'TOWN', 'Town', 342), (r'EVENT', 'Event', 343),
    (r'CALL', 'Call', 350), (r'JOY', 'Joy', 351), (r'FUN', 'Fun', 352), (r'LAUGH', 'Laugh', 353), (r'PRAISE', 'Praise', 354),
    (r'SURPRISE', 'Surprise', 355), (r'SHY', 'Shy', 356), (r'TROUBLE', 'Trouble', 357), (r'SAD', 'Sad', 358),
    (r'ANGRY|ANGER', 'Angry', 359), (r'REACT', 'Reaction', 360),
]
# unit rows only Japan names (no Global row for that cue yet): hand translations, Global names where the game has them
HAND_EN = {'真奥義発動中1': 'During True Arts 1', '真奥義発動中2': 'During True Arts 2', '真奥義発動中3': 'During True Arts 3',
           '真奥義1': 'Name of True Arts 1', '真奥義2': 'Name of True Arts 2', '真奥義3': 'Name of True Arts 3',
           'アルビオン・ブレイズカットイン': 'Albion Blaze cut in', 'アルビオン・ブレイズ発動中': 'During Albion Blaze', 'アルビオン・ブレイズ': 'Albion Blaze',
           '夢の終わりカットイン': 'End of the Dream cut in', '夢の終わり発動中': 'During End of the Dream', '夢の終わり': 'End of the Dream',
           '魔血開眼カットイン': 'Demon Blood Awakening cut in', '魔血開眼': 'Demon Blood Awakening'}
# words in raw cue names (minigame / town lines) -> readable
RAW_WORDS = {'Bulivisit': 'Visit', 'Buil': 'Building', 'Buillleavealone': 'Idle'}
SKIP_BASES = set()   # filled from js/voices.js hand entries (main)
RANK = {'own': 0, 'generic': 1, 'generic-any-star': 2, 'hidden': 3, 'variant': 4, 'tagged': 4, 'fallback': 5, 'raw': 6}
JP2EN = {}           # Japanese album name -> Global album name (filled in main from rows both servers have)


def load(region, name):
    return json.load(open(glob.glob(os.path.join(ROOT, 'dlc', region, '_DATABASE', '*', name + '.json'))[0], encoding='utf-8'))


def num(v):
    return int(v) if str(v).lstrip('-').isdigit() else 0


def norm(cue):
    c = cue.strip().upper()
    for a, b in TYPOS:
        c = re.sub(a, b, c)
    return c


def tail(cn):
    """cue without its sheet number: 349_VOICE_FULLARTS_KAIGAN -> VOICE_FULLARTS_KAIGAN (3300_FREE_VOICE_F -> VOICE_FREE_F)"""
    t = re.sub(r'^(SE_)?\d+[A-Z]?_', '', cn)
    return re.sub(r'^FREE_VOICE_', 'VOICE_FREE_', t)


def bank(sheet):
    return next((p for p in (os.path.join(d, sheet + '.acb') for d in BANKS) if os.path.exists(p)), None)


def read_streams(acb):
    """[[index, [normalized stream names]], ...]"""
    meta = subprocess.run([VGM, '-m', acb], capture_output=True, text=True, errors='replace').stdout
    m = re.search(r'stream count: (\d+)', meta)
    out = []
    for i in range(1, (int(m.group(1)) if m else 1) + 1):
        t = subprocess.run([VGM, '-m', '-s', str(i), acb], capture_output=True, text=True, errors='replace').stdout
        name = re.search(r'stream name: (.*)', t)
        out.append([i, [norm(n) for n in (name.group(1) if name else '').split(';') if n.strip()]])
    return out


def extract(job):
    acb, index, dest = job
    if os.path.exists(dest) and os.path.getsize(dest) > 0:
        return
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, 'a.wav')
        subprocess.run([VGM, '-s', str(index), '-o', wav, acb], capture_output=True, check=True)
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', wav, '-ac', '1', '-ar', '48000', '-c:a', 'aac', '-b:a', '96k',
                        '-movflags', '+faststart', dest], check=True)


def hand_bases():
    src = open(os.path.join(ROOT, '..', 'WEB-DEV', 'js', 'voices.js'), encoding='utf-8').read()
    units = src[src.index('units: {'):]
    return {int(b) for b in re.findall(r'^\s+(\d+): \[', units, re.M)}


SUBS_EN = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'voice_subs_en.json'), encoding='utf-8'))
SUB_FIELDS = {'STRENGTH': 'comment_powerup', 'DROP': 'comment_gain', 'EVOLUTION': 'comment_evolution',
              'LIMITBREAK': 'comment_limitberak', 'LUCKMAX': 'comment_fortune_max'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=os.path.join(ROOT, '..', 'GS-voice'))
    ap.add_argument('--only', default='')
    ap.add_argument('--jobs', type=int, default=8)
    ap.add_argument('--dry', action='store_true', help='labels + report only, no audio')
    a = ap.parse_args()
    out = os.path.abspath(a.out)
    os.makedirs(out, exist_ok=True)
    SKIP_BASES.update(hand_bases())

    sound = load('Japan', 'sound_master')
    by_sheet = {}
    for s in sound:
        by_sheet.setdefault(s['cue_sheet_name'], []).append(s)
    gl_units = {num(u['id']): u for u in load('Global', 'unit_master')}
    jp_units = {num(u['id']): u for u in load('Japan', 'unit_master')}
    album = load('Global', 'album_voice_master')
    gl_keys = {(num(r['unit_id']), r['cue_name']) for r in album}
    album += [dict(r, album_name=r['album_name'] and 'JP:' + r['album_name']) for r in load('Japan', 'album_voice_master')
              if num(r['unit_id']) and (num(r['unit_id']), r['cue_name']) not in gl_keys]
    gl_by = {(num(r['unit_id']), r['cue_name']): r['album_name'] for r in album if r['album_name'] and not r['album_name'].startswith('JP:')}
    pairs = Counter((' '.join(r['album_name'].split()), ' '.join(gl_by[(num(r['unit_id']), r['cue_name'])].split()))
                    for r in load('Japan', 'album_voice_master') if r['album_name'] and (num(r['unit_id']), r['cue_name']) in gl_by)
    for (j, e), _ in pairs.most_common():
        JP2EN.setdefault(j, e)
    generic = sorted((r for r in album if r['album_name'] and r['cue_name'].startswith('^')), key=lambda r: num(r['priority']))
    own_rows = {}
    for r in album:
        if num(r['unit_id']):
            own_rows.setdefault(num(r['unit_id']), {})[tail(norm(r['cue_name']))] = r

    site = set()
    for reg in ('Global', 'Japan'):
        site |= {int(k) for k in json.load(open(os.path.join(ROOT, 'dlc', reg, '_DATABASE', 'others', 'unitsv2_detail.json'), encoding='utf-8'))}
    if a.only:
        site &= {int(x) for x in a.only.split(',')}

    forms_of = {}
    for uid, u in list(jp_units.items()) + [(k, v) for k, v in gl_units.items() if k not in jp_units]:
        forms_of.setdefault(num(u['base_unit_id']), []).append(gl_units.get(uid, u))

    # stream lists per bank, cached between runs
    cache = json.load(open(META_CACHE, encoding='utf-8')) if os.path.exists(META_CACHE) else {}
    need = set()
    for base in site:
        for u in forms_of.get(base, []):
            for sh in (str(u['cue_sheet_name']), str(u['cue_sheet_system_name']), str(2000 + base)):
                p = bank(sh)
                if p and p not in cache:
                    need.add(p)
    if need:
        print(f'reading {len(need)} banks ...', file=sys.stderr)
        with ThreadPoolExecutor(a.jobs) as ex:
            for p, st in zip(need, ex.map(read_streams, need)):
                cache[p] = st
        json.dump(cache, open(META_CACHE, 'w', encoding='utf-8'))

    def gen_hit(cn, stars, any_star=False):
        key = re.sub(r'^\d+[A-Z]?_', '0_', cn)
        for r in generic:
            if (any_star or num(r['rarity']) == 0 or num(r['rarity']) in stars) and re.match(r['cue_name'], key):
                return r
        return None

    manifest, subs, report, jobs = {}, {}, [], []
    for base in sorted(site):
        forms = sorted(forms_of.get(base, []), key=lambda u: num(u['rarity']))
        if not forms:
            continue
        top, stars, ids = forms[-1], {num(u['rarity']) for u in forms}, {num(u['id']) for u in forms}
        own = {}
        for i in ids:
            own.update(own_rows.get(i, {}))
        sheets, form_tag = [], {}
        for u in [top] + forms[::-1]:
            sh = str(u['cue_sheet_name'])
            if sh != 'None' and sh not in sheets:
                sheets.append(sh)
                if sh != str(top['cue_sheet_name']):
                    form_tag[sh] = u
        sys_sheet = str(top['cue_sheet_system_name'])
        if sys_sheet != 'None' and sys_sheet not in sheets:
            sheets.append(sys_sheet)
        # 2<base>: the character's minigame / town lines (Clair 394 -> 2394 is the one unit_master names; Azel 2391,
        # Yuna 2393, 111-117 town buildings follow the same rule). 3-digit bases only, so it can't hit another unit's sheet
        if 100 <= base <= 999 and str(2000 + base) not in sheets and bank(str(2000 + base)):
            sheets.append(str(2000 + base))
        rows, notes = [], []
        for si, sh in enumerate(sheets):
            p = bank(sh)
            if not p:
                if by_sheet.get(sh):
                    notes.append(f'no bank for sheet {sh} ({len(by_sheet[sh])} cues)')
                continue
            streams = cache[p]
            cues = [(num(s['cue_id']), s['cue_name']) for s in by_sheet.get(sh, [])]
            listed = {norm(c) for _, c in cues}
            extra = sorted({n for _, ns in streams for n in ns} - listed)
            cues += [(10 ** 6 + k, n) for k, n in enumerate(extra)]
            if extra:
                notes.append(f'{sh}: {len(extra)} bank cue(s) not in sound_master: {", ".join(extra)}')
            for cid, cue in cues:
                cn = norm(cue)
                lines = [i for i, ns in streams if cn in ns]
                if not lines:
                    notes.append(f'{cue.strip()}: no audio in {sh}.acb')
                    continue
                hit, how = own.get(tail(cn)), 'own'
                if hit is not None and not hit['album_name']:
                    # the game hides it from its menu, but the line is real audio: keep it, labelled like the plain cue
                    notes.append(f'{cue.strip()}: hidden in the game menu (blank unit row), kept')
                    hit, how = None, 'hidden'
                star = 0
                if hit is None:
                    hit = gen_hit(cn, stars)
                    how = how if how == 'hidden' else 'generic'
                if hit is None:
                    hit = gen_hit(cn, stars, True)
                    how = how if how == 'hidden' else 'generic-any-star'
                if hit is None:
                    plain = cn
                    while hit is None and VARIANT.search(plain):
                        plain = VARIANT.sub('', plain)
                        hit = gen_hit(plain, stars) or gen_hit(plain, stars, True)
                    how = 'variant' if how != 'hidden' else how
                if hit is not None:
                    label, prio, star = ' '.join(hit['album_name'].split()), num(hit['priority']) + (0.5 if how == 'variant' else 0), num(hit['rarity'])
                else:
                    suffix = cn.split('_VOICE_', 1)[-1]
                    fb = next(((l, pr) for rx, l, pr in FALLBACK if re.match(rx, suffix)), None)
                    if fb:
                        label, prio, how = fb[0], fb[1], 'fallback'
                    else:
                        label, prio, how = ' '.join(RAW_WORDS.get(w, w) for w in suffix.replace('_', ' ').title().split()), 900, 'raw'
                if label.startswith('JP:'):
                    label = JP2EN.get(label[3:]) or HAND_EN.get(label[3:], label)
                tags = ''   # shown after the number: Free Voice 1 (Ex), Attack 1 (Rekyuon)
                for rx, tag in TAGS:
                    tm = re.search(rx, cn)
                    if tm and tag.split()[0] not in label:
                        tags += ' (' + tag.format(*tm.groups()) + ')'
                        if how == 'variant':
                            how = 'tagged'
                        break
                if sh in form_tag:
                    tags += f" ({form_tag[sh]['name']})"
                # only the generic star-keyed rows (Enhance, Summon, Evolve ...) tell lines apart by star
                rows.append(dict(rank=RANK.get(how, 9), prio=prio, si=si, cid=cid, label=label + tags, base=label, tags=tags, sheet=sh,
                                 cue=cue.strip(), cn=cn, lines=lines, star=star if how in ('generic', 'generic-any-star', 'hidden') else 0,
                                 how=how, acb=p))
        # named lines claim their audio first; pooled / fallback cues only keep lines nobody else has
        rows.sort(key=lambda r: (r['rank'], r['prio'], r['si'], r['cid']))
        used, kept = {}, []
        for r in rows:
            fresh = [i for i in r['lines'] if i not in used.setdefault(r['acb'], set())]
            if not fresh:
                notes.append(f"{r['cue']}: same audio as an earlier button, skipped")
                continue
            used[r['acb']].update(fresh)
            r['lines'] = fresh
            kept.append(r)
        kept.sort(key=lambda r: (r['prio'], r['si'], r['cid']))
        uses, star_sets = {}, {}
        for r in kept:
            star_sets.setdefault(r['label'], set()).add(r['star'])
        for r in kept:   # star-tagged rows are told apart by their star; the rest are numbered among themselves
            if not (len(star_sets[r['label']]) > 1 and r['star']):
                uses[r['label']] = uses.get(r['label'], 0) + 1
        seen, entries, slugs_used = {}, [], set()
        os.makedirs(os.path.join(out, str(base)), exist_ok=True) if not a.dry and base not in SKIP_BASES else None
        for r in kept:
            label, plain = r['label'], r['base']
            if len(star_sets[label]) > 1 and r['star']:
                name = f"{plain} ({r['star']}★){r['tags']}"
            else:
                seen[label] = seen.get(label, 0) + 1
                # a label that already ends in a number (Damage 3, Cross Arts 1) gets #n
                if uses.get(label, 0) > 1:
                    name = (f'{plain} #{seen[label]}' if plain[-1].isdigit() else f'{plain} {seen[label]}') + r['tags']
                else:
                    name = label
            slug = re.sub(r'[^a-z0-9_]+', '_', r['cn'].lower().split('_voice_', 1)[-1]).strip('_')
            if r['sheet'] in form_tag:
                slug = f"f{num(form_tag[r['sheet']]['rarity'])}_{slug}"
            while slug in slugs_used:
                slug += 'x'
            line_slugs = []
            for k, i in enumerate(r['lines']):
                s = slug if k == 0 else f'{slug}_{k + 1}'
                slugs_used.add(s)
                line_slugs.append(s)
                if not a.dry and base not in SKIP_BASES:
                    jobs.append((r['acb'], i, os.path.join(out, str(base), s + '.m4a')))
            r['slugs'] = line_slugs
            entries.append([name, line_slugs[0] if len(line_slugs) == 1 else line_slugs])
            # subtitles: unit_master comment text of the form the clip belongs to
            m = re.match(r'(STRENGTH|DROP|EVOLUTION|LIMITBREAK|LUCKMAX)(?:_0?(\d))?$', r['cn'].split('_VOICE_', 1)[-1])
            if m:
                st = int(m.group(2)) if m.group(2) and m.group(1) in ('STRENGTH', 'DROP', 'EVOLUTION') else None
                form = next((u for u in forms if num(u['rarity']) == st), None) if st else top
                if form:
                    fid = num(form['id'])
                    t = {k: [ln.strip() for ln in ((src.get(fid) or {}).get(SUB_FIELDS[m.group(1)]) or '').splitlines() if ln.strip()]
                         for k, src in (('jp', jp_units), ('en', gl_units))}
                    if fid not in gl_units:
                        t['tl'] = 1
                        t['en'] = SUBS_EN.get('\n'.join(t['jp']), [])   # site translation, tools/voice_subs_en.json
                    if t['jp'] or t['en']:
                        for s in line_slugs:
                            subs.setdefault(str(base), {})[s] = t
        report.append(f"\n== {base} {top['name']}  forms {sorted(stars)}  sheets {sheets}  buttons {len(entries)}  clips {sum(len(r['slugs']) for r in kept)}"
                      + ('  [hand-made entry kept]' if base in SKIP_BASES else ''))
        for r, (name, _) in zip(kept, entries):
            report.append(f"   {name:34} {r['how']:16} {r['cue']}  x{len(r['slugs'])}")
        report += ['   ! ' + n for n in notes]
        if base not in SKIP_BASES and entries:
            manifest[str(base)] = entries
    for b in SKIP_BASES:
        subs.pop(str(b), None)

    print(f'{len(manifest)} units, {len(jobs)} clips to write', file=sys.stderr)
    if jobs:
        done = 0
        with ThreadPoolExecutor(a.jobs) as ex:
            for _ in ex.map(extract, jobs):
                done += 1
                if done % 500 == 0:
                    print(f'  {done}/{len(jobs)}', file=sys.stderr)
    if not a.only:
        json.dump({'units': manifest, 'subs': subs}, open(os.path.join(out, 'voices.json'), 'w', encoding='utf-8'),
                  ensure_ascii=False, separators=(',', ':'))
    open(os.path.join(out, '_report.txt' if not a.only else '_report_only.txt'), 'w', encoding='utf-8').write('\n'.join(report))


if __name__ == '__main__':
    main()
