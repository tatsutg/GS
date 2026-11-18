local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="人族の遺跡10層_NORMAL_ジオ＝ザグナス", version=2.6, id=2061190});
class:inheritFromEnemy("2061195");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    },
    HUMMER = {
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL10 = 3,  --ハンマー抜刀
    ATTACK4 = 4,
    ATTACK5 = 5,  --掴み
    ATTACK6 = 6,  --投擲物
    ATTACK7 = 7,  --毒瓶
    ATTACK8 = 8,  --掴み投げ
    SKILL1 = 9,
    SKILL2 = 10
}


class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 6
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 6
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 6
    },
    POISON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 7
    }
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 20611951,
            BUFF_ID = 112,  --状態異常耐性
            VALUE = self.GD.buffVal_112,
            DURATION = 999999,
            ICON = 77,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 20611952,
            BUFF_ID = 113, --状態異常回避率
            VALUE = self.GD.buffVal_112,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 99
        }
    }
    self.STUN_BUFF_LIST = {
        ID = 2061199,
        BUFF_ID = 89,  --気絶効果
        VALUE = 100,
        DURATION = self.GD.buffTime_89,
        ICON = 79
    }
end


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
    }
    self.HUMMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE1 or "ハンマー状態：魔法ダメージで解除", COLOR = Color.white})
    }
    self.HUMMER_LOST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_LOST_MESSAGE1 or "ハンマー状態解除成功！", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "状態異常耐性ダウン", COLOR = Color.red, isPlayer = true})
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
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP50_MESSAGE_LIST);
        self.gameUnit:setAttackDelay(self.GD.hpAttackDelay);
        self.hpFlg = true;
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        startAddSP = 0,
        attackDelay = 8,
        hitStop = 100,
        hpAttackDelay = 5,

        grenadeRecast = 5,
        hummerOnDmgVal = 0.01,
        subHpRate1 = 0.2,

        buffVal_112 = -30,
        buffTime_89 = 3
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---サブHPギミック
    self.subBarFlg = false;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = 0;---サブバーのHP
    self.damage = 0;---サブバー表示時のダメージ

    ---ボスギミック
    self.attackFlg = false;
    self.hpFlg = false;
    self.hpSkillFlg = false;
    self.hp50Flg = false;
    self.throwSetter = 0;
    self.takeHummerCount = 0;
    self.targetElement = nil;

    ---投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    ---武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();
    ---足関係
    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    --HPトリガー後のハンマー抜刀
    if event.unit:getUnitState() ~= kUnitState_skill and self.hpSkillFlg then
        self.hpSkillFlg = false;
        self.hpSkill = 10;
        self.saveBP = self.gameUnit:getBurstPoint();
        self.gameUnit:addSP(100);
    end
    --サブバーギミック
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end
    --投擲物関係
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:grenadeCheck(event.deltaTime);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---ハンマーギミックのダメージ補正
    if self.subBarFlg then
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if self.takeHummerCount == 1 then
            --魔法ダメージ
            if attribute == 2 then
                self.damage = self.damage + event.value;
            end
        end
        event.value = 1;
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

--===============================================================================================================================================
--投擲物関連のメソッド/
------------------
function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GD.grenadeRecast and self:isHost() then
        self.grenadeTimer = 0;
        self.throwSetter = self.throwSetter + 1;
        if self.throwSetter > 2 then self.throwSetter = 1; end
        if self.throwSetter == 1 then
            self:takeOtherAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
        else
            self:takePoizonGrenadeAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        end
    end
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POISON);
end

--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    unit:setSetupAnimationName("setUpWeapon");
    self:initAttackWeight({HUMMER = 100});
    self.subBarFlg = true;
    self.damage = 0;

    --メッセージ関連
    local iconNum = 0;
    self.takeHummerCount = self.takeHummerCount + 1;
    self:showMessage(self.HUMMER_MESSAGE_LIST,self.takeHummerCount);
    if self.takeHummerCount == 1 then
        iconNum = 11;
        self.SUB_HP = unit:getCalcHPMAX() * self.GD.subHpRate1;---サブバーのHP
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    self:initAttackWeight({DEFAULT = 100});
    self:showMessage(self.HUMMER_LOST_MESSAGE_LIST);

    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setReduceHitStop(0,0);--ヒットストップ無効解除
    unit:setSkin("1");

    --気絶効果付与
    self:execAddBuff(unit,self.STUN_BUFF_LIST);
end


class:publish();

return class;