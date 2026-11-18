local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="30章フレイダル normal", version=1.3, id=3005013});
class:inheritFromEnemy("3005014");

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {

    }
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

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "水属性耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "毒・燃焼状態のとき、被ダメージアップ", COLOR = Color.yellow})
    }
    self.ATTACK6_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ATTACK6_MESSAGE1 or "いてつく強風が吹き荒れる", COLOR = Color.cyan})
    }
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    if self.attack6FLG then
        self.attack6FLG = false
        local stun = event.unit:getTeamUnitCondition():findConditionValue(89);
        local paralyze = event.unit:getTeamUnitCondition():findConditionValue(91);
        if stun == 0 and paralyze == 0 then
            self:showMessage(self.ATTACK6_MESSAGE_LIST)
            self:enemyDamage(event.unit)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

class:publish();

return class;