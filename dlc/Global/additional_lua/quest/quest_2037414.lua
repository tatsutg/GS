--[[
    knights of blood  第４部後編　チャレンジクエスト
  ]]
    
--初期化
function quest_init()
    print("init");
    quest_2037414Class:setUpMessages();
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
    
    quest_2037414Class:onStartWave(wave);
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    quest_2037414Class:onUpdate(wave,delta,time);
    return 1;
end

--ユニットが倒れた時
function deadUnit(wave , unit)
    if unit:getisPlayer() == false then
        quest_2037414Class:deadCount(unit:getUnitID());
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


quest_2037414Class = {
    timeLimit = 121,
    delay = 4
}

function quest_2037414Class:setUpMessages()
    self.TEXT = summoner.Text:fetchByQuestID(2037414);

    self.START_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "120秒以内に10体以上討伐でクリア！",
            COLOR = summoner.Color.white,
            DURATION = 7
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "オロチ：回避率アップ",
            COLOR = summoner.Color.magenta,
            DURATION = 7
        },
        [3] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "フィアナ：奥義ダメージ軽減",
            COLOR = summoner.Color.red,
            DURATION = 7
        },
        [4] = {
            MESSAGE = self.TEXT.START_MESSAGE4 or "ライザー：クリティカル耐性",
            COLOR = summoner.Color.yellow,
            DURATION = 7
        }
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "合計%d体撃破！",
            COLOR = summoner.Color.white,
            DURATION = 7
        }
    }

    self.END_MESSAGE_LIST1 = {
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE1 or "オロチ%d体",
            COLOR = summoner.Color.magenta,
            DURATION = 7
        }
    }
    self.END_MESSAGE_LIST2 = {
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE2 or "フィアナ%d体",
            COLOR = summoner.Color.red,
            DURATION = 7
        }
    }
    self.END_MESSAGE_LIST3 = {
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE3 or "ライザー%d体",
            COLOR = summoner.Color.yellow,
            DURATION = 7
        }
    }
end

function quest_2037414Class:showMessages(messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function quest_2037414Class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function quest_2037414Class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function quest_2037414Class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function quest_2037414Class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function quest_2037414Class:showFormatMessages(messages,count)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(string.format(v.MESSAGE,count),v.DURATION,v.COLOR);
    end
end

function quest_2037414Class:onStartWave(wave)
    if wave == 1 then
        BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit -1 ,30, 620 , -100 ,0.8);
        self:showMessage(self.START_MESSAGE_LIST)
        ---死亡数カウント
        self.count = {
            [100554512] = 0,
            [100514112] = 0,
            [100444412] = 0
        }
        self.enemyTable = {
            [100554512] = 2037456,
            [100514112] = 2037457,
            [100444412] = 2037458
        }
        self.totalDead = 0
        ---バフテーブル
        self.BUFF_BOX_LIST = {
            [100554512] = {
                ID = 100554512,
                BUFF_ID = 31,---回避率
                VALUE = 8,
                DURATION = 99999,
                ICON = 16,
                COUNT = 0
            },
            [100514112] = {
                ID = 100514112,
                BUFF_ID = 21,---奥義ダメージカット
                VALUE = -6,
                DURATION = 99999,
                ICON = 20,
                SCRIPT = {
                    SCRIPT_ID = 58
                },
                COUNT = 0
            },
            [100444412] = {
                ID = 100444412,
                BUFF_ID = 23,---クリティカル耐性
                VALUE = -15,
                DURATION = 99999,
                ICON = 188,
                COUNT = 0
            },
            [1] = {
                ID = 0,
                BUFF_ID = 1,---最大HP
                VALUE = 0,
                DURATION = 99999,
                ICON = 0
            }
        }
    end
end

function quest_2037414Class:deadCount(enemyId)
    local team = megast.Battle:getInstance():getTeam(false);
    ---死亡数カウント
    self.count[enemyId] = self.count[enemyId] + 1
    self.totalDead = self.totalDead + 1
    self:showFormatMessages(self.DEAD_MESSAGE_LIST,self.totalDead)
    ---0~5の場所が空席ならユニット召喚
    for i=0,6 do
        if team:getTeamUnit(i) == nil then
            team:addUnit(i,self.enemyTable[enemyId]);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            ---召喚ユニットのHPアップ
            self.BUFF_BOX_LIST[1].VALUE = (250000 * self.count[enemyId]) + ((self.count[enemyId] ^ 2) * 40000)
            self:execAddBuff(team:getTeamUnit(i),self.BUFF_BOX_LIST[1])
            ---召喚ユニットに特有のバフ付与
            self.BUFF_BOX_LIST[enemyId].COUNT = self.BUFF_BOX_LIST[enemyId].COUNT + 1
            local saveValue = self.BUFF_BOX_LIST[enemyId].VALUE
            self.BUFF_BOX_LIST[enemyId].VALUE = self.BUFF_BOX_LIST[enemyId].VALUE * self.BUFF_BOX_LIST[enemyId].COUNT
            self:execAddBuff(team:getTeamUnit(i),self.BUFF_BOX_LIST[enemyId])
            self.BUFF_BOX_LIST[enemyId].VALUE = saveValue
            return;
        end
    end
end

function quest_2037414Class:onUpdate(wave,delta,time)
    self:countDown(delta);
end


function quest_2037414Class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self:gameEnd();
        if self.totalDead < 10 then
            megast.Battle:getInstance():waveEnd(false);
            self:showFormatMessages(self.DEAD_MESSAGE_LIST,self.totalDead)
            self:showFormatMessages(self.END_MESSAGE_LIST1,self.count[100554512])
            self:showFormatMessages(self.END_MESSAGE_LIST2,self.count[100514112])
            self:showFormatMessages(self.END_MESSAGE_LIST3,self.count[100444412])
        else
            megast.Battle:getInstance():waveEnd(true);
            self.isShowResult = true;
            self:showFormatMessages(self.DEAD_MESSAGE_LIST,self.totalDead)
            self:showFormatMessages(self.END_MESSAGE_LIST1,self.count[100554512])
            self:showFormatMessages(self.END_MESSAGE_LIST2,self.count[100514112])
            self:showFormatMessages(self.END_MESSAGE_LIST3,self.count[100444412])
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

function quest_2037414Class:gameEnd()
    self.isBattleEnd = true;
    megast.Battle:getInstance():setBattleState(kBattleState_none);
end

-- バフ処理実行
function quest_2037414Class:execAddBuff(unit,buffBox)
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

