local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="人族の遺跡11層_聖樹弓神アシュ・トト(NORMAL)", version=2.7, id=2061201});
class:inheritFromEnemy("2061206");

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}

    -- 蘇生後はやらない
    if self.gameUnit:getParameter("revivalFlg") == "2" then
        self.TRIGGERS = {}
    end

    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:setIDs()
    -- 相方ミュゼのエネミーID
    self.summonEnemyID = 2061202
end

class:publish();

return class;