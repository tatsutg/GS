local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒西行寺幽々子", version=2.6, id=108367512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1083371122,
            BUFF_ID = 17,
            VALUE = 100,
            DURATION = 99999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 520,
                VALUE1 = 4
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit;
    event.unit:setDeadEffectWithFile("EAST_dead","dead");

    ---アビリティ：再起 Lv.1
    self.BUFF_ID = 10836701;
    self.iconUpdateTimer = 0;
    self.revivalStop = "1";
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
    ---アビリティ：再起 Lv.1
    self:checkRevivalBuff(event.unit);
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 3 then
        if event.unit:getHP() < 1 then
            event.unit:setHP(1);
        end
    end
    return 1
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

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    BattleControl:get():cancelChangeBackgroundMusic(event.unit);
    if event.index == 5 then
        BattleControl:get():changeBackgroundMusic("LOSTWORD_YUYUKO_ONESHOT",event.unit,1000,1000,0,true,0.8);
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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
    return buff
end

class:publish();

return class;