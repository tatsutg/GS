"""Which units / equips exist on only one server (dlc/v2_servers.json).

The site reads this small index so the EN | JP server switch knows, before it switches, whether the
open unit or equip exists on the other server (no need to download the other server's detail JSON).

    {"units":  {"jpOnly": [base, ...], "glOnly": [base, ...]},
     "equips": {"jpOnly": [base, ...], "glOnly": [base, ...]}}

Bases are the family / base ids the V2 tabs use (unitsv2_detail keys, equipsv2_detail equips[].b).
Run after build_unitsv2_detail.py / build_equipsv2_detail.py (both call it at the end).
"""
import json
import os

GS = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(GS, 'dlc', 'v2_servers.json')


def _load(region, name):
    path = os.path.join(GS, 'dlc', region, '_DATABASE', 'others', name)
    if not os.path.exists(path):
        return None
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def _bases(kind, region):
    if kind == 'units':
        d = _load(region, 'unitsv2_detail.json')
        return None if d is None else {int(k) for k in d}
    d = _load(region, 'equipsv2_detail.json')
    return None if d is None else {int(e['b']) for e in d.get('equips', [])}


def main():
    out = {}
    for kind in ('units', 'equips'):
        gl, jp = _bases(kind, 'Global'), _bases(kind, 'Japan')
        if gl is None or jp is None:
            print(f'v2_servers: {kind} detail missing for a server, skipped')
            return
        out[kind] = {'jpOnly': sorted(jp - gl), 'glOnly': sorted(gl - jp)}
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(out, f, separators=(',', ':'))
    print('v2_servers: ' + ', '.join(f"{k} {len(v['jpOnly'])} JP-only / {len(v['glOnly'])} GL-only" for k, v in out.items())
          + f' -> {OUT}')


if __name__ == '__main__':
    main()
