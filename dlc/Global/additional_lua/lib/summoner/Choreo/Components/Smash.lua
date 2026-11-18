------
-- summoner.Choreo.Components.Smash
--
-- 奥義（スキル）の行動抽選 Component。Selector 基底 + takeSkill。
-- 実行時に Burst（奥義）状態へ移行する。マルチ同期は内部の Sync が自動処理。
--
-- カットイン: cutin = { [index] = 種別 }（通常発動でも強制発動でも index 紐付けで使用）
--   種別: Choreo.Cutin.Arts(0=奥義) / Choreo.Cutin.TrueArts(1=真奥義) / 無指定=カットインなし
--
-- 任意奥義の強制発動: UseSkill Action（フェーズ等から）。
--
-- @example
--     boss:add(Smash{
--         weights = { [1]=50, [2]=50 }, activeSkills = { [1]=7, [2]=8 },
--         cutin   = { [2] = Choreo.Cutin.ShinOugi },     -- 奥義2は真奥義カットイン
--     })
--     boss:add(Phases{ { at=60, actions = {
--         UseSkill{ index = 2, invincible = 5, keepGauge = true },  -- 奥義2を強制発動
--     } } })
--
-- ⚠ keepGauge を使う場合は update を使うため boss version >= 1.1。
------
local _NAME = 'summoner.Choreo.Components.Smash'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Selector = require('summoner.Choreo.Components.Selector')
local Action = require('summoner.Choreo.Action')

-- keepGauge 復元: 強制奥義が skill 状態を抜けたら saveBP を戻す（実ボス「奥義後に addSP(saveBP)」相当）
local function restoreUpdate(self, event)
    if not self._SmashRestorePending then
        return
    end
    if self.unit:getUnitState() == kUnitState_skill then
        self._SmashRestoreSaw = true                       -- 奥義中を確認
    elseif self._SmashRestoreSaw then
        self.unit:addSP(self._SmashRestoreSaveBP or 0)     -- 奥義を抜けた → ゲージ復元
        self._SmashRestorePending = nil
        self._SmashRestoreSaw = nil
        self._SmashRestoreSaveBP = nil
    end
end

local makeSmash   -- 前方宣言

local Smash = setmetatable({}, {
    __call = function(_, config) return makeSmash(config) end
})

function makeSmash(config)
    local component = Selector.makeComponent({
        name = 'Smash',
        event = Events.OnSmash,
        channel = 'skill',
        animBase = 'skill',    -- C++ 既定アニメ名（takeSkill → "skill<N>"）
        trigger = function(unit, index, cutin)
            if cutin ~= nil then
                unit:takeSkillWithCutin(index, cutin)   -- カットイン付き発動
            else
                unit:takeSkill(index)
            end
        end,
        onExecute = function(self, unit, index)
            unit:setBurstState(kBurstState_active)       -- 奥義状態へ
            if self._SmashRestoreArmed then              -- keepGauge: 強制奥義が出たら復元待ちへ
                self._SmashRestoreArmed = nil
                self._SmashRestorePending = true
                self._SmashRestoreSaw = nil
            end
        end,
        config = config,
    })

    -- keepGauge 復元用に update を追加
    local baseInit = component.initialize
    component.initialize = function(dispatcher)
        baseInit(dispatcher)
        dispatcher:addEventListener(Events.OnUpdate, restoreUpdate)
    end

    -- ゲージ保存（UseSkill{keepGauge=true} 用）
    component.armSmashGauge = function(self)
        self._SmashRestoreSaveBP = self.unit:getBurstPoint()
        self._SmashRestoreArmed = true
    end

    return component
end

------
-- UseSkill Action: 任意奥義を強制発動する（フェーズ等から）
--   index      number  強制発動する奥義インデックス
--   invincible number  (任意) 発動中の無敵秒数（setInvincibleTime）
--   keepGauge  bool    (任意) 発動前のゲージを保存し、奥義後に復元（ボスの本来ゲージを消費しない）
--   cutin      number  (任意) **この発動だけ**のカットイン種別（Choreo.Cutin.*。1回限りの上書き）
-- 常時のカットインは Smash の cutin[index]（index 紐付け）。cutin 指定はそれより優先され、
-- 通常ローテの同 index には影響しない（出典: 実ボス慣用＝発動ごとに takeSkillWithCutin を出し分け）。
------
Smash.UseSkill = Action.define('UseSkill', function(a, d, e)
    local index = a.index or a[1]
    if a.keepGauge then
        d:armSmashGauge()                  -- ゲージ保存（復元は奥義後）
    end
    d:forceSmash(index, a.cutin)           -- 次の奥義抽選を強制 index に（cutin=この発動だけの上書き）
    d.unit:addSP(100)                       -- ゲージ満タン → エンジンが奥義発動
    if a.invincible ~= nil then
        d.unit:setInvincibleTime(a.invincible)
    end
end)

_G.package.loaded[_NAME] = Smash
return Smash
