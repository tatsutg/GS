------
-- summoner.Choreo.Components.Reraise
--
-- 復活／HP0トリガー。死亡時の avoidDead で「死亡を回避（HP復帰＋無敵＋アクション）」する。
-- 復活回数を超えたら死亡を許可。HP0 で最終奥義を撃つ「自爆」もこれで表す。
-- 出典: 実ボス慣用（avoidDead で setHP(1)+setInvincibleTime+takeAnimation → return 0=死亡回避）。
--
-- ⚠ avoidDead を使うため boss version >= 2.6。
--
-- @example
--     boss:add(Reraise{ times = 3, hp = 1, invincible = 1.8, animation = "reraise",
--                       actions = { UseSkill{ 4 } } })   -- 復活ごとに奥義4
--     -- HP0 で最終奥義(自爆)を撃ってから死ぬ:
--     boss:add(Reraise{ times = 1, actions = { UseSkill{ 6 } } })
--
-- 設定:
--   times      number  死亡回避できる回数（既定1）。超過したら死亡を許可。
--   hp         number  復活時の HP（setHP、既定1）
--   invincible number  復活直後の無敵秒（任意, setInvincibleTime）
--   animation  string  復活アニメ名（任意, takeAnimation/takeAnimationEffect "1_"..name）
--   actions    Action|list  死亡回避時に実行（UseSkill 等）
------
local _NAME = 'summoner.Choreo.Components.Reraise'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function Reraise(config)
    config = config or {}
    local times = config.times or 1
    local hp = config.hp or 1
    local invincible = config.invincible
    local animation = config.animation
    local actions = config.actions
    local component = { name = 'Reraise' }

    local function onLoad(self, event)
        self._reraiseCount = 0
    end

    local function onAvoidDead(self, event)
        self._reraiseCount = (self._reraiseCount or 0) + 1
        if self._reraiseCount > times then
            return                      -- 既定 returnValue(1) のまま＝死亡を許可
        end
        local unit = event.unit
        if animation ~= nil then
            unit:takeAnimation(0, animation, false)
            unit:takeAnimationEffect(0, '1_' .. animation, false)
        end
        unit:setUnitState(kUnitState_skill)
        unit:setBurstState(kBurstState_active)
        if invincible ~= nil then
            unit:setInvincibleTime(invincible)
        end
        unit:setHP(hp)
        if actions ~= nil then
            Action.runActions(self, event, actions)
        end
        event:setReturnValue(0)         -- 死亡回避
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.avoidDead, onAvoidDead)
    end

    return component
end

_G.package.loaded[_NAME] = Reraise
return Reraise
