local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒ミリム戦闘形態", version=1.3, id=107846112});
class:inheritFromUnit("107847112");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.checkFlg = false
    self.upFlg  = false
    self.skill2Flg = false
    self.skill3Flg = false
    self.skill5Flg = false
    self.skill3PowerPoint = 260
    self.skill3BreakPoint = 2500
    self.breakUpCount = 0
    self.breakUpCountMax = 4

    self:setBuffBoxList()
    return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.checkFlg then
        self.checkFlg = false
        self:checkFlgList(event.unit)
    end

    if self.skill2Flg then
        self.skill2Flg = false
        self.breakUpCount = 0
        event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
    elseif self.skill3Flg and self.upFlg then
        self.upFlg  = false
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setDamageRate(self.skill3PowerPoint)
            event.unit:getActiveBattleSkill():setBreakValue(self.skill3BreakPoint * self.breakUpCount)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            --local a = event.unit:getActiveBattleSkill():getDamageRate()
            --local b = event.unit:getActiveBattleSkill():getBreakValue()
            --summoner.Utility.messageByEnemy("Damage:"..a);
            --summoner.Utility.messageByEnemy("Break:"..b);
        end
    end
    return 1
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.checkFlg = true
    if event.index == 1 then
        self.skill2Flg = false
    elseif event.index == 2 then
        self.skill2Flg = true
    elseif event.index == 3 then
        self.upFlg = true
        self.skill2Flg = false
        self.skill3Flg = true
        self.breakUpCount = self.breakUpCount + 1
    end

    if self.breakUpCount >= self.breakUpCountMax then
        self.breakUpCount = self.breakUpCountMax
    end
    return 1
end


class:publish();

return class;