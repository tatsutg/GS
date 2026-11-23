"""Boss mechanics, read from the battle messages the game shows for an enemy.

An enemy's script (additional_lua/enemy/<enemy_id>.lua, or additional_lua/unit/<unit_id>.lua for boss units)
shows its rules as messages: self.TEXT.START_MESSAGE3 or "魔法ダメージ無効・光属性キラー".
self.TEXT is the locale table keyed by the same id (additional_lua/lib/summoner/locale/en_us.lua:
[200020903] = { START_MESSAGE3 = "Negates Magic DMG taken & Light killer", ... }).
Immunities are not coded in those scripts, so the message is the only place that states them.

Texts(...).mechanics(ids, own_name) -> [[text, from the start 1 / later 0, rules(, Japanese text)], ...]
  only messages that read as a rule (DMG, killer, resist, negates, UP / DOWN, ...), not the boss's lines.
  from the start: START_* / WAVE* messages; any other message is shown later in the fight (rage, HP triggers).
  rules: what the damage calculator can apply, [kind, value]:
    ['attr', 1|2]        negates physical / magic DMG
    ['el', 1..5]         negates DMG from that element
    ['onlyEl', [els]]    negates all DMG except these elements (0 = no element)
    ['crit', 0]          negates critical (does not say whether crits stop or deal no DMG: NEEDS CONFIRMATION)
    ['nonCrit', 0]       negates all DMG except critical DMG
    ['skill', 0]         negates DMG except Arts DMG (Skills and normal attacks do nothing)
    ['arts', 0]          negates Arts DMG
    ['defPen', 0]        negates DEF penetration (DEF ignore does nothing)
    ['cond', 0]          negates DMG under a condition the calculator cannot check (ailments, a part, ...)
  A message that names another unit ("Mokyuon:Negates Physical DMG") belongs to that unit: it is kept only
  when the name is the enemy's own.
"""
import json
import os
import re

STR = r'"((?:[^"\\]|\\.)*)"'
EL = {'fire': 1, 'water': 2, 'earth': 3, 'light': 4, 'dark': 5}
ELS = r'(fire|water|earth|light|dark)'
MECH_WORDS = re.compile(r'negat|nullif|immun|killer|resist|reflect|damage|critical|gauge|break|invincib|barrier|evasion|ailment|'
                        r'regenerat|accuracy|無効|耐性|キラー|ダメージ|アップ|ダウン|反射|奥義', re.I)
MECH_CAPS = re.compile(r'\b(?:DMG|CRI|UP|DOWN|ATK|DEF|HP)\b')     # the game writes these in capitals; "show up" is a line


# kana / kanji, not the "・" separator the English texts also use
JP = re.compile(r'[぀-ゟ゠-ヺー-ヿ一-鿿]')


def _clean(t):
    return t.replace('\\n', ' ').replace('\\"', '"').strip()


class _Mech:
    @staticmethod
    def search(t):
        return MECH_WORDS.search(t) or MECH_CAPS.search(t)


MECH = _Mech


def _blocks(text):
    """locale file -> {id: {key: text}}"""
    out = {}
    for m in re.finditer(r'^\s*\[(\d+)\]\s*=\s*\{(.*?)^\s*\}', text, flags=re.M | re.S):
        out[int(m.group(1))] = dict(re.findall(r'(\w+)\s*=\s*' + STR, m.group(2)))
    return out


def rules(t):
    """[[kind, value], ...] the calculator can apply for one message (see the module text)"""
    s = t.lower()
    out = []
    if re.search(r'(物理|魔法)ダメージ無効', t):
        out += [['attr', 1 if m == '物理' else 2] for m in re.findall(r'(物理|魔法)ダメージ無効', t)]
    if 'クリティカル' in t and '無効' in t and '以外' not in t:   # "クリティカル以外…無効" = only crits hit
        out.append(['crit', 0])
    if 'negat' not in s:
        return out
    m = re.search(r'negates? (?:all )?dmg except ((?:' + ELS + r'|non-elemental|&|\s)+)', s)
    if m:
        out.append(['onlyEl', sorted({EL.get(w, 0) for w in re.findall(ELS + r'|non-elemental', m.group(1))})])
        return out
    if re.search(r'all dmg \(except cri', s) or re.search(r'all dmg \(except crit', s) or re.search(r'dmg except cri', s):
        out.append(['nonCrit', 0])
        return out
    if re.search(r'dmg \(except arts', s):
        out.append(['skill', 0])
        return out
    if re.search(r'negates? (?:dmg )?except|except (?:while|when|poison|burn|blind)|negates? dmg except', s):
        out.append(['cond', 0])
        return out
    for m in re.finditer(r'negates? (physical|magic)|(physical|magic) (?:damage|dmg) negated', s):
        r = ['attr', 1 if (m.group(1) or m.group(2)) == 'physical' else 2]
        if r not in out:
            out.append(r)
    els = re.findall(r'\b' + ELS + r' (?:dmg|atk|unit|units)\b', s) + re.findall(r'(?:dmg|atk)(?: & break)? (?:from|by) ' + ELS, s)
    for w in els:
        if ['el', EL[w]] not in out:
            out.append(['el', EL[w]])
    if re.search(r'negates? (?:cri|critical)(?: dmg| damage)?\b(?! buff| resist| rate)', s):
        out.append(['crit', 0])
    if re.search(r'negates? arts dmg', s):
        out.append(['arts', 0])
    if re.search(r'negates? def penetration', s):
        out.append(['defPen', 0])
    return out


class Texts:
    def __init__(self, locale_roots, lua_roots):
        """locale_roots / lua_roots: additional_lua folders, first wins (texts, then scripts missing in the first)"""
        self.roots = lua_roots
        self.loc = {}
        for root in locale_roots:
            for name in ('en_us.lua', 'ja_jp.lua'):
                f = os.path.join(root, 'lib', 'summoner', 'locale', name)
                if os.path.exists(f):
                    with open(f, encoding='utf-8', errors='replace') as h:
                        for k, v in _blocks(h.read()).items():
                            self.loc.setdefault(k, v)
        self.ja_loc = {}
        for root in locale_roots:
            f = os.path.join(root, 'lib', 'summoner', 'locale', 'ja_jp.lua')
            if os.path.exists(f):
                with open(f, encoding='utf-8', errors='replace') as h:
                    for k, v in _blocks(h.read()).items():
                        self.ja_loc.setdefault(k, v)
        self.ja2en = self._ja2en(locale_roots)

    def _ja2en(self, locale_roots):
        """{Japanese message: English} from the game's own translations: for every id the English locale has, the
        same key's Japanese text (ja_jp.lua, else the script's fallback) -> the English text. When a boss has no
        English text (its script is newer than the Global locale), the same Japanese line translated for another
        enemy is used; several translations -> the most common one. Lines never translated stay Japanese."""
        en, ja = {}, {}
        for root in locale_roots:
            for name, d in (('en_us.lua', en), ('ja_jp.lua', ja)):
                f = os.path.join(root, 'lib', 'summoner', 'locale', name)
                if os.path.exists(f):
                    with open(f, encoding='utf-8', errors='replace') as h:
                        for k, v in _blocks(h.read()).items():
                            d.setdefault(k, v)
        pairs = {}
        for i, e in en.items():
            src = dict(self._defaults(i))
            src.update(ja.get(i, {}))
            for k, t in e.items():
                j, t = _clean(src.get(k, '')), _clean(t)
                if j and t and JP.search(j) and not JP.search(t):
                    c = pairs.setdefault(j, {})
                    c[t] = c.get(t, 0) + 1
        out = {j: max(c.items(), key=lambda x: (x[1], x[0]))[0] for j, c in pairs.items()}
        # hand translations (Global glossary style) for lines the game never translated + fixes for tied picks
        with open(os.path.join(os.path.dirname(__file__), 'boss_text_ja2en.json'), encoding='utf-8') as h:
            out.update(json.load(h))
        return out

    def _defaults(self, i):
        """the script's own fallback texts: {key: text}"""
        for r in self.roots:
            for sub in ('enemy', 'unit'):
                f = os.path.join(r, sub, f'{i}.lua')
                if os.path.exists(f):
                    with open(f, encoding='utf-8', errors='replace') as h:
                        src = h.read()
                    out = dict(re.findall(r'self\.TEXT\.(\w+)\s+or\s+' + STR, src))
                    # newer scripts: boss:add(C.Start{ C.Say{ key = "START_MESSAGE2", text = "..." }, ... }); a Say
                    # without a key gets one named after its trigger (Start -> START_..., so it counts from the start)
                    for n, line in enumerate(src.splitlines()):
                        trig = re.search(r'C\.(\w+)\{', line)
                        for k, (key, t) in enumerate(re.findall(r'C\.Say\{[^}]*?(?:key\s*=\s*"(\w+)"\s*,\s*)?text\s*=\s*' + STR, line)):
                            out.setdefault(key or f"{(trig.group(1) if trig else 'SAY').upper()}_SAY{n}_{k}", t)
                    return out
        return {}

    def mechanics(self, ids, own=''):
        out, seen = [], set()
        own = (own or '').strip().lower()
        for i in ids:
            if not i:
                continue
            jtexts = dict(self._defaults(i))
            jtexts.update(self.ja_loc.get(i, {}))
            texts = dict(self._defaults(i))
            texts.update(self.loc.get(i, {}))
            for key, t in texts.items():
                ja = _clean(t)
                t = self.ja2en.get(ja, ja)                   # Japanese fallback -> the game's English for that line
                if not t or t in seen or '%' in t.replace('％', '%') and re.search(r'%[sd]', t) or not MECH.search(t):
                    continue
                seen.add(t)
                who = re.match(r'\s*([^:：]{1,40}?)\s*[:：]', t)
                r = rules(t)
                if ja != t:                                  # translated: the Japanese wording's rules count too
                    r += [x for x in rules(ja) if x not in r]
                if who and who.group(1).strip().lower() != own:
                    r = []                                   # another unit's rule
                row = [t, 1 if re.match(r'(START|WAVE)', key) else 0, r]
                jp = _clean(jtexts.get(key, ''))
                if jp != t and JP.search(jp):
                    row.append(jp)                           # the Japanese text, for the site's 日本語 toggle
                out.append(row)
        return out
