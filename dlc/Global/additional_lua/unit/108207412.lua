local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_フリーレン", version=1.8, id=108207412});

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
    self.skill1Flg = false;
    self:setBuffBoxList();
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill1Flg then
        self.skill1Flg = false;
        self:checkUnitBuff(event.unit,21,139);
    end
    return 1
end

function class:checkUnitBuff(unit,buffType,thumbnailId)
    --自分PTからみて味方PTを取る
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    --PT全体バフチェック
    local targetTbl = {};
    for i = 0,7 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if self:checkIconCondition(myTeamUnit,buffType,thumbnailId) then
                table.insert(targetTbl,myTeamUnit);
                --summoner.Utility.messageByEnemy(myTeamUnit:getIndex());
            end
        end
    end

    if #targetTbl == 0 then
        return;
    end

    --対象をランダムで抽選してバフを解除
    if self:isHost() then
        local rand = math.random(1,#targetTbl);
        for i, targetUnit in pairs(targetTbl) do
            if i == rand then
                self:removeIconCondition(targetUnit,thumbnailId);
                megast.Battle:getInstance():sendEventToLua(self.scriptID,1,targetUnit:getIndex())
                return;
            end
        end
    end
end

function class:checkIconCondition(unit,buffType,thumbnailId)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getConditionTypeAsInt() == buffType and cond:getThumbnailID() == thumbnailId and cond:getNumber() <= 0 then
                return true;
            end
        end
    end
    return false;
end

function class:removeIconCondition(unit,thumbnailId)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getThumbnailID() == thumbnailId and cond:getNumber() <= 0 then
                cond:setThumbnailID(0);
                cond:setTime(0); --バフ除去
                break;
            end
        end
    end
end

function class:isHost()
    local bool = false;
    if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
        bool = true;
    end
    return bool;
end

function class:receive1(args)
    local unitTeam = self.gameUnit:getTeam();
    local targetTeam = nil;
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    for i = 0,7 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == args.arg then
                self:removeIconCondition(myTeamUnit,139);
                return 1;
            end
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skill1Flg = true;
    elseif event.index == 2 then
        self.skill1Flg = false;
    elseif event.index == 3 then
        self.skill1Flg = false;
    elseif event.index == 5 then
        self.skill1Flg = false;
        if self:checkSize(event.unit,3) then
            event.unit:setNextAnimationName("skill5_Boss");
            event.unit:setNextAnimationEffectName("2-skill5-boss");
        end
    end
    return 1
end

-- 敵のサイズをチェックする。ユニットは1、大型ボスは3
function class:checkSize(unit,size)
    local targetUnit = unit:getTargetUnit();
    if targetUnit ~= nil and targetUnit:getSize() == size then
        return true;
    end
    return false;
end



class:publish();

return class;