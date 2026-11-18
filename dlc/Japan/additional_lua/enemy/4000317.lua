--@additionalEnemy,4000313,4000314
--[[
    神殿/植物/初級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="植物兄", version=1.5, id=4000317})
enemy:inheritFromEnemy(4000352)

enemy.skill2FixedDamage = 70;
--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000313] = 50,--コログラン    
    [4000314] = 50,--ログボード　     
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
        [1] = 4000313,
        [2] = 4000314
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
