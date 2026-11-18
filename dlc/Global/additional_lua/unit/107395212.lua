local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="サンタリムル", version=1.3, id=107395212});
--------[[バフ]]--------
function class:setBuffBoxList(i)
    self.ANIMATIONS = {
        [1] = {
            [1] = {
                ANIMATION = "skill1",
                EF = "2-skill1",
                ID = 1073962121,
                BUFF = function(unit) unit:getTeamUnitCondition():addCondition(
                        1073952121,
                        10,
                        2,
                        5 + i,
                        36
                ) end
            },
            [2] = {
                ANIMATION = "skill1_2",
                EF = "skill1_2",
                ID = 1073962122,
                BUFF = function(unit) unit:getTeamUnitCondition():addCondition(
                        1073952122,
                        13,
                        15,
                        5 + i,
                        3
                ) end
            },
            [3] = {
                ANIMATION = "skill1_3",
                EF = "skill1_3",
                ID = 1073962123,
                BUFF = function(unit) unit:getTeamUnitCondition():addCondition(
                        1073952123,
                        7,
                        math.floor(unit:getCalcHPMAX() * 0.02),
                        5 + i,
                        self.gameUnit,
                        35
                ) end
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skillFlag = false
    self.skillCheckFLG = false
    self.surfaceIndex = 1

    self:setBuffBoxList(0)
    return 1
end



----// takeSkill //-----------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        event.unit:setNextAnimationName(self.ANIMATIONS[event.index][self.surfaceIndex].ANIMATION)
        event.unit:setNextAnimationEffectName(self.ANIMATIONS[event.index][self.surfaceIndex].EF)
        self:execAddBuff(event.unit,self.ANIMATIONS[event.index][self.surfaceIndex])
        self:moveSkill()
    end
    return 1
end


-----------------------------
function class:moveSkill()
    if self.surfaceIndex < 3 then
        self.surfaceIndex = self.surfaceIndex + 1
    else
        self.surfaceIndex = 1
    end
end

-----------------------------
function class:execAddBuff(unit,box)
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
        if teamUnit ~= nil then
            local b = teamUnit:getTeamUnitCondition():findConditionWithID(box.ID)
            if b == nil then
                box.BUFF(teamUnit)
            end
        end
    end
end



class:publish();

return class;