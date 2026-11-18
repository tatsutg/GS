local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="女神", version=1.3, id=2022501});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50,
    ATTACK6 = 50
    -- ATTACK7 = 50,
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9
}

function class:setBuffBoxList(time)
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20131311,
            BUFF_ID = 13, -- 攻撃力
            VALUE = time / 3,
            DURATION = 99999,
            ICON = 7
        },
        [2] = {
            ID = 20131312,
            BUFF_ID = 21, -- 被ダメ軽減
            VALUE = -95 + (time / 5),
            DURATION = 99999,
            ICON = 20
        },
        [3] = {
            ID = 20131313,
            BUFF_ID = 22, -- クリティカル
            VALUE = 20 + (time / 2),
            DURATION = 99999,
            ICON = 0
        }
    }
    return self.BUFF_BOX_LIST
end

function class:setCriticalBuffBox(id)
    return {ID = id,BUFF_ID = 0,VALUE = 0,DURATION = 99999,ICON = 11}
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "TIME",
            action = function (status) self:timeUp(status) end,
            used = false
        }
    }
end

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIME_UP_MESSAGE_LIST)
    end
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 8,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "闇属性キラー"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "時間経過で攻撃力・クリティカル率アップ"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "時間経過で被ダメージアップ"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "クリティカル耐性アップ"
        })
    }
    self.TIME_UP_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.TIME_UP_MESSAGE1 or "タイムアップ！",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.TIME_UP_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.red
        })
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.TIME_UP = 300
class.INTERVAL = 1
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hitStop = 1
    self:setMessageBoxList()
    self:setTriggerList()
    self:showMessage(self.START_MESSAGE_LIST)
    event.unit:addSP(20)
    event.unit:setAttackDelay(2)

    self.timer = 0
    self.buffTimer = 0
    self.skillCount = 1

    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.TIME_UP ,30, 620 , -100 ,0.8);
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    event.unit:setNextAnimationName("idle1")
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.TRIGGERS[1].used then
        return 9999999;
    end
    return event.value
end

function class:takeDamageValue(event)
   if self.TRIGGERS[1].used then
        return 1;
    end
   return event.value;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,self.hitStop)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self:timeController(event.unit,event.deltaTime)
    end
    return 1
end

function class:timeController(unit,deltaTime)
    if self.buffTimer + self.timer + deltaTime >= self.TIME_UP then
        self.gameUnit:addSP(100);
        -- self.gameUnit:setInvincibleTime(10);
        if not self.TRIGGERS[1].used then
            self:execTrigger(1)
        end
    end

    if self.timer < self.INTERVAL then
        self.timer = self.timer + deltaTime
        return
    end

    self.timer = self.timer - self.INTERVAL
    self.buffTimer = self.buffTimer + self.INTERVAL
    self:addBuff(unit,self:setBuffBoxList(self.buffTimer))
    self:addCriticalIcon(math.floor(self.BUFF_BOX_LIST[3].VALUE / 10))
end

function class:addCriticalIcon(count)
    for c = 1, count do
        self:execAddBuff(self.gameUnit,self:setCriticalBuffBox(100+c))
    end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
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

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    skillIndex = self.skillCount
    if self.skillCount < 2 then
        self.skillCount = self.skillCount + 1
    else
        self.skillCount = 1
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
    return 1
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
    for _,buffBox in pairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in pairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3

    local action = "use" .. receiveNumber

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
    self.TRIGGERS[args.arg].used = true
    return 1
end


class:publish();

return class;
