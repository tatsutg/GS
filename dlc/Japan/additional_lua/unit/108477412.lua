local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒イリヤ（皇帝フォーム）", version=2.8, id=108477412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---スカイライト---
        [1] = {
            ID = 10840,
            BUFF_ID = 21,
            VALUE = 100,
            DURATION = 45,
            ICON = 139,
            -- SCRIPT = {
            --     SCRIPT_ID = 17,
            --     VALUE1 = 7---神族
            -- },
            GROUP_ID = 3971,
            PRIORITY = 100
        },
        ---グランヴィス---
        [2] = {
            ID = 10841,
            BUFF_ID = 21,
            VALUE = 100,
            DURATION = 45,
            ICON = 139,
            -- SCRIPT = {
            --     SCRIPT_ID = 17,
            --     VALUE1 = 1---人族
            -- },
            GROUP_ID = 3972,
            PRIORITY = 100
        },
        ---ダークブリンガー---
        [3] = {
            ID = 10842,
            BUFF_ID = 21,
            VALUE = 100,
            DURATION = 45,
            ICON = 139,
            -- SCRIPT = {
            --     SCRIPT_ID = 17,
            --     VALUE1 = 8---魔族
            -- },
            GROUP_ID = 3973,
            PRIORITY = 100
        },
        ---バフ削除用
        [4] = {
            ID = 10840,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
    self.ICON_BUFF_BOX_LIST = {
        ---アイコン用
        [1] = {
            ID = 108477412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 219  --スカイライト
        },
        [2] = {
            ID = 108477412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 220  --グランヴィス
        },
        [3] = {
            ID = 108477412,
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
    --self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
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
    elseif event.index == 8 then --主人公化
        self.skill2Flg = false
    end
    return 1
end

function class:skill2Buff(unit,weapon)
    local raceTbl = {[1] = 7,[2] = 1,[3] = 8};
    local targetTeam = self:getMyTaem(unit,false);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getRaceType() == raceTbl[weapon] then
                self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[weapon]);
            end
        end
    end
end

--- チーム取得
function class:getMyTaem(unit,teamFlg)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if teamFlg then
        --自分PTからみて味方PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end
    else
        --自分PTからみて敵PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(false);
        else
            targetTeam = megast.Battle:getInstance():getTeam(true);
        end
    end
    return targetTeam;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
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