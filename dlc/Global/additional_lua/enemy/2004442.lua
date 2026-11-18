local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="水霧ビッグフレイド", version=1.3, id=2004442});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 5015150,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE or "start",
            COLOR = Color.yellow
        })
    }

end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.countTime = 0
    event.unit:getSkeleton():setScaleX(0.7)
    event.unit:getSkeleton():setScaleY(0.7)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self:setMessageBoxList()
    self:setBuffBoxList()
    self.BUFF_BOX_LIST[1].DURATION = math.random(25, 35)
    self.BUFF_BOX_LIST[1].ID = self.BUFF_BOX_LIST[1].ID + event.unit:getIndex()
    self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1])
    self.CountDownFLG = true
    self.takeSkillFLG = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.CountDownFLG then
        self.countTime = self.countTime + event.deltaTime
        self:updateScale(event.unit,self.countTime)
        --summoner.Utility.messageByEnemy(self.countTime)
        if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID) == nil then
            event.unit:addSP(100)
            self.CountDownFLG = false
        end

    end
    return 1
end

function class:updateScale(unit,countTime)
    self.scale = 0.7 + (1.1 / self.BUFF_BOX_LIST[1].DURATION * countTime)
    unit:getSkeleton():setScaleX(self.scale)
    unit:getSkeleton():setScaleY(self.scale)
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if self.takeSkillFLG == true then
        event.unit:setHP(0)
    end
    return 1
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if self.takeSkillFLG == true and event.index == 1 then
        event.unit:setHP(0)
    end
    if event.index == 2 then
        self.takeSkillFLG = true
    end
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ダメージ量
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if event.unit:getTeamUnitCondition():findConditionWithType(96) == nil then
        event.value = 0
    end
    return event.value
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
    for _,messageBox in ipairs(messageBoxList) do
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

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
end

function class:teamAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:execAddBuff(buffBox)
        end
    end
end


class:publish();

return class;