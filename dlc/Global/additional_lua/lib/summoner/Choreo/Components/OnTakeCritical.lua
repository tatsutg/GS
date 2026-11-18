------
-- summoner.Choreo.Components.OnTakeCritical
--
-- 被クリティカル（クリティカル攻撃を受けた）でアクションを実行するトリガー Component。
--
-- 出典: 2004556 takeDamageValue「クリティカル攻撃を受けた場合は遅延」
--       （`getAncestorUnit(event.enemy):getTeamUnitCondition():getDamageAffectInfo().critical`
--         → エクストラタイマーの遅延フラグを立てる）/ 2077790 のクリ判定による被ダメ・被ブレイク補正。
--
-- ⚠ takeDamageValue を使うため boss version >= 1.1。
-- ⚠ event.value は書き換えない（被ダメージ補正は Defense / Break の担当。宣言順に影響しない）。
-- ⚠ 多段ヒットの奥義は**ヒットごとに**発火する（1ヒット1回）。
--
-- 同期: クリティカル判定は engine 側で決まり、他端末から来たダメージは配信された判定をそのまま使う
--       （C++ BattleLogic: `if(isRecv){ isCritical = inRecvIsCritical; }`）ため全端末で一致する。
--       → host 分岐なしで各端末が同じ結果になる（原典 2004556 も分岐していない）。
--
-- 設定:
--   actions    Action|list|function  被クリティカル時に実行（runActions 経由＝素の関数も可）
--   superOnly  bool  true でスーパークリティカルのみ（getDamageAffectInfo().superCritical）
--
-- @example エクストラタイマーを2秒間 1/2 に（重複なし・再クリで残り2秒に上書き）
--     boss:add(ExtraTimer{ key = "T", maxTime = 30, loopLimit = 999, onRound = { UseSkill{ index = 5 } },
--                          speedRules = { { when = { breaking = true }, speed = 0 },
--                                         { when = { smashing = true }, speed = 0 } } })
--     boss:add(OnTakeCritical{ actions = { ExtraTimer.SetSpeed{ key = "T", speed = 0.5, duration = 2 } } })
------
local _NAME = 'summoner.Choreo.Components.OnTakeCritical'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

------
-- 被弾情報（クリ/属性/物理魔法）を取り出す。
-- 攻撃側はオービット弾のことがあるので祖先ユニットまで遡る（出典 2004556 の getAncestorUnit）。
-- engine は caster 側・target 側の両方に同じ critical を書くため、攻撃元不明時は自分側から読む。
------
local function damageAffectInfo(event)
    local attacker = event.enemy
    if attacker ~= nil then
        while attacker:getParentTeamUnit() ~= nil do
            attacker = attacker:getParentTeamUnit()
        end
        return attacker:getTeamUnitCondition():getDamageAffectInfo()
    end
    if event.unit ~= nil then
        return event.unit:getTeamUnitCondition():getDamageAffectInfo()
    end
    return nil
end

local function OnTakeCritical(config)
    config = config or {}
    local actions = config.actions
    local superOnly = config.superOnly
    local component = { name = 'OnTakeCritical' }

    local function onDamage(self, event)
        local info = damageAffectInfo(event)
        if info == nil or not info.critical then return end
        if superOnly and not info.superCritical then return end
        Action.runActions(self, event, actions)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.takeDamageValue, onDamage)
    end

    return component
end

_G.package.loaded[_NAME] = OnTakeCritical
return OnTakeCritical
