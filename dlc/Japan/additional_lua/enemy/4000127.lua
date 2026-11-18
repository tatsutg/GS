--@additionalEnemy,4000111,4000148
--[[
    神殿/冥蟲姫ラドアクネ/中級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="冥蟲姫ラドアクネ", version=1.5, id=4000127})
enemy:inheritFromEnemy(4000117)

enemy.BARRIER_HP_DEFAULT = 80000;

--バリア時にかかるバフ内容
enemy.BUFF_ARGS = {
    {
        ID = 4000117,
        EFID = 31,         --回避率アップ
        VALUE = 60,        --回避率
        DURATION = 9999999,
        ICON = 16
    }
}

--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000111] = 50,
    [4000148] = 50
    --[4000149] = 50,
    --[4000150] = 50,
    --[4000151] = 50
}

enemy.ATTACK_BUFFID = {
    93440800,
	93441000,
	83440200,
	83440500,
	83440600
}

enemy:publish()
return enemy
