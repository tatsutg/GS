"""Voice subtitles, second pass over GS-voice voices.json (after build_all_voices.py):

  1. ro: romaji (Hepburn with macrons, from UniDic's pronunciation) for every JP line that has none
     (every line with --redo-romaji, after the romaji rules change).
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
_tag2 = None


KATA = re.compile(r'^[ァ-ヺー]+$')
_robo = {}   # katakana robot-speech word -> its hiragana reading, filled per line before the tokens are read
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


def shout(text):
    """A drawn-out kana shout (はああああ, ニャアアアア, キュキューーーー) as one word: the tagger cuts it into
    syllables ("Ha aa aa"). ー repeats the vowel before it."""
    import jaconv
    out = ''
    for part in re.split(r'([^ぁ-ゖァ-ヺー])', text):
        if not part or not re.match(r'[ぁ-ゖァ-ヺー]', part):
            out += {'！': '!', '？': '?', '、': ', ', '。': '.', '゛': '', '゙': '', '　': ' '}.get(part, part)
            continue
        h = jaconv.kata2hira(part).translate(str.maketrans('ぁぃぅぇぉ', 'あいうえお'))   # small vowels: drawn out
        for seg in re.split(r'(ー+)', h):
            if seg.startswith('ー'):
                v = re.findall(r'[aiueo]', out)
                out += (v[-1] if v else '') * len(seg)
            elif seg:
                try:
                    out += _cut.map_kana(seg.rstrip('っ'))   # a final っ (くっ) is a cut-off, not a sound
                except KeyError:   # a kana cutlet has no table entry for (ゖ …)
                    pass
    out = re.sub(r'([aiueo])\1{4,}', r'\1\1\1\1', out)   # same cap as the JP line
    return out[:1].upper() + out[1:]


def robot(kata):
    """Katakana that reads as a Japanese sentence (オレニハヒカリガ…) and not a loanword name (ジェイデスジェミニオン):
    as hiragana it parses into real words. Under a third of the pieces may be junk (unknowns, symbols, interjections,
    suffixes, 1-kana nouns): クナッタヨウダ (く + なった…) is a sentence, a name is mostly junk."""
    import jaconv, fugashi
    global _tag2
    if _tag2 is None:
        _tag2 = fugashi.Tagger()   # own tagger: re-running _cut.tagger frees the nodes romaji() is still reading
    ws = [w for w in _tag2(jaconv.kata2hira(kata))]
    bad = sum(w.is_unk or w.feature.pos1 in ('記号', '感動詞', '接尾辞') or (w.feature.pos1 == '名詞' and len(w.surface) == 1) for w in ws)
    return bad * 3 < len(ws)


_kname = None


def kata_name(kata):
    """A katakana skill / place name (ジェイデスジェミニオン, ロギズレイジ), not robot speech (キオクガカイフクシタ):
    it has foreign-only kana (small ァィゥェォ, ヴ) or is part of a skill name in the game data."""
    global _kname
    if re.search(r'[ァィゥェォヴ]', kata):
        return True
    if _kname is None:
        try:
            _kname = {k for v in skill_names().values() for jp, _ in v for k in re.findall(r'[ァ-ヺー]{4,}', jp)}
        except OSError:   # no game DB here
            _kname = set()
    return kata in _kname or any(kata in k for k in _kname)


# words the dictionary reads wrong or not at all (?? in the romaji): their reading, as the series / official name spells it
READ = {'霊丸': 'Rei Gan', '闘舞': 'tōbu', '刀舞': 'tōbu', '爆根': 'bakkon', '天上天下': 'tenjō tenge', '邪王炎殺': 'jaō ensatsu', '炎殺': 'ensatsu', '鮮血更衣': 'senketsu kisaragi', '龍槌閃': 'ryūtsuisen', '龍巻閃': 'ryūkansen', 'ツヴァイ': 'tsuvai', 'フィーア': 'fīa', 'フュンフ': 'fyunfu', '飛天御剣流': 'hiten mitsurugi-ryū', '結跏趺斬': 'kekkafuzan', '捩摺': 'mojizuri', '玉響': 'tamayura', '炎斬剣': 'enzanken', '断砕牙': 'dansaiga', '蒼獅子': 'sōjishi', '水牙斬': 'suigazan', '流爪刃': 'ryūsōjin', '蒼流斬': 'sōryūzan', '炎断剣': 'endanken', '碧命剣': 'hekimeiken', '森精招来': 'shinsei shōrai', '神静剣': 'shinseiken', '氷竜爪': 'hyōryūsō', '彩刃斬': 'saijinzan', '双襲刃': 'sōshūjin', '疾風迅撃': 'shippū jingeki', '鳳翔烈破': 'hōshō reppa', '獣皇掌': 'jūkōshō', '炎突槍': 'entotsusō', '羅生天牙': 'rashō tenga', '襲牙': 'shūga', '牙狼': 'garō', '華厳裂斬肢': 'kegon retsuzanshi', '雪散華': 'sessanka', '場地さん': 'Baji-san', '干将・莫耶': 'Kanshō Bakuya', '風縫い': 'kazenui', '火法師': 'hibōshi', '遠坂凛': 'Tōsaka Rin', '三ツ星極制服': 'mitsuboshi gokuseifuku', '縛の装': 'shibari no sō', '我心開放': 'gashin kaihō', '闘殺法': 'tōsappō', 'ボルザンベル': 'boruzanberu', 'レイルザイデン': 'reiruzaiden', '半世紀': 'hanseiki', 'お何発': 'o-nanpatsu', '鳳蝶紋': 'agehamon', '死槍': 'shisō', '帝剣': 'teiken', '氷連波': 'hyōrenha', '忍法線斬行': 'ninpō senzangyō', '聖魔断業斬': 'seima dangōzan', '乱炎撃': 'ranengeki', '滅炎刹刃衝': 'metsuen setsujinshō'}


def romaji(text):
    """romaji_line() with READ words put in: each goes through as a Latin stand-in (zqa …) that the tagger leaves alone."""
    keys = [k for k in READ if k in text]
    if not keys:
        return romaji_line(text)
    tag = {k: 'zq' + chr(97 + i) for i, k in enumerate(keys)}
    for k in keys:
        text = text.replace(k, tag[k])
    r = romaji_line(text)
    for k in keys:
        r = re.sub(tag[k], lambda m: READ[k][:1].upper() + READ[k][1:] if m.group()[0] == 'Z' else READ[k], r, flags=re.I)
    return r


def romaji_line(text):
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
            if w.is_unk and w.surface in _robo:   # a sentence in katakana (robot speech): read as hiragana
                return _robo[w.surface]
            if w.is_unk and re.match(r'^[ァ-ヺー・]+$', w.surface):   # unknown katakana word(s): ー is a long vowel
                return ' '.join(long_kana((c, c) for c in jaconv.kata2hira(x.rstrip('ッ'))) for x in w.surface.split('・') if x.rstrip('ッ'))
            if w.is_unk or not getattr(f, 'kana', None) or not getattr(f, 'pron', None) or w.surface in _cut.exceptions                     or f.pos1 == '補助記号' or (f.pos1 == '助詞' and f.pron in ('ワ', 'エ', 'オ')):
                return base(w)
            k, p = jaconv.kata2hira(f.kana), jaconv.kata2hira(f.pron)
            if len(k) != len(p) or 'ー' not in p:
                return base(w)
            return long_kana(zip(k, p))
        _cut.romaji_word = word
    if re.fullmatch(r'[ぁ-ゖァ-ヺー゛゙！!？?、。…\s]+', text) and re.search(r'([ぁ-ゖァ-ヺー])\1', text):
        out = ''   # per phrase: a drawn-out shout (はああああ) as one word, real words (ここ, いい) the normal way
        for part in re.split(r'([^ぁ-ゖァ-ヺー]+)', text):
            if not part:
                continue
            if not re.match(r'[ぁ-ゖァ-ヺー]', part):
                out += re.sub(r'\s+', '', part.translate(str.maketrans({'！': '!', '？': '?', '、': ',', '。': '.', '…': '...', '゛': '', '゙': ''}))) + ' '
                continue
            drawn = (re.search(r'([ぁ-ゖァ-ヺ])\1\1|([ぁ-ゖァ-ヺ])\2ー|ーー|[ぁぃぅぇぉァィゥェォ]{2}|[ぁぃぅぇぉァィゥェォ]([あいうえおアイウエオ])\3', part)
                     or (re.search(r'([ぁ-ゖァ-ヺ])\1', part) and not robot(part)))   # ここ / いい / まあ stay words
            drawn = drawn and len(re.sub(r'(.{1,3}?)\1+', r'\1', re.sub(r'[ーぁぃぅぇぉァィゥェォっッ]', '', part))) <= 6   # a shout is short: きれーーにこなごなにするよ is a sentence
            r = shout(part) if drawn else romaji_plain(part)
            out += r if not out else r[:1].lower() + r[1:]
        return re.sub(r' +([!?.,])', r'\1', out).strip()
    return romaji_plain(text)


def romaji_plain(text):
    import cutlet, jaconv
    _robo.clear()
    _merge.clear()   # keyed by id(): stale ids from the last line can match new tokens
    for w in [w.surface for w in _cut.tagger(cutlet.cutlet.normalize_text(text)) if w.is_unk]:
        if re.match(r'^[ァ-ヺ]{5,}$', w) and not kata_name(w):   # long unknown katakana, no ー
            _robo[w] = _cut.romaji(jaconv.kata2hira(w), capitalize=False)
    words = list(_cut.tagger(cutlet.cutlet.normalize_text(text)))   # fresh: tagging again frees earlier nodes
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


BATTLE = os.path.join(HERE, 'voice_subs_battle.json')   # Arts / True Arts / Super Arts lines (tools/voice_asr_arts.py + EN pass)
BATTLE_EN = os.path.join(HERE, 'voice_subs_battle_en.json')   # hand translation map: JP line (after snap) -> English, ["fixed JP", English] or "-" (no line)
# Whisper's stock hallucinations on roars / grunts / silence (YouTube outro text it was trained on)
HALLU = ('ご視聴', 'チャンネル登録', '字幕', 'ビデオ', 'お疲れ様でした', 'ありがとうございました', 'おやすみなさい', '次回', 'エンディング', 'NOTICE', 'subtitle')


def weak(line, lp, ns):
    """True when a transcribed line is likely not real speech: stock phrase, low confidence or no speech."""
    # ns (no-speech prob) is not used: shouted skill names over music score 0.8-1.0 and are real
    return any(h in line for h in HALLU) or (lp is not None and lp < -1.0) or not re.search(r'[぀-ヿ一-鿿A-Za-z]', line)


def jp_names():
    """base -> [(jp, en or '')] like skill_names(), JP-only names included (for spelling the JP line). Each name
    also comes as its parts (壱鬼槍・豪士 -> 壱鬼槍, 豪士): units often shout a name in two clips. A part gets its
    English part when both split the same (First Spear "Master" -> First Spear, Master), else ''."""
    jp = {r['id']: r['name'] for r in rows('Japan', 'skill_master')}
    en = dict((j, e) for b in skill_names().values() for j, e in b)
    cols = ('chargearts_skill_id', 'chargearts_skill_id2', 'full_chargearts_skill_id', 'full_chargearts_skill_id2', 'super_full_chargearts_skill_id')
    out = {}
    for u in rows('Japan', 'unit_master'):
        b = str(int(str(u['id'])[1:5]))
        for c in cols:
            n = (jp.get(u.get(c)) or '').strip()
            e = en.get(core(n), '')
            jp_sp = [m.span() for m in re.finditer(r'[^・：:『』「」\s]+', n)]
            en_sp = [m.span() for m in re.finditer(r'[^:"“”]+', e) if m.group().strip()]
            jp_parts = [n[a:z] for a, z in jp_sp]
            # every run of parts (久遠・闘舞「天上天下」（未完成）-> 久遠・闘舞, 「天上天下」（未完成）…): one clip often says only
            # some of a long name. The JP keeps the game's own marks between the parts (closing 」 / 』 kept with its part)
            cand = [(n, e)]
            if len(jp_parts) > 1:
                for a in range(len(jp_sp)):
                    for z in range(a + 1, len(jp_sp) + 1):
                        if (a, z) == (0, len(jp_sp)):
                            continue
                        lo, hi = jp_sp[a][0], jp_sp[z - 1][1]
                        while lo > 0 and n[lo - 1] in '「『':
                            lo -= 1
                        while hi < len(n) and n[hi] in '」』':
                            hi += 1
                        ep = e[en_sp[a][0]:en_sp[z - 1][1]].strip(' :') if len(en_sp) == len(jp_sp) else ''
                        if ep.count('"') % 2:   # a quote opened (or closed) outside the run
                            ep = ep.replace('"', '')
                        cand.append((n[lo:hi] if z - a > 1 else jp_parts[a], ep))
            for x in cand:
                if len(core(x[0])) >= 2 and all(y[0] != x[0] for y in out.setdefault(b, [])):
                    out[b].append(x)
    return out


def snap_battle(write=False):
    """Transcribed lines that are a skill name said slightly differently by Whisper (kana / kanji, a missing ・)
    take the game's spelling, and the official English name. Other lines keep the transcription; their
    en stays null until the translation pass fills it."""
    from difflib import SequenceMatcher
    d = json.load(open(BATTLE, encoding='utf-8'))
    names, n, dropped = jp_names(), 0, 0
    tr = json.load(open(BATTLE_EN, encoding='utf-8')) if os.path.exists(BATTLE_EN) else {}
    keys = {}

    def key(s):   # compare by sound: Whisper writes a name in other kanji / kana (紫凰 -> 四方, 衝炎牙 -> 昇炎)
        if s not in keys:
            r = romaji(re.sub(r'[・：:『』「」、，,\s]', '', core(s))).lower()
            for a, z in (('ā', 'a'), ('ī', 'i'), ('ū', 'u'), ('ē', 'e'), ('ō', 'o'), ('ou', 'o'), ('uu', 'u')):
                r = r.replace(a, z)
            keys[s] = re.sub(r'[^a-z]', '', r)
        return keys[s]
    for b, m in d.items():
        for s, t in m.items():
            # Whisper runs a long shout on (うおおお… x200, ママ、ママ、… x80)
            jp = [re.sub(r'(.{2,6}?)\1{4,}', r'\1\1\1\1', re.sub(r'(.)\1{4,}', r'\1\1\1\1', x)) for x in t.get('jp') or []]
            lp, ns = t.pop('lp', None) or [None] * len(jp), t.pop('ns', None) or [None] * len(jp)
            keep = [i for i, x in enumerate(jp) if not weak(x, lp[i], ns[i]) and tr.get(x) != '-']   # map '-': gibberish, no line
            dropped += len(jp) - len(keep)
            en = [(t.get('en') or [None] * len(jp))[i] for i in keep]
            jp = [jp[i] for i in keep]
            for i, line in enumerate(jp):
                if jp[i] in tr:   # map value: "English", or ["fixed JP", "English"] where Whisper misheard; no name guess
                    v = tr[jp[i]]
                    jp[i], en[i] = (v[0], v[1]) if isinstance(v, list) else (jp[i], v)
                    continue
                def snap(piece):   # -> (ratio, jp name, en name) of the closest name or run of name parts
                    ln = key(piece)
                    if len(ln) < 3:
                        return (0, '', '')
                    # ties: the longer name (a whole name over its first part)
                    best = max(((SequenceMatcher(None, ln, key(j)).ratio(), len(j), j, e) for j, e in names.get(b, [])), default=(0, 0, '', ''))
                    best = (best[0], best[2], best[3])
                    # a name of several parts: the dictionary misreads invented kanji (紫凰 -> murasaki), so a close first part
                    # plus a fair match of the rest also counts (闇陣剣『怨』 / 『怨呪』 picked by the rest)
                    for j, e in names.get(b, []):
                        parts = [x for x in re.split(r'[・：:『』「」\s]+', j) if x]
                        p0 = key(parts[0])
                        if len(parts) > 1 and len(ln) - len(p0) >= 2 and SequenceMatcher(None, ln[:len(p0)], p0).ratio() >= 0.8:
                            r = SequenceMatcher(None, ln[len(p0):], key(''.join(parts[1:]))).ratio()
                            if r >= 0.6 and 0.8 + r / 10 > best[0]:
                                best = (0.8 + r / 10, j, e)
                    return best if best[0] >= 0.8 else (0, '', '')
                tail = re.search(r'[！!？?。…]+$', line.strip())
                p = tail.group(0) if tail else '!'
                pe = p.replace('！', '!').replace('？', '?').replace('。', '.')
                end = lambda s, q: s if re.search(r'[！!？?。…!?.]$', s) else s + q
                whole = snap(line)
                if whole[0]:
                    jp[i] = end(whole[1], p)
                    if whole[2]:
                        en[i] = end(whole[2], pe)
                    n += 1
                    continue
                # several names in one line (アインシュトラール、アンファングブリッター、…): each piece on its own; the
                # line takes names only when every piece is one
                pieces = [x for x in re.split(r'[、，,]\s*|\s+', core(line)) if x]
                got = [snap(x) for x in pieces] if len(pieces) > 1 else []
                if got and all(g[0] for g in got):
                    jp[i] = end('、'.join(g[1] for g in got), p)
                    if all(g[2] for g in got):
                        en[i] = end(', '.join(g[2].rstrip('!?.') for g in got), pe)
                    n += 1
            for i, x in enumerate(jp):   # a snapped part of a name with no official English part: the map, keyed by the game's spelling
                if not en[i] and isinstance(tr.get(x), str) and tr[x] != '-':
                    en[i] = tr[x]
            t['jp'], t['en'] = jp, en
    if write:   # --snap: look at the result; the merge snaps in memory, so the raw transcription (with lp / ns) stays as it is
        json.dump(d, open(BATTLE, 'w', encoding='utf-8'), ensure_ascii=False, indent=0, sort_keys=True)
    print(f'skill-name lines snapped: {n}, weak lines dropped: {dropped}')
    return d


def merge_battle(subs, battle):
    """Add the Arts / True Arts / Super Arts lines; asr: 1 marks a machine transcription. Lines without English yet show JP / romaji only.
    Earlier asr lines are replaced (the transcription or map changed); hand-written subs stay."""
    n = 0
    for b, m in battle.items():
        for s, t in m.items():
            old = subs.get(b, {}).get(s)
            if old is not None and not old.get('asr'):
                continue
            if not t.get('jp'):
                if old is not None:
                    del subs[b][s]   # line now dropped (weak, or '-' in the map)
                continue
            e = {'jp': t['jp'], 'asr': 1}
            if t.get('en') and any(t['en']):
                e['en'] = [x or '' for x in t['en']]
            subs.setdefault(b, {})[s] = e; n += 1
    return n


def main():
    if sys.argv[1:2] == ['--snap']:
        return snap_battle(write=True)
    redo = '--redo-romaji' in sys.argv   # romaji rules changed: rebuild it for every clip, not only new ones
    args = [a for a in sys.argv[1:] if a != '--redo-romaji']
    gv = args[0] if args else os.path.join(os.path.dirname(GS), 'GS-voice')
    p = os.path.join(gv, 'voices.json')
    d = json.load(open(p, encoding='utf-8'))
    subs = d.get('subs', {})
    battle = snap_battle() if os.path.exists(BATTLE) else {}   # weak lines out, game spelling for names, translation map in
    print(f'battle lines merged: {merge_battle(subs, battle)}')
    report = []
    fixed = fix_names(subs, skill_names(), report)
    ro = 0
    for m in subs.values():
        for t in m.values():
            if t.get('jp') and (redo or not t.get('ro')):
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
