local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡／天魔帥ゼ＝レムナ normal", version=1.3, id=2064530});
class:inheritFromEnemy("2064535")

function class:setMessageBoxList()
    self.elementName = {
        [0] = self.TEXT.ELEMENT0 or "無",
        [1] = self.TEXT.ELEMENT1 or "炎",
        [2] = self.TEXT.ELEMENT2 or "水",
        [3] = self.TEXT.ELEMENT3 or "樹",
        [4] = self.TEXT.ELEMENT4 or "光",
        [5] = self.TEXT.ELEMENT5 or "闇"
    }
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.LOCK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE1 or "%s属性をロック", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE2 or "ロックされたユニットの命中率ダウン", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false,
            isEnableSkip = false
        }
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

class:publish();

return class;