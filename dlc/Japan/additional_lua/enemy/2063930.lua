local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡_６層_NORMAL_静聖神覇罪皇ギアベール", version=2.0, id=2063930});
class:inheritFromEnemy("2063935");


--------[[バフ]]--------
function class:setBuffBoxList()
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20639352,
            BUFF_ID = 17,  --与ダメージ
            VALUE = self.GD.buffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 20639353,
            BUFF_ID = 13,  --攻撃力Down
            VALUE = self.GD.buffValue_13,
            DURATION = 999999,
            ICON = 4,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 20639354,
            BUFF_ID = 21,  --被ダメージ
            VALUE = self.GD.buffValue_21,
            DURATION = 99999,
            ICON = 139,
            COUNT = 0,
            MAX = 10
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル耐性", COLOR = Color.yellow})
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 8,
        hitStop = 100,
        buffValue_13 = -10,
        buffValue_17 = 20,
        buffValue_21 = 10
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    self.hp50Flg = false
    self.skillBuffFlg = false
    self.changeSkillFlg = false
    self.attack5Flg = false

    --ギアベールの変数
    self.mode = 1
    self.stunFLG = -1
    return 1
end

function class:skillAddBuff(unit,buffBox)
    self.skillBuffFlg = false
    self:execAddBuff(unit,buffBox)
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end



class:publish();

return class;