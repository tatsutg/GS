local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒イスリーダ皇帝", version=1.9, id=103426412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---スカイライト---
        [1] = {
            ID = 103421,
            BUFF_ID = 32,---命中率
            VALUE = 30,
            DURATION = 15,
            ICON = 14,
            GROUP_ID = 3192,
            PRIORITY = 30
        },
        [4] = {
            ID = 10342,
            BUFF_ID = 17,
            VALUE = 150,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 7---神族
            },
            GROUP_ID = 1073,
            PRIORITY = 150
        },

        ---グランヴィス---
        [2] = {
            ID = 103422,
            BUFF_ID = 21,---被ダメ軽減
            VALUE = -20,
            DURATION = 15,
            ICON = 20,
            GROUP_ID = 6,
            PRIORITY = 20
        },
        [5] = {
            ID = 10342,
            BUFF_ID = 17,
            VALUE = 150,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 1---人族
            },
            GROUP_ID = 1073,
            PRIORITY = 150
        },

        ---ダークブリンガー---
        [3] = {
            ID = 103423,
            BUFF_ID = 13,---攻撃力
            VALUE = 50,
            DURATION = 15,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 50
        },
        [6] = {
            ID = 10342,
            BUFF_ID = 17,
            VALUE = 150,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 8---魔族
            },
            GROUP_ID = 1073,
            PRIORITY = 150
        },

        ---バフ削除用
        [7] = {
            ID = 10342,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
    self.ICON_BUFF_BOX_LIST = {
        ---アイコン用
        [1] = {
            ID = 103426412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 219
        },
        [2] = {
            ID = 103426412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 220
        },
        [3] = {
            ID = 103426412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 221
        },
    }
end

function class:firstIn(event)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("empty")
    return 0;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()
    self.myPosition = event.unit:getIndex() + 1
    self.weaponNum = self.myPosition
    if self.myPosition >= 4 then
        self.weaponNum = 1
    end
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()
    self.myPosition = event.unit:getIndex() + 1
    self.weaponNum = self.myPosition
    if self.myPosition >= 4 then
        self.weaponNum = 1
    end
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -1
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end

function class:takeDamage(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end

function class:takeFront(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end

function class:takeBack(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 3 then
        event.unit:setNextAnimationName("skill3_"..self.weaponNum)
        event.unit:setNextAnimationEffectName("2-skill3_"..self.weaponNum)
        self:skill3Buff(event.unit,self.weaponNum)
        if self.myPosition >= 4 then
            self.weaponNum = self.weaponNum + 1
            if self.weaponNum > 3 then
                self.weaponNum = 1
            end
        end
    end
    return 1
end

function class:skill3Buff(unit,weapon)
    local myTeam = megast.Battle:getInstance():getTeam(unit:getisPlayer());
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[weapon])
        end
    end
    self:execAddBuff(unit,self.BUFF_BOX_LIST[weapon + 3])
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[7])
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = 0
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

function class:teamAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;