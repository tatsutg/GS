--[[
    クエストに紐づくスクリプト
    3−4 グラード[2]

    ・グラードのHPが半分まで減少したところで、ロイを参戦させる    
  ]]
    
--初期化
function quest_init()
    print("init");
    joinUnitFLG = false;
    FLGStartValue = 0.5;        --グラードのHPがこの割合まで減少したらロイを参戦させる
    roy_skill_timer = 1.0;     --ロイのスキルクールタイム
    roy_burst_timer = 30.0;    --ロイの奥義クールタイム
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


--ロイのスキルを発動
function roySkill()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkill(1);
    return 1;
end

--ロイの奥義を発動
function royBurst()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkillWithCutin(2);
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
    
    local enemy = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(1);
    local enMaxHp = enemy:getCalcHPMAX();
    local enCurrentHP = enemy:getHP();
    if enCurrentHP / enMaxHp <= FLGStartValue then
        if not joinUnitFLG then
            joinUnitFLG = true;
            megast.Battle:getInstance():setBattleState(kBattleState_none);  --バトルステータスを非アクティブに
            BattleControl:get():callLuaMethod(30405,"scenarioStart_3040503",3);
        end
    end

    if joinUnitFLG then
        roy_burst_timer = roy_burst_timer - delta;
        roy_skill_timer = roy_skill_timer - delta;
        if roy_burst_timer < 0 then
            royBurst();
            roy_burst_timer = 30.0;
        end
    end

    return 1;
end

function scenarioStart_3040503()
    BattleControl:get():playScenario(3040503);   --シナリオの挿入
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
    if roy_skill_timer < 0 then
        BattleControl:get():callLuaMethod(30405 , "roySkill" , 1.7);
        roy_skill_timer = 6;
    end
    return 1;
end

function quest_castItem(index, itemNo, targetIndex)
    
    return 1;
end

--シナリオのイベントコールバック
function scenarioOnButtonCallback(event)
    
    return 1;
end

--シナリオの終了時コールバック
function scenarioEndCallback(event)
    if joinUnitFLG then
        print("★★★★★★★★　joinUnitFLG is true　★★★★★★★★★★");
        joinUnit_Roy();
        BattleControl:get():callLuaMethod(30405,"waveRestart",2.5);
    end
    return 1;
end

-- ロイを途中参戦させる
function joinUnit_Roy()
    
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101034211,1,4);
    unit:setBaseHP(10000);
    unit:setHP(10000);
    unit:setPosition(150,-50);
    unit:setDefaultPosition(150,-50);
    unit:setBasePower(8000);
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