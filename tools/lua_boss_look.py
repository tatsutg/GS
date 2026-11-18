"""How an enemy's Lua sets up its look when the fight starts (class:start / class:startWave):
  unit:addSubSkeleton("50103_leg", -30)   an extra skeleton (legs, a reaper, a dragon) drawn with the body,
                                          playing the same animation names; the number is its z order
                                          (below 0 behind the body)
  unit:setSkin("1")                       the skin that holds parts missing from the default skin (weapons)
  unit:setSetupAnimationName("setUp1")    the pose (slot attachments) the body starts from
look(text) -> [[[name, z], ...], skin, setup] or 0 when the script sets none of them.
Later changes (rage skins, broken weapons) are not read."""
import re

STR = r'"([^"]*)"'


def strip_comments(s):
    s = re.sub(r'--\[(=*)\[.*?\]\1\]', '', s, flags=re.S)
    return re.sub(r'--[^\n]*', '', s)


def body(s, name):
    m = re.search(r'^function\s+\w+:' + name + r'\s*\(', s, flags=re.M)
    if not m:
        return ''
    n = re.search(r'^function\s', s[m.end():], flags=re.M)
    return s[m.end():m.end() + n.start()] if n else s[m.end():]


def look(text):
    s = strip_comments(text)
    part = body(s, 'start') + '\n' + body(s, 'startWave')
    subs = []
    for m in re.finditer(r'addSubSkeleton\(\s*' + STR + r'\s*,\s*([^)]+?)\s*\)', part):
        z = m.group(2)
        if not re.fullmatch(r'-?\d+', z):            # a variable: its first numeric assignment in the script
            v = re.search(r'\b' + re.escape(z.split('.')[-1]) + r'\s*=\s*(-?\d+)', s)
            z = v.group(1) if v else '0'
        if [m.group(1), int(z)] not in subs:
            subs.append([m.group(1), int(z)])
    skin = re.findall(r'setSkin\(\s*' + STR + r'\s*\)', part)
    setup = re.findall(r'setSetupAnimationName\(\s*' + STR + r'\s*\)', part)
    out = [subs, skin[0] if skin else '', setup[0] if setup else '']
    return out if subs or out[1] or out[2] else 0
