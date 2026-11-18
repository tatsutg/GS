local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="38章_NORMAL_幻聖プラチナ", version=2.8, id=3805032});
class:inheritFromEnemy("3805034");


function class:setBuffBoxList()
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 38050342,
            BUFF_ID = 21,
            VALUE = self.GD.skillBuffValue_21,
            DURATION = 999999,
            ICON = 185,
            COUNT = 0,
            MAX = 99,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 380503450,
        BUFF_ID = 23, --被クリティカル率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 380503450,
        BUFF_ID = 0, --被クリティカル率
        VALUE = 0,
        DURATION = 0.1,
        ICON = 0
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "はじめましょう", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.FRIEND_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FRIEND_DEAD_MESSAGE1 or "マジ…かよ……！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRIEND_DEAD_MESSAGE2 or "パロット…仇は討ちます", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "敗れた…なぜ……", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {};
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 5,
        startAddSP = 0,
        attackDelay = 6,
        hitStop = 100,
        isHARD = 0,
        physicalTakeDmgVal = 0.02,
        skillBuffValue_21 = 20
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
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    ---相方死亡時info
    if not self.friendDeadInfoFlg then
        if not self:findFriend() then
            self.friendDeadInfoFlg = true;
            self:showMessage(self.FRIEND_DEAD_MESSAGE_LIST);
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end



class:publish();

return class;