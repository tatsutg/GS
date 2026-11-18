local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒エキドナ", version=2.8, id=108446312});
class:inheritFromUnit("108447312");


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 108447312,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1.8,
            ICON = 0
        }
    }
    self.SKILL_BUFF_BOX = {
        [1] = {
            ID = -1084463121,
            BUFF_ID = 21,
            VALUE = 25,
            DURATION = 60,
            ICON = 175,
            SCRIPT = {
                SCRIPT_ID = 3
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.abilityLevel = 1;
    self.runReraiseFLG = false;
    self.reraiseTimeFLG = false;
    self:setBuffBoxList();

    --奥義効果
    self.skill2Flg = false;
    self.skillBuffFlg = {};
    for i = 0,7 do
        self.skillBuffFlg[i] = false;
    end
    return 1;
end



class:publish();

return class;