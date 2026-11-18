local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="人族の遺跡_11層_NORMAL_猛餓禁樹ゴールドーラ", version=2.6, id=2061200});
class:inheritFromEnemy("2061205");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL3 = 8
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 20612001,
            BUFF_ID = 109,  --燃焼回避
            VALUE = self.GD.hpBuffVal_109,
            DURATION = 999999,
            ICON = 66,
            COUNT = 0,
            MAX = 3
        },
        [2] = {
            ID = 20612002,
            BUFF_ID = 105,  --暗闇回避
            VALUE = self.GD.hpBuffVal_105,
            DURATION = 999999,
            ICON = 62,
            COUNT = 0,
            MAX = 3
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 206120010,
            BUFF_ID = 21, -- 被ダメージ
            VALUE = self.GD.skillBuffVal_21,
            DURATION = 999999,
            ICON = 139,
            COUNT = 0,
            MAX = 99
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "チューイングローズ：%dの固定ダメージ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE2 or "チューイングローズ・改：%dの固定ダメージ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度・奥義ゲージ上昇量アップ", COLOR = Color.yellow})
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
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP50_MESSAGE_LIST);
        self:refreshAll(self.gameUnit);
        self:setHpBuff(self.gameUnit);
        self.spValue = self.GD.hpAddSP;
        self.gameUnit:setAttackDelay(self.GD.hpAttackDelay);
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
        hpAddSP = 35,
        hpAttackDelay = 5,

        skillFixDmg1 = 2000,
        skillFixDmg2 = 4000,

        skillBuffVal_21 = 5,
        hpBuffVal_105 = 25,
        hpBuffVal_109 = 25
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

    self.stateName = "NORMAL";
    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;

    --attack3はaddSPしないのでその対策
    self.addSpFLG = false;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1;
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

    if event.index == 1 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
        self:takeDeBuff();
        self:takeFixDamage(self.GD.skillFixDmg1);
        self:showFormatMessage(self.SKILL1_MESSAGE_LIST[1],self.GD.skillFixDmg1);
    elseif event.index == 2 then
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("1-skill3");
        self:takeDeBuff();
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
        self:takeDeBuff();
        self:takeFixDamage(self.GD.skillFixDmg2);
        self:showFormatMessage(self.SKILL1_MESSAGE_LIST[2],self.GD.skillFixDmg2);
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end



class:publish();

return class;