--[[
    クエストに紐づくスクリプト
    5-6 ラグシェルム[2] ＋ 真ラグシェルム
    ID 500251593のインデックスは1　
    ID 500262593のインデックスは2
  ]]
    
--初期化
function quest_init()
    print("init");
    joinUnitFLG = false;
    partyUnits = {};
    deadUnits_Party = {};
    deadUnits_Enemy = {};
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
    team:addIgnoreIndex(2);
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
    for i=0,6 do
        local uni = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
        if uni ~= nil then
            table.insert(partyUnits,uni);
        end
    end
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
    return 1;
end

--戦闘が終了した時
function waveEnd(wave,iswin)
    if iswin and joinUnitFLG == false then
            joinUnitFLG = true;
            megast.Battle:getInstance():setBattleState(kBattleState_none);  --バトルステータスを非アクティブに
            BattleControl:get():callLuaMethod(50605,"scenarioStart_5060502",3);
            return 0;
    end
    return 1;
end

function scenarioStart_5060502()
    BattleControl:get():hideUnit();
    BattleControl:get():hideStatus();
    BattleControl:get():hideTop();
    BattleControl:get():playScenario(5060502);   --シナリオの挿入
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
    if phase == 1 then
        phase = 2;
        BattleControl:get():showStatus();
        BattleControl:get():showTop();
        BattleControl:get():callLuaMethod(50605,"waveRestart",2.5);
    end
    
    if joinUnitFLG and phase == 0 then
        --print("★★★★★★★★　joinUnitFLG is TRUE　★★★★★★★★★★★")
        BattleControl:get():showUnit();
        joinUnit_EXRagshelm();
        BattleControl:get():playScenario(5060503);   --シナリオの挿入
        phase = 1;
    end
    
    return 1;
end

function joinUnit_EXRagshelm()
    megast.Battle:getInstance():getEnemyTeam():removeUnit(1);

    local unit = megast.Battle:getInstance():getEnemyTeam():addTeamUnitWithBattleMaster(6,2);
    unit:takeIn();

    return 1;
end

function waveRestart()
    megast.Battle:getInstance():setBattleState(kBattleState_active);    --バトルステータスをアクティブに
    for i=0, 6 do 
        local uni = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
        if uni ~= nil then
            uni:excuteAction();
        end
    end
    return 1;
end
