--[[
    questLua
  ]]
    
--初期化
function quest_init()
    print("init");
    quest_2039916Class:setUpMessages();
    return 1;
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("initPlayerTeam");
    
    return 1;
end

--エネミーのチームの初期化
function initEnemyTeam(team, wave)
    print("initEnemyTeam");

    return 1;
end

--ユニットが生成された時
function quest_takeIn(wave,unit)
    print("Lua:takeIn");
    
    return 1;
end

--バトルのセットアップ時
function questStart()
    print("Lua:questStart");
    
    return 1;
end

--戦闘開始の準備ができた時
function battleReady(wave)
    print("Lua:battleReady");
    
    return 1;
end

--戦闘の開始命令 注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    
    quest_2039916Class:onStartWave(wave);
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    quest_2039916Class:onUpdate(wave,delta,time);
    return 1;
end

function deadUnit(wave, unit)

    return 1
end

-- エネミー追加
function summon()
    if Quest:getInstance():isAbleToSummon() then
        Quest:getInstance():summonNewEnemy()
        return 1
    else
        return 0
    end
end

--戦闘が終了した時
function waveEnd(wave,iswin)
    quest_2039916Class:onEndWave(wave);
    return 1;
end

--画面タッチ時
function onTouchBegan()

    return 1;
end

--画面タッチ終了時
function onTouchEnded(x , y)

    return 1;
end

--スキルボタンのタッチ終了時
function onTouchSkillEnded(index,isBurst)

    return 1;
end

--アイテムボタンタッチ時
function onTouchItem(index,itemIndex)

    return 1;
end

--ユニットのスキル発動時
function useSkill(index, isBurst)

    return 1;
end

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem ".. index .. "," .. itemNo);

    return 1;
end

--シナリオのイベントコールバック
function scenarioOnButtonCallback(event)

    return 1;
end

--シナリオの終了時コールバック
function scenarioEndCallback(event)

    return 1;
end


quest_2039916Class = {
    TIME_LIMIT = 300,
    battleEnd = false,
    inWave = false
}

function quest_2039916Class:onStartWave(wave)
    if wave == 1 then
        BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.TIME_LIMIT ,30, 620 , -100 ,0.8);
        self.BUFF_BOX_LIST = {
            [1] = {
                ID = 2039916,
                BUFF_ID = 11,
                VALUE = 1000,
                DURATION = 99999,
                ICON = 0,
                SCRIPT = {
                    SCRIPT_ID = 295
                }
            }
        }
    end
    self.inWave = true
end

function quest_2039916Class:onEndWave(wave)
    self.inWave = false
end


function quest_2039916Class:onUpdate(wave,delta,time)
    if self.inWave then
        self:teamAddBuffUpdate(self.BUFF_BOX_LIST[1])
    end
    if not self.battleEnd and BattleControl:get():getTime() > self.TIME_LIMIT then
        self.battleEnd = true
        self:showMessage(self.END_MESSAGE_LIST)
        megast.Battle:getInstance():waveEnd(false)
    end
end

function quest_2039916Class:setUpMessages()
    self.TEXT = summoner.Text:fetchByQuestID(2039916);

    self.END_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE1 or "スピードチャレンジ失敗…",
            COLOR = summoner.Color.red,
            DURATION = 7
        }
    }
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function quest_2039916Class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function quest_2039916Class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function quest_2039916Class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function quest_2039916Class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function quest_2039916Class:showFormatMessages(messages,count)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(string.format(v.MESSAGE,count),v.DURATION,v.COLOR);
    end
end

-- バフ処理実行
function quest_2039916Class:execAddBuff(unit,buffBox)
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

    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end
end

function quest_2039916Class:teamAddBuffUpdate(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
            if buff == nil then
                self:execAddBuff(myTeamUnit,buffBox)
            end
        end
    end
end
