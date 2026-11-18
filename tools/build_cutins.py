"""Grand Summoners: export the battle Arts cut-ins (CocoStudio .csb) for the site's battle simulator.

Reads the game's own cut-in scenes from a JP dlc dump and writes
  dlc/ASSETS/battle/cutin/cutins.json   node trees + timelines (60 fps) + particle emitters
  dlc/ASSETS/battle/cutin/img/*.png     every sprite they use (cut out of their plist sheets)

  arts  Battle.csb  cutin_node + name bar (cutin_bg), animation list "cutin"  (128..214)
  ta    Battle.csb  cutin_node2 + name bar,             animation list "cutin2" (305..381)
  sa    Battle/SuperArts/SuperArtsCutin.csb,            animation list "SuperArtsCutin" (305..389)

The unit's art goes into these nodes (the game adds it in code): arts cutin_layout (battle_cutin_<id>),
ta cutin_layout2 (battle_cutin_512_<id>), sa sa_cutin_unit (battle_cutin_sa_<id>).
The Arts cut-in only keys its name bar; the game moves the rest in code (see js/battlesim.js).

usage: python tools/build_cutins.py [dlc dir]   (default G:/game data/JP GRAND SUMMONERS/dlc, or GS_JP_DLC)
"""
import json
import os
import plistlib
import re
import shutil
import struct
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
DLC = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('GS_JP_DLC', r'G:\game data\JP GRAND SUMMONERS\dlc')
COCO = os.path.join(DLC, 'CocoStudio')
OUT = os.path.join(GS, 'dlc', 'ASSETS', 'battle', 'cutin')
IMG = os.path.join(OUT, 'img')


class Csb:
    """CocoStudio binary (flatbuffers, CSParseBinary schema)"""

    def __init__(self, path):
        self.b = open(path, 'rb').read()

    def u32(self, p): return struct.unpack_from('<I', self.b, p)[0]
    def i32(self, p): return struct.unpack_from('<i', self.b, p)[0]
    def u16(self, p): return struct.unpack_from('<H', self.b, p)[0]
    def f32(self, p): return struct.unpack_from('<f', self.b, p)[0]
    def ref(self, p): return p + self.u32(p)

    def field(self, t, i):
        vt = t - self.i32(t)
        if 4 + 2 * i >= self.u16(vt):
            return None
        o = self.u16(vt + 4 + 2 * i)
        return t + o if o else None

    def string(self, p):
        if p is None:
            return None
        s = self.ref(p)
        return self.b[s + 4:s + 4 + self.u32(s)].decode('utf-8', 'replace')

    def vec(self, p):
        if p is None:
            return []
        v = self.ref(p)
        return [v + 4 + 4 * k for k in range(self.u32(v))]

    def looks_string(self, p):
        try:
            s = self.ref(p); n = self.u32(s)
            return 0 < n < 300 and s + 4 + n <= len(self.b) and all(32 <= ch < 127 for ch in self.b[s + 4:s + 4 + n])
        except Exception:
            return False

    def table(self, p):
        return self.ref(p) if p is not None else None

    def xy(self, p, d):
        return [round(self.f32(p), 3), round(self.f32(p + 4), 3)] if p is not None else d

    def byte(self, p, d):
        return self.b[p] if p is not None else d

    def argb(self, p):
        return list(self.b[p:p + 4]) if p is not None else None   # a, r, g, b

    def resource(self, p):
        """ResourceData { path, plistFile, resourceType }"""
        t = self.table(p)
        if t is None:
            return None
        return {'path': self.string(self.field(t, 0)) or '', 'plist': self.string(self.field(t, 1)) or ''}


# ---------------- nodes ----------------
def widget(c, t):
    """WidgetOptions: 0 name, 1 actionTag, 2 rotationSkew, 3 zOrder, 4 visible, 5 alpha, 6 tag, 7 position, 8 scale,
    9 anchorPoint, 10 color, 11 size, 12 flipX, 13 flipY"""
    g = lambda i: c.field(t, i)
    col = c.argb(g(10))
    return {
        'n': c.string(g(0)), 'tag': c.i32(g(1)) if g(1) else 0, 'r': c.xy(g(2), [0, 0]), 'zo': c.i32(g(3)) if g(3) else 0,
        'v': c.byte(g(4), 1), 'o': c.byte(g(5), 255), 'p': c.xy(g(7), [0, 0]), 's': c.xy(g(8), [1, 1]),
        'a': c.xy(g(9), [0, 0]), 'col': col[1:] if col and col[1:] != [255, 255, 255] else None, 'z': c.xy(g(11), [0, 0]),
        'fx': c.byte(g(12), 0), 'fy': c.byte(g(13), 0),
    }


def node(c, t):
    cls = c.string(c.field(t, 0))
    opt = c.table(c.field(t, 2))
    d = c.table(c.field(opt, 0)) if opt is not None else None
    n = {'c': cls}
    if d is not None:
        f0 = c.field(d, 0)
        # node classes keep their WidgetOptions in field 0 of their own options table; a plain node's options
        # table is the WidgetOptions itself (field 0 is then the name string)
        w = d if f0 is not None and c.looks_string(f0) else c.table(f0)
        n.update(widget(c, w))
        if cls in ('Sprite', 'Particle'):
            n['res'] = c.resource(c.field(d, 1))
            bf = c.field(d, 2)
            if bf is not None:
                n['bl'] = [c.i32(bf), c.i32(bf + 4)]
        elif cls == 'ImageView':
            n['res'] = c.resource(c.field(d, 1))
        elif cls == 'Panel':
            n['res'] = c.resource(c.field(d, 1))
            n['clip'] = c.byte(c.field(d, 2), 0)
            ct = c.byte(c.field(d, 6), 0)
            if ct == 1:
                bg = c.argb(c.field(d, 3))
                n['bg'] = bg[1:] + [c.byte(c.field(d, 7), 255)]
        elif cls == 'Text':
            n['fs'] = c.i32(c.field(d, 3)) if c.field(d, 3) else 20
            n['txt'] = c.string(c.field(d, 4)) or ''
        elif cls == 'ProjectNode':
            n['file'] = c.string(c.field(d, 1))
    kids = [node(c, c.ref(k)) for k in c.vec(c.field(t, 1))]
    if kids:
        n['ch'] = kids
    return n


# ---------------- timelines ----------------
PROPS = {'Position': 'p', 'Scale': 's', 'RotationSkew': 'r', 'AnchorPoint': 'a', 'VisibleForFrame': 'v', 'Alpha': 'o',
         'CColor': 'col', 'FileData': 'res', 'ZOrder': 'zo', 'BlendFunc': 'bl'}


def frames(c, tl):
    out = []
    for fp in c.vec(c.field(tl, 2)):
        ft = c.ref(fp)
        for k in range(9):   # 0 point 1 scale 2 color 3 texture 4 event 5 int 6 bool 7 innerAction 8 blend
            p = c.field(ft, k)
            if p is None:
                continue
            t = c.ref(p)
            idx = c.i32(c.field(t, 0)) if c.field(t, 0) else 0
            tween = c.byte(c.field(t, 1), 1)
            v = c.field(t, 2)
            ease = 0
            ez = c.table(c.field(t, 3))
            if ez is not None:
                ease = c.i32(c.field(ez, 0)) if c.field(ez, 0) else 0
            if k in (0, 1):
                val = c.xy(v, [0, 0])
            elif k == 2:
                val = c.argb(v)[1:] if v is not None else [255, 255, 255]
            elif k == 3:
                val = c.resource(v)
            elif k == 5:
                val = c.i32(v) if v is not None else 0
            elif k == 6:
                val = c.byte(v, 0)
            elif k == 8:
                val = [c.i32(v), c.i32(v + 4)] if v is not None else None
            else:
                val = None
            out.append([idx, val, tween, ease])
            break
    return out


def load(path):
    c = Csb(path)
    root = c.u32(0)
    tree = node(c, c.ref(c.field(root, 3)))
    act = c.table(c.field(root, 4))
    lines = {}
    for tl in c.vec(c.field(act, 2)):
        t = c.ref(tl)
        prop = PROPS.get(c.string(c.field(t, 0)))
        tag = c.i32(c.field(t, 1)) if c.field(t, 1) else 0
        if prop:
            lines.setdefault(tag, {})[prop] = frames(c, t)
    lists = {}
    for al in c.vec(c.field(root, 5)):
        t = c.ref(al)
        lists[c.string(c.field(t, 0))] = [c.i32(c.field(t, 1)) if c.field(t, 1) else 0, c.i32(c.field(t, 2)) if c.field(t, 2) else 0]
    return tree, lines, lists


def attach(n, lines, lo, hi):
    """keyframes for this subtree (frames in [lo, hi] plus the last one before lo, so the start pose is right)"""
    tl = lines.get(n.get('tag'))
    if tl:
        k = {}
        for prop, fr in tl.items():
            fr = sorted(fr, key=lambda f: f[0])
            before = [f for f in fr if f[0] < lo]
            keep = before[-1:] + [f for f in fr if lo <= f[0] <= hi]
            if keep:
                k[prop] = keep
        if k:
            n['k'] = k
    for ch in n.get('ch', []):
        attach(ch, lines, lo, hi)
    n.pop('tag', None)


def find(n, name):
    if n.get('n') == name:
        return n
    for ch in n.get('ch', []):
        f = find(ch, name)
        if f:
            return f
    return None


# ---------------- sprites + particles ----------------
_sheets = {}


def sheet_frames(plist):
    if plist not in _sheets:
        d = plistlib.load(open(plist, 'rb'))
        meta = d.get('metadata', {})
        tex = meta.get('textureFileName') or meta.get('realTextureFileName') or os.path.basename(plist)[:-6] + '.png'
        _sheets[plist] = (d['frames'], os.path.join(os.path.dirname(plist), tex))
    return _sheets[plist]


def cut_frame(plist, name, dst):
    fr, tex = sheet_frames(plist)
    f = fr[name]
    nums = lambda s: [int(float(x)) for x in re.findall(r'-?[\d.]+', s)]
    if 'frame' in f:
        x, y, w, h = nums(f['frame']); rot = f.get('rotated', False)
        ow, oh = nums(f['sourceSize']); ox, oy = nums(f['offset']) if 'offset' in f else (0, 0)
    else:
        x, y, w, h = nums(f['textureRect']); rot = f.get('textureRotated', False)
        ow, oh = nums(f['spriteSourceSize']); ox, oy = nums(f.get('spriteOffset', '{0,0}'))
    sheet = Image.open(tex).convert('RGBA')
    crop = sheet.crop((x, y, x + (h if rot else w), y + (w if rot else h)))
    if rot:
        crop = crop.rotate(90, expand=True)
    full = Image.new('RGBA', (ow, oh))
    full.paste(crop, ((ow - w) // 2 + ox, (oh - h) // 2 - oy))
    full.save(dst)


ALL_PLISTS = None


def image(res):
    """copy / cut one sprite into img/; returns its file name or None"""
    global ALL_PLISTS
    if not res or not res.get('path') or res['path'].startswith('Default/'):
        return None
    name = os.path.basename(res['path'])
    dst = os.path.join(IMG, name)
    if os.path.exists(dst):
        return name
    if res.get('plist'):
        pl = os.path.join(COCO, res['plist'])
        if os.path.exists(pl) and name in sheet_frames(pl)[0]:
            cut_frame(pl, name, dst)
            return name
    direct = os.path.join(COCO, res['path'])
    if os.path.exists(direct):
        shutil.copyfile(direct, dst)
        return name
    if ALL_PLISTS is None:
        ALL_PLISTS = [os.path.join(r, f) for r, _, fs in os.walk(os.path.join(COCO, 'Battle')) for f in fs if f.endswith('.plist')]
    for pl in ALL_PLISTS:
        try:
            if name in sheet_frames(pl)[0]:
                cut_frame(pl, name, dst)
                return name
        except Exception:
            continue
    print('missing sprite', res)
    return None


PKEYS = ['maxParticles', 'duration', 'emitterType', 'angle', 'angleVariance', 'speed', 'speedVariance', 'gravityx', 'gravityy',
         'radialAcceleration', 'radialAccelVariance', 'tangentialAcceleration', 'tangentialAccelVariance', 'particleLifespan',
         'particleLifespanVariance', 'startParticleSize', 'startParticleSizeVariance', 'finishParticleSize',
         'finishParticleSizeVariance', 'rotationStart', 'rotationStartVariance', 'rotationEnd', 'rotationEndVariance',
         'sourcePositionVariancex', 'sourcePositionVariancey', 'blendFuncSource', 'blendFuncDestination',
         'maxRadius', 'maxRadiusVariance', 'minRadius', 'rotatePerSecond', 'rotatePerSecondVariance']
CKEYS = ['startColor', 'startColorVariance', 'finishColor', 'finishColorVariance']


def particle(res, particles):
    if not res or not res.get('path'):
        return None
    key = os.path.basename(res['path'])[:-6]
    if key in particles:
        return key
    pl = os.path.join(COCO, res['path'])
    d = plistlib.load(open(pl, 'rb'))
    p = {k: round(float(d.get(k, 0)), 4) for k in PKEYS}
    for ck in CKEYS:
        p[ck] = [round(float(d.get(ck + ch, 0)), 4) for ch in ('Red', 'Green', 'Blue', 'Alpha')]
    tex = d.get('textureFileName')
    src = os.path.join(os.path.dirname(pl), tex)
    p['tex'] = tex
    shutil.copyfile(src, os.path.join(IMG, tex))
    particles[key] = p
    return key


def resolve(n, particles):
    if n['c'] == 'Particle':
        n['pt'] = particle(n.pop('res', None), particles)
    elif 'res' in n:
        n['img'] = image(n.pop('res'))
    for prop, fr in n.get('k', {}).items():
        if prop == 'res':
            for f in fr:
                f[1] = image(f[1])
    if 'k' in n and 'res' in n['k']:
        n['k']['img'] = n['k'].pop('res')
    for ch in n.get('ch', []):
        resolve(ch, particles)


def main():
    os.makedirs(IMG, exist_ok=True)
    particles = {}
    out = {'fps': 60, 'cutins': {}, 'particles': particles}

    tree, lines, lists = load(os.path.join(COCO, 'Battle', 'Battle.csb'))
    # the name bar is the ImageView cutin_bg directly under "bottom" (other cutin_bg nodes are Sprites)
    bottom = find(tree, 'bottom')
    bar = next(ch for ch in bottom['ch'] if ch.get('n') == 'cutin_bg' and ch['c'] == 'ImageView')
    for key, sub, lst in (('arts', 'cutin_node', 'cutin'), ('ta', 'cutin_node2', 'cutin2')):
        lo, hi = lists[lst]
        root = json.loads(json.dumps({'c': 'Node', 'n': key, 'p': [0, 0], 's': [1, 1], 'r': [0, 0], 'a': [0, 0], 'z': [640, 1136],
                                      'o': 255, 'v': 1, 'ch': [find(tree, sub), bar]}))
        root['ch'][0]['v'] = 1   # the game shows the cut-in node in code
        attach(root, lines, lo, hi)
        resolve(root, particles)
        out['cutins'][key] = {'start': lo, 'end': hi, 'root': root}

    tree, lines, lists = load(os.path.join(COCO, 'Battle', 'SuperArts', 'SuperArtsCutin.csb'))
    lo, hi = lists['SuperArtsCutin']
    attach(tree, lines, lo, hi)
    resolve(tree, particles)
    out['cutins']['sa'] = {'start': lo, 'end': hi, 'root': tree}

    with open(os.path.join(OUT, 'cutins.json'), 'w', encoding='utf-8') as f:
        json.dump(out, f, separators=(',', ':'))
    print('cutins', list(out['cutins']), 'particles', list(particles), 'images', len(os.listdir(IMG)))


if __name__ == '__main__':
    main()
