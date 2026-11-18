local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = Bootstrap.createEnemyClass({label="ラグシェルムX／超神級／Wave1", version=1.9, id=2027007})
class:inheritFromEnemy("2027006") -- 超神級／Wave1

----------[[ メッセージ ]]----------
function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "最大HPが高いユニットへのダメージUP",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "闇属性耐性・光キラー・反射耐性",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.GRAB_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE1 or "祈れ…懺悔ノ時間ダ",
            COLOR = Color.magenta,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE2 or "HPの高い者をホールド",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE3 or "一定ダメージを与えると解除",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.GRAB_BREAK_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.GRAB_BREAK_MESSAGE1 or "何ぃいィイイ！？",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
    self.OGI_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.OGI_MESSAGE1 or "消え失セロォォオオオ！！",
            COLOR = Color.magenta,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.OGI_MESSAGE2 or "ダメージ無効化無効",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.HP20_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "刻め…コレが恐怖ダ",
            COLOR = Color.magenta,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "攻撃力・行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.DEAD_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "消えヌ…我ガ怒りハ…決し…テ……",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
end

--------[[ バフ ]]--------
function class:setBuffBoxList()
    self.HP20_BUFF_LIST = {
        {
            ID = 20054351,
            BUFF_ID = 28,   -- 攻撃速度
            VALUE = 20,
            DURATION = 99999,
            ICON = 7,
        },
        {
            ID = 20054352,
            BUFF_ID = 13, -- 攻撃力
            VALUE = 100,
            DURATION = 99999,
            ICON = 3
        }
    }
end

function class:setTriggersList()
    self.TRIGGERS = {
        {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false
        }
    }
end

function class:hp20(status)
    if status == "use3" then
        self:addBuff(self.gameUnit,self.HP20_BUFF_LIST)
        self:showMessage(self.HP20_MESSAGE_LIST)
        self.spValue = 30
        self.attackDelay = 2
        self.gameUnit:setAttackDelay(self.attackDelay)

        if self.isDPSCheck then return end

        self.gameUnit:takeAnimation(0,"attack3",false)
        self.gameUnit:takeAnimationEffect(0,"1-attack3",false)
        self.isBarrier = true
     end
end

function class:setDamageParSecond(unit, count)
    local needHP = 0
    if     count == 1 then needHP = unit:getCalcHPMAX() * 0.09
    elseif count == 2 then needHP = unit:getCalcHPMAX() * 0.14
    elseif count == 3 then needHP = unit:getCalcHPMAX() * 0.19
                      else needHP = unit:getCalcHPMAX() * 0.24 end
    return needHP
end

function class:initializeParameters(unit)
    class:parent().initializeParameters(self, unit)
    self.startSp = 20
    self.attackDelay = 3.3
    self.isFirst = false

    self.isBarrier = false
    self.barrierTimer = 0
    self.BARRIER_LIMIT = 1.66

end

function class:startWave(event)
    class:parent().startWave(self, event)
    event.unit:takeAttack(7)
    for i = 0, 3 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if target ~= nil then
            target:getTeamUnitCondition():addCondition(-10, 89, 1, 3, 0)
        end
    end
    return 1
end

function class:takeIn(event)
    event.unit:setPosition(750, 0)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("in2")
    return 1
end

function class:run(event)
    class:parent().run(self, event)
    if event.spineEvent == "inAttack" then self:inAttack() end
    return 1
end

function class:inAttack()
    for i = 0, 3 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if target ~= nil then
            local hp = target:getHP()/2
            target:setHP(hp < 1 and 1 or math.floor(hp))
            target:setBurstPoint(0)
        end
    end
end

function class:takeDamageValue(event)
    class:parent().takeDamageValue(self, event)
    if self.isBarrier then
        return 1
    end
    return event.value
end

function class:update(event)
    class:parent().update(self, event)
    if not self.isFirst then
        event.unit:setPosition(750, 0)
    end

    if self.isBarrier then
        self:checkBarrierTime(event.deltaTime)
    end
    return 1
end

function class:checkBarrierTime(deltaTime)
    self.barrierTimer = self.barrierTimer + deltaTime
    if self.barrierTimer > self.BARRIER_LIMIT then
        self.isBarrier = false
    end
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    if self.isRage then
        self.isRage = false
        attackIndex = 6
        self.gameUnit:setAttackDelay(self.attackDelay)
    elseif not self.isFirst then
        self.isFirst = true
        attackIndex = 7
    else
        self:movePatternState(self.ATTACK_SET_LIST, self.STATE_ATTACK)
    end

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, attackIndex)
    return 0
end

class:publish()
return class
