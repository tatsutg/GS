--[[
    knights of blood  第４部後編　チャレンジクエスト
  ]]
    
--初期化
function quest_init()
    print("init");
    quest_2014814Class:setUpMessages();
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
    
    quest_2014814Class:onStartWave(wave);
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    quest_2014814Class:onUpdate(wave,delta,time);
    return 1;
end

--ユニットが倒れた時
function deadUnit(wave , unit)
    
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


quest_2014814Class = {
    timeLimit = 251,
    delay = 5,
    waveCnt = 1
}

function quest_2014814Class:setUpMessages()
    self.TEXT = summoner.Text:fetchByQuestID(2014814);

    self.TIMEUP_MESSAGES = {};

    self.TIMEUP_MESSAGES[1] = {
        [0] = {
            MESSAGE = self.TEXT.TALK_1 or "時間切れだね",
            COLOR = summoner.Color.cyan,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.TALK_2 or "またねー！",
            COLOR = summoner.Color.green,
            DURATION = 5
        }
    }

    self.TIMEUP_MESSAGES[2] = {
        [0] = {
            MESSAGE = self.TEXT.TALK_3 or "おっと、残念…！",
            COLOR = summoner.Color.cyan,
            DURATION = 5
        }
    }

    self.TIMEUP_MESSAGES[3] = {
        [0] = {
            MESSAGE = self.TEXT.TALK_4 or "ここまでかな",
            COLOR = summoner.Color.red,
            DURATION = 5
        }
    }

    self.TIMEUP_MESSAGES[4] = {
        [0] = {
            MESSAGE = self.TEXT.TALK_5 or "惜しかったな…",
            COLOR = summoner.Color.magenta,
            DURATION = 5
        }
    }
end

function quest_2014814Class:showMessages(messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

function quest_2014814Class:onStartWave(wave)
    if wave == 1 then
        BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit -1 ,30, 620 , -100 ,0.8);
    end
    self.waveCnt = wave;
end


function quest_2014814Class:onUpdate(wave,delta,time)
    self:countDown(delta);
end


function quest_2014814Class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self:gameEnd();
        megast.Battle:getInstance():waveEnd(false);
    end

    if self.isBattleEnd then
        self.delay = self.delay - deltaTime;
    end

    if self.delay < 0 and not self.isShowResult then
        
        
        megast.Battle:getInstance():endBattle(false);
        
        self.isShowResult = true;
    end
end

function quest_2014814Class:gameEnd()
    self.isBattleEnd = true;
    megast.Battle:getInstance():setBattleState(kBattleState_none);
    
    self:showMessages(self.TIMEUP_MESSAGES[self.waveCnt]);
end

