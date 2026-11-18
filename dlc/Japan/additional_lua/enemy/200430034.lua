--@additionalEnemy,200430030,200430031,200430032,200430033
local class = summoner.Bootstrap.createEnemyClass({label="水龍神　ウル＝メギア", version=1.3, id=200430034});
class:inheritFromUnit("dragonBase");

function class:initValues(event)
    --使うアイテムと呼ぶユニット
    --self.TEXTを使いたいため定数ではなく変数にして実態化してから作る
    --子クラス龍神たちはここを書き換えて使う
    self.items = {}
    self.summonUnits = {}

    --使うアイテム
    self.items[0] = {
        NAME = self.TEXT.ITEM1,
        ID = 102932100,
        INVINCIBLE = 0
    }
    self.items[1] = {
        NAME = self.TEXT.ITEM2,
        ID = 102941100,
        INVINCIBLE = 0
    }
    self.items[2] = {
        NAME = self.TEXT.ITEM3,
        ID = 104062100,
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

class:publish();

return class;