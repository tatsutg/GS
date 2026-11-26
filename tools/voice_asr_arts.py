"""Japanese transcription of the Arts / True Arts / Super Arts voice lines (fullarts_*) that have no game text.

The game only has subtitle text for unit-menu lines (unit_master comments); battle lines have none. This runs
faster-whisper large-v3 (CUDA) over GS-voice/<base>/<slug>.m4a for every fullarts_* clip missing from voices.json subs,
with the unit's own JP skill names as the prompt (so called-out names are spelled like the game), and writes
tools/voice_subs_battle.json  {base: {slug: {"jp": [...], "asr": 1}}}  (resumable: done clips are skipped).
English (en) is added to that file by hand / translation pass; tools/voice_subs_extra.py merges it into voices.json.

Run with the whisper venv:  ~/.cache/watch/whisperx-venv/Scripts/python -I tools/voice_asr_arts.py [GS-voice dir] [--noprompt] [--prefix skill]
"""
import json, os, re, subprocess, sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
GS = os.path.dirname(HERE)
OUT = os.path.join(HERE, 'voice_subs_battle.json')
# --noprompt: second pass with no skill-name prompt, to voice_subs_battle_np.json. On unclear audio the prompted pass can
# echo the prompt (Hiei's cut-in came out as his two skill names); voice_subs_extra.py compares the two.
NOPROMPT = '--noprompt' in sys.argv
if NOPROMPT:
    sys.argv.remove('--noprompt')
    OUT = os.path.join(HERE, 'voice_subs_battle_np.json')
# --prefix skill: other clip kinds (Skill lines) instead of fullarts_*
PREFIX = 'fullarts'
if '--prefix' in sys.argv:
    i = sys.argv.index('--prefix'); PREFIX = sys.argv[i + 1]; del sys.argv[i:i + 2]
DB = os.path.join(GS, 'dlc', 'Japan', '_DATABASE', 'others', '{}.json')


def rows(name):
    d = json.load(open(DB.format(name), encoding='utf-8'))
    return d if isinstance(d, list) else next(v for v in d.values() if isinstance(v, list))


def jp_skill_names():
    """base -> JP names of its forms' Skill / Arts / True Arts / Super Arts."""
    sk = {r['id']: r['name'] for r in rows('skill_master')}
    cols = ('chargearts_skill_id', 'chargearts_skill_id2', 'full_chargearts_skill_id', 'full_chargearts_skill_id2', 'super_full_chargearts_skill_id')
    out = {}
    for u in rows('unit_master'):
        b = str(int(str(u['id'])[1:5]))
        for c in cols:
            n = sk.get(u.get(c))
            if n and n not in out.setdefault(b, []):
                out[b].append(n)
    return out


def audio(path):   # 16 kHz mono float32 via ffmpeg (faster-whisper's own decoder trips on these m4a on Windows)
    raw = subprocess.run(['ffmpeg', '-v', 'quiet', '-i', path, '-f', 'f32le', '-ac', '1', '-ar', '16000', '-'],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32)


def main():
    sys.stdout.reconfigure(encoding='utf-8')   # -I ignores PYTHONIOENCODING; JP text on a cp1252 console
    gv =sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(GS), 'GS-voice')
    d = json.load(open(os.path.join(gv, 'voices.json'), encoding='utf-8'))
    done = json.load(open(OUT, encoding='utf-8')) if os.path.exists(OUT) else {}
    names = jp_skill_names()
    jobs = []
    for b, L in d['units'].items():
        have = d['subs'].get(b, {})
        for _, sl in L:
            for s in ([sl] if isinstance(sl, str) else sl):
                if re.match(PREFIX + r'(_|\d|$)', s) and (NOPROMPT or s not in have) and s not in done.get(b, {}) \
                        and os.path.exists(os.path.join(gv, b, s + '.m4a')):
                    jobs.append((b, s))
    print(f'{len(jobs)} clips to transcribe', flush=True)
    from faster_whisper import WhisperModel
    m = WhisperModel('large-v3', device='cuda', compute_type='float16')
    for i, (b, s) in enumerate(jobs):
        try:
            a = audio(os.path.join(gv, b, s + '.m4a'))
            prompt = None if NOPROMPT else '、'.join(names.get(b, [])) or None
            segs, _ = m.transcribe(a, language='ja', beam_size=5, temperature=0, condition_on_previous_text=False,
                                   initial_prompt=prompt, vad_filter=False)
            segs = [x for x in segs if x.text.strip()]
        except Exception as e:   # one bad clip must not stop the run
            print('ERR', b, s, e, flush=True)
            continue
        # lp / ns: Whisper's confidence (avg log-prob, no-speech prob) per line: tools/voice_subs_extra.py drops weak lines
        done.setdefault(b, {})[s] = {'jp': [x.text.strip() for x in segs], 'asr': 1,
                                     'lp': [round(x.avg_logprob, 2) for x in segs], 'ns': [round(x.no_speech_prob, 2) for x in segs]}
        if i % 50 == 0 or i == len(jobs) - 1:
            json.dump(done, open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=0, sort_keys=True)
            print(f'{i + 1}/{len(jobs)}', b, s, done[b][s]['jp'], flush=True)


if __name__ == '__main__':
    main()
