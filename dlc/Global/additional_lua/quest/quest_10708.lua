--[[
    クエストに紐づくスクリプト
    塔を染める悪意
  ]]
    
--初期化
function quest_init()
    print("init 塔を染める悪意");
    phase = 0;
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
    if wave == 4 then
        team:addIgnoreIndex(4);
    end
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
 
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then

        return 1;
    end
    

    return 1;
end

--ユニットが倒れた時
function deadUnit(wave , unit)
    if wave == 4 then
        if unit:getisPlayer() == false and phase == 0 then
            phase = 1;                        
            BattleControl:get():callLuaMethod(10708,"joinUnit",2);
        end
    end
 
    return 1;
end

--戦闘が終了した時
function waveEnd(wave,iswin)
 
    if wave == 4 and iswin == true then
        if phase ~= 2 then
            return 0;
        end
    end
 
    return 1;
end

function scenarioStart_4060502()
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

--シナリオのイベントコールバック
function scenarioOnButtonCallback(event)
    --シナリオ側からイベントを呼び出されたら、ここに対応する処理を記す

    return 1;
end

--シナリオの終了時コールバック
function scenarioEndCallback(event)
 
    return 1;
end
 
function joinUnit()
    --一旦全ての敵ユニットを削除
    for i=0,6 do
        megast.Battle:getInstance():getEnemyTeam():removeUnit(i);
    end
    megast.Battle:getInstance():setBattleState(kBattleState_none);  --バトルステータスを非アクティブに

    phase = 2;

    local unit = megast.Battle:getInstance():getEnemyTeam():addTeamUnitWithBattleMaster(4,4);
    unit:takeIn();
    BattleControl:get():callLuaMethod(10708,"waveRestart",2);

    return 1;
end

function waveRestart()
    megast.Battle:getInstance():setBattleState(kBattleState_active);    --バトルステータスをアクティブに
    return 1;
end

