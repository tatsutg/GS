--@additionalEnemy,2064612
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡12層_NORMAL_ハイゴブル", version=2.8, id=2064611});
class:inheritFromEnemy("2064616");

---召喚するゴブルのエネミーID
class.SUMMON_ENEMY_ID = 2064612;

--使用する通常攻撃とその確率
--スキル1 -> 繰り返し
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK2 = 100 },                              ---スキル1 ヒートスイング
    },
}

--使用する奥義とその確率
--奥義2 -> 繰り返し
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },                               ---奥義2 サウザンドストライク
    },
}

---NORMALは奥義3（ミリオンズストライク）を持たない
class.ACTIVE_SKILLS = {
    ATTACK2 = 1,    ---ヒートスイング       (skill1のアニメを流用)
    SKILL2  = 2,    ---サウザンドストライク (skill2)
}

class.cutInSkill = {
}


--------[[バフ]]--------
-- NORMALはダメージ耐性・ゴブル撃破カウントを持たないので討伐報酬のみ
function class:setBuffBoxList()
    self.REWARD_BUFF_LIST = {
        [1] = {
            ID = 206461603,
            BUFF_ID = 13,                       ---攻撃力
            VALUE = 0,                          ---撃破時に経過時間から算出して上書きする
            DURATION = 999999,
            ICON = 3,
        },
        [2] = {
            ID = 206461604,
            BUFF_ID = 15,                       ---防御力
            VALUE = 0,
            DURATION = 999999,
            ICON = 5,
        },
    }
end


--------[[メッセージ]]--------
function class:setMessageBoxList()
    ---戦闘開始時（HARDのみの3件は実装しない）
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ハイゴブルを早く倒すほどパーティの攻撃力・防御力アップ", COLOR = Color.yellow}),
    }

    ---ハイゴブル撃破時（ユニット側）
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "パーティの攻撃力・防御力%d%%アップ", COLOR = Color.white, isPlayer = true}),
    }
end


--------[[特殊行動]]--------
-- NORMALはHPフラグを持たない
function class:setTriggerList()
    self.TRIGGERS = {};
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
-- 継承元のテーブルは使えない（子で宣言しないとギミックカラムに項目が出ない）ため全項目を並べる。
-- NORMALはダメージ耐性・HPフラグを持たないので、その分のキーは持たない。
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 4,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---召喚ギミック
        summonNum = 1,              --奥義2発動ごとに召喚する数
        summonMax = 6,              --場に維持できるゴブルの最大数

        ---討伐報酬（攻撃力・防御力 [rewardBase - 経過秒×rewardDecay]%／最低保証 rewardMin%）
        rewardBase = 200,           --基礎値%
        rewardDecay = 2,            --経過1秒あたりの減少%
        rewardMin = 10,             --最低保証%
    };
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, self:getGimmickDefault());
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;

    ---召喚ギミック
    self.friendCount = 0;
    self.goburuKillCount = 0;
    self.rewardDone = false;

    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
-- NORMALはゴブル撃破カウントを持たない
function class:update(event)
    self:findFriend();
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
-- 経過時間の判定はホストのみ。効果量をゲストへ配って揃える
function class:dead(event)
    self:killAllGoburu();
    if megast.Battle:getInstance():isHost() then
        local rate = self:calcRewardRate();
        self:execReward(rate);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,rate);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- receive6（討伐報酬の効果量同期）
---------------------------------------------------------------------------------
function class:receive6(args)
    self:killAllGoburu();
    self:execReward(args.arg);
    return 1;
end


----// takeDamageValue //-----------------------------------------------------------------------------
-- NORMALはダメージ耐性を持たない
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    return event.value;
end


class:publish();

return class;
