local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡12層_NORMAL_双頭魔獣ジンガルム", version=2.8, id=2064010});
class:inheritFromEnemy("2064015");

--使用する通常攻撃とその確率
--スキル1 -> スキル2 -> スキル3 -> スキル4 -> スキル5 -> スキル6 -> 繰り返し
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK3 = 100 },
        { ATTACK4 = 100 },
        { ATTACK5 = 100 },
        { ATTACK6 = 100 },
    },
}

--使用する奥義とその確率
--奥義8 -> 奥義9 -> 繰り返し
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL1 = 100 },
        { SKILL2 = 100 },
    },
}

--ACTIVE_SKILLS / cutInSkill は 2064015 と同じものを継承する


--------[[バフ]]--------
function class:setBuffBoxList()
    ---物理／魔法耐性（[1]=物理 [2]=魔法）
    ---NORMALはHP50%の1回のみなのでスタックしない（MAXを持たせない）
    self.RESIST_BUFF_LIST = {
        [1] = {
            ID = 206401501,
            BUFF_ID = 21,                       ---被ダメージ（負値＝軽減）
            VALUE = self.GD.resistVal_21,
            DURATION = 999999,
            ICON = 21,                          ---物理耐性
            SCRIPT = { SCRIPT_ID = 2 },         ---受けるダメージが物理のとき
        },
        [2] = {
            ID = 206401502,
            BUFF_ID = 21,
            VALUE = self.GD.resistVal_21,
            DURATION = 999999,
            ICON = 22,                          ---魔法耐性
            SCRIPT = { SCRIPT_ID = 3 },         ---受けるダメージが魔法のとき
        },
    }
end


--------[[メッセージ]]--------
function class:setMessageBoxList()
    ---戦闘開始時（白2件はHARDのみなので実装しない）
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
    }

    ---HP50%（[1]=物理 [2]=魔法　累計ダメージが大きかった方を出す）
    self.HP50_RESIST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_RESIST_MESSAGE1 or "物理耐性アップ・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_RESIST_MESSAGE2 or "魔法耐性アップ・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }

    ---トリガー番号 → 物理／魔法耐性メッセージ（NORMALはHP50%がトリガー1番）
    self.RESIST_MESSAGE_LIST = {
        [1] = self.HP50_RESIST_MESSAGE_LIST,
    }
end


--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
    }
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);                             ---状態異常を回復
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;                                       ---奥義10（SKILL3スロット）
            self.saveBP = self.gameUnit:getBurstPoint();             ---直前の奥義ゲージを引き継ぐ
            self.gameUnit:addSP(100);
        end
        self.spValue = self.GD.hp50AddSP;                           ---奥義ゲージ上昇量アップ
        self.gameUnit:setInvincibleTime(self.GD.hpInvincibleTime);
        self.hpSkillFLG = true;
        self.hpDmgMult = 0;                                         ---打ち終わるまでダメージ0・ブレイク0
        self:execResistBuff(1);                                     ---累計ダメージの大きい方の耐性アップ
    end
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
-- 継承元のテーブルは使えない（子で宣言しないとギミックカラムに項目が出ない）ため全項目を並べる。
-- NORMALはタイマー・召喚・エクストラゲージ・ピヨリを持たないので、その分のキーは持たない。
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 7,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---物理／魔法耐性アップ（HP50%の1回のみ）
        resistVal_21 = -50,         --耐性アップ量（負値＝被ダメージ軽減）

        ---HPフラグ
        hpInvincibleTime = 10,      --HPフラグ奥義中の無敵時間
        hp50AddSP = 25,             --HP50%以降のSP獲得量
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
    self.hpDmgMult = nil;

    ---物理／魔法の累計ダメージ
    self.physicalDamage = 0;
    self.magicDamage = 0;

    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
-- NORMALはタイマーを持たないので何もしない
function class:extraTimerOneRound(event)
    return event.count;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
-- NORMALはタイマー・召喚を持たないので後始末が不要
function class:dead(event)
    return 1;
end


----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);

    ---① HPフラグ奥義中はダメージ0
    if self.hpDmgMult ~= nil then
        event.value = math.floor(event.value * self.hpDmgMult);
    end

    ---② 物理／魔法の累計ダメージを集計（ホストのみ・HPフラグでリセット）
    if megast.Battle:getInstance():isHost() then
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            self.physicalDamage = self.physicalDamage + event.value;
        elseif attribute == 2 then
            self.magicDamage = self.magicDamage + event.value;
        end
    end

    ---③ HPフラグ境界でのダメージ調整（必ず最後）
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないため属性の判定はできない）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    elseif self.hpDmgMult ~= nil then
        event.value = math.floor(event.value * self.hpDmgMult);
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end


class:publish();

return class;
