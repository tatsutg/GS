local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="リゼロ前半_真EX_ラインハルト", version=2.8, id=2081380});
class:inheritFromEnemy("2081390");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
}

class.cutInSkill = {
    [2] = 0,
    [3] = 1,
    [5] = 4
}

function class:setBuffBoxList()
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "騎士として、受けて立とう。", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "HPが50%以上のユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "HPが50%未満のユニットからの被ダメージダウン", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "人・神・魔族ユニットからの被ダメージアップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "正しいことをする。", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "与ダメージアップ", COLOR = Color.yellow}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "……やっかいだな。", COLOR = Color.red}),
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
        self.hpSkill = 5;
        self.saveBP = self.gameUnit:getBurstPoint();
        self.gameUnit:addSP(100);
        -- self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        self:showMessage(self.HP50_MESSAGE_LIST);
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
        damageUpValue = 1.2,
        damageDownValue = 0.2,
        hpSkillDamageRate = 0.2,
    })
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
    self.hpSkill = 0;
    self.saveBP = 0;

    self.breakFlg = false;
    self.hpSkillFLG = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);

    ---ボスギミック

    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
---HPトリガーがHP50だけなので、TRIGGERS[4]を参照する親のdeadは使わない
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    if event.index == 6 then
        event.unit:setNextAnimationName("skill5");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill5");
    end

    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100});---奥義使用後はリセットでスキル1からスタート
    return 1
end



class:publish();

return class;