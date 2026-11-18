--@additionalEnemy,200430030,200430031,200430032,200430033
--@additionalItem,103462510,101062510,102121410
local class = summoner.Bootstrap.createUnitClass({label="龍神", version=1.3, id=599990001});

--属性回廊用龍神のベースクラス

class.ACTIVE_SKILLS = {

}

class.MESSAGE_COLOR = summoner.Color.cyan;



--=====================================================================================================
--初期化

function class:initValues(event)
    --使うアイテムと呼ぶユニット
    --self.TEXTを使いたいため定数ではなく変数にして実態化してから作る
    --子クラス龍神たちはここを書き換えて使う
    self.items = {}
    self.summonUnits = {}

    --使うアイテム
    self.items[0] = {
        NAME = self.TEXT.ITEM1,
        ID = 103462510,
        INVINCIBLE = 0
    }
    self.items[1] = {
        NAME = self.TEXT.ITEM2,
        ID = 101062510,
        INVINCIBLE = 0
    }
    self.items[2] = {
        NAME = self.TEXT.ITEM3,
        ID = 102121410,
        INVINCIBLE = 5
    }

    --呼ぶユニット
    self.summonUnits[0] = {
        INFO = self.TEXT.SUMMON1,
        ID = 200430030,
        MENY = 2,
        INVINCIBLE = 0
    }
    self.summonUnits[1] = {
        INFO = self.TEXT.SUMMON2,
        ID = 200430031,
        MENY = 2,
        INVINCIBLE = 10
    }
    self.summonUnits[2] = {
        INFO = self.TEXT.SUMMON3,
        ID = 200430032,
        MENY = 2,
        INVINCIBLE = 0
    }
    self.summonUnits[3] = {
        INFO = self.TEXT.SUMMON4,
        ID = 200430033,
        MENY = 3,
        INVINCIBLE = 10
    }

    self.hpTriggers = {
        [100] = {
            EVENT = "item",
            INDEX = 0
        },
        [90] = {
            EVENT = "summon",
            INDEX = 0
        },
        [70] = {
            EVENT = "summon",
            INDEX = 1
        },
        [50] = {
            EVENT = "summon",
            INDEX = 2
        },
        [49] = {
            EVENT = "item",
            INDEX = 0
        },
        [30] = {
            EVENT = "summon",
            INDEX = 3
        },
        [5] = {
            EVENT = "item",
            INDEX = 2
        }
    }

    self.currentIndex = 0;
    self.fullArtsCount = 0;
    self.counterRecat = 0;

    self.enemyArtsStates = {};

end

--=====================================================================================================
--デフォルトのイベント

function class:start(event)
    self:initValues(event);
    self:setItems(event.unit);
    self.hpMarkers = {}
    for index,trigger in pairs(self.hpTriggers) do
        if index ~= 100 then
            self.hpMarkers[index] = event.unit:addNumHpMarker(index * 0.01)
        end
    end

    return 1;
end


function class:takeAttack(event)

    return 1
end


function class:takeSkill(event)
 
    return 1
end

function class:update(event)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self:HPTriggersCheck(event.unit);
        self:fullArtsCheck(event.unit,event.deltaTime);
    end
    return 1;
end


--=====================================================================================================
function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end

function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end

--=====================================================================================================
--監視
function class:HPTriggersCheck(unit)
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.hpTriggers) do

        if i >= hpRate and self.hpTriggers[i] ~= nil then
            self:excuteTrigger(unit,self.hpTriggers[i]);
            self.hpTriggers[i] = nil;
            if i ~= 100 then
                unit:removeHpMarker(self.hpMarkers[i])
            end
        end
    end

end

function class:excuteTrigger(unit,triggerTable)
    if triggerTable.EVENT == "item" then
        self:useItem(unit,triggerTable.INDEX);
    elseif triggerTable.EVENT == "item2" then
        self:useItem(unit,triggerTable.INDEX);
        
    else
        self:summon(unit,triggerTable.INDEX);
    end
end


function class:fullArtsCheck(unit,deltaTime)
    self.counterRecat = self.counterRecat - deltaTime;
    for i = 0,5 do
        --指定されたインデックスでユニットを取得
        local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if uni ~= nil then
            if uni:getBurstState() == kBurstState_active and uni:getBurstState() ~= self.enemyArtsStates[i] then
                self.fullArtsCount = self.fullArtsCount + 1;
            end
            self.enemyArtsStates[i] = uni:getBurstState();
        end

    end
    if self.fullArtsCount >= 3 and self.counterRecat <= 0 then
        self.counterRecat = 2;
        self:useItem(unit,1);
        self.fullArtsCount = self.fullArtsCount -3;
    end
   
end

--=====================================================================================================
--アイテム使用関連のメソッド

function class:setItems(unit)
    for i = 0,table.maxn(self.items) do
        unit:setItemSkill(i,self.items[i].ID);
    end
end

function class:useItem(unit,index)
    unit:takeItemSkill(index);
    local infoText = self.items[index].NAME;
    summoner.Utility.messageByEnemy(infoText,5,self.MESSAGE_COLOR);
    if self.items[index].INVINCIBLE > unit:getInvincibleTime() then
        unit:setInvincibleTime(self.items[index].INVINCIBLE);
    end
end

--=====================================================================================================
--召喚関連のメソッド

function class:summon(unit,index)
    local summonTable = self.summonUnits[index];
    local cnt = summonTable.MENY;
    if summonTable.INVINCIBLE > unit:getInvincibleTime() then
        unit:setInvincibleTime(summonTable.INVINCIBLE);
    end
    
    --指定の場所が空席ならユニット召喚
    for i = 0,6 do
        if unit:getTeam():getTeamUnit(i) == nil and cnt > 0 then
            cnt = cnt - 1;
            unit:getTeam():addUnit(i,summonTable.ID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
        end
        
    end
    summoner.Utility.messageByEnemy(summonTable.INFO,5,self.MESSAGE_COLOR);
end


class:publish();

return class;
