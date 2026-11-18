local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.MapThemeEventDispatcher.createMapThemeClass({label="MapTheme24 洞窟", version=1.0, id=24});

local json = summoner.Json;

class.startBuffType = 93
class.startBuffValue = 30
class.startBuffIcon = 83
class.startBuffTime = 99999
--class.startBuffScriptID = 405
--class.startBuffValue1 = 1
--class.startBuffValue2 = 7
class.startBuffTimer = 20

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
    self.TIMER_MESSAGE_LIST = {
        [93] = self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE1 or "洞窟の暗闇に視界を奪われる", COLOR = Color.magenta, isPlayer = true})
    }
end

function class:init()
    print("mapTheme_init_24");
    self:setMessageBoxList()
    self.timer = self.startBuffTimer
    return 1
end

-- event { deltaTime,playerTeam,enemyTeam,customParameter }
function class:update(event)
    if self:updateCheck() then
        self:fixedUpdate(event)
    end
    return 1;
end

function class:fixedUpdate(event)
    self.timer = self.timer + event.deltaTime
    if self.timer >= self.startBuffTimer then
        self.timer = self.timer - self.startBuffTimer
        self:timerBuff(event.playerTeam)
    end
end

function class:updateCheck()
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        return true
    elseif megast.Battle:getInstance():getBattleState() == kBattleState_waveend then
        return true
    elseif megast.Battle:getInstance():getBattleState() == kBattleState_lose then
        return true
    elseif megast.Battle:getInstance():getBattleState() == kBattleState_ready then
        return true
    elseif megast.Battle:getInstance():getBattleState() == kBattleState_none then
        return true
    end
    return false
end

function class:timerBuff(playerTeam)
    ---洞窟用ギミック
    if self.startBuffType == 93 then
        local BUFF_BOX_LIST = {
            ID = 600124,
            BUFF_ID = self.startBuffType,
            VALUE = self.startBuffValue + (math.ceil(megast.Battle:getInstance():getCurrentGrandBattleFloor() * 0.2)),
            DURATION =self.startBuffTime,
            ICON = self.startBuffIcon,
            --SCRIPT = {
            --    SCRIPT_ID = self.startBuffScriptID,
            --    VALUE1 = self.startBuffValue1,
            --    VALUE2 = self.startBuffValue2 * megast.Battle:getInstance():getCurrentGrandBattleFloor();
            --}
        }
        if self:playerAddBuff(playerTeam,BUFF_BOX_LIST) then
            if self.TIMER_MESSAGE_LIST[self.startBuffType] ~= nil then
                self:execShowMessage(self.TIMER_MESSAGE_LIST[self.startBuffType])
            end
        end
    end
    return;
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave開始時に呼ばれる
function class:waveRun(event)
    print("mapTheme_waveRun_24");
    return 1;
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave終了時に呼ばれる
function class:waveEnd(event)
    print("mapTheme_waveEnd_24");
   return 1
end

-- event { target,caster,power,customParameter }
--Unit側の takeDamageValue のあとに呼ばれる
function class:takeDamageValue(event)
    print("mapTheme_takeDamageValue_24");
    return 1;
end

-- event { target,caster,breakpower,customParameter }
--Unit側の takeBreakeDamageValue のあとに呼ばれる
function class:takeBreakeDamageValue(event)
    print("mapTheme_takeBreakeDamageValue_24");
    return 1;
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

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:playerAddBuff(playerTeam,buffBox)
    local flg = false
    for i = 0,6 do
        local myTeamUnit = playerTeam:getTeamUnit(i)
        if myTeamUnit ~= nil and myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID) == nil  then
            flg = true;
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
    return flg
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

class:publish();

return class;
