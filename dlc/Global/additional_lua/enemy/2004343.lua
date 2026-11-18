local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="大炎ミモーザス", version=1.3, id=2004343});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 2,
            VALUE = ((1 + self.deadEnemies / 5) * 100)- 100,
            DURATION = 99999,
            ICON = 1
        },
        [2] = {
            ID = 0,
            BUFF_ID = 15,
            VALUE = ((1 + self.deadEnemies / 8) * 100) - 100,
            DURATION = 99999,
            ICON = 5
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "魔法・クリティカル耐性"
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ミモーザス"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE2 or "体撃破！"
        })
    }

end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.deadEnemies = self:getCount()
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self:setMessageBoxList()
    self:setBuffBoxList()
    self.addBuffFLG = true
    self.gameEnd = false
    return 1
end

function class:getCount() ---wave1ミモーザス死亡数をreturn
    for i = 0,7 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            return localUnit:getParameter("count") ~= "" and localUnit:getParameter("count") or 0
        end
    end
end

----// startWave //-----------------------------------------------------------------------------
-- 条件 : wave開始時。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:startWave(event)
    self:showMessage(self.START_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.addBuffFLG then
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        self.addBuffFLG = false
    end
    event.unit:setReduceHitStop(100,1)
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(2004343);
    if cond ~= nil then
        self.gameEnd = true
        event.unit:setHP(0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.gameEnd then
        self.deadEnemies = self.deadEnemies + 1
        for i = 0,7 do
            local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
            if localUnit ~= nil then
                localUnit:setParameter("count",self.deadEnemies)
            end
        end
        local text1 = self.TEXT.DEAD_MESSAGE1 or "ミモーザス"
        local text2 = self.TEXT.DEAD_MESSAGE2 or "体撃破！"
        summoner.Utility.messageByEnemy(text1..self.deadEnemies..text2,
                7,Color.red)
        self:summon(event.unit,2004343)
    end
    return 1
end

function class:receive4(args)

    return 1
end

function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                break
            end
        end
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


class:publish();

return class;