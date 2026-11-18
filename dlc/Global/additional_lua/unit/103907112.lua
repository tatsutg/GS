local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ヴェルザード", version=1.9, id=103907112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1039701,
            BUFF_ID = 17, --与ダメ
            VALUE = 60,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 5
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.CHECK_ID = 103907
    self.checkTimer = 0
    self.skill1Flg = false
    self.skillAddSPValue = 25
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---敵死亡判定
    self:checkDeath3(self:getAncestorUnit(event.unit),event.deltaTime)
    return 1
end

function class:checkDeath3(unit,deltaTime)
    self.checkTimer = self.checkTimer + deltaTime
    if  self.checkTimer < 0.2 then return end
    self.checkTimer = self.checkTimer - 0.2
    local targetList =  self:getTargetList(unit)
    for _,index in pairs(targetList) do
        if self:deadOrNew(unit,index) then
            self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
            self:cleanUpTargetParam(unit,index);
        end
    end
    --self:influenceLastAttackChecker(unit);
end

function class:receive1(args)
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
    return 1
end

function class:getTargetList(unit)
    local key = self:createKey("lastAttackChecker",unit:getIndex(),"index")
    local lst = {}
    for i=0,7 do
        local param = unit:getParameter(key..i);
        if param ~= "" and param ~= nil and param ~= "error" then
            local lastAttackerIndex = tonumber(param);
            if lastAttackerIndex == unit:getIndex() then
                table.insert(lst,i);
            end
        end
    end
    return lst
end

function class:createKey(key,index,key2)
    return key .. index .. key2
end

function class:deadOrNew(unit,index)
    local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index,true)
    local buffID = self.CHECK_ID + unit:getIndex();
    if target ~= nil then
        local buff = target:getTeamUnitCondition():findConditionWithID(buffID);
        if buff == nil then
            return true;
        end
    end
    return target == nil or target:getHP() <= 0;
end

function class:execAddStatus(unit,value)
    self.BUFF_BOX_LIST[1].VALUE = value
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
end

function class:cleanUpTargetParam(unit,index)
    local key = self:createKey("lastAttackChecker",unit:getIndex(),"index")
    unit:setParameter(key..index,"-1");
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.skill1Flg = false
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skill1Flg = true
    elseif event.index == 2 then
        self.skill1Flg = false
    elseif event.index == 3 then
        self.skill1Flg = false
    elseif event.index == 5 then
        self.skill1Flg = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    self:influenceLastAttackChecker(event.unit)
    --skill1効果
    if self.skill1Flg then
        self:skill1AddSP(event.unit)
    end
    return event.value
end

function class:influenceLastAttackChecker(unit)
    if not megast.Battle:getInstance():isHost() then return end
    local buffID = self.CHECK_ID + unit:getIndex();
    for i=0,7 do
        local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i,true);
        if target ~= nil then
            local buff = target:getTeamUnitCondition():findConditionWithID(buffID);
            if buff == nil and target:getHP() > 0 then
                buff = target:getTeamUnitCondition():addCondition(buffID,21,1,99999,0);
                buff:setScriptID(179);
                buff:setValue1(unit:getIndex());
            end
        end
    end
end

function class:skill1AddSP(unit)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        self.skill1Flg = false
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:addSPWithPvpCorrection(self.skillAddSPValue);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    self:influenceLastAttackChecker(self:getAncestorUnit(event.unit))
    return event.value
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_orbit_skill5" then
        event.unit:addOrbitSystem("orbit_skill5",0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self.skill1Flg = false
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

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end


class:publish();

return class;