local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡_7層_光耀竜フォスラディウス", version=2.0, id=2064540});
class:inheritFromEnemy("2064545");


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 2064501,
            BUFF_ID = 17,  --与ダメージ
            VALUE = self.GD.buffVal_17_1,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 2064502,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.buffVal_13,
            DURATION = 999999,
            ICON = 4,
            COUNT = 0,
            MAX = 99
        }
    }
    self.ICON_BUFF_LIST = {
        [1] = {
            ID = 20645050,
            BUFF_ID = 0,  --物理耐性アイコン
            VALUE = 0,
            DURATION = 999999,
            ICON = 21
        },
        [2] = {
            ID = 20645051,
            BUFF_ID = 0,  --魔法耐性アイコン
            VALUE = 0,
            DURATION = 999999,
            ICON = 22
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "物理耐性", COLOR = Color.yellow}),
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "攻撃力ダウン", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "物理耐性ダウン", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "魔法耐性", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "フォトンブレス：ダメージ無効化無効", COLOR = Color.yellow})
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
            isEnableSkip = true
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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
            self.hpSkill = 2
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.cutInFLG = true
        self.gameUnit:setInvincibleTime(12)
        self:showMessage(self.HP50_MESSAGE_LIST)

        self.physicsDmgFlg = false
        self.magicDmgFlg = true
        self:execAddBuff(self.gameUnit,self.ICON_BUFF_LIST[2])
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.ICON_BUFF_LIST[1].ID)
        if cond ~= nil then
            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
        end
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.gameUnit:addSP(100)
        end
        self.gameUnit:setInvincibleTime(12)
        self:showMessage(self.HP0_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 0,
        attackDelay = 8,
        hitStop = 100,

        physicsDmgVal = 0.5,
        magicDmgVal = 0.5,

        buffVal_17_1 = 20,
        buffVal_13 = -10
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

    ---ボスギミック
    self.isHard = false
    self.physicsDmgFlg = false
    self.magicDmgFlg = false
    self.skill1Count = 0

    --光竜共通
    self.isLockOn = true
    self.neckAngle = 0
    self.shotAngle = 0
    self.isFireEnd = true
    self.fireSwitch = 1
    return 1
end


class:publish();

return class;