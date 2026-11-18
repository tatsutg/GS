local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="27章normal聖騎士ロイ", version=1.3, id=2704003});
class:inheritFromEnemy("2704013");

function class:setMessageBoxList()
    self.TRUE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_MESSAGE1 or "レイアス、お前が最後のピースだ", COLOR = Color.cyan})
    }
    self.FALSE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_MESSAGE1 or "ようやく始められる", COLOR = Color.cyan})
    }
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射耐性", COLOR = Color.yellow})
    }
    self.TRUE2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE2_MESSAGE1 or "レイアスをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE2_MESSAGE2 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "氷結耐性低下", COLOR = Color.red})
    }
    self.TRUE_HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_HP80_MESSAGE1 or "レイアス、全力で来い……！", COLOR = Color.cyan})
    }
    self.FALSE_HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_HP80_MESSAGE1 or "聖剣グラディウスよ", COLOR = Color.cyan})
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "与ダメージ・物理回避率アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "お前の動きは覚えた", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "鉄壁状態：ブレイクで解除", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "さあ、罪を暴き出せ", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.TRUE_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_DEAD_MESSAGE1 or "レイアス、真なる王に……さぁ……", COLOR = Color.cyan})
    }
    self.FALSE_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_DEAD_MESSAGE1 or "あと一手だと言うのに……", COLOR = Color.cyan})
    }
end

function class:setTriggerList()
    self.TRIGGERS = {
    }

    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

---レイアスサーチ
function class:findTheProtagonist(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getBaseID() == 10101 then
                --[[
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.TARGET_BUFF_LIST1.ID);
                if cond == nil then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                    unit:setHateTarget(myTeamUnit)
                    unit:updateHateTarget();
                end
                ]]--
                return true
            end
        end
    end
    return false
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 5;---addSPの量
    event.unit:setAttackDelay(1);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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
    if self:findTheProtagonist(event.unit) then
        self:showMessage(self.TRUE_MESSAGE_LIST)
        self.isProtagonist = true
        event.unit:setBattleStartVoice("VOICE_BATTLESTART_B")
    else
        self:showMessage(self.FALSE_MESSAGE_LIST)
        self.isProtagonist = false
    end
    self:showMessage(self.START_MESSAGE_LIST)
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    self.saveBP = 0

    self.hp0FLG = true

    self.breakFLG = false

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    return 1
end

class:publish();

return class;