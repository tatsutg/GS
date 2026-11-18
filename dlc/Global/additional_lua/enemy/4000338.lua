--@additionalEnemy,4000333,4000334,4000347
--[[
    神殿/植物/上級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="植物兄", version=1.5, id=4000338})
enemy:inheritFromEnemy(4000352)

--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000333] = 50,--ラグドベイオス   奥義ゲージ吸収 
    [4000334] = 50,--モルドーラ　     大ダメージ
    [4000347] = 50,--メオール　       全体回復
}

--使用する奥義とその確率　[アニメーションの番号] = 重み　skill2は今回は不使用
enemy.SKILL_WEIGHTS = {
    [2] = 50,
    [3] = 50,
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40001171,
        EFID = 28,         --速度アップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    }
}

--２０秒チャレンジ失敗時にかかるバフ内容
enemy.SPECIAL_BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 17,         --攻撃アップ
        VALUE = 30,        --効果量
        DURATION = 50,
        ICON = 26
    },
    {
        ID = 40001174,
        EFID = 21,         --防御アップ
        VALUE = 50,        --効果量
        DURATION = 50,
        ICON = 20,
        EFFECT = 50009
    }
}

function enemy:start(event)
    event.unit:setSPGainValue(0);
    self.spRizeValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.gameUnit = event.unit;
    self.isRage = false;
    self.summonUpdateTimer = 0;
    self.firstSummon = true;
    self.hideTimer = 0;
    self.hideUpdateTimer = 0;
    self.criticalDamage = 0;--クリティカルで受けたダメージを覚えておく
    self.criticalCheckFlag = false;
    self.absorbFlg = false;
    self.engage = false; --交戦許可　隠れて戻ってくるまでの間は一切攻撃しないためのもの
    self.isShownFirstMessage = false;
    self.hpMarkers = {
        [60] = self.gameUnit:addNumHpMarker(0.6),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }
    self.HP_TRIGGERS = {
        [60] = "summon",
        [30] = "getRage"
    };

    self.firstSummonUnits = {
        [1] = 4000333,
        [2] = 4000334,
        [3] = 4000337
    };

    return 1;
end

function enemy:skillBranch(unit)
    local skillIndex = Random.sampleWeighted(self.SKILL_WEIGHTS);
    unit:takeSkill(skillIndex)
    return 0;
end

enemy:publish()
return enemy
