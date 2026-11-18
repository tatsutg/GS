local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="人族遺跡_12層_NORMAL_統神イフリート", version=2.8, id=2061210});
class:inheritFromEnemy("2061215");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20612150,
            BUFF_ID = 59, --氷結耐性
            VALUE = self.GD.buffVal_59_1,
            DURATION = self.GD.buffTime_59,
            ICON = 75,
        },
        [2] = {
            ID = 20612151,
            BUFF_ID = 108, --氷結回避率
            VALUE = self.GD.buffVal_59_1,
            DURATION = self.GD.buffTime_59,
            ICON = 0,
        }
    }
    self.ICE_BUFF_LIST = {
        [1] = {
            ID = 20612152,
            BUFF_ID = 59, --氷結耐性
            VALUE = self.GD.buffVal_59_2,
            DURATION = 999999,
            ICON = 65,
            COUNT = 0,
            MAX = 99
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 20612153,
            BUFF_ID = 17,   --クリティカルダメージUP
            VALUE = self.GD.buffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ボス燃焼時、CRI率アップ", COLOR = Color.yellow}),
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "一定時間氷結耐性ダウン", COLOR = Color.red}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカルダメージアップ", COLOR = Color.yellow}),
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
            self.hpSkill = 1;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP50_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
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

        buffValue_17 = 50,
        buffVal_59_1 = -200,
        buffVal_59_2 = 10,
        buffTime_59 = 5,
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

    ---ボスギミック
    self.skillBuffFlg = false;
    self.deBuffFlg = false;
    self.fieldCount = 0;
    self.hpInfoFlg = false;
    self.infoTime = 0;
    self.showInfoTime = 5;
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.elementBox = {};
    for i = 1,5 do
        self.elementBox[i] = false;
    end
    self.elementCount = self:enemyElementCount(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    --奥義後にバフを付与
    if self.skillBuffFlg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skillBuffFlg = false;
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[1]);
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2]);
        self:showMessage(self.SKILL_MESSAGE_LIST);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    return event.count;
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