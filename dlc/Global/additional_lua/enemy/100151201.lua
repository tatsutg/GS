local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="修行の間_サンドバッグ_ヴァルザンデス", version=1.3, id=100151201});
class:inheritFromUnit("unitBossBase");

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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "超回復"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "180秒で耐久してクリア"})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 0;---addSPの量
    event.unit:setAttackDelay(9999999);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self:setMessageBoxList()
    self:showMessage(self.START_MESSAGE_LIST)
    self.stateName = "NORMAL"

    event.unit:setElementType(0)  --無属性
    self.clearTime = 180
    self.endFlg = true
    self.myHP = event.unit:getHP()
    ---右上タイマー表示
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.clearTime ,30, 620 , -100 ,0.8);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    --event.unit:setReduceHitStop(2,1)---ヒットストップ無効or時止め無効
    event.unit:setHP(self.myHP)
    local time = BattleControl:get():getTime();
    if time >= self.clearTime and self.endFlg then
        self.endFlg = false
        megast.Battle:getInstance():setBattleState(kBattleState_none);
        megast.Battle:getInstance():waveEnd(true);
    end

    if event.unit:getUnitState() ~= kUnitState_idle then
        event.unit:takeIdle();
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    return 1
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