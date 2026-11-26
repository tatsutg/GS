"""Unit voice clips for the site's Unit Info Voice tab (WEB-DEV js/voices.js).

Usage: python tools/make_unit_voices.py <base id> [<base id> ...]

For each base unit:
  - cues come from the JP sound_master: sheet <base> (battle lines) and 3<base> (unit menu lines)
  - labels and menu order come from album_voice_master (Global = English names): generic rows match a cue by
    regex and apply to every star level (rarity 0) or one star level; unit rows name a unit's own lines
    (e.g. True Arts names). Star levels = the unit's forms; a label with lines for several (Enhance) gets (N★).
  - one button per matched cue, as in game; a label used by several buttons is numbered (Skill 1, Skill 2 ...)
  - every line of a cue is extracted (the game picks one at random); the site cycles them per press
Clips: JP voice banks (<VOICE_DIR>/<sheet>.acb) -> vgmstream -> AAC mono 48 kHz -> GS-voice repo (next to this one) <base>/<slug>.m4a
Prints the js/voices.js entry for each unit. With --subs: prints the subtitle block (unit_master comment text).
"""
import glob
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOICE_DIR = os.environ.get('GS_VOICE_DIR', r'G:\game data\JP GRAND SUMMONERS\dlc\audio\adx2\voice')
VGM = os.environ.get('VGMSTREAM', r'C:\Users\noora\Downloads\Compressed\vgmstream-win64\vgmstream-cli.exe')
OUT = os.path.join(os.path.dirname(ROOT), 'GS-voice')   # all clips live in the GS-voice repo


def load(region, name):
    path = glob.glob(os.path.join(ROOT, 'dlc', region, '_DATABASE', '*', name + '.json'))[0]
    return json.load(open(path, encoding='utf-8'))


def num(v):
    return int(v) if str(v).lstrip('-').isdigit() else 0


def subsongs(acb):
    """[(index, [cue names lowercase]), ...] for every stream in the bank"""
    meta = subprocess.run([VGM, '-m', acb], capture_output=True, text=True, errors='replace').stdout
    count = int(re.search(r'stream count: (\d+)', meta).group(1))
    out = []
    for i in range(1, count + 1):
        m = subprocess.run([VGM, '-m', '-s', str(i), acb], capture_output=True, text=True, errors='replace').stdout
        name = re.search(r'stream name: (.*)', m)
        out.append((i, [n.strip().lower() for n in (name.group(1) if name else '').split(';')]))
    return out


def extract(acb, index, dest):
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, 'a.wav')
        subprocess.run([VGM, '-s', str(index), '-o', wav, acb], capture_output=True, check=True)
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', wav, '-ac', '1', '-ar', '48000', '-c:a', 'aac', '-b:a', '96k', dest],
                       check=True)


def main(bases):
    sound = load('Japan', 'sound_master')
    # a unit row with no name hides that cue for the unit (e.g. a True Arts unit has no plain "During Arts")
    album = load('Global', 'album_voice_master')
    units = load('Global', 'unit_master')
    # JP-only units (not on Global yet), and unit rows only Japan has: forms / rows come from Japan, labels marked JP:
    # to translate by hand
    gl_ids = {num(u['id']) for u in units}
    units += [u for u in load('Japan', 'unit_master') if num(u['id']) not in gl_ids]
    gl_album = {(num(a['unit_id']), a['cue_name']) for a in album}
    album += [dict(a, album_name=a['album_name'] and 'JP:' + a['album_name']) for a in load('Japan', 'album_voice_master')
              if num(a['unit_id']) and (num(a['unit_id']), a['cue_name']) not in gl_album]
    for base in bases:
        forms = sorted((u for u in units if num(u['base_unit_id']) == base), key=lambda u: num(u['rarity']))
        top = forms[-1]
        stars, sheets = {num(u['rarity']) for u in forms}, [str(top['cue_sheet_name']), str(top['cue_sheet_system_name'])]
        own = {a['cue_name']: a for a in album if num(a['unit_id']) in {num(u['id']) for u in forms}}
        generic = [a for a in album if a['album_name'] and a['cue_name'].startswith('^') and (num(a['rarity']) == 0 or num(a['rarity']) in stars)]
        rows = []   # (priority, cue id order, label, sheet, cue)
        for s in sound:
            if s['cue_sheet_name'] not in sheets:
                continue
            cue = s['cue_name']
            hit = own.get(cue) or next((a for a in sorted(generic, key=lambda a: num(a['priority']))
                                        if re.match(a['cue_name'], cue)), None)
            if hit and not hit['album_name']:
                print(f'  - {cue}: hidden for this unit (unnamed unit row)', file=sys.stderr)
            elif hit:
                label = ' '.join(hit['album_name'].split())
                rows.append((num(hit['priority']), sheets.index(s['cue_sheet_name']), num(s['cue_id']), label, s['cue_sheet_name'], cue,
                             num(hit['rarity'])))
            else:
                print(f'  - {cue}: no menu label (not in the in-game voice menu)', file=sys.stderr)
        rows.sort()
        uses, star_sets = {}, {}
        for r in rows:
            uses[r[3]] = uses.get(r[3], 0) + 1
            star_sets.setdefault(r[3], set()).add(r[6])
        seen, banks, entries = {}, {}, []
        os.makedirs(os.path.join(OUT, str(base)), exist_ok=True)
        for _, _, _, label, sheet, cue, star in rows:
            acb = os.path.join(VOICE_DIR, sheet + '.acb')
            if sheet not in banks:
                banks[sheet] = subsongs(acb)
            lines = [i for i, names in banks[sheet] if cue.lower() in names]
            if not lines:
                print(f'  ! {cue}: no stream in {sheet}.acb', file=sys.stderr)
                continue
            seen[label] = seen.get(label, 0) + 1
            # one line per star level (Enhance 6★ / 7★ on a unit with both forms) -> star tag; else number repeats
            if len(star_sets[label]) > 1 and star:
                name = f'{label} ({star}★)'
            else:
                name = f'{label} {seen[label]}' if uses[label] > 1 else label
            slug = cue.lower().split('_voice_', 1)[1]
            slugs = []
            for k, i in enumerate(lines):
                s = slug if k == 0 else f'{slug}_{k + 1}'
                extract(acb, i, os.path.join(OUT, str(base), s + '.m4a'))
                slugs.append(s)
            entries.append((name, slugs))
        print(f"            {base}: [   // {top['name']}")
        body = []
        for name, slugs in entries:
            arg = f"'{slugs[0]}'" if len(slugs) == 1 else '[' + ', '.join(f"'{s}'" for s in slugs) + ']'
            body.append(f"                L('{name.replace(chr(39), chr(92) + chr(39))}', {arg})")
        print(',\n'.join(body))
        print('            ]')


# subtitle text per clip: unit_master comment fields (Global = English, Japan = Japanese), per form
SUB_FIELDS = {'strength': 'comment_powerup', 'drop': 'comment_gain', 'evolution': 'comment_evolution',
              'limitbreak': 'comment_limitberak', 'luckmax': 'comment_fortune_max'}


def subtitles(bases):
    """window.gsVoices.subs entries: {base: {slug: {jp: [lines], en: [lines]}}} for every clip that has text"""
    langs = {k: {num(u['id']): u for u in load(r, 'unit_master')} for k, r in (('jp', 'Japan'), ('en', 'Global'))}
    out = {}
    for base in bases:
        forms = sorted((u for u in langs['jp'].values() if num(u['base_unit_id']) == base), key=lambda u: num(u['rarity']))
        folder = os.path.join(OUT, str(base))
        for f in sorted(os.listdir(folder)):
            slug = f[:-4]
            m = re.match(r'^(strength|drop|evolution|limitbreak|luckmax)(?:_0?(\d))?$', slug)
            if not m:
                continue
            star = int(m.group(2)) if m.group(2) and m.group(1) in ('strength', 'drop', 'evolution') else None
            form = next((u for u in forms if num(u['rarity']) == star), None) if star else forms[-1]
            if not form:
                continue
            text = {k: [ln.strip() for ln in (langs[k].get(num(form['id']), {}).get(SUB_FIELDS[m.group(1)]) or '').splitlines() if ln.strip()]
                    for k in ('jp', 'en')}
            text['jp_only'] = num(form['id']) not in langs['en']   # en is a site translation until Global has it
            if text['jp'] or text['en']:
                out.setdefault(str(base), {})[slug] = text
    return out


if __name__ == '__main__':
    if sys.argv[1:2] == ['--subs']:   # print the subtitle block for js/voices.js (no extraction)
        print(json.dumps(subtitles([int(a) for a in sys.argv[2:]]), ensure_ascii=False, indent=1))
    else:
        main([int(a) for a in sys.argv[1:]])
