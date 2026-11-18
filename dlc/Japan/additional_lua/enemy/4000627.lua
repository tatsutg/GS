local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.3, id=4000627});
enemy:inheritFromEnemy("4000647");

--通常時にかかるバフ内容
enemy.NORMAL_BUFF_ARGS = {
    {
        ID = 40071,
        EFID = 61,         --炎耐性
        VALUE = 40,        --効果量
        DURATION = 9999999,
        ICON = 38
    },
    {
        ID = 40072,
        EFID = 62,         --水耐性
        VALUE = 40,        --効果量
        DURATION = 9999999,
        ICON = 39
    },
    {
        ID = 40073,
        EFID = 63,         --樹耐性
        VALUE = 40,        --効果量
        DURATION = 9999999,
        ICON = 40
    },
    {
        ID = 40074,
        EFID = 65,         --闇耐性
        VALUE = 40,        --効果量
        DURATION = 9999999,
        ICON = 42
    }
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40076,
        EFID = 28,         --速度アップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    },
    {
        ID = 40077,
        EFID = 64,         --光耐性
        VALUE = 40,        --効果量
        DURATION = 9999999,
        ICON = 41
    }
}


enemy:publish();

return enemy;