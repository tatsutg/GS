--[[
    試練の回廊31F wave2
  ]]
    
--初期化
function quest_init()
    print("init");
    quest_2000531Class:setUpMessages();
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
    
    quest_2000531Class:onStartWave(wave);
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    quest_2000531Class:onUpdate(wave,delta,time);
    return 1;
end

--ユニットが倒れた時
function deadUnit(wave , unit)
    if unit:getisPlayer() == false then
        quest_2000531Class:deadCount(unit:getUnitID(), wave);
    end
    return 1;
end

--戦闘が終了した時
function waveEnd(wave,iswin)
    
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


quest_2000531Class = {
    timeLimit = 46,
    delay = 0
}

function quest_2000531Class:setUpMessages()
    self.TEXT = summoner.Text:fetchByQuestID(2000531);

    self.START_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "クリティカル耐性",
            COLOR = summoner.Color.yellow,
            DURATION = 7
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "一定時間内に倒した数でステータスアップ",
            COLOR = summoner.Color.white,
            DURATION = 7
        }
    }

    self.DEAD_MESSAGE_LIST = {
        [0] = {
            MESSAGE = self.TEXT.DEAD_MESSAGE0 or "パーティのHPアップ！",
            COLOR = summoner.Color.white,
            DURATION = 7
        },
        [1] = {
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "パーティの攻撃力アップ！",
            COLOR = summoner.Color.white,
            DURATION = 7
        }
    }
end

function quest_2000531Class:showMessages(messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function quest_2000531Class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function quest_2000531Class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function quest_2000531Class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function quest_2000531Class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function quest_2000531Class:showFormatMessages(messages,count)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(string.format(v.MESSAGE,count),v.DURATION,v.COLOR);
    end
end

function quest_2000531Class:onStartWave(wave)
    if wave == 2 then
        --BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit -1 ,30, 620 , -100 ,0.8);
        self:showMessage(self.START_MESSAGE_LIST)
        ---死亡数カウント
        self.count = {
            [100503512] = 0
        }
        self.enemyTable = {
            [100503512] = 2000685
        }
        ---バフテーブル
        self.BUFF_BOX_LIST = {
            [0] = {
                ID = 20005311,
                BUFF_ID = 1,---最大HP
                VALUE = 750,
                DURATION = 99999,
                ICON = 1,
                COUNT = 1,
                MAX = 10
            },
            [1] = {
                ID = 20005312,
                BUFF_ID = 12,---攻撃力固定値
                VALUE = 500,
                DURATION = 99999,
                ICON = 3,
                COUNT = 1,
                MAX = 10
            },
            [2] = {
                ID = 0,
                BUFF_ID = 1,---最大HP
                VALUE = 0,
                DURATION = 99999,
                ICON = 0
            }
        }
    end
end

function quest_2000531Class:deadCount(enemyId, wave)
    if wave ~= 2 then
        return;
    end
    if self.isBattleEnd then
        return
    end
    local team = megast.Battle:getInstance():getTeam(false);
    ---死亡数カウント
    self.count[enemyId] = self.count[enemyId] + 1
    ---プレイヤー側に攻撃力or最大HPアップ付与
    local N = self.count[enemyId] % 2
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[N].ID);
            if cond == nil then
                self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[N])
            else
                local defaultValue = self.BUFF_BOX_LIST[N].VALUE
                self.BUFF_BOX_LIST[N].VALUE = cond:getValue() + defaultValue
                self.BUFF_BOX_LIST[N].COUNT = math.floor(self.BUFF_BOX_LIST[N].VALUE / defaultValue)
                if self.BUFF_BOX_LIST[N].COUNT <= 10 then
                    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[N])
                end
                self.BUFF_BOX_LIST[N].VALUE = defaultValue
            end
        end
    end
    self:execShowMessage(self.DEAD_MESSAGE_LIST[N])
    ---0~5の場所が空席ならユニット召喚
    for i=0,6 do
        if team:getTeamUnit(i) == nil then
            team:addUnit(i,self.enemyTable[enemyId]);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            ---召喚ユニットのHPアップ
            self.BUFF_BOX_LIST[2].VALUE = (300000 * self.count[enemyId])
            self:execAddBuff(team:getTeamUnit(i),self.BUFF_BOX_LIST[2])
            return;
        end
    end
end

function quest_2000531Class:onUpdate(wave,delta,time)
    if wave == 2 then
        self:countDown(delta);
    end
end


function quest_2000531Class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self:gameEnd();
        local myTeam = megast.Battle:getInstance():getTeam(false);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:setHP(0)
            end
        end
    end

    if self.isBattleEnd then
        self.delay = self.delay - deltaTime;
    end

    if self.delay < 0 and not self.isShowResult then
        --megast.Battle:getInstance():endBattle(false);
        self.isShowResult = true;
    end
end

function quest_2000531Class:gameEnd()
    self.isBattleEnd = true;
    --megast.Battle:getInstance():setBattleState(kBattleState_none);
end

-- バフ処理実行
function quest_2000531Class:execAddBuff(unit,buffBox)
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
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end
end

