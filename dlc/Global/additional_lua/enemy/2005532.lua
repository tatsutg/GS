--@additionalEnemy,2005528,2005529,2005529,2005531
local class = summoner.Bootstrap.createEnemyClass({label="光龍神　アーク", version=1.3, id=2005532});
class:inheritFromUnit("dragonBase");
class.MESSAGE_COLOR = summoner.Color.yellow;
class.CRITICAL_BORDER = 150000;

function class:initValues(event)
    --使うアイテムと呼ぶユニット
    --self.TEXTを使いたいため定数ではなく変数にして実態化してから作る
    --子クラス龍神たちはここを書き換えて使う
    self.items = {}
    self.summonUnits = {}

    --使うアイテム
    self.items[0] = {
        NAME = self.TEXT.ITEM1,
        ID = 104562501,
        INVINCIBLE = 0
    }
    self.items[1] = {
        NAME = self.TEXT.ITEM2,
        ID = 104571501,
        INVINCIBLE = 0
    }
    self.items[2] = {
        NAME = self.TEXT.ITEM3,
        ID = 104582501,
        INVINCIBLE = 5
    }

    --呼ぶユニット
    self.summonUnits[0] = {
        INFO = self.TEXT.SUMMON1,
        ID = 2005528,
        MENY = 2,
        INVINCIBLE = 0
    }
    self.summonUnits[1] = {
        INFO = self.TEXT.SUMMON2,
        ID = 2005529,
        MENY = 2,
        INVINCIBLE = 10
    }
    self.summonUnits[2] = {
        INFO = self.TEXT.SUMMON3,
        ID = 2005530,
        MENY = 2,
        INVINCIBLE = 0
    }
    self.summonUnits[3] = {
        INFO = self.TEXT.SUMMON4,
        ID = 2005531,
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
        },
        [70.01] = {
            EVENT = "function",
            FUNCTION = self.criticalCheck 
        },
        [30.01] = {
            EVENT = "function",
            FUNCTION = self.criticalCheck 
        }
    }

    self.currentIndex = 0;
    self.fullArtsCount = 0;
    self.counterRecat = 0;
    self.enemyArtsStates = {};
    self.criticalDamage = 0;

end


function class:takeDamageValue(event)

    self:criticalDamageCheck(event);

    return event.value;
end

--=========================================================================================================================================
--闇龍神特有のトリガーを処理するためにオーバーライド

function class:excuteTrigger(unit,triggerTable)
    if triggerTable.EVENT == "item" then
        self:useItem(unit,triggerTable.INDEX);
    elseif triggerTable.EVENT == "item2" then
        self:useItem(unit,triggerTable.INDEX);
    elseif triggerTable.EVENT == "function" then
        triggerTable.FUNCTION(self,unit);
    else
        self:summon(unit,triggerTable.INDEX);
    end
end


--=========================================================================================================================================
--対クリティカルダメージ用メソッド

function class:criticalDamageCheck(event)
    if event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
        self.criticalDamage = self.criticalDamage + event.value;
    end
end

function class.criticalCheck(self,unit)
    if self.criticalDamage >= self.CRITICAL_BORDER then
        self.useItem(self,unit,2);
    end
    self.criticalDamage = 0;
    self.CRITICAL_BORDER = self.CRITICAL_BORDER + 50000;
end

class:publish();

return class;