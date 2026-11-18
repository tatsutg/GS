local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒美樹さやか", version=2.6, id=108317212});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self:setBuffBoxList();

    ---アビリティ：再起 Lv.2
    self.BUFF_ID = 10831701;
    self.iconUpdateTimer = 0;
    self.revivalStop = "2";
    if event.unit:getParameter("revivalFlg") == "" then
        event.unit:setParameter("revivalFlg","0");
        event.unit:setParameter("revivalStop",self.revivalStop);
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,37);
        buff:setNumber(tonumber(event.unit:getParameter("revivalStop")));
        megast.Battle:getInstance():updateConditionView();
    end
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("revivalFlg") == "" then
        event.unit:setParameter("revivalFlg","0");
        event.unit:setParameter("revivalStop",self.revivalStop);
    end

    if event.waves == 1 then
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,37);
        buff:setNumber(tonumber(event.unit:getParameter("revivalStop")));
        megast.Battle:getInstance():updateConditionView();
    end
    return 1;
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    if event.unit:getParameter("revivalFlg") == "" then
        event.unit:setParameter("revivalFlg","0");
        event.unit:setParameter("revivalStop",self.revivalStop);
    end

    local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,37);
    buff:setNumber(tonumber(event.unit:getParameter("revivalStop")));
    megast.Battle:getInstance():updateConditionView();
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---バフアイコン数値更新
    self.iconUpdateTimer = self.iconUpdateTimer + event.deltaTime;
    if self.iconUpdateTimer > 0.1 then
        self:updateBuffIcon(event.unit);
        self.iconUpdateTimer = 0;
    end
    ---アビリティ：再起 Lv.2
    self:checkRevivalBuff(event.unit);
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 3 then
        if event.unit:getHP() < 1 then
            event.unit:setHP(1);
        end
    end
    return 1;
end

function class:updateBuffIcon(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 3 then
        local num = math.ceil(cond:getTime());
        cond:setNumber(num);
        megast.Battle:getInstance():updateConditionView();
    end
end

function class:checkRevivalBuff(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond == nil then
        local nowFlg = tonumber(unit:getParameter("revivalFlg")) + 1;
        local maxFlg = tonumber(unit:getParameter("revivalStop"));
        if nowFlg < maxFlg then
            unit:setDeadSkillCount(nowFlg);
            local flgCount = maxFlg - nowFlg;
            unit:setParameter("revivalFlg",tostring(flgCount));
            local buff = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,37);
            buff:setNumber(flgCount);
            megast.Battle:getInstance():updateConditionView();
        end
    end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---復活から3秒間は死なない
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 3 then
        local damage = event.unit:getHP() - event.value;
        if damage < 1 then
            event.unit:setHP(1);
        end
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 3 then
        event.unit:setDeadSkillCount(-1);
        return 0;
    end

    self:addBuff(event.unit);
    event.unit:updateStatus();
    return 1;
end

function class:addBuff(unit)
    local buffTime = 3;
    if megast.Battle:getInstance():isPvp() then buffTime = 1; end
    local buff = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,buffTime,179);
    buff:setNumber(buffTime);
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    ---復活から3秒間は死なない
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 3 then
        event.unit:setHP(1);
        return 0;
    end
    return 1;
end

function class:isControll(unit)
    local ret = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
    if megast.Battle:getInstance():isPvp() then
        ret = true;
    end
    return ret;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    ---グループID関係1
    local targetCond = nil;
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond;
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond);
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return;
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
    return buff;
end


class:publish();

return class;