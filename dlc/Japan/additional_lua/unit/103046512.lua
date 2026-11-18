local class = summoner.Bootstrap.createUnitClass({label="てんぷれさん", version=1.3, id=00000000});


class.BUFF_BOX_LIST = {
  [1] = {
    ID = 500211,
    EFID = 0,            --見た目だけのバフ
    VALUE = 1,
    DURATION = 120,
    ICON = 0,
    EFSKELETON = "unit/animation/10304ef.json",
    ANIMATION = "aura"
  }
}


function class:start(event)
    self.gameUnit = event.unit;
    return 1;
end

function class:run(event)
    if event.spineEvent == "deadEnd" then
        self:addBuff(self.gameUnit,self.BUFF_BOX_LIST);
    end
    return 1;
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
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.EFID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.EFID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
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
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end


class:publish();

return class;