--[[
    クエストに紐づくスクリプト
    
  ]]
    
--初期化
function quest_init()
    print("init");
    
    timelimit = 180; --制限時間

    BattleControl:get():preload("unit/animation/50068hand.png");
    BattleControl:get():preload("unit/animation/50068HandEF.png");
    BattleControl:get():preload("unit/animation/50068back_gate.png");
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
    BattleControl:get():showCountDownTime("additional/other/worldend.png", timelimit ,30, 620 , -80 ,0.8);

    return 1;
end

--戦闘の開始命令 注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    if wave < megast.Battle:getInstance():getWaveMax() then
        if  BattleControl:get():getTime() > timelimit and megast.Battle:getInstance():getBattleState() == kBattleState_active then
            megast.Battle:getInstance():setBattleState(kBattleState_none);
            megast.Battle:getInstance():whiteOut(1,99,0);
            BattleControl:get():callLuaMethod(1000105 , "deadend" , 4);
        end
    end
    return 1;
end

function deadend()
            local i = 0;
            for i = 0 , 4 do
                local teamunit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
                if teamunit ~= nil then
                    teamunit:setHP(0);
                    teamunit:getTeam():deadUnit(teamunit:getIndex());
                end
            end
            for i = 0 , megast.Battle:getInstance():getEnemyTeam():getIndexMax() do
                local teamunit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
                if teamunit ~= nil then
                if teamunit:getUnitID() ~= 500681113 then 
                    teamunit:setHP(0);
                end
                end
            end            
            BattleControl:get():callLuaMethod(1000105 , "questend" , 0.1);
    return 1;
end

function questend()
    if megast.Battle:getInstance():getBattleState() == kBattleState_none then
        megast.Battle:getInstance():waveEnd(false);
    end
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
