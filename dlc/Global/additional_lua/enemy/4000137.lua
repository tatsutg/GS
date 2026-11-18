--@additionalEnemy,4000111,4000148,4000149
--[[
    神殿/冥蟲姫ラドアクネ/上級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="冥蟲姫ラドアクネ", version=1.5, id=4000137})
enemy:inheritFromEnemy(4000117)

enemy.BARRIER_HP_DEFAULT = 150000;

--バリア時にかかるバフ内容
enemy.BUFF_ARGS = {
    {
        ID = 4000117,
        EFID = 31,         --回避率アップ
        VALUE = 80,        --回避率
        DURATION = 9999999,
        ICON = 16
    }
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40001174,
        EFID = 28,         --速度アップ
        VALUE = 25,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    }
}

--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000111] = 50,
    [4000148] = 50,
    [4000149] = 50
    --[4000150] = 50,
    --[4000151] = 50
}

enemy.ATTACK_BUFFID = {
    93450800,
	93451000,
	83450200,
	83450500,
	83450600
}

enemy:publish()
return enemy
