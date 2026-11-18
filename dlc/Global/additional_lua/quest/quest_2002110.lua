--[[
    クエストに紐づくスクリプト
    フェンイベントクエスト10
  ]]
    
--初期化
function quest_init()
    print("init");
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
    if phase == 0 and wave == megast.Battle:getInstance():getWaveMax() then
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
            if boss ~= nil and boss:getHPPercent() <= 0.5 then
            megast.Battle:getInstance():setBattleState(kBattleState_none);  --バトルステータスを非アクティブに
            BattleControl:get():callLuaMethod(6015,"scenarioStart_2002110",2.5);
            BattleControl:get():hideStatus();
            BattleControl:get():hideTop();
            local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
            if boss ~= nil then
                boss:setHP(boss:getCalcHPMAX());
            end
            phase = 1;
        end
    end
    return 1;
end

function scenarioStart_2002110()
    BattleControl:get():hideUnit();
    BattleControl:get():playScenario(201708106);   --シナリオの挿入
    BattleControl:get():syncScenarioLayer();


    return 1;
end

function waveRestart()
    megast.Battle:getInstance():setBattleState(kBattleState_active);    --バトルステータスをアクティブに
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101054311,1,4);--フェン
    unit:setBaseHP(50000);
    unit:setHP(50000);
    unit:setPosition(100,-50);
    unit:setDefaultPosition(100,-50);
    unit:setBasePower(10000);
    unit:takeIn();

    
    for i=0, 6 do 
        local uni = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
        if uni ~= nil then
            uni:excuteAction();
        end
    end
    for i=0, 6 do 
        local uni = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
        if uni ~= nil then
            uni:excuteAction();
        end
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
    --レイアス変身
   --for i = 0 , 4 do
    --    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
   --    if unit ~= nil then
    --        if unit:getBaseID() == 10101 then
    --            unit:setBaseHP(unit:getCalcHPMAX() + 1200);
    --            if unit:getEvolutionStage() < 4 then
     --              unit:loadAnimation(101015411);
      --             unit:setUnitID(101015411);
      --              unit:updateStatusThumbnail();
       --             unit:resetBattleSkill();
       --             unit:setEvolutionStage(4);
      --         unit:getBurstSkill():setSkillname("エターナルセイバー");
       --             unit:takeIdle();
      --          end
      --      end
     --   end
   --end  


   
        BattleControl:get():showUnit();
        BattleControl:get():showStatus();
        BattleControl:get():showTop();
        BattleControl:get():callLuaMethod(6015,"waveRestart",2.5);
    return 1;
end
