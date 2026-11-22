# Sync non-DB game dlc files from the removable drive into the repo (gs-dlc-merge rules).
# Run from PowerShell (G:/F: not visible to the Bash tool).
#   python tools/sync_dlc.py GL   # or JP, default both
# Match by relative path; skip md5-identical, overwrite changed, copy new.
# Skips db/ (handled by decrypt_db.py) and audio/adx2 raw banks (~1.8GB).
import os, sys, hashlib, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.join(HERE, '..')
REGIONS = {'GL': ('GL GRAND SUMMONERS', 'Global'), 'JP': ('JP GRAND SUMMONERS', 'Japan')}
SKIP_PREFIX = (os.path.join('db', ''), os.path.join('audio', 'adx2', ''))


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


def run(rk):
    folder, region = REGIONS[rk]
    src = find_src(folder)
    if not src:
        print('[%s] dlc not found' % rk); return
    dst_root = os.path.join(REPO, 'dlc', region)
    print('[%s] %s -> %s' % (rk, src, dst_root))
    same = changed = new = 0
    newfiles = []
    for root, _, files in os.walk(src):
        rel_dir = os.path.relpath(root, src)
        rel_dir = '' if rel_dir == '.' else rel_dir
        if any((rel_dir + os.sep).startswith(p) for p in SKIP_PREFIX):
            continue
        for fn in files:
            rel = os.path.join(rel_dir, fn)
            s = os.path.join(root, fn)
            d = os.path.join(dst_root, rel)
            if os.path.exists(d):
                if md5(s) == md5(d):
                    same += 1; continue
                changed += 1
            else:
                new += 1; newfiles.append(rel)
            os.makedirs(os.path.dirname(d), exist_ok=True)
            shutil.copy2(s, d)
    print('[%s] same %d / changed %d / new %d' % (rk, same, changed, new))
    for f in newfiles[:60]:
        print('   + ' + f)
    if len(newfiles) > 60:
        print('   ... +%d more' % (len(newfiles) - 60))


if __name__ == '__main__':
    arg = (sys.argv[1].upper() if len(sys.argv) > 1 else 'BOTH')
    for rk in (['GL', 'JP'] if arg == 'BOTH' else [arg]):
        run(rk)
