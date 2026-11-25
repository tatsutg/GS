"""Voice subtitles, second pass over GS-voice voices.json (after build_all_voices.py):

  1. ro: romaji (Hepburn with macrons, from UniDic's pronunciation) for every JP line that has none.
  2. Skill names: a line where the unit says one of its own skill names (Skill / Arts / True Arts / Super Arts,
     JP unit_master skill ids -> JP skill_master name) gets that skill's official English name (Global
     skill_master, else the site's JP-only translation in units.json) instead of a free translation.
     Lines that do not say a skill name keep their transcription / translation as they are.

Needs:  pip install cutlet unidic-lite   (any Python; tools run it as  python -I tools/voice_subs_extra.py <GS-voice dir>)
Writes: <GS-voice>/voices.json in place, and <GS-voice>/_skillname_report.txt (lines that say a skill name inside a
        longer sentence: their English is left alone and listed for a manual check).
"""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DB = os.path.join(GS, 'dlc', '{}', '_DATABASE', 'others', '{}.json')


def rows(region, name):
    d = json.load(open(DB.format(region, name), encoding='utf-8'))
    return d if isinstance(d, list) else next(v for v in d.values() if isinstance(v, list))


# ---------------- romaji ----------------
MAC = {'a': 'ā', 'i': 'ī', 'u': 'ū', 'e': 'ē', 'o': 'ō'}
_cut = None


KATA = re.compile(r'^[ァ-ヺー]+$')
_merge = {}   # id(token) -> romaji for a merged katakana run ('' for the run's later tokens)


def long_kana(seg_pairs):
    """[(kana, pron)] hiragana pairs -> romaji, a long vowel (pron ー) as a macron on the vowel before it."""
    out, seg = '', ''
    for kc, pc in seg_pairs:
        if pc == 'ー' and kc in 'うおあえー' and seg:
            r = _cut.map_kana(seg)
            i = max(r.rfind(v) for v in 'aiueo')
            out += r[:i] + MAC[r[i]] + r[i + 1:] if i >= 0 else r
            seg = ''
        else:
            seg += kc
    return out + (_cut.map_kana(seg) if seg else '')


def romaji(text):
    """Hepburn romaji. Long vowels: UniDic's pron writes them as ー (容赦 ヨーシャ -> Yōsha, ルーン -> Rūn);
    えい stays ei (先生 sensei), verbs keep their u (思う omou). A katakana name the dictionary splits
    (ヘリオルド -> heri + orudo) is read as one word (Heriorudo)."""
    global _cut
    import cutlet, jaconv
    if _cut is None:
        _cut = cutlet.Cutlet()
        _cut.use_foreign_spelling = False
        base = _cut.romaji_word

        def word(w):
            if id(w) in _merge:
                return _merge[id(w)]
            f = w.feature
            if w.is_unk and re.match(r'^[ァ-ヺ]{5,}$', w.surface):   # long unknown katakana, no ー: a sentence in
                return _cut.romaji(jaconv.kata2hira(w.surface), capitalize=False)   # katakana (robot speech): read it as hiragana
            if w.is_unk and re.match(r'^[ァ-ヺー・]+$', w.surface):   # unknown katakana word(s): ー is a long vowel
                return ' '.join(long_kana((c, c) for c in jaconv.kata2hira(x)) for x in w.surface.split('・') if x)
            if w.is_unk or not getattr(f, 'kana', None) or not getattr(f, 'pron', None) or w.surface in _cut.exceptions                     or f.pos1 == '補助記号' or (f.pos1 == '助詞' and f.pron in ('ワ', 'エ', 'オ')):
                return base(w)
            k, p = jaconv.kata2hira(f.kana), jaconv.kata2hira(f.pron)
            if len(k) != len(p) or 'ー' not in p:
                return base(w)
            return long_kana(zip(k, p))
        _cut.romaji_word = word
    words = list(_cut.tagger(cutlet.cutlet.normalize_text(text)))
    _merge.clear()
    i = 0
    while i < len(words):   # runs of 2+ katakana nouns / unknowns: one word
        j = i
        while j < len(words) and KATA.match(words[j].surface) and (words[j].is_unk or words[j].feature.pos1 == '名詞'):
            j += 1
        if j - i >= 2:
            kana = jaconv.kata2hira(''.join(w.surface for w in words[i:j]))
            _merge[id(words[i])] = long_kana((c, c) for c in kana)
            for w in words[i + 1:j]:
                _merge[id(w)] = ''
            i = j
        else:
            i += 1
    r = ''.join(str(t) for t in _cut.romaji_tokens(words)).strip()
    r = re.sub(r'([aiueo]) ?-', lambda m: MAC[m.group(1)], r)   # unknown words keep ー as "-" (some as their own token): a long vowel
    r = re.sub(r' +([!?.,…~])', r'\1', r)   # a merged run's empty tokens leave a space before punctuation
    r = re.sub(r'([āīūēōĀĪŪĒŌ]) ?-+', r'\1', r)   # ーーー after a macron
    r = re.sub(r',+', ',', r)                # ふふっ、 -> "Fufu,,"
    return re.sub(r'\s*/\s*', ' ', re.sub(r'  +', ' ', r)).strip()   # 中黒 (・) comes out as "/"


# ---------------- skill names ----------------
PUNCT = '！!？?。、…・「」『』〈〉《》【】―〜~　 ,.'   # not ー: it ends names (ルーンマスター)


def core(s):
    return s.strip().strip(PUNCT)


def skill_names():
    """base -> [(jp, en)] for every unit form of that base (base = unit id digits 2-5)."""
    gl = {r['id']: r['name'] for r in rows('Global', 'skill_master')}
    jp = {r['id']: r['name'] for r in rows('Japan', 'skill_master')}
    site = {}   # JP-only units: the site's translated names (units.json: English column + JP name column for Arts)
    for u in json.load(open(os.path.join(GS, 'units.json'), encoding='utf-8')):
        if u.get('JP Arts') and u.get('Arts'):
            site[u['JP Arts'].strip()] = u['Arts'].split('\n')[0].strip()
    cols = ('chargearts_skill_id', 'chargearts_skill_id2', 'full_chargearts_skill_id', 'full_chargearts_skill_id2', 'super_full_chargearts_skill_id')
    out = {}
    for u in rows('Japan', 'unit_master'):
        base = str(int(str(u['id'])[1:5]))
        for c in cols:
            sid = u.get(c)
            if not isinstance(sid, int) or not sid or sid not in jp:
                continue
            j = core(jp[sid])
            e = (gl.get(sid) or site.get(jp[sid].strip()) or '').strip()
            if re.search(r'[぀-ヿ一-鿿]', e):   # no English name yet (JP text in the site's column)
                continue
            if len(j) >= 2 and e and (j, e) not in out.setdefault(base, []):
                out[base].append((j, e))
    return out


def fix_names(subs, names, report):
    n = 0
    for base, m in subs.items():
        for slug, t in m.items():
            jp, en = t.get('jp') or [], t.get('en') or []
            for i, line in enumerate(jp):
                for j, e in names.get(base, []):
                    if j not in line:
                        continue
                    whole = core(line) == j
                    tail = re.search(r'[！!？?。…]+$', line.strip())
                    p = (tail.group(0) if tail else '').replace('！', '!').replace('？', '?').replace('。', '.')
                    if whole and len(en) == len(jp):          # the line is the name: its English line is the official name
                        want = e if re.search(r'[!?.]$', e) else e + p   # the official name may carry its own "!"
                        if en[i] != want:
                            en[i] = want; n += 1
                    elif e.lower() not in ' '.join(en).lower():
                        report.append(f'{base}\t{slug}\t{line}\t{" | ".join(en)}\t-> {e}')
            if en:
                t['en'] = en
    return n


def main():
    gv = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(GS), 'GS-voice')
    p = os.path.join(gv, 'voices.json')
    d = json.load(open(p, encoding='utf-8'))
    subs = d.get('subs', {})
    report = []
    fixed = fix_names(subs, skill_names(), report)
    ro = 0
    for m in subs.values():
        for t in m.values():
            if t.get('jp') and not t.get('ro'):
                t['ro'] = [romaji(x) for x in t['jp']]; ro += 1
    json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    rp = os.path.join(gv, '_skillname_report.txt')
    if report:
        open(rp, 'w', encoding='utf-8').write('\n'.join(report) + '\n')
    elif os.path.exists(rp):
        os.remove(rp)
    print(f'skill-name lines set: {fixed}, romaji added: {ro}, report rows: {len(report)}')


if __name__ == '__main__':
    main()
