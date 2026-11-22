# Decrypt GS SQLCipher3 master DBs and export each table to _DATABASE/<db>/<table>.{json,csv}.
# Run from PowerShell (the G:/F: removable drive is not visible to the Bash tool).
#   python tools/decrypt_db.py GL    # or: JP   (default: both)
# Key = nX2cr6uw+basename, PBKDF2-HMAC-SHA1 64000 -> AES-256-CBC per 1024B page, reserve=48.
# Overwrites only changed/new table files and reports same/changed/new counts + new rows in key tables.
import os, sys, csv, json, sqlite3, hashlib, tempfile, glob
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.join(HERE, '..')
PAGE, RESERVE, KDF_ITER = 1024, 48, 64000
REGIONS = {'GL': ('GL GRAND SUMMONERS', 'Global'), 'JP': ('JP GRAND SUMMONERS', 'Japan')}
# tables where we report the new row ids (the "new content" check)
KEY_TABLES = ('unit_master', 'item_equipment_master', 'summon_master', 'quest_master',
              'gacha_master', 'skill_master', 'arts_master')


def find_db_dir(folder):
    for drv in 'GFEDC':
        p = '%s:\\game data\\%s\\dlc\\db' % (drv, folder)
        if os.path.isdir(p):
            return p
    return None


def decrypt(path):
    raw = open(path, 'rb').read()
    salt = raw[:16]
    passphrase = ('nX2cr6uw' + os.path.basename(path)[len('encrypted_'):-len('.db')]).encode()
    key = hashlib.pbkdf2_hmac('sha1', passphrase, salt, KDF_ITER, 32)
    out = bytearray()
    for pi in range(len(raw) // PAGE):
        page = raw[pi * PAGE:(pi + 1) * PAGE]
        iv = page[PAGE - RESERVE:PAGE - RESERVE + 16]
        start = 16 if pi == 0 else 0
        body = page[start:PAGE - RESERVE]
        dec = Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
        pt = dec.update(body) + dec.finalize()
        if pi == 0:
            out += b'SQLite format 3\x00'
        out += pt + page[PAGE - RESERVE:PAGE]
    return bytes(out)


def export_table(con, table, db_out):
    cur = con.execute('SELECT * FROM "%s"' % table)
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    dicts = [dict(zip(cols, r)) for r in rows]
    jpath = os.path.join(db_out, table + '.json')
    cpath = os.path.join(db_out, table + '.csv')
    jnew = json.dumps(dicts, ensure_ascii=False).encode('utf-8')
    import io
    sio = io.StringIO()
    w = csv.writer(sio)
    w.writerow(cols)
    w.writerows(rows)
    cnew = sio.getvalue().encode('utf-8')
    status = 'new'
    if os.path.exists(jpath):
        status = 'same' if open(jpath, 'rb').read() == jnew else 'changed'
    if status != 'same':
        open(jpath, 'wb').write(jnew)
        open(cpath, 'wb').write(cnew)
    return status, dicts


def run_region(rk):
    folder, region = REGIONS[rk]
    src = find_db_dir(folder)
    if not src:
        print('[%s] db dir not found on any drive' % rk); return
    out_root = os.path.join(REPO, 'dlc', region, '_DATABASE')
    print('[%s] %s -> %s' % (rk, src, out_root))
    counts = {'same': 0, 'changed': 0, 'new': 0}
    newcontent = {}
    for enc in sorted(glob.glob(os.path.join(src, 'encrypted_*.db'))):
        base = os.path.basename(enc)[len('encrypted_'):-len('.db')]
        db_out = os.path.join(out_root, base)
        os.makedirs(db_out, exist_ok=True)
        # old id sets for key tables (before overwrite)
        old_ids = {}
        for t in KEY_TABLES:
            jp = os.path.join(db_out, t + '.json')
            if os.path.exists(jp):
                try:
                    old_ids[t] = {r.get('id') for r in json.load(open(jp, encoding='utf-8'))}
                except Exception:
                    old_ids[t] = set()
        plain = decrypt(enc)
        tf = tempfile.NamedTemporaryFile(suffix='.db', delete=False)
        tf.write(plain); tf.close()
        con = sqlite3.connect(tf.name)
        con.text_factory = str
        integ = con.execute('PRAGMA integrity_check').fetchone()[0]
        tables = [r[0] for r in con.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")]
        tc = {'same': 0, 'changed': 0, 'new': 0}
        for t in tables:
            st, dicts = export_table(con, t, db_out)
            counts[st] += 1; tc[st] += 1
            if t in KEY_TABLES and t in old_ids:
                added = [d for d in dicts if d.get('id') not in old_ids[t]]
                if added:
                    newcontent.setdefault(base, {})[t] = [(d.get('id'), d.get('name')) for d in added]
        con.close(); os.unlink(tf.name)
        print('  %-10s integrity=%s  %d tables  (same %d / changed %d / new %d)'
              % (base, integ, len(tables), tc['same'], tc['changed'], tc['new']))
    print('[%s] TOTAL  same %d / changed %d / new %d' % (rk, counts['same'], counts['changed'], counts['new']))
    for base, tabs in newcontent.items():
        for t, adds in tabs.items():
            print('  [%s] %s: %d new rows' % (base, t, len(adds)))
            for i, n in adds[:40]:
                print('      %s  %s' % (i, n))
            if len(adds) > 40:
                print('      ... +%d more' % (len(adds) - 40))


if __name__ == '__main__':
    arg = (sys.argv[1].upper() if len(sys.argv) > 1 else 'BOTH')
    for rk in (['GL', 'JP'] if arg == 'BOTH' else [arg]):
        run_region(rk)
