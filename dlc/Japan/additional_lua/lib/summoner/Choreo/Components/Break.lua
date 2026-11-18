------
-- summoner.Choreo.Components.Break
--
-- ブレイク回数による段階補正テーブル（[06] パターン6-B / TenebriusTemplate デグルマグナ方式）。
-- ブレイクするたびに breakCount を進め、被ダメージ/被ブレイク倍率をテーブル参照で補正する。
--
-- ⚠ takeBreake / takeBreakeDamageValue を使うため boss version >= 1.3。
--
-- @example
--     boss:add(Break{
--         badges = 5,                                                  -- addNumBreakBadge(5)+各ブレイクで除去
--         skipFirst = true,                                           -- 最初の被ブレイクダメージ1回を0（HPトリガー境界対策）
--         damageByCount = { [0]=0.05, [1]=0.3, [2]=0.5, [3]=0.7, [4]=1.0 },  -- 被ダメージ倍率
--         damageOver = function(c) return (c + 6) * 0.1 end,           -- テーブル超過時(>=5)
--         breakByCount  = { [0]=1.0, [1]=0.8, [2]=0.7, [3]=0.4, [4]=0.2 },   -- 被ブレイク倍率
--         breakOver = 0.1,
--         onBreak = { Say{"BREAK!"} },                                 -- ブレイクするたび（任意）
--     })
--
-- 設定:
--   badges         number   addNumBreakBadge(N)。各ブレイクで removeNumBreakBadge（任意）
--   skipFirst      bool     最初の被ブレイクダメージ1イベントを 0 にする（HPトリガー境界対策・デグルマグナ方式。任意）
--   damageByCount  table    breakCount => 被ダメージ倍率（takeDamageValue）
--   damageOver     number|function(count)  テーブルにキーが無い回数のときの倍率
--   breakByCount   table    breakCount => 被ブレイク倍率（takeBreakeDamageValue）
--   breakOver      number|function(count)
--   onBreak        Action|list  ブレイクするたびに実行（任意）
--   lockWhileInvincible  bool  無敵中(=HPトリガー奥義中)はブレイク不可。legacy「全HPトリガーは
--                              発動〜奥義終了までブレイク不可」準拠。getInvincibleTime()>0 で判定（任意）
------
local _NAME = 'summoner.Choreo.Components.Break'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function rate(byCount, over, count)
    if byCount ~= nil and byCount[count] ~= nil then
        return byCount[count]
    end
    if type(over) == 'function' then
        return over(count)
    end
    if over ~= nil then
        return over
    end
    return 1.0
end

local function Break(config)
    local badges = config.badges
    local skipFirst = config.skipFirst
    local damageByCount = config.damageByCount
    local damageOver = config.damageOver
    local breakByCount = config.breakByCount
    local breakOver = config.breakOver
    local onBreak = config.onBreak
    local lockWhileInvincible = config.lockWhileInvincible   -- 無敵中(HPトリガー奥義中)はブレイク不可（legacy 仕様）

    local component = { name = 'Break' }

    local function onLoad(self, event)
        self._breakCount = 0
        self._breakSkip = skipFirst and true or false
        if badges ~= nil then
            event.unit:addNumBreakBadge(badges)
        end
    end

    -- ブレイク成立: 回数加算 + バッジ除去 + onBreak
    local function onBreakEvent(self, event)
        if badges ~= nil then
            event.unit:removeNumBreakBadge()
        end
        self._breakCount = (self._breakCount or 0) + 1
        if onBreak ~= nil then
            Action.runActions(self, event, onBreak)
        end
    end

    -- 被ダメージ補正（damageByCount[breakCount] 倍）
    local function onDamage(self, event)
        if damageByCount ~= nil or damageOver ~= nil then
            event.value = event.value * rate(damageByCount, damageOver, self._breakCount or 0)
        end
    end

    -- 被ブレイク補正（無敵中ロック + 初回スキップ + breakByCount[breakCount] 倍）
    local function onBreakDamage(self, event)
        -- 無敵中(=HPトリガー奥義中)はブレイク不可（legacy: 全HPトリガーは発動〜奥義終了までブレイク不可）。
        -- breakSkip は消費しない（無敵が明けてからの最初の被ブレイクに残す）。
        if lockWhileInvincible and event.unit:getInvincibleTime() > 0 then
            event.value = 0
            return
        end
        if self._breakSkip then
            self._breakSkip = false
            event.value = 0
            return
        end
        if breakByCount ~= nil or breakOver ~= nil then
            event.value = event.value * rate(breakByCount, breakOver, self._breakCount or 0)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.takeBreake, onBreakEvent)
        dispatcher:addEventListener(Events.takeDamageValue, onDamage)
        dispatcher:addEventListener(Events.takeBreakeDamageValue, onBreakDamage)
    end

    return component
end

_G.package.loaded[_NAME] = Break
return Break
