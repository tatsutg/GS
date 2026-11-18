local class = summoner.Bootstrap.createUnitClass({label="ノエル", version=1.3, id=103206412});


class.BUFF_BOX_LIST = {
  [1] = {
    ID = 500211,
    BUFF_ID = 17,            --与ダメアップ
    VALUE = 50,
    DURATION = 120,
    ICON = 0,
    SCRIPT = 233,
    SCRIPTVALUE1 = 10320502,
    SCRIPTVALUE2 = 7,
    GROUP_ID = 3530,
    PRIORITY = 300,
    ONESHOT = true
  }
}


class.TARGET_BUFF_BOX_LIST = {--バフ剥がしの時に使うだけ
  [1] = {
    ID = 10320502,
  }
}

function class:start(event)
    self.gameUnit = event.unit;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:enemyCheck(event.unit)
    return 1
end

function class:enemyCheck(unit)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(10320502);
            if cond ~= nil then
                local stage = cond:getValue5()
                if stage == 0 then stage = 1 end
                myTeamUnit:setParameter("320_Kusabi",""..stage)
            else
                myTeamUnit:setParameter("320_Kusabi",""..0)
            end
        end
    end
end

function class:run(event)
    if event.spineEvent == "skill3End" then
        self:removeKusabi(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
    return 1;
end

function class:takeSkill(event)
    if event.index == 3 then
        self:addBuff(self.gameUnit,self.BUFF_BOX_LIST);
    end
    return 1;
end

function class:removeKusabi(unit)
    self:removeBuffs(unit,self.BUFF_BOX_LIST);
    for i = 0, 6 do
        local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if target ~= nil then
           self:removeBuffs(target,self.TARGET_BUFF_BOX_LIST);
        end
    end
end


--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:addBuffTimes(unit,buffs)
    for k,v in pairs(buffs) do
        local buff = unit:getTeamUnitCondition():findConditionWithID(v.ID);
        if buff ~= nil then
            buff:setTime(self.downTimer);
        end
    end
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
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

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end

    if buffBox.EFSKELETON ~= nil then
        buff:addAnimationWithFile(buffBox.EFSKELETON,buffBox.ANIMATION);
    end

    if buffBox.ONESHOT then
        buff:setRemoveOnResetState(true);
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
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end

    if buffBox.EFSKELETON ~= nil then
        buff:addAnimationWithFile(buffBox.EFSKELETON,buffBox.ANIMATION);
    end

    if buffBox.ONESHOT then
        buff:setRemoveOnResetState(true);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

function class:receive3(args)
    self:removeKusabi(self.gameUnit);
    return 1;
end


class:publish();

return class;