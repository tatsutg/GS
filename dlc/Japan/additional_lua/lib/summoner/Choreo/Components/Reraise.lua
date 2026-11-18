------
-- summoner.Choreo.Components.Reraise
--
-- 復活／HP0トリガー。HP が0になったときの dead で死亡を取り消す（HP 復帰＋無敵＋アクション）。
-- 復活回数を超えたら死亡を許可。HP0 で最終奥義を撃つ「自爆」もこれで表す。
-- 出典: 実ボス慣用（dead で setHP(1)＋setInvincibleTime → return 0＝死亡取消。unit/500721013.lua の dead 等）。
--
-- ⚠ engine の avoidDead は dead 型スキル（skill_type=dead）を持つユニットでしか呼ばれない（Team.cpp の死亡判定）ので使わない。
--    dead は HP が0以下になったユニットで毎回呼ばれ、0 を返すと死亡処理を飛ばす。
-- ⚠ dead を使う（version 1.0）。
-- ⚠ Dead より前に宣言する（取り消した dead で後ろのリスナを止める＝撃破 INFO 等を出させない）。
-- ⚠ animation を指定したときだけ、そのアニメを奥義扱い（unit state = skill / burst active）で流す。
--    指定しないときは state を触らない（UseSkill の奥義は state が skill の間は始まらないため）。
-- 同期: dead は各端末で起き、HP・無敵・アニメは各端末で同じことをする（決定的）。actions の UseSkill は
--   Smash の二段発火に乗る（ホストが決めて配信）。
--
-- @example
--     boss:add(Reraise{ times = 3, hp = 1, invincible = 1.8, animation = "reraise",
--                       actions = { UseSkill{ 4 } } })   -- 復活ごとに奥義4
--     -- HP0 で最終奥義(自爆)を撃つ（撃ち終わりで倒すなら SkillFinishWatch{ onSkill = {6}, onFinish = { SetHP{0} } }）:
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

    local function onDead(self, event)
        self._reraiseCount = (self._reraiseCount or 0) + 1
        if self._reraiseCount > times then
            return                      -- 既定の戻り値(1)のまま＝死亡を許可
        end
        local unit = event.unit
        unit:setHP(hp)
        event:prevent()                 -- 死亡を取り消す（C++ へ 0 を返し、後ろの dead リスナも止める）
        if animation ~= nil then
            unit:takeAnimation(0, animation, false)
            unit:takeAnimationEffect(0, '1_' .. animation, false)
            unit:setUnitState(kUnitState_skill)
            unit:setBurstState(kBurstState_active)
        end
        if invincible ~= nil then
            unit:setInvincibleTime(invincible)
        end
        if actions ~= nil then
            Action.runActions(self, event, actions)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnDrop, onDead)
    end

    return component
end

_G.package.loaded[_NAME] = Reraise
return Reraise
