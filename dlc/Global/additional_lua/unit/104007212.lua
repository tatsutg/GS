local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒水着ミラ", version=1.3, id=104007212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1040072121,
            BUFF_ID = 17,---与ダメージアップ
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            SCRIPT = {
                SCRIPT_ID = 408,
                VALUE1 = 32,
                VALUE2 = self.damageRate
            }
        },
        [2] = {
            ID = 1040072122,
            BUFF_ID = 10,---奥義ゲージ自然上昇
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.abilityStopFLG = 190400
    self.damageRate = 2
    self.burstUpRate = 1/20
    self.saveValue32 = 0
    self.saveValue32other = 0
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local FLG = false
    ---命中率のバフ量を取得
    local value32 = event.unit:getTeamUnitCondition():findConditionValueIgnoreOther(32)
    if value32 < 0 then
        value32 = 0
    end
    local value32other = self:findEnemyConditionValueWithOther(event.unit,32);
    if value32other < 0 then
        value32other = 0
    end
    ---命中率バフ量に変化がある場合のみ動かす
    if self.saveValue32 ~= value32 then
        self.saveValue32 = value32
        FLG = true
    end
    if self.saveValue32other ~= value32other then
        self.saveValue32other = value32other
        FLG = true
    end
    if FLG then
        ---与ダメージアップ
        local buff1 = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if buff1 == nil then
            buff1 = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        end
        if value32 > 0 or value32other > 0 then
            buff1:setThumbnailID(26)
        else
            buff1:setThumbnailID(0)
        end
        buff1:setValue(value32 * self.damageRate)
        ---奥義ゲージ自然上昇
        local pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(10,1);
        local buff2 = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        local FLG_buff = event.unit:getTeamUnitCondition():findConditionWithID(self.abilityStopFLG);
        if FLG_buff == nil then
            if buff2 == nil then
                buff2 = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
            end
            if value32 > 0 then
                buff2:setThumbnailID(36)
            else
                buff2:setThumbnailID(0)
            end
            buff2:setValue(value32 * self.burstUpRate * pvpCorrectionValue)
        end
        ---バフアイコン更新
        megast.Battle:getInstance():updateConditionView();
    end
    return 1
end

function class:findEnemyConditionValueWithOther(unit,type)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    local value = 0
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            value = value + unit:getTeamUnitCondition():findConditionValueWithOther(type,myTeamUnit);
        end
    end
    return value;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
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

    return buff;
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;