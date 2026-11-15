"""
Make a stand-in picture for enemies the game ships no unit thumbnail for (neither dlc/Global nor dlc/Japan
unit/thumbnail has unit_thumbnail_<id>.png). Their battle sprite still exists as a Spine skeleton
(dlc/<region>/unit/animation/<id>.json + .atlas + .png), so this draws the skeleton in the first frame of its idle
animation (region and mesh attachments; effects, shadows and hit boxes left out) and writes it as a 128 x 128
transparent PNG:

    dlc/ASSETS/enemy_sprite/enemy_sprite_<unit id>.png

tools/build_quests_detail.py uses these when there is no real thumbnail. Only enemies in enemy_master
(either region) are made. Existing files are kept, so re-running only adds new ones (delete the folder
to redraw them all). Run from the repo root (needs Pillow):
    python tools/make_enemy_sprites.py
"""
import json
import math
import os

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
DLC = os.path.join(os.path.dirname(HERE), 'dlc')
OUT = os.path.join(DLC, 'ASSETS', 'enemy_sprite')
SIZE = 128
REGIONS = ('Global', 'Japan')
SKIP = ('shadow', 'grid', 'grit', 'hitbox', 'damagearea', 'hpbar', 'bg', 'ui', 'ef/')


def listdir(*p):
    d = os.path.join(DLC, *p)
    return set(os.listdir(d)) if os.path.isdir(d) else set()


def read_atlas(path):
    """libGDX / Spine atlas -> {region name: {'page', 'xy', 'size', 'orig', 'offset', 'rotate'}}; a page starts
    with its picture's file name, then its own 'size: / format:' lines (unindented, so they never reach a region)"""
    regions, cur, page = {}, None, None
    with open(path, encoding='utf-8') as f:
        lines = [l.rstrip('\n') for l in f]
    for l in lines:
        if not l.strip():
            cur = None
            continue
        if not l.startswith(' ') and ':' not in l:
            if l.strip().lower().endswith('.png'):
                page, cur = l.strip(), None
            else:
                cur = regions.setdefault(l.strip(), {'page': page})
        elif not l.startswith(' '):
            continue
        elif cur is not None and ':' in l:
            k, v = (x.strip() for x in l.split(':', 1))
            if k == 'rotate':
                cur[k] = v == 'true'
            elif k in ('xy', 'size', 'orig', 'offset'):
                cur[k] = tuple(int(n) for n in v.split(','))
    return {n: r for n, r in regions.items() if 'xy' in r and 'size' in r and r['page']}


class Sheet:
    """an atlas with its page pictures; region(name) -> the region as an upright picture of its full (orig) size"""

    def __init__(self, atlas):
        self.dir, self.reg, self.pages, self.cache = os.path.dirname(atlas), read_atlas(atlas), {}, {}

    def find(self, name):
        if name in self.reg:
            return name
        short = name.split('-', 1)[-1]   # '300-idle_00' -> 'idle_00'
        return short if short in self.reg else None

    def page(self, name):
        if name not in self.pages:
            self.pages[name] = Image.open(os.path.join(self.dir, name)).convert('RGBA')
        return self.pages[name]

    def stored(self, name):
        """the region as stored on its page (rotated regions stay rotated) and its page rectangle"""
        r = self.reg[name]
        (x, y), (w, h) = r['xy'], r['size']
        pw, ph = (h, w) if r.get('rotate') else (w, h)
        return self.page(r['page']), (x, y, pw, ph)

    def region(self, name):
        if name not in self.cache:
            r = self.reg[name]
            page, (x, y, pw, ph) = self.stored(name)
            im = page.crop((x, y, x + pw, y + ph))
            if r.get('rotate'):
                im = im.transpose(Image.Transpose.ROTATE_270)   # stored turned 90° counter-clockwise
            ow, oh = r.get('orig', im.size)
            ox, oy = r.get('offset', (0, 0))
            full = Image.new('RGBA', (ow, oh))
            full.paste(im, (ox, oh - oy - im.height))   # offset counts from the bottom-left
            self.cache[name] = full
        return self.cache[name]


def mul(p, c):
    """2x3 affine p * c (each (a, b, c, d, x, y): world = (a*x + b*y + tx, c*x + d*y + ty))"""
    a, b, cc, d, x, y = p
    a2, b2, c2, d2, x2, y2 = c
    return (a * a2 + b * c2, a * b2 + b * d2, cc * a2 + d * c2, cc * b2 + d * d2, a * x2 + b * y2 + x, cc * x2 + d * y2 + y)


def local(x=0, y=0, rot=0, sx=1, sy=1):
    r = math.radians(rot)
    return (math.cos(r) * sx, -math.sin(r) * sy, math.sin(r) * sx, math.cos(r) * sy, x, y)


def apply(m, x, y):
    return (m[0] * x + m[1] * y + m[4], m[2] * x + m[3] * y + m[5])


def first(keys, t=0):
    """the key at time 0 of a timeline, if any"""
    return next((k for k in keys or [] if k.get('time', 0) <= t), None)


def idle_pose(skel):
    """the first frame of the idle animation: {bone: (dx, dy, d rotation, scale x, scale y)}, {slot: attachment},
    {slot: colour}. Many sprites show their body only through it (the setup pose hides it)."""
    anims = skel.get('animations', {})
    name = next((n for n in ('idle', 'wait', 'idle1') if n in anims), None) or next((n for n in anims if 'idle' in n.lower()), None)
    a = anims.get(name, {}) if name else {}
    bones = {}
    for bn, tl in (a.get('bones') or {}).items():
        r, t, sc = first(tl.get('rotate')), first(tl.get('translate')), first(tl.get('scale'))
        bones[bn] = ((t or {}).get('x', 0), (t or {}).get('y', 0), (r or {}).get('angle', 0), (sc or {}).get('x', 1), (sc or {}).get('y', 1))
    atts, cols = {}, {}
    for sn, tl in (a.get('slots') or {}).items():
        k = first(tl.get('attachment'))
        if k is not None:
            atts[sn] = k.get('name')
        k = first(tl.get('color'))
        if k is not None:
            cols[sn] = k.get('color')
    return bones, atts, cols


def triangles(skel, sheet, skip=SKIP):
    """[(source picture, 3 source points (px), 3 world points)] in draw order, for the idle pose"""
    pose, atts, cols = idle_pose(skel)
    bones, world = {}, {}
    for b in skel['bones']:
        bones[b['name']] = b
        dx, dy, dr, sx, sy = pose.get(b['name'], (0, 0, 0, 1, 1))
        loc = local(b.get('x', 0) + dx, b.get('y', 0) + dy, b.get('rotation', 0) + dr, b.get('scaleX', 1) * sx, b.get('scaleY', 1) * sy)
        world[b['name']] = mul(world[b['parent']], loc) if b.get('parent') else loc
    names = [b['name'] for b in skel['bones']]
    skins = skel.get('skins', {})
    if not isinstance(skins, dict):
        skins = {s.get('name'): s.get('attachments', {}) for s in skins}
    # some sprites keep the body in a named skin ('normal' / 'rage'): use it, with 'default' as the fallback
    named = skins.get('normal') or next((v for k, v in skins.items() if k != 'default'), {})
    skin = {sn: {**skins.get('default', {}).get(sn, {}), **named.get(sn, {})} for sn in set(skins.get('default', {})) | set(named)}
    out = []
    for s in skel.get('slots', []):
        att_name = atts.get(s['name'], s.get('attachment'))
        if not att_name or s.get('blend') in ('additive', 'screen') or str(cols.get(s['name'], s.get('color')) or 'ff')[-2:] == '00':
            continue
        if any(k in (s['name'] + ' ' + s['bone']).lower() for k in skip):
            continue
        att = skin.get(s['name'], {}).get(att_name)
        if not att:
            continue
        kind = att.get('type', 'region')
        reg = sheet.find(att.get('path') or att.get('name') or att_name)
        if not reg or kind in ('boundingbox', 'path', 'point', 'clipping'):
            continue
        bone = world[s['bone']]
        if kind == 'region':
            pic = sheet.region(reg)
            w, h = att.get('width', pic.width), att.get('height', pic.height)
            m = mul(bone, local(att.get('x', 0), att.get('y', 0), att.get('rotation', 0), att.get('scaleX', 1), att.get('scaleY', 1)))
            corners = [apply(m, -w / 2, h / 2), apply(m, w / 2, h / 2), apply(m, w / 2, -h / 2), apply(m, -w / 2, -h / 2)]
            src = [(0, 0), (pic.width, 0), (pic.width, pic.height), (0, pic.height)]
            out += [(pic, [src[0], src[1], src[2]], [corners[0], corners[1], corners[2]]),
                    (pic, [src[0], src[2], src[3]], [corners[0], corners[2], corners[3]])]
            continue
        if kind not in ('mesh', 'weightedmesh', 'skinnedmesh'):
            continue
        uvs, tris, verts = att.get('uvs', []), att.get('triangles', []), att.get('vertices', [])
        n = len(uvs) // 2
        pts = []
        if kind == 'mesh' and len(verts) == 2 * n:
            pts = [apply(bone, verts[2 * i], verts[2 * i + 1]) for i in range(n)]
        else:   # weighted: per vertex [bone count, (bone index, x, y, weight) * count]
            i = 0
            while i < len(verts) and len(pts) < n:
                cnt, i, wx, wy = int(verts[i]), i + 1, 0.0, 0.0
                for _ in range(cnt):
                    bi, x, y, wt = int(verts[i]), verts[i + 1], verts[i + 2], verts[i + 3]
                    px, py = apply(world[names[bi]], x, y)
                    wx, wy, i = wx + px * wt, wy + py * wt, i + 4
                pts.append((wx, wy))
        if len(pts) != n:
            continue
        page, (x, y, pw, ph) = sheet.stored(reg)
        rot = sheet.reg[reg].get('rotate')
        # Spine 3 RegionAttachment / MeshAttachment.updateUVs: a rotated region swaps u and v
        src = [(x + uvs[2 * i + 1] * pw, y + ph - uvs[2 * i] * ph) if rot else (x + uvs[2 * i] * pw, y + uvs[2 * i + 1] * ph) for i in range(n)]
        for t in range(0, len(tris) - 2, 3):
            a, b, c = tris[t], tris[t + 1], tris[t + 2]
            out.append((page, [src[a], src[b], src[c]], [pts[a], pts[b], pts[c]]))
    return out


def solve(dst, src):
    """affine coefficients mapping output pixel (X, Y) -> source pixel, from 3 point pairs"""
    (x1, y1), (x2, y2), (x3, y3) = dst
    det = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)
    if abs(det) < 1e-9:
        return None
    co = []
    for k in (0, 1):
        s1, s2, s3 = src[0][k], src[1][k], src[2][k]
        a = (s1 * (y2 - y3) + s2 * (y3 - y1) + s3 * (y1 - y2)) / det
        b = (s1 * (x3 - x2) + s2 * (x1 - x3) + s3 * (x2 - x1)) / det
        c = (s1 * (x2 * y3 - x3 * y2) + s2 * (x3 * y1 - x1 * y3) + s3 * (x1 * y2 - x2 * y1)) / det
        co += [a, b, c]
    return co


def draw(tris):
    xs = [p[0] for _, _, d in tris for p in d]
    ys = [p[1] for _, _, d in tris for p in d]
    span = max(max(xs) - min(xs), max(ys) - min(ys), 1)
    scale = 512 / span   # draw big, then shrink: keeps edges clean
    w, h = int((max(xs) - min(xs)) * scale) + 4, int((max(ys) - min(ys)) * scale) + 4
    canvas = Image.new('RGBA', (w, h))
    for pic, src, dst in tris:
        d = [((x - min(xs)) * scale + 2, (max(ys) - y) * scale + 2) for x, y in dst]
        x0, y0 = int(min(p[0] for p in d)), int(min(p[1] for p in d))
        x1, y1 = int(math.ceil(max(p[0] for p in d))) + 1, int(math.ceil(max(p[1] for p in d))) + 1
        if x1 - x0 < 1 or y1 - y0 < 1:
            continue
        co = solve([(px - x0, py - y0) for px, py in d], src)
        if not co:
            continue
        patch = pic.transform((x1 - x0, y1 - y0), Image.Transform.AFFINE, co, Image.Resampling.BICUBIC)
        mask = Image.new('L', patch.size)
        ImageDraw.Draw(mask).polygon([(px - x0, py - y0) for px, py in d], fill=255, outline=255)
        patch.putalpha(Image.composite(patch.getchannel('A'), Image.new('L', patch.size), mask))
        canvas.alpha_composite(patch, (x0, y0))
    return canvas


def picture(base):
    with open(base + '.json', encoding='utf-8', errors='replace') as f:   # a few carry stray bytes in names
        skel = json.loads(f.read(), strict=False)
    sheet = Sheet(base + '.atlas')
    # a few sprites name their body parts 'EF/...' (normally effects): when nothing else draws, allow them
    tris = triangles(skel, sheet) or triangles(skel, sheet, tuple(k for k in SKIP if k != 'ef/'))
    if not tris:
        return None
    im = draw(tris)
    box = im.getbbox()
    if not box:
        return None
    im = im.crop(box)
    side = int(max(im.size) / 0.9)
    sq = Image.new('RGBA', (side, side))
    sq.paste(im, ((side - im.width) // 2, side - im.height - (side - max(im.size)) // 2))
    return sq.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def main():
    thumbs = set().union(*(listdir(r, 'unit', 'thumbnail') for r in REGIONS))
    anims = {r: listdir(r, 'unit', 'animation') for r in REGIONS}
    ids = set()
    for r in REGIONS:
        p = os.path.join(DLC, r, '_DATABASE', 'others', 'enemy_master.json')
        if os.path.exists(p):
            with open(p, encoding='utf-8') as f:
                ids |= {e['unit_id'] for e in json.load(f) if e.get('unit_id')}
    os.makedirs(OUT, exist_ok=True)
    made = kept = none = 0
    for u in sorted(ids):
        if f'unit_thumbnail_{u}.png' in thumbs:
            continue
        out = os.path.join(OUT, f'enemy_sprite_{u}.png')
        if os.path.exists(out):
            kept += 1
            continue
        reg = next((r for r in REGIONS if {f'{u}.json', f'{u}.atlas'} <= anims[r]), None)
        try:
            im = reg and picture(os.path.join(DLC, reg, 'unit', 'animation', str(u)))
        except (OSError, ValueError, KeyError, IndexError, TypeError) as e:
            print(f'  {u}: {e}')
            im = None
        if im is None:
            none += 1
            continue
        im.save(out, optimize=True)
        made += 1
    print(f'enemy sprites: {made} made, {kept} kept, {none} without a sprite')


if __name__ == '__main__':
    main()
