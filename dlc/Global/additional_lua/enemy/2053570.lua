local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX_クオ・ヴァディス(白亜の巨神)", version=1.3, id=2053570});
class:inheritFromEnemy("2053580");


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 20535701,
            BUFF_ID = 13,  --攻撃力UP
            VALUE = 50,
            DURATION = 99999,
            ICON = 3
        },
        [2] = {
            ID = 20535701,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20535702,
            BUFF_ID = 13,  --攻撃力UP
            VALUE = 100,
            DURATION = 30,
            ICON = 3
        },
        [2] = {
            ID = 20535702,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "魔族からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒状態の時、攻撃力・被ダメージアップ", COLOR = Color.yellow})
    }
    self.DEBUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_MESSAGE1 or "攻撃力・被ダメージアップ", COLOR = Color.red})
    }
    self.DEBUFF_CLEAR_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_CLEAR_MESSAGE1 or "攻撃力・被ダメージダウン", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        }
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 10;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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
    self.buffDamageValRate = 0.1
    self.raceDamageValRate = 0.1

    ---ボスギミック
    self.hpSkillFlg = false
    self.debuffFlg = false
    self.debuffMsgFlg = 0
    self.buffIDList = {90}

    --白亜の巨神で使用するやつ
    self.unitIndexList = {}
    self.unitIndexList = self:searchUnitList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --デバフギミック
    self:checkDebuff(event.unit)
    if self.debuffFlg then
        if self.debuffMsgFlg == 0 then
            self.debuffMsgFlg = 1
        end

        if self.hpSkillFlg then
            self:execAddBuff(event.unit,self.BUFF_LIST[2])
        end
    end

    if self.hpSkillFlg then
        --奥義中か確認
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.hpSkillFlg = false
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2])
        elseif event.unit:getUnitState() == kUnitState_skill and not self.debuffFlg then
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2])
        elseif event.unit:getUnitState() == kUnitState_skill and self.debuffFlg then
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[1])
        end
    else
        if self.debuffFlg then
            self:execAddBuff(event.unit,self.BUFF_LIST[1])
        else
            self:execAddBuff(event.unit,self.BUFF_LIST[2])
        end
    end

    if self.debuffMsgFlg == 1 and self.debuffFlg then
        self.debuffMsgFlg = 2
        self:showMessage(self.DEBUFF_MESSAGE_LIST)
    elseif self.debuffMsgFlg == 2 and not self.debuffFlg then
        self.debuffMsgFlg = 0
        self:showMessage(self.DEBUFF_CLEAR_MESSAGE_LIST)
    end

    --白亜の巨神で使用するやつ
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self:setPosition(event.unit)
    end
    self:checkUnitPosition(self.unitIndexList)
    return 1
end

function class:checkDebuff(unit)
    self.debuffFlg = false
    for k,v in ipairs(self.buffIDList) do
        local teamUnit = unit:getTeamUnitCondition():findConditionWithType(self.buffIDList[k])
        if teamUnit ~= nil then
            self.debuffFlg = true
            break
        end
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    if not self.debuffFlg then
        event.value = event.value * 0.6
    elseif self.debuffFlg and self.hpSkillFlg then
        event.value = event.value * 3.6
    elseif self.debuffFlg then
        event.value = event.value * 1.8
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end


class:publish();

return class;