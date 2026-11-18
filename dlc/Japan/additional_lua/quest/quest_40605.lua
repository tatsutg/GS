--@additionalItem,100611400,100481200
--[[
    クエストに紐づくスクリプト
    4−6 グラード＆ニーア ＋ ラグシェルム
  ]] 
    
--初期化
function quest_init()
    print("init");

    joinUnitFLG = false;	    --ラグシェルム参戦フラグ（true = 参戦している）
    deadEndFLG = false;         --敗北でクエストクリアにさせるフラグ
    annihilationFLG = false;    --全滅したかどうかの判別フラグ
    -- hakkyoFLG   = false;	    --ラグシェルム発狂フラグ
    -- hakkyoStartValue = 0.75;	--ラグシェルムのHPがこの割合まで減少したら発狂開始

    partyUnits = {};
    deadUnits_Party = {};
    fen_cast_timer = 15.0;    --フェンの奥義クールタイム

    return 1;
end

--フェンがアイテムを使用
function fenCast()
    local rand = math.random(100);
    if rand < 50 then
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5):takeItemSkill(0);
    else
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5):takeItemSkill(1);
    end
    return 1;
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("initPlayerTeam");

    return 1;
end

function addUnit()
    local fen = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101054311,10,5); --フェン
    fen:setBaseHP(8000);
    fen:setHP(8000);
    fen:setPosition(50,100);
    fen:setDefaultPosition(50,100);
    fen:setBasePower(20000);
    fen:setItemSkill(0,100611400);
    fen:setItemSkill(1,100481200);
    fen:takeIn();
    fen:getTeamUnitCondition():addCondition(-1,10,2, 999, 0, 0);
    fen:setBurstPoint(80);
    
    local roy = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101034211,10,6); --ロイ
    roy:setBaseHP(8000);
    roy:setHP(8000);
    roy:setPosition(50,-100);
    roy:setDefaultPosition(50,-100);
    roy:setBasePower(20000);
    roy:setItemSkill(0,100611400);
    roy:setItemSkill(1,100481200);
    roy:takeIn();
    roy:setSkillInvocationWeight(25);
    return 1;
end

--エネミーのチームの初期化
function initEnemyTeam(team, wave)
    print("initEnemyTeam");
    team:addIgnoreIndex(5);
    return 1;
end

--ユニットが生成された時
function quest_takeIn(wave,unit)
    print("Lua:takeIn");

    -- if unit:getisPlayer() == false then
    --     return 0;
    -- end
    
    return 1;
end

--バトルのセットアップ時
function questStart()
    print("Lua:questStart");
    addUnit();
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

    fen_cast_timer = fen_cast_timer - delta;    
    if fen_cast_timer < 0 then
        fenCast();
        fen_cast_timer = 15.0;
    end      

    return 1;
end

--ユニットが倒れた時
function deadUnit(wave , unit)
    if unit:getisPlayer() then
        table.insert(deadUnits_Party,unit);
    end
    if unit:getisPlayer() and unit:getIndex() > 3 and joinUnitFLG then
    	--ロイとフェンが死ぬと敗北判定が２回以上走ってしまうのでラグシェルム戦でロイとフェンが死のうとしたら拒否する
        unit:setHP(1);
        return 0;
    end
    return 1;
end

--戦闘が終了した時
function waveEnd(wave,iswin)

    if deadEndFLG == true and annihilationFLG == false then
        annihilationFLG = true;
        megast.Battle:getInstance():setBattleState(kBattleState_none);
        megast.Battle:getInstance():waveEnd(true);
        return 0;
    end

    if iswin == true then
  	 if joinUnitFLG == false then
    	    if table.maxn(partyUnits) ~= table.maxn(deadUnits_Party) then   --パーティーが全滅していない場合にシナリオを流す
     	       joinUnitFLG = true;
      	      removeCondition();
      	      megast.Battle:getInstance():setBattleState(kBattleState_none);  --バトルステータスを非アクティブに
      	      BattleControl:get():callLuaMethod(40605,"scenarioStart_4060502",3);
      	      return 0;
        end
   	 end
     end
    return 1;
end

function removeCondition()
    for i=0,6 do
        local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
        if unit ~= nil then
            unit:getTeamUnitCondition():removeAllCondition();
        end
    end
    return 1;
end

function scenarioStart_4060502()
    BattleControl:get():hideTop();
    BattleControl:get():hideStatus();
    BattleControl:get():playScenario(4060502);   --シナリオの挿入
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
    if joinUnitFLG then
        BattleControl:get():showTop();
        BattleControl:get():showStatus();
        print("★★★★★★★★　joinUnitFLG is true　★★★★★★★★★★");
        BattleControl:get():callLuaMethod(40605,"resumeBattle",1.0);
        BattleControl:get():setRetireEnabled(false); 
        BattleControl:get():callLuaMethod(40605,"waveRestart",5.0);
    end
    return 1;
end

function resumeBattle()
    local unit1 = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(1 , true);
    local unit2 = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(4 , true);
    unit1:runAction(cc.FadeOut:create(1));
    unit2:runAction(cc.FadeOut:create(1));
    unit1:takeBack();
    unit2:takeBack();

    BattleControl:get():callLuaMethod(40605,"joinUnit_Ragshelm",2);
    return 1;
end

function joinUnit_Ragshelm()
    --一旦全ての敵ユニットを削除
    for i=0,6 do
        megast.Battle:getInstance():getEnemyTeam():removeUnit(i);
    end
    deadEndFLG = true;
    megast.Battle:getInstance():setBattleLWFEnable(false);
    local unit = megast.Battle:getInstance():getEnemyTeam():addTeamUnitWithBattleMaster(6,5);
    unit:takeIn();
    unit:setPositionX(-100);

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

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem ".. index .. "," .. itemNo);
    
    return 1;
end