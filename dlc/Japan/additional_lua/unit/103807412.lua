local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒超皇帝", version=1.9, id=103807412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---スカイライト---
        [1] = {
            ID = 103801,
            BUFF_ID = 30, --装備CT
            VALUE = 30,
            DURATION = 25,
            ICON = 224,
            SCRIPT = {
                SCRIPT_ID = 290,
                VALUE1 = 2---魔法
            }
        },
        [4] = {
            ID = 10380,
            BUFF_ID = 17,
            VALUE = 200,
            DURATION = 25,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 7---神族
            },
            GROUP_ID = 3710,
            PRIORITY = 180
        },

        ---グランヴィス---
        [2] = {
            ID = 103802,
            BUFF_ID = 30, --装備CT
            VALUE = 30,
            DURATION = 25,
            ICON = 227,
            SCRIPT = {
                SCRIPT_ID = 290,
                VALUE1 = 5---援護
            }
        },
        [5] = {
            ID = 10381,
            BUFF_ID = 17,
            VALUE = 200,
            DURATION = 25,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 1---人族
            },
            GROUP_ID = 3711,
            PRIORITY = 180
        },

        ---ダークブリンガー---
        [3] = {
            ID = 103803,
            BUFF_ID = 30, --装備CT
            VALUE = 30,
            DURATION = 25,
            ICON = 223,
            SCRIPT = {
                SCRIPT_ID = 290,
                VALUE1 = 1---物理
            }
        },
        [6] = {
            ID = 10382,
            BUFF_ID = 17,
            VALUE = 200,
            DURATION = 25,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 8---魔族
            },
            GROUP_ID = 3712,
            PRIORITY = 180
        },

        ---バフ削除用
        [7] = {
            ID = 10380,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
    self.ICON_BUFF_BOX_LIST = {
        ---アイコン用
        [1] = {
            ID = 103807412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 219  --スカイライト
        },
        [2] = {
            ID = 103807412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 220  --グランヴィス
        },
        [3] = {
            ID = 103807412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 221  --ダークブリンガー
        }
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
    self.skill2Flg = false
    self.skill5Flg = false
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
    return 1;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end

---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self:execAddBuff(event.unit,self.ICON_BUFF_BOX_LIST[self.weaponNum])
    return 1;
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    --self:execAddBuff(event.unit,self.BUFF_BOX_LIST[7])
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

    if self.skill2Flg then
        self.skill2Flg = false
        self:skill2Buff(event.unit,self.weaponNum)
        if self.myPosition >= 4 then
            self.weaponNum = self.weaponNum + 1
            if self.weaponNum > 3 then
                self.weaponNum = 1
            end
        end
    end
    if self.skill5Flg then
        self.skill5Flg = false
        event.unit:getBurstSkill3():runSkillEffectWithID(20381001,false);
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
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.skill2Flg = true
        event.unit:setNextAnimationName("skill2_"..self.weaponNum)
        event.unit:setNextAnimationEffectName("2-skill2_"..self.weaponNum)
    elseif event.index == 3 then
        self.skill2Flg = false
    elseif event.index == 5 then
        self.skill2Flg = false
        self.skill5Flg = true
        event.unit:getBurstSkill3():runSkillEffectWithID(20381002,false);
        event.unit:setIsDisableSkillEffect(true)
    end
    return 1
end

function class:skill2Buff(unit,weapon)
    local myTeam = megast.Battle:getInstance():getTeam(unit:getisPlayer());
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[weapon])
        end
    end
    self:execAddBuff(unit,self.BUFF_BOX_LIST[weapon + 3])
end

function class:weaponCoolTimeSet(unit)
    local battleSkill = nil
    for i = 0,2 do
        battleSkill = unit:getItemSkill(i)
        if battleSkill ~= nil then
            if not megast.Battle:getInstance():isPvp() then
                battleSkill:setCoolTimer(battleSkill:getCoolTimer() * 0.5)
            else
                battleSkill:setCoolTimer(battleSkill:getCoolTimer() * 0.9)
            end
        end
    end
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