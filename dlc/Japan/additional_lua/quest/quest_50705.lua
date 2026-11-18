--[[
    クエストに紐づくスクリプト
    ラスボス
    phase 0 :オージュ１前
    phase 1 :オージュ１後
    pahse 2 :オージュ２前
    phase 3 :オージュ２後
    phase 4 :マールゼクス
  ]]
    
--初期化
function quest_init()
    print("init");
    megast.Battle:getInstance():setBattleLWFEnable(false);
    
    phase = 0;
    
    if BattleControl:get():getCameraDefaultScale() > 0.88 then
        BattleControl:get():setCameraDefaultScale(0.88);
    end

    assist1_timer = LuaUtilities.rand(2,5);
    assist2_timer = LuaUtilities.rand(15,20);
    assist3_timer = LuaUtilities.rand(10,20);
    assist4_timer = LuaUtilities.rand(7,15);
    assist5_timer = LuaUtilities.rand(5,10);

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

    team:addIgnoreIndex(0);
    team:addIgnoreIndex(1);

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
    
    if phase == 1 then
        local unit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
        if unit:getHPPercent() < 0.6 then
            phase = 2;
            megast.Battle:getInstance():setBattleState(kBattleState_none);
            unit:stopAllActions();
            unit:takeAnimation(0,"damage",false);
            unit:takeAnimationEffect(0,"empty",false);
            BattleControl:get():hideTop();
            BattleControl:get():hideStatus();
            BattleControl:get():callLuaMethod(50705,"whitephase2" , 2);
        end
    end
    
    if phase == 2 then
        assist1_timer = assist1_timer - delta;
        assist2_timer = assist2_timer - delta;
        assist3_timer = assist3_timer - delta;
        assist4_timer = assist4_timer - delta;
        assist5_timer = assist5_timer - delta;
        assist1Check();
        assist2Check();
        assist3Check();
        assist4Check();
        assist5Check();
    end
    
    return 1;
end

--ロイアシスト
function assist1Check()
    if assist1_timer < 0 then
        local orbit = BattleControl:get():addOrbitSystemWithFile("scenario/unit/scenario_9006.json","assist");
        orbit:setPositionX(LuaUtilities.rand(0,50) - 50);
        orbit:setPositionY(LuaUtilities.rand(0,50) - 50);
        orbit:setBasePower(3500);
        orbit:setAttackDelay(10);
        assist1_timer = LuaUtilities.rand(5,20);
    end
end

--フェンアシスト
function assist2Check()
    if assist2_timer < 0 then
        local orbit = BattleControl:get():addOrbitSystemWithFile("scenario/unit/scenario_9008.json","assist");
        orbit:setPositionX(LuaUtilities.rand(0,50) + 100);
        orbit:setPositionY(LuaUtilities.rand(0,50) + 50);
        orbit:setBasePower(3500);
        orbit:setAttackDelay(10);
        assist2_timer = LuaUtilities.rand(5,20);
    end
end

--メリアアシスト
function assist3Check()
    if assist3_timer < 0 then
        local orbit = BattleControl:get():addOrbitSystemWithFile("scenario/unit/scenario_9010.json","assist");
        orbit:setPositionX(LuaUtilities.rand(0,50) + 200);
        orbit:setPositionY(LuaUtilities.rand(0,50) + 70);
        orbit:setBasePower(3500);
        orbit:setAttackDelay(10);
        assist3_timer = LuaUtilities.rand(5,20);
    end
end

--ゼイオルグアシスト
function assist4Check()
    if assist4_timer < 0 then
        local orbit = BattleControl:get():addOrbitSystemWithFile("scenario/unit/scenario_9009.json","assist");
        orbit:setPositionX(LuaUtilities.rand(0,50) + 70);
        orbit:setPositionY(LuaUtilities.rand(0,50) + 30);
        orbit:setBasePower(3500);
        orbit:setAttackDelay(10);
       assist4_timer = LuaUtilities.rand(5,20);
    end
end

--ミラアシスト
function assist5Check()
    if assist5_timer < 0 then
        local orbit = BattleControl:get():addOrbitSystemWithFile("scenario/unit/scenario_9007.json","assist");
        orbit:setPositionX(LuaUtilities.rand(0,100) + 100 );
        orbit:setPositionY(LuaUtilities.rand(0,100) );
        orbit:setBasePower(3500);
        orbit:setAttackDelay(10);
        assist5_timer = LuaUtilities.rand(5,20);
    end
end



function whitephase2()
    megast.Battle:getInstance():blackOutFront(0.5,1,1);
    BattleControl:get():callLuaMethod(50705,"playScenario2" , 1);
    return 0;
end

function whitephase3()
    megast.Battle:getInstance():blackOutFront(0.5,1,1);
    BattleControl:get():callLuaMethod(50705,"playScenario3" , 1);
    return 0;
end

--ユニットが倒れた時
function deadUnit(wave , unit)
    if unit:getisPlayer() == true then
        return 1;
    end

    if phase == 0 then
        BattleControl:get():callLuaMethod(50705,"timescale" , 0.4);
        BattleControl:get():callLuaMethod(50705,"white" , 0.1);
        BattleControl:get():callLuaMethod(50705,"playScenario1" , 1.6);
        return 1;
    end
    
    if phase == 2 then
        phase = 3;
        megast.Battle:getInstance():setBattleState(kBattleState_none);
        unit:stopAllActions();
        unit:takeAnimation(0,"damage",false);
        unit:takeAnimationEffect(0,"empty",false);
        BattleControl:get():hideTop();
        BattleControl:get():hideStatus();
        BattleControl:get():callLuaMethod(50705,"whitephase3" , 2);
        return 1;
    end
    
    if phase == 4 then
        phase = 4;
        BattleControl:get():playPrevBGM();
        BattleControl:get():hideTop();
        BattleControl:get():hideStatus();
        BattleControl:get():callLuaMethod(50705,"timescale" , 0.4);
        BattleControl:get():callLuaMethod(50705,"timescalereset" , 1);
        BattleControl:get():callLuaMethod(50705,"whiteend" , 0.1);
        return 1;
    end

   return 1;
end

function timescale()
    BattleControl:get():setTimeScale(0.3);
    return 1;
end

function timescalereset()
    BattleControl:get():setTimeScale(1);
    return 1;
end

function white()
    BattleControl:get():hideTop();
    BattleControl:get():hideStatus();
    megast.Battle:getInstance():whiteOutFront(0.7,1,0);
    return 1;
end

function whiteend()
    BattleControl:get():hideTop();
    BattleControl:get():hideStatus();
    megast.Battle:getInstance():whiteOutFront(0.7,10,0);
    return 1;
end

function playScenario1()
    megast.Battle:getInstance():setBackGroundColor(0,255,255,255);
    BattleControl:get():hideUnit();
    BattleControl:get():setTimeScale(1);
    BattleControl:get():hideStatusBack();
    removeBoss();
    BattleControl:get():playPrevBGM();
    BattleControl:get():playScenario(5070501);
    BattleControl:get():syncScenarioLayer();
    return 1;
end

function playScenario2()
    bossfire:setVisible(false);
    BattleControl:get():hideUnit();
    BattleControl:get():playPrevBGM();
    BattleControl:get():playScenario(5070502);
    BattleControl:get():syncScenarioLayer();
    BattleControl:get():hideStatusBack();
    bossfire:setVisible(false);
    return 1;
end

function playScenario3()
    removeBoss();
    bossfire:removeFromParent();
    BattleControl:get():hideUnit();
    BattleControl:get():playPrevBGM();
    BattleControl:get():playScenario(5070503);
    BattleControl:get():syncScenarioLayer();
    BattleControl:get():hideStatusBack();

    return 1;
end

function createNextBoss()
    if phase == 0 then
        local unit = megast.Battle:getInstance():getEnemyTeam():addTeamUnitWithBattleMaster(6,0);
        unit:setVisible(false);
        unit:takeIdle();
        phase = 1;
        return 0;
    end
    
    if phase == 3 then
       local unit = megast.Battle:getInstance():getEnemyTeam():addTeamUnitWithBattleMaster(6,1);
       unit:setPositionX(-70);
       unit:takeIdle();
       phase = 4;
       return 0;
    end
    
    return 0;
end

function resumeBattle1()
   createNextBoss();

   bossfire = BattleControl:get():addAnimation("FIRE","FIRE3",true);
   bossfire:setPositionX(-450);
   bossfire:setPositionY(-30);
   bossfire:setZOrder(30000);
   bossfire:setScale(1.2);
   BattleControl:get():excuteAll();

   local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
   boss:setDefaultPosition(-400 , -100);
   boss:setPosition(-400 , -100);
   BattleControl:get():focusCamera(0,0,0,0.72,4,0,1);
   BattleControl:get():setCameraDefaultScale(0.72);
   BattleControl:get():showStatusBack();

   BattleControl:get():showUnit();
   BattleControl:get():showTop();
   BattleControl:get():showStatus();
   BattleControl:get():callLuaMethod(50705,"active" , 2);
   BattleControl:get():resetPlayerPosition();

   megast.Battle:getInstance():blackOutFront(0,0.2,1);
   return 0;
end

function resumeBattle2()
   bossfire:setVisible(true);

   BattleControl:get():excuteAll();
   BattleControl:get():focusCamera(0,-250,0,0.72,4,0,1);
   BattleControl:get():setCameraDefaultScale(0.72);
   BattleControl:get():showStatusBack();
   bossfire:setVisible(true);

   BattleControl:get():showUnit();
   BattleControl:get():showTop();
   BattleControl:get():showStatus();
   BattleControl:get():callLuaMethod(50705,"active" , 2);
   BattleControl:get():resetPlayerPosition();

   megast.Battle:getInstance():blackOutFront(0,0.2,1);
   return 0;
end

function resumeBattle3()
    --レイアス変身
   --for i = 0 , 4 do
   --     local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
   --    if unit ~= nil then
   --         if unit:getBaseID() == 10101 then
   --             unit:setBaseHP(unit:getCalcHPMAX() + 1200);
   --             if unit:getEvolutionStage() < 4 then
   --                 unit:loadAnimation(101015411);
   --                 unit:setUnitID(101015411);
   --                 unit:updateStatusThumbnail();
   --                 unit:resetBattleSkill();
   --                 unit:setEvolutionStage(4);
   --                 unit:getBurstSkill():setSkillname("エターナルセイバー");
   --             end
   --         end
   --     end
   --end  

   BattleControl:get():revive();
   BattleControl:get():callLuaMethod(50705,"removeUnusedTexture" , 0.2);
   BattleControl:get():callLuaMethod(50705,"resumeBattle3After" , 2);

   BattleControl:get():setCameraDefaultScale();
   BattleControl:get():showStatusBack();

   BattleControl:get():showUnit();
   BattleControl:get():showTop();
   BattleControl:get():showStatus();
   BattleControl:get():callLuaMethod(50705,"active" , 7);
   BattleControl:get():resetPlayerPosition();

   megast.Battle:getInstance():whiteOutFront(0,2.5,2.5);
   
   return 0;
end

function resumeBattle3After()
   createNextBoss();
   BattleControl:get():excuteAll();
   return 1;
end

function removeUnusedTexture()
    BattleControl:get():removeUnusedTexture();
    return 1;
end


function active()
  megast.Battle:getInstance():setBattleState(kBattleState_active);
  local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
  boss:resumeUnit();
  boss:excuteAction();
  return 1;
end

function removeBoss()
    megast.Battle:getInstance():getEnemyTeam():removeUnit(6);
   return 0;
end

--戦闘が終了した時
function waveEnd(wave,iswin)
    print("Lua: waveEnd");
    if not (phase == 4) and iswin == true then
        return 0;
    end

    if iswin == false then
        megast.Battle:getInstance():setBattleLWFEnable(true);
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
    
    return 1;
end

--シナリオのイベントコールバック
function scenarioOnButtonCallback(event)

    return 1;
end

--シナリオの終了時コールバック
function scenarioEndCallback(event)
    if phase == 0 then
        resumeBattle1();
    end
    
    if phase == 2 then
        resumeBattle2();
    end
    
    if phase == 3 then
        resumeBattle3();
    end
    return 1;
end
