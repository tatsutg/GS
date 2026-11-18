local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="フリーレンコラボ_フェルン", version=1.8, id=108216212});
class:inheritFromUnit("108217212");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1082101,
            BUFF_ID = 0,  --真奥義ダメージ倍率増加(iconのみ)
            VALUE = 0,
            DURATION = 999999,
            ICON = 31,
            COUNT = 0,
            MAX = 5
        },
    }
end

class.skill3PowerPoint = 500; -- 真奥義ダメージ率基礎値

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skill3Flg = false
    self.skill3Cnt = 0
    self.skill3removeFlg = false
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)

    if self.skill3Flg then
        self.skill3Flg = false
        self.skill3Cnt = self.skill3Cnt + 1
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        if self.skill3Cnt > 5 then
            self.skill3Cnt = 5
        elseif self.skill3Cnt <= 0 then
            self.skill3Cnt = 1
        end
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setDamageRate(self.skill3PowerPoint * self.skill3Cnt)
        end
    end

    if self.skill3removeFlg then
        self.skill3removeFlg = false
        self.skill3Cnt = 0
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(cond);
        end
    end

    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.skill3removeFlg = true
    elseif event.index == 3 then
        self.skill3Flg = true
        self.skill3removeFlg = false
    end
    return 1
end

class:publish();

return class;