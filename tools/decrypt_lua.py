"""
Decrypt the game's Lua scripts (dlc/<Region>/additional/**/*.dat) into readable dlc/<Region>/additional_lua/**/*.lua.

The .dat files are cocos2d-x XXTEA: 5-byte sign "XXTEA", then XXTEA (16-byte key, length word at the end).
Unit kits that the master tables do not hold (modes like Unlimited Blade Works, "DMG when used during ...")
live in additional/unit/<unit id>.dat (unit_master.is_lua = 1).

The key is not stored in this repo. Give it one of two ways:
    GS_LUA_KEY=<key> python tools/decrypt_lua.py [Global|Japan ...]
    python tools/decrypt_lua.py --lib path/to/libcocos2dcpp.so [Global|Japan ...]
--lib finds the key next to the "XXTEA" sign string in the game's native library
(lib/arm64-v8a/libcocos2dcpp.so inside config.arm64_v8a.apk of the XAPK).

Only files whose decrypted text changed are written. Run from the repo root.
"""
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
SIGN = b'XXTEA'
DELTA = 0x9E3779B9


def xxtea_decrypt(data, key):
    if len(data) % 4 or len(data) < 8:
        return None
    v = list(struct.unpack('<%dI' % (len(data) // 4), data))
    k = struct.unpack('<4I', (key + b'\0' * 16)[:16])
    n = len(v) - 1
    s = ((6 + 52 // (n + 1)) * DELTA) & 0xffffffff
    y = v[0]
    while s:
        e = (s >> 2) & 3
        for p in range(n, -1, -1):
            z = v[p - 1] if p > 0 else v[n]
            mx = (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((s ^ y) + (k[(p & 3) ^ e] ^ z))
            v[p] = (v[p] - mx) & 0xffffffff
            y = v[p]
        s = (s - DELTA) & 0xffffffff
    m = v[-1]
    if not (len(v) - 1) * 4 - 3 <= m <= (len(v) - 1) * 4:
        return None
    return struct.pack('<%dI' % (len(v) - 1), *v[:-1])[:m]


def key_from_lib(path):
    """the 16-character key sits just before the sign string in the library's read-only data"""
    b = open(path, 'rb').read()
    for m in re.finditer(rb'\x00XXTEA\x00', b):
        before = re.findall(rb'[\x21-\x7e]{16}', b[m.start() - 40:m.start()])
        if before:
            return before[-1]
    sys.exit('no XXTEA key found in ' + path)


args = sys.argv[1:]
key = os.environ.get('GS_LUA_KEY', '').encode()
if '--lib' in args:
    i = args.index('--lib')
    key = key_from_lib(args[i + 1])
    del args[i:i + 2]
if not key:
    sys.exit(__doc__)
regions = args or ['Global', 'Japan']

for region in regions:
    src = os.path.join(GS, 'dlc', region, 'additional')
    dst = os.path.join(GS, 'dlc', region, 'additional_lua')
    done = same = bad = 0
    for root, _, files in os.walk(src):
        for f in files:
            if not f.endswith('.dat'):
                continue
            raw = open(os.path.join(root, f), 'rb').read()
            out = xxtea_decrypt(raw[len(SIGN):], key) if raw.startswith(SIGN) else None
            if out is None:
                bad += 1
                print('could not decrypt', os.path.relpath(os.path.join(root, f), GS))
                continue
            path = os.path.join(dst, os.path.relpath(root, src), f[:-4] + '.lua')
            if os.path.exists(path) and open(path, 'rb').read() == out:
                same += 1
                continue
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, 'wb') as fh:
                fh.write(out)
            done += 1
    print(region, done, 'written,', same, 'unchanged,', bad, 'failed ->', dst)
