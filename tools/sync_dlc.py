# Sync non-DB game dlc files from the removable drive into the repo (gs-dlc-merge rules).
# Run from PowerShell (G:/F: not visible to the Bash tool).
#   python tools/sync_dlc.py GL             # or JP, default both
#   python tools/sync_dlc.py GL 2026-11-01  # new-file cutoff (default: 1st of current month)
# The repo keeps only a CURATED subset: top-level dlc dirs already tracked in git
# (unit/skill/effect/etc are CDN-served and NOT stored). So:
#   - only sync into top dirs git already tracks (per region),
#   - overwrite changed files (updates to tracked assets, any date),
#   - copy NEW files ONLY if mtime >= cutoff (this update); older "new" files are
#     the full-drive mirror gap the repo never wanted -> skip.
# Skips db/ (handled by decrypt_db.py) and audio/adx2 raw banks (~1.8GB).
import os, sys, hashlib, shutil, datetime, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.join(HERE, '..')
REGIONS = {'GL': ('GL GRAND SUMMONERS', 'Global'), 'JP': ('JP GRAND SUMMONERS', 'Japan')}
SKIP_PREFIX = (os.path.join('db', ''), os.path.join('audio', 'adx2', ''))


def tracked_tops(region):
    out = subprocess.run(['git', 'ls-tree', 'HEAD', 'dlc/%s/' % region, '--name-only'],
                         cwd=REPO, capture_output=True, encoding='utf-8').stdout
    return {os.path.basename(l.strip()) for l in out.splitlines() if l.strip()}


def find_src(folder):
    for drv in 'GFEDC':
        p = '%s:\\game data\\%s\\dlc' % (drv, folder)
        if os.path.isdir(p):
            return p
    return None


def md5(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        for b in iter(lambda: f.read(1 << 20), b''):
            h.update(b)
    return h.digest()


def run(rk, cutoff):
    folder, region = REGIONS[rk]
    src = find_src(folder)
    if not src:
        print('[%s] dlc not found' % rk); return
    dst_root = os.path.join(REPO, 'dlc', region)
    tops = tracked_tops(region)
    print('[%s] %s -> %s  (tracked tops: %d, new-file cutoff %s)'
          % (rk, src, dst_root, len(tops), cutoff.date()))
    same = changed = new = skip_gap = skip_untracked = 0
    newfiles = []
    for root, _, files in os.walk(src):
        rel_dir = os.path.relpath(root, src)
        rel_dir = '' if rel_dir == '.' else rel_dir
        if any((rel_dir + os.sep).startswith(p) for p in SKIP_PREFIX):
            continue
        top = rel_dir.split(os.sep)[0] if rel_dir else ''
        for fn in files:
            rel = os.path.join(rel_dir, fn)
            s = os.path.join(root, fn)
            d = os.path.join(dst_root, rel)
            if os.path.exists(d):               # tracked asset: overwrite if changed
                if md5(s) == md5(d):
                    same += 1; continue
                changed += 1
            else:                                # new file: only if curated + this update
                if top not in tops:
                    skip_untracked += 1; continue
                if datetime.datetime.fromtimestamp(os.path.getmtime(s)) < cutoff:
                    skip_gap += 1; continue
                new += 1; newfiles.append(rel)
            os.makedirs(os.path.dirname(d), exist_ok=True)
            shutil.copy2(s, d)
    print('[%s] same %d / changed %d / new %d  (skipped: %d untracked-dir, %d old-gap)'
          % (rk, same, changed, new, skip_untracked, skip_gap))
    for f in newfiles[:60]:
        print('   + ' + f)
    if len(newfiles) > 60:
        print('   ... +%d more' % (len(newfiles) - 60))


if __name__ == '__main__':
    arg = (sys.argv[1].upper() if len(sys.argv) > 1 else 'BOTH')
    now = datetime.datetime.now()
    cutoff = datetime.datetime(now.year, now.month, 1)
    for a in sys.argv[2:]:
        try:
            cutoff = datetime.datetime.strptime(a, '%Y-%m-%d')
        except ValueError:
            pass
    for rk in (['GL', 'JP'] if arg == 'BOTH' else [arg]):
        run(rk, cutoff)
