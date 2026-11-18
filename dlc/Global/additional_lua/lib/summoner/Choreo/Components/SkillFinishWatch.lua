------
-- summoner.Choreo.Components.SkillFinishWatch
--
-- 「arm フィールドが立ったら、その後に発火する奥義(takeSkill)を対象とみなし、
--  奥義直後の takeAttack / takeIdle / takeBack で撃ち終わりを検知して onFinish を1回実行し、
--  active フィールドを下ろす」監視。イベント駆動（既存ボスの addSpSkipFLG 慣用に準拠）。
--  ※takeBack(戻りモーション)も復帰点に含める＝奥義後の余計な1動作を挟まず即閉じる。
-- ムーマ王(2082790)の奥義5自滅監視・真EX(2082780)のHPトリガー窓管理を共通化したもの。
--
-- なぜ固定秒数(setInvincibleTime 等)でなくこれか:
--   「発動から撃ち終わるまで」を秒数決め打ちすると演出尺とズレる。行動イベントで正確に追従する。
-- なぜ takeSkill を gate にするか:
--   発動(arm)時に別の奥義が再生中でも、その旧奥義の takeSkill は arm より前なので対象外。
--   arm 後に撃つHPトリガーの奥義だけを skillSeen とし、旧奥義終わりで誤って閉じない。
--
-- @example HPトリガーの「被ダメ×0.1＋状態異常無効」の窓管理
--   -- Phases 側（発動時）: self._hpTrigActive=true, self._hpTrigPending=true にし耐性バフを付与
--   boss:add(SkillFinishWatch{
--       arm = '_hpTrigPending', active = '_hpTrigActive',
--       onFinish = function(self, e) --[[ 付与した耐性バフを除去 ]] end,
--   })
--   -- Defense 側: { mult = 0.1, when = function(self, e) return self._hpTrigActive == true end }
--
-- @example 奥義後に自滅（ムーマ王）
--   boss:add(SkillFinishWatch{ arm = '_doomPending',
--       onFinish = function(self, e) local u = self.unit
--           u:getTeam():deadUnit(u:getIndex()); megast.Battle:getInstance():waveEnd(true) end })
--
-- @example 特定の奥義（天候変化 4/5/6）の撃ち終わりで無敵を閉じる（皇雅）
--   boss:add(SkillFinishWatch{ onSkill = { 4, 5, 6 }, onFinish = { Invincible{ 0 } } })
--
-- 設定:
--   arm       string    この dispatcher フィールドが true になったら監視開始（開始時に false へ消費＝多重発火防止）
--   onSkill   table     (任意) この奥義 index が発火したら自動で監視開始（arm フラグ不要）。
--                       arm と併用可（どちらかが成立すれば監視開始）
--   active    string    (任意) 監視中は呼び出し側が true にし、撃ち終わりで false にするフィールド名
--   onFinish  Action|list|function  (任意) 撃ち終わり時に1回実行（runActions 経由＝素の関数も可）
------
local _NAME = 'summoner.Choreo.Components.SkillFinishWatch'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function SkillFinishWatch(config)
    config = config or {}
    local armKey = config.arm
    local activeKey = config.active
    local onFinish = config.onFinish
    local onSkill = nil
    if config.onSkill ~= nil then
        onSkill = {}
        for i = 1, #config.onSkill do
            onSkill[config.onSkill[i]] = true
        end
    end
    local component = { name = 'SkillFinishWatch' }

    -- 監視状態は per-instance（規約 §6-3）。クロージャ変数にすると同じボスID の複数体・
    -- リトライ（永続 VM）で状態を共有してしまう。
    local function onLoad(self, event)
        self._skillFinishPending = false    -- arm 済みで撃ち終わり待ち
        self._skillFinishSeen = false       -- arm 後に「対象の奥義」が発火(takeSkill)したか
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)

        -- arm の検出（フラグは Phases 等の呼び出し側が立てる）
        dispatcher:addEventListener(Events.OnUpdate, function(self, event)
            if not self._skillFinishPending and armKey ~= nil and self[armKey] then
                self._skillFinishPending = true
                self._skillFinishSeen = false
                self[armKey] = false          -- 消費（多重監視を防ぐ）
            end
        end)

        -- takeSkill(奥義発火)の gate。arm より前に発火した「進行中だった旧奥義」は
        -- ここに来ないので除外され、arm 後に撃つHPトリガーの奥義だけを対象にできる。
        -- onSkill 指定時は、その index の発火（＝index 付きの pass2）自体が arm を兼ねる。
        dispatcher:addEventListener(Events.OnSmash, function(self, event)
            if onSkill ~= nil and event.index ~= nil and onSkill[event.index] then
                self._skillFinishPending = true
            end
            if self._skillFinishPending then self._skillFinishSeen = true end
        end)

        -- 撃ち終わり＝奥義直後の takeAttack(既存ボス慣用の復帰点) or takeIdle。
        -- skillSeen 前(=対象奥義がまだ始まっていない)の発火では閉じない。
        local function finish(self, event)
            if not (self._skillFinishPending and self._skillFinishSeen) then return end
            self._skillFinishPending = false
            self._skillFinishSeen = false
            if activeKey ~= nil then self[activeKey] = false end
            Action.runActions(self, event, onFinish)
        end
        dispatcher:addEventListener(Events.OnAttack, finish)   -- takeAttack
        dispatcher:addEventListener(Events.takeIdle, finish)   -- takeIdle（idle復帰でも閉じる）
        dispatcher:addEventListener(Events.takeBack, finish)   -- takeBack（奥義後の戻りモーション。これも復帰点として即閉じる）
    end

    return component
end

_G.package.loaded[_NAME] = SkillFinishWatch
return SkillFinishWatch
