local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒エレンス", version=1.3, id=104097312});

function class:start(event)
    self.gameUnit = event.unit
    self.tenSeconds = math.ceil(BattleControl:get():getTime() / 10)
    return 1;
end

--version1.1
function class:update(event)
    if not self:findAnother(event.unit) then
        if math.ceil(BattleControl:get():getTime() / 10) > self.tenSeconds then
            self.tenSeconds = math.ceil(BattleControl:get():getTime() / 10)
            --summoner.Utility.messageByEnemy(self.tenSeconds)
            self:HealAndAddSP(event.unit,0.25,50)
        end
    end
    return 1;
end

function class:findAnother(unit)
    local myTeam = unit:getTeam()
    local index = unit:getIndex() - 1
    if index >= 0 then
        for i = 0,index do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getBaseID() == unit:getBaseID() then
                    return true
                end
            end
        end
    end
    return false
end

function class:HealAndAddSP(unit,healRate,addSP)
    local myTeam = unit:getTeam()
    local targetUnit = nil
    local minSP = 99999
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if minSP > myTeamUnit:getBurstPoint() then
                minSP = myTeamUnit:getBurstPoint()
                targetUnit = myTeamUnit
            end
            local rate = 1 + myTeamUnit:getTeamUnitCondition():findConditionValue(110)/100;--回復量アップ
            local rate2 = 1 + unit:getTeamUnitCondition():findConditionValue(115)/100;--回復力アップ
            myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX() * healRate * rate * rate2,unit)
        end
    end
    if targetUnit then
        targetUnit:addSPWithPvpCorrection(addSP)
    end
end

class:publish();

return class;