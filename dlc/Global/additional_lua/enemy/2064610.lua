local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡12層_NORMAL_焔巨砦ゴルマーグ", version=2.8, id=2064610});
class:inheritFromEnemy("2064615");

--使用する通常攻撃とその確率
--スキル1 -> スキル2 -> (スキル5 or スキル1 or スキル2) -> (スキル1 or スキル2) -> (スキル1 or スキル2) -> スキル5 -> 繰り返し
--NORMALはスキル3（ハンマー抜刀）・スキル4（ハンマー攻撃）を使用しない
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK5 = 50, ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK5 = 100 },
    },
}

--使用する奥義とその確率
--奥義9 -> 繰り返し
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---踏みつけ       (attack1)
    ATTACK2 = 2,    ---アッパー       (attack2)
    ATTACK5 = 5,    ---掴み           (attack5)
    ATTACK6 = 6,    ---投擲物         (goblin_ax／bone／iron-ball のオービット)
    ATTACK7 = 7,    ---毒瓶           (goblin_poison のオービット)
    ATTACK8 = 8,    ---掴み投げ       (掴みの throwEnd で当てる)
    SKILL2  = 9,    ---飛びかかる     (skill2)
    SKILL3  = 10,   ---飛びかかる・強 (skill2のアニメを流用／HP50%フラグ)
}

class.cutInSkill = {
}


--------[[バフ]]--------
-- NORMALはタイマー・一騎打ち・属性性質耐性を持たないのでターゲット用のみ
function class:setBuffBoxList()
    self.TARGET_BUFF_LIST1 = {
        ID = 206461501,
        BUFF_ID = 23,                       ---被クリティカル率
        VALUE = self.GD.targetCritRate,
        DURATION = 999999,
        ICON = 0                            ---ターゲットギミックのバフはアイコン不要
    };
    self.TARGET_BUFF_LIST0 = {
        ID = 206461501,                     ---TARGET_BUFF_LIST1と同じIDで打ち消す
        BUFF_ID = 23,
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
    };
end


--------[[メッセージ]]--------
function class:setMessageBoxList()
    ---戦闘開始時（HARDのみの2件は実装しない）
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "リーダーに対してターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ターゲットしたユニットに対して", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "CRI率アップ", COLOR = Color.yellow}),
    }

    ---HP50%
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
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
        self:refresh(self.gameUnit);                                ---停止系状態異常除去
        self:releaseGlab(self.gameUnit);                            ---掴み中なら中断（固定ダメージで倒れるのを防ぐ）
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;                                       ---奥義10 飛びかかる・強
            self.saveBP = self.gameUnit:getBurstPoint();             ---直前の奥義ゲージを引き継ぐ
            self.gameUnit:addSP(100);
        end
        self.hpSkillFLG = true;                                     ---打ち終わるまでブレイク不可
        self.spValue = self.GD.hp50AddSP;                           ---奥義ゲージ上昇量アップ
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
-- 継承元のテーブルは使えない（子で宣言しないとギミックカラムに項目が出ない）ため全項目を並べる。
-- NORMALはタイマー・一騎打ち・属性性質耐性・ハンマー状態を持たないので、その分のキーは持たない。
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 8,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---ターゲットギミック
        targetCritRate = 20,        --ターゲットに対するクリティカル率アップ%（被クリティカル率）

        ---HPフラグ
        hp50AddSP = 35,             --HP50%以降のSP獲得量

        ---掴み＆掴み投げ
        throwDownBP = 50,           --掴み投げの奥義ゲージDOWN量
        throwFixDmgBase = 1000,     --掴み投げの固定ダメージ（基礎）
        throwFixDmgAdd = 100,       --掴み投げの固定ダメージ（掴み回数ごとの加算）

        ---投射物（スキル6 投擲物 → スキル7 毒瓶 → 繰り返し）
        grenadeRecast = 8,          --投射の間隔秒数
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
    self.afterSkillFLG = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;

    ---ターゲットギミック（自動ヘイトは使わない）
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.targetIndex = -1;

    ---掴み関連
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    self.glabCount = 0;

    ---投射物関連
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    self.grenadeTurn = 1;               ---次に投げるもの（1=スキル6 投擲物 / 2=スキル7 毒瓶）
    self.grenadeKind = 1;               ---今のアニメで投げるもの
    self.grenadeFired = true;           ---1アニメで1回だけ発射するためのフラグ

    ---継承した処理が参照するだけのフラグ（NORMALはタイマー・一騎打ちを持たない）
    self.timeIndex = nil;
    self.tgDelayTime = 0;
    self.duelFLG = false;
    self.duelReserve = 0;

    ---武器状態（NORMALはハンマー抜刀を使わない）
    self.state = self.WEAPON_STATES.NONE;
    self.isRage = false;
    self.hummerAttackIndex = nil;

    event.unit:addSubSkeleton("50003_leg",-30);
    event.unit:setSkin("1");
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    ---ターゲットギミック
    self:targetOperation(event.unit);

    ---掴み投げ
    if self.isGlab and self.glabTargetIndex ~= nil then
        ---掴み中に奥義が発生した場合の対策
        if event.unit:getUnitState() == kUnitState_skill then
            self:throwEnd(event.unit);
        else
            self:glabControll(event.unit);
        end
    end

    ---投擲物・毒瓶
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:grenadeCheck(event.deltaTime);
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
-- NORMALはタイマー・一騎打ちを持たないので後始末が不要
function class:dead(event)
    return 1;
end

function class:receive4(args)
    return 1;
end

---------------------------------------------------------------------------------
-- receive9（NORMALはタイマーを持たないので何もしない）
---------------------------------------------------------------------------------
function class:receive9(args)
    return 1;
end


----// takeDamageValue //-----------------------------------------------------------------------------
-- NORMALは一騎打ち・属性性質耐性を持たない
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---HPフラグ境界でのダメージ調整
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end


class:publish();

return class;
