local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="36章_真EX_超レオーネ", version=2.5, id=3605026});
class:inheritFromEnemy("3605029");


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 3605001,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.buffVal_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        }
    }
    self.TIME_BUFF_BOX = {
        [1] = {
            ID = 36050010,
            BUFF_ID = 22,  --クリティカル率
            VALUE = self.GD.tgBuffVal_22,
            DURATION = 999999,
            ICON = 11,
            COUNT = 0,
            MAX = 10
        }
    }
    self.HP_BUFF_BOX = {
        [1] = {
            ID = 3605002,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.hpBuffVal_13,
            DURATION = 999999,
            ICON = 3
        },
        [2] = {
            ID = 3605003,
            BUFF_ID = 21,  --魔法耐性
            VALUE = self.GD.hpBuffVal_21,
            DURATION = 999999,
            ICON = 22,
            SCRIPT = {
                SCRIPT_ID = 3
            }
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "我が花園へようこそ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "光属性・魔族からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "奥義ゲージ低下・反射耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過で大封印発動：病気・暗闇で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "毒状態のユニットの数が多いほどダメージアップ", COLOR = Color.yellow})
    }
    self.TIME_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIME_MESSAGE1 or "大封印-2.0：敵・味方の状態異常回復、回復数が多いほどクリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "虚無の世界より出でよ――", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "攻撃力・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "大封印-2.0＜グランド・ロスト＞――", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "魔法耐性アップ", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "この身は、朽ちぬ永劫の花――", COLOR = Color.yellow})
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
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
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
        self.hpSkill = 3;
        self.gameUnit:addSP(100);
        self:showMessage(self.HP50_MESSAGE_LIST);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_BOX[1]);
        self.spValue = self.GD.hp50AddSP;
    end
end

function class:hp20(status)
    if status == "use3" then
        self.hpSkill = 5;
        self.gameUnit:addSP(100);
        self:showMessage(self.HP20_MESSAGE_LIST);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_BOX[2]);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 10,
        startAddSP = 0,
        attackDelay = 8,
        hitStop = 100,
        hp50AddSP = 20,

        tgTimer = 60,
        tgLimit = 99,
        tgIconNum1 = 11,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.4,

        buffVal_17 = 10,
        hpBuffVal_13 = 50,
        hpBuffVal_21 = -30,
        tgBuffVal_22 = 3,

        deBuffDmgVal = {
            0.4,
            0.7,
            1.0,
            1.3
        }
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
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0

    --超レオーネ固有
    self.skill5FLG = false;
    self.orbitLeafRain = nil;
    self.orbitCanter = nil;

    -- 経過時間ギミック
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)

    --ボスギミック
    self.breakFlg = false;
    self.removeBuffCount = 0;
    self.buffIDList = {90,93,94,97,131};
    self.deBuffDmgVal = {};
    for i = 0,3 do
        self.deBuffDmgVal[i] = self.GD.deBuffDmgVal[i + 1];
    end
    return 1
end


class:publish();

return class;