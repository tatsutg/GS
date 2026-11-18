------
-- summoner.Choreo.Components.AnnounceOrbit
--
-- 【MEGA_D-9763】行動（奥義の index）ごとに「Lua の弾（SpawnOrbit）に渡す取り分」を、ボスの技の予告に知らせる Component。
-- 予告は表示専用。本 Component はバトルの状態を何も変えない（unit:announceSkillDamage を呼ぶだけ）。
--
-- 出典: 本体の取り分を DamageRate で下げ、残りを Timeline の SpawnOrbit（damageRate）で弾に渡すボス。
--       予告は本体のヒットしか知らないので、弾の分（取り分 × 本数）を takeSkill の中で知らせる
--       （`announceSkillDamage(3, 取り分, 本数)`。cocos-megast の claudedocs/battle/boss-skill-warning-refresh/for-lua-and-master.md）。
--
-- ⚠ 知らせを受け付けるのは takeSkill の中だけ。行動が成立した回に知らせるため `takeSkill@commit` を購読する
--    （DamageRate と同じ。Selector の二段発火で pass1 に食われない）。通常攻撃（takeAttack）には予告が出ないので扱わない。
-- ⚠ 取り分は SpawnOrbit の damageRate と同じ値を書く（弾のアニメーションのヒットの割合の合計が 1 のとき、弾 1 本が当てる割合）。
--    本数は、その奥義のアニメーションで SpawnOrbit が発火する回数。
-- ⚠ 古いアプリには announceSkillDamage が無いので、あるときだけ呼ぶ。
--
-- 同期: 表示だけ（host 分岐不要）。
--
-- 設定:
--   smash  table  takeSkill の index => { rate = 弾の取り分, count = 本数（既定 1） }
--
-- @example 奥義4 は本体 0.9・残り 0.1 を shot オービットへ委譲（DamageRate・Timeline と並べて書く）
--     boss:add(DamageRate{ smash = { [4] = { damageRate = 0.9, breakRate = 0.9 } } })
--     boss:add(AnnounceOrbit{ smash = { [4] = { rate = 0.1, count = 1 } } })
------
local _NAME = 'summoner.Choreo.Components.AnnounceOrbit'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function AnnounceOrbit(config)
    config = config or {}
    local smash = config.smash or {}
    local component = { name = 'AnnounceOrbit' }

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnSmashCommit, function(self, event)
            local unit = event.unit or self.unit
            if unit == nil or unit == false or not unit.announceSkillDamage then
                return
            end
            local orbit = event.index ~= nil and smash[event.index] or nil
            if orbit == nil or orbit.rate == nil then
                return
            end
            unit:announceSkillDamage(3, orbit.rate, orbit.count or 1)
        end)
    end

    return component
end

_G.package.loaded[_NAME] = AnnounceOrbit
return AnnounceOrbit
