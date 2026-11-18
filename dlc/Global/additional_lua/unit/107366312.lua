local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ラム", version=1.3, id=107376312});

function class:start(event)
    self.subaru:init(event,self);
    return 1;
end

function class:startWave(event)
    if event.waves == 1 and not megast.Battle:getInstance():isPvp() then
        local luck = event.unit:getLuckLevel();
        event.unit:addSPWithPvpCorrection(luck);
    end
    return 1;
end


function class:takeSkill(event)
    --self.subaru:takeSkill(event);
    return 1;
end

function class:run(event)
    self.subaru:run(event);
    return 1;
end


--===============================================================================================================================================
-- スバルクラス
--===============================================================================================================================================

class.subaru = {}

--キャラによって奥義か新奥義かどっちでスバルが出るか違うらしいのでここで指定
class.subaru.BuffTargetSkillIndex = 3;

--バフかけ対象の列挙
class.subaru.targetType = {
    myself = 1,
    party = 2,
    enemys = 3
}


--バフ　適当
class.subaru.BUFF_ARGS = {
    -- [1] = {
    --     ID = 1030802,
    --     BUFF_ID = 8,
    --     VALUE = 10,
    --     DURATION = 1,
    --     ICON = 0
    -- }
}


--バフをかける対象　上記の列挙から選択してね！
class.subaru.buffTarget = class.subaru.targetType.party;

class.subaru.CHECK_BUFF_ID = 50244400;

function class.subaru:init(event,parentClass)
    self.parent = parentClass;
end

--function class.subaru:takeSkill(event)
--    if event.index == self.BuffTargetSkillIndex then
--        self:checkBuff(event);
--    end
--end

function class.subaru:run(event)
    if event.spineEvent == "call" then
        self:checkBuff(event);
    end

    if event.spineEvent == "addBuff" then
        self:addSpecialBuff(event.unit);
    end
    if event.spineEvent == "voice" then
        self:voice(event.unit);
    end
end

function class.subaru:addSpecialBuff(unit)


        --ラムはSP増加なのでここで直
        unit:addSPWithPvpCorrection(30);
   

    
end

function class.subaru:checkBuff(event)
    if event.unit:getTeamUnitCondition():findConditionWithID(self.CHECK_BUFF_ID) ~= nil then
        self:call(event);
    end
end


function class.subaru:call(event)
    local rand = Random.range(1,4);--1~3までの乱数
    local animationName = "736"..rand;
    local orbit = event.unit:addOrbitSystemWithFile("107385512",animationName);
    orbit:setPosition(0,0);
    
end



--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return;
            end
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local buff = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    buff:setGroupID(buffBox.GROUP_ID);
    buff:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       buff:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end


class:publish();

return class;