local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡_10層_Normal_天魔封神オージュ", version=2.5, id=2063990});
class:inheritFromEnemy("2063995");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK4 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL3 = 8,
    SKILL4 = 9
}


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [2] = {
            ID = 20639952,
            BUFF_ID = 56,  --暗闇耐性
            VALUE = self.GD.bufVal_56,
            DURATION = 999999,
            ICON = 62
        },
        [3] = {
            ID = 20639953,
            BUFF_ID = 105,  --暗闇回避
            VALUE = self.GD.bufVal_56,
            DURATION = 999999,
            ICON = 0
        },
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20639954,
            BUFF_ID = 112,  --状態異常耐性
            VALUE = self.GD.bufVal_112,
            DURATION = 999999,
            ICON = 77,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 20639955,
            BUFF_ID = 113,  --状態異常回避
            VALUE = self.GD.bufVal_112,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 99
        }
    }
    self.TG_BUFF_LIST = {
        [1] = {
            ID = 20639956,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.tgBufVal_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 20639957,
            BUFF_ID = 102,  --毒回避率
            VALUE = self.GD.hpBufVal_102,
            DURATION = 999999,
            ICON = 59
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "一定時間経過でダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒で遅延・暗闇で停止", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "暗闇状態中、ボスの命中率ダウン", COLOR = Color.yellow})
    }
    self.START_WAVE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_WAVE_MESSAGE1 or "瘴気があたりを包む", COLOR = Color.white})
    }
    self.DEBUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_MESSAGE1 or "暗闇回復・暗闇耐性アップ：ブレイクで解除", COLOR = Color.yellow})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "暗闇耐性ダウン", COLOR = Color.white})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "全状態異常耐性ダウン", COLOR = Color.red, isPlayer = true})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "毒耐性アップ", COLOR = Color.yellow})
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
            self.hpSkill = 4;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(15);
        self:showMessage(self.HP50_MESSAGE_LIST);
        self.spValue = self.GD.hp50AddSP;
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
        self:deBuffRefresh(self.gameUnit);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        hp50AddSP = 30,
        startAddSP = 0,
        attackDelay = 8,
        hitStop = 100,

        tgTimer = 20,
        tgLimit = 99,
        tgIconNum1 = 26,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.3,

        bufVal_56 = 200,
        bufVal_112 = -20,

        tgBufVal_17 = 30,

        hpBufVal_102 = 50
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

    -- 経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)

    ---ボスギミック
    self.isHard = false;
    self.deBuffFlg = false;
    self.tgTakeCount = 0;

    -- オージュ第二形態用
    local bossfire = BattleControl:get():addAnimation("FIRE","FIRE3",true);
    bossfire:setPositionX(-450);
    bossfire:setPositionY(-30);
    bossfire:setZOrder(30000);
    bossfire:setScale(1.2);
    return 1;
end

function class:doubleSaw (unit)
    local saw1 = unit:addOrbitSystemWithFile("skill3_EF","saw1");
    local saw2 = unit:addOrbitSystemWithFile("skill3_EF","saw2");
    saw1:setZOrder(8000);
    saw2:setZOrder(0);
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end


class:publish();

return class;