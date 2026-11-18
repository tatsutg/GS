--[[
    大炎遺跡14F_questLua
  ]]
    
--初期化
function quest_init()
    print("init");
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
    
    quest_2004314Class:onStartWave(wave);
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    quest_2004314Class:onUpdate(wave,delta,time);
    return 1;
end

function deadUnit(wave, unit)
    --quest_2004314Class:onDead(wave,unit);
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
    if wave == 1 then
        BattleControl:get():removeCountDownTime("unit/animation/timeLimit.png");
    end
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


quest_2004314Class = {
    timeLimit = 60,
    delay = 5,
    waveCnt = 1,
    numDeadEnemies = 0
}

function quest_2004314Class:onStartWave(wave)
    if wave == 1 then
        BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit -1 ,30, 620 , -100 ,0.8);
    end
end


function quest_2004314Class:onUpdate(wave,delta,time)
    if wave == 1 then
        self:countDown(delta);
    end
end

function quest_2004314Class:onDead(wave,unit)
    if wave == 1 then
        if unit:getisPlayer() == false then
            self.numDeadEnemies = self.numDeadEnemies + 1
            for i = 0,7 do
                local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
                if localUnit ~= nil then
                    localUnit:setParameter("count",self.numDeadEnemies)
                end
            end
        end
    end
end


function quest_2004314Class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 then
        self:gameEnd();
    end
end

function quest_2004314Class:gameEnd()
    for i = 0,7 do
        local localUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i)
        if localUnit ~= nil then
            localUnit:getTeamUnitCondition():addCondition(2004343,0,0,99999,0);
        end
    end
end

