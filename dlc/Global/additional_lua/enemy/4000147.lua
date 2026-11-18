--@additionalEnemy,4000111,4000148,4000149,4000150,4000151
--[[
    神殿/冥蟲姫ラドアクネ/超級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="冥蟲姫ラドアクネ", version=1.5, id=4000147})
enemy:inheritFromEnemy(4000117)

enemy.BARRIER_HP_DEFAULT = 350000;

enemy.BUFF_ARGS = {
    [1] = {
        ID = 40001171,
        EFID = 31,         --回避率アップ
        VALUE = 90,        --回避率
        DURATION = 9999999,
        ICON = 16
    },
    [2] = {
        ID = 40001172,
        EFID = 7,         --自然回復
        VALUE = 5000,        --回復力毎秒
        DURATION = 9999999,
        ICON = 35
    }
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 17,         --ダメージアップ
        VALUE = 120,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40001174,
        EFID = 28,         --速度アップ
        VALUE = 35,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    }
}

--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000111] = 50,
    [4000148] = 50,
    [4000149] = 50,
    [4000150] = 50,
    [4000151] = 50
}

enemy.ATTACK_BUFFID = {
    93460800,
	93461000,
	83460200,
	83460500,
	83460600
}

--１度の召喚で呼ばれるユニットの最大数　１〜４で指定
enemy.SUMMON_CNT_MAX = 2;

function enemy:start(event)
    event.unit:setSPGainValue(0);
    self.spRizeValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.gameUnit = event.unit;
    self.barrier = nil;
    self.barrierHP = 0;
    self.barrierPreparation = true;
    self.isRage = false;

    --バリアの耐久表示用サブゲージ
    self.subBar = self:createSubBar(event.unit);

    self.hpMarkers = {
        [80] = self.gameUnit:addNumHpMarker(0.8),
        [50] = self.gameUnit:addNumHpMarker(0.5),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }
    self.HP_TRIGGERS = {
        [80] = "addBarrier",
        [50] = "addBarrier",
        [30] = "getRage"
    }

    return 1;
end

function enemy:removeBarrier(unit)
    self.barrier:takeAnimation(0,"wallBreak",false);

    self.barrier = nil;
    self.barrierHP = 0;

    for k,v in pairs(self.BUFF_ARGS) do
        Utility.removeUnitBuffByID(unit,v.ID);
    end
    self.BUFF_ARGS[1].ID = 4000117

    unit:takeDamage();
end

enemy:publish()
return enemy
