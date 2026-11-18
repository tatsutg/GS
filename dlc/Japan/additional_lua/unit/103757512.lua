local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒ロゼッタ（サマーver）", version=1.3, id=103757512});

function class:setBuffBoxList()
    --固有アビリティ
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1037501,
            BUFF_ID = 30,  --装備CT
            VALUE = 30,
            DURATION = 99999,
            ICON = 0,
            SCRIPT = {
                SCRIPT_ID = 290,
                VALUE1 = 4
            }
        },
        [2] = {
            ID = 1037502,
            BUFF_ID = 126,  --回復力UP
            VALUE = 70,
            DURATION = 99999,
            ICON = 0,
            SCRIPT = {
                SCRIPT_ID = 351,
                VALUE1 = 4
            }
        },
        [3] = {
            ID = 1037501,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [4] = {
            ID = 1037502,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
end

----// start //----------------------------------------------------------------------------
-- 条件 : ユニット登場時。（戦闘開始、交代、蘇生時など）
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.badStatusFlg = false
    return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:badStatusCheck(event.unit)
    return 1
end

function class:badStatusCheck(unit)
    self.badStatusFlg = false
    for k,v in pairs(self:getBadStatusList()) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            self.badStatusFlg = true
        end
    end

    if not self.badStatusFlg then
        self:addBuffList(unit)
    else
        self:removeBuffList(unit)
    end
    megast.Battle:getInstance():updateConditionView();
end

function class:getBadStatusList()
    local badStatusList = {
        89,90,91,92,93,94,95,96,97,129,131,135,
        201,202,203,204,205,206,207,208,233,234
    }
    return badStatusList
end

function class:addBuffList(unit)
    self:teamAddBuff(unit,self.BUFF_BOX_LIST[1])
    self:teamAddBuff(unit,self.BUFF_BOX_LIST[2])
end

function class:removeBuffList(unit)
    self:teamAddBuff(unit,self.BUFF_BOX_LIST[3])
    self:teamAddBuff(unit,self.BUFF_BOX_LIST[4])
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
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;