"""Grand Summoners: HP markers (the diamonds on a boss HP bar) read from an enemy Lua script: gameUnit:addNumHpMarker(fraction).
markers(text) -> sorted list of [percent, skip] (skip 1: the cyan 'white' marker, isEnableSkip), or None if the
script adds markers in a form this reader does not follow."""
import re

NUM = r'-?\d+(?:\.\d+)?'


def strip_comments(s):
    s = re.sub(r'--\[(=*)\[.*?\]\1\]', '', s, flags=re.S)
    return re.sub(r'--[^\n]*', '', s)


def block(s, i):
    """s[i] == '{': return index after the matching '}'"""
    d = 0
    for j in range(i, len(s)):
        c = s[j]
        if c == '"' or c == "'":
            k = s.find(c, j + 1)
            while k > 0 and s[k - 1] == '\\':
                k = s.find(c, k + 1)
            j = k
            continue
        if c == '{':
            d += 1
        elif c == '}':
            d -= 1
            if d == 0:
                return j + 1
    return len(s)


def entries(s, name):
    """top-level entries of the first non-empty `name = { ... }` table: list of (key or None, body text)"""
    for m in re.finditer(r'(?:self\.)?' + name + r'\s*=\s*\{', s):
        i = m.end() - 1
        body = s[i + 1:block(s, i) - 1]
        out, j = [], 0
        if '{' not in body:                       # [30] = "getRage": keyed plain values
            out = [(float(k), '') for k in re.findall(r'\[\s*(' + NUM + r')\s*\]\s*=', body)]
        while '{' in body:
            k = body.find('{', j)
            if k < 0:
                break
            head = body[j:k]
            km = re.search(r'\[\s*(' + NUM + r')\s*\]\s*=\s*$', head)
            e = block(body, k)
            out.append((float(km.group(1)) if km else None, body[k + 1:e - 1]))
            j = e
        if out:
            return out
    return []


def field(body, f):
    m = re.search(r'\b' + f + r'\s*=\s*(' + NUM + r')', body)
    return float(m.group(1)) if m else None


def markers(text):
    s = strip_comments(text)
    calls = list(re.finditer(r'addNumHpMarker\(([^\n]*?)\)\s*(?:\n|;|$)', s))
    if not calls:
        return []
    res, ok = set(), True
    for c in calls:
        expr = c.group(1).strip()
        if re.fullmatch(r'[\d.\s*/+\-()]+', expr):
            res.add((round(eval(expr) * 100, 2), 0))
            continue
        m = re.fullmatch(r'(?:(?:self\.)?(\w+)\[\w+\]|(\w+))\.(\w+)\s*\*\s*(' + NUM + r')', expr) or \
            re.fullmatch(r'()()(index)\s*\*\s*(' + NUM + r')', expr)
        if not m:
            ok = False
            continue
        tbl, var, fld, k = m.group(1), m.group(2), m.group(3), float(m.group(4))
        # the loop the call sits in: for index,trigger in pairs(self.X)
        loops = list(re.finditer(r'for\s+(\w+)\s*,\s*(\w+)\s+in\s+pairs\((?:self\.)?(\w+)\)\s*do', s[:c.start()]))
        if not loops:
            ok = False
            continue
        lp = loops[-1]
        tbl = tbl or lp.group(3)
        inner = s[lp.end():c.start()]
        tag = re.search(r'\.tag\s*==\s*"(\w+)"', inner)
        for key, body in entries(s, tbl):
            if tag and not re.search(r'\btag\s*=\s*"' + tag.group(1) + '"', body):
                continue
            v = key if fld == 'index' else field(body, fld)
            if v is None:
                continue
            skip = 1 if re.search(r'isEnableSkip\s*=\s*true', body) and 'changeHpMarkerTexture' in s else 0
            res.add((round(v * k * 100, 2), skip))
    if not ok and not res:
        return None
    return [[int(p) if p == int(p) else p, sk] for p, sk in sorted(res, reverse=True) if 0 < p < 100]


if __name__ == '__main__':
    import glob, os, sys
    d = sys.argv[1]
    none = got = empty = 0
    for f in sorted(glob.glob(os.path.join(d, '*.lua'))):
        m = markers(open(f, encoding='utf-8', errors='replace').read())
        if m is None:
            none += 1
            print('??', os.path.basename(f))
        elif m:
            got += 1
            if len(sys.argv) > 2:
                print(os.path.basename(f), m)
        else:
            empty += 1
    print('markers', got, 'none', empty, 'unread', none)
