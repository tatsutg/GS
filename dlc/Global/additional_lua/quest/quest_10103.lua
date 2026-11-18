--[[
    クエストに紐づくスクリプト
    
    チュートリアルその３
    phase1 : wave3開始スクリプト
    phase2 : ヴァルザンデス登場
    phase3 : ボス戦闘開始準備
    phase4 : ボス戦闘開始
    phase5 : 奥義カウンター説明
    phase6 : 奥義カウンター明
    phase7 : バトル再開
    phase8 : やばいのがくるぞディレイ
    phase9 : やばいのがくるぞ説明
    phase10 : バトル再開
    phase11 : 一時停止
    phase12 : ３剣シナリオ
    phase13 : ３剣召喚
    phase14 : バトル再開準備
    phase15 : バトル再開
    phase16 : ヴァルザンデス停止
    phase17 : ３剣しまう
    phase18 : やったか？シナリオ
    phase19 : ヴァルザン再起動
    phase20 : ロイ乱入
    phase21 : バトル再開準備
    phase22 : バトル再開


  ]]
    
function quest_init()
    print("init");

    if megast.Battle:getInstance():getIsTutorial() == false then
        return 0;
    end

    phase = 0;
    isroySkillSetup = 0;
    phaseTimer = 0;
    megast.Battle:getInstance():setBossAlertEnable(false);
    return 1;
end
    
function phase1()
    print("Lua:run pahse1()");
    BattleControl:get():hideStatus();
    BattleControl:get():hideTop();
    BattleControl:get():hideUnit();

    BattleControl:get():playScenario(1010302);
    BattleControl:get():syncScenarioLayer();

end

function phase2()
    print("Lua:run pahse2()");
    
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:setReady(false);
    boss:takeAnimation(0,"threaten",false);
    boss:setVisible(true);
    boss:setOpacity(255);
    boss:setAttackDelay(4.0);
    megast.Battle:getInstance():playLastBattle();            
    boss:getTeamUnitCondition():addCondition(-1,17,10, 99, 0, 0);
    boss:getTeamUnitCondition():addCondition(-2,27, -100, 99, 0, 0);
    boss:setBasePower(4000);
    boss:setPosition(-350,-70);
    boss:setDamageDropSp(5);
    boss:setDefaultPosition(-350,-70);
    boss:setBaseHP(70000);
    boss:setHP(70000);
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 3);
            
    local unit0 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
    local unit1 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4);
    unit0:setPosition(170, 80);
    unit1:setPosition(140, -50);
    BattleControl:get():showUnit();
end

function phase3()
    print("Lua:run pahse3()");
            
    BattleControl:get():showStatus();
    BattleControl:get():showTop();
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 2);

end

function phase4()
    print("Lua:run pahse4()");
    
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 12 , true);
end
        
function phase5()
    print("Lua:run pahse5()");
    
    BattleControl:get():showOverlay();
    BattleControl:get():pause();
    BattleControl:get():playScenario(1010303);

end

function phase6()
    print("Lua:run pahse6()");

    BattleControl:get():focusNode("//skill_counter_panel" , "");
    BattleControl:get():showFocusFrame("//skill_counter_panel","",131,15,200,50);

end

function phase7()
    print("Lua:run pahse7()");
    
    BattleControl:get():hideFocusFrame();
    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
    BattleControl:get():resume();

end

function phase8()
    print("Lua:run pahse8()");
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss.m_IgnoreHitStopTime = 5;
    
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 2 , true);
end

function phase9()
    print("Lua:run pahse9()");
    BattleControl:get():pause();

    BattleControl:get():playScenario(1010304);
end

function whiteout()
   megast.Battle:getInstance():whiteOut(0.6,2.5,1.5);
   return 1;
end

function phase10()
    print("Lua:run pahse10()");

    BattleControl:get():resume();

    BattleControl:get():callLuaMethod(10103 ,"statusLock", 1.7 , true);
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 3.3 , true);
    
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:setAttackTimer(5);
end

function phase11()
   print("Lua:run pahse11()");
   
   BattleControl:get():hideStatus();
   BattleControl:get():hideTop();
   megast.Battle:getInstance():setBattleState(kBattleState_none);  

   BattleControl:get():stopAllUnit();
   BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 1);
   local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
   boss:takeAnimation(0,"attack4",false);
   boss:setUnitState(kUnitState_none);
end

function phase12()
   print("Lua:run pahse12()");
   
   BattleControl:get():playScenario(1010305);
   BattleControl:get():syncScenarioLayer();
   megast.Battle:getInstance():getPlayerTeam():removeUnit(1);
       
   BattleControl:get():hideUnit();

end

function phase13()
    print("Lua:run pahse13()");
    megast.Battle:getInstance():whiteOut(0,1,3);
    BattleControl:get():hideScenarioUnit();
    BattleControl:get():showUnit();

    BattleControl:get():callLuaMethod(10103 ,"superSummon", 0);
    BattleControl:get():callLuaMethod(10103 ,"flash", 2.5);
    BattleControl:get():callLuaMethod(10103 ,"summon1", 2.5);
    BattleControl:get():callLuaMethod(10103 ,"summon2", 2.1);
    BattleControl:get():callLuaMethod(10103 ,"summon3", 2.3);
    BattleControl:get():callLuaMethod(10103 ,"hpmax", 0);
    BattleControl:get():callLuaMethod(10103 ,"focusCamera", 2.4);

    BattleControl:get():playBGM("GS201_SENTOU");
    
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:takeIdle();
end

function focusCamera()
    BattleControl:get():unsyncScenarioLayer();
    BattleControl:get():focusCamera(0.2,0,0,0.77,4,0,1);
    return 1;
end

function hpmax()
   local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
   unit:setHP(unit:getCalcHPMAX());
   unit:getTeamUnitCondition():addCondition(-1,7,35, 99, 0, 0);
   return 1;
end

function flash()
   megast.Battle:getInstance():whiteOut(0.2,0,2);
   return 1;
end

function summon1()
   local unit1 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(1);
   unit1:takeIn(2);
   unit1:setVisible(true);
   unit1:getTeamUnitCondition():addCondition(-1,7,35, 99, 0, 0);

   return 0;
end

function summon2()
   local unit2 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(2);
   unit2:takeIn(2);
   unit2:setVisible(true);
   unit2:getTeamUnitCondition():addCondition(-1,7,35, 99, 0, 0);

   return 0;
end

function summon3()
   local unit3 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(3);
   unit3:takeIn(2);
   unit3:setVisible(true);
   unit3:getTeamUnitCondition():addCondition(-1,7,35, 99, 0, 0);
   return 0;
end

function phase14()
    print("Lua:run pahse14()");
    
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    local per = boss:getHPPercent();
    boss:setBaseHP(34000 / per);
    boss:setHP(34000);
    BattleControl:get():showStatus();
    BattleControl:get():showTop();
    statusLock();    
    shiftPhase();
end

function phase15()
    print("Lua:run pahse15()");
    statusUnLock();   

    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:setAttackTimer(1.5);
    boss:setBaseDefence(5000);
    boss:getTeamUnitCondition():removeAllCondition();
    boss:getTeamUnitCondition():addCondition(-2,27, -100, 99, 0, 0);

    BattleControl:get():callLuaMethod(10103 ,"excuteAction", 2);

end

function excuteAction()
    megast.Battle:getInstance():setBattleState(kBattleState_active);   

    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(1):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(2):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(3):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):excuteAction();
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:setAttackTimer(0);
    boss:excuteAction();
    return 1;
end

function phase16()
    print("Lua:run pahse16()");
    
    megast.Battle:getInstance():setBattleState(kBattleState_none);   
    statusLock();
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 4);
end

function phase17()
    print("Lua:run pahse17()");
    
    if megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):getPositionX() < 150 then
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):takeBack();
    end
    
    if megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):getPositionX() < 150 then
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeBack();
    end
    
    local unit1 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(1);
    local unit2 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(2);
    local unit3 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(3);
    unit1:takeSummon();
    unit2:takeSummon();
    unit3:takeSummon();
    
    unit1:runAction(cc.FadeOut:create(1));
    unit2:runAction(cc.FadeOut:create(1));
    unit3:runAction(cc.FadeOut:create(1));
    
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 2);
    
    focusCamera();
end

function phase18()
    print("Lua:run pahse18()");
    BattleControl:get():playScenario(1010306);
    megast.Battle:getInstance():getPlayerTeam():removeUnit(1);
    megast.Battle:getInstance():getPlayerTeam():removeUnit(2);
    megast.Battle:getInstance():getPlayerTeam():removeUnit(3);
    BattleControl:get():hideStatus();
    BattleControl:get():hideTop();
end

function phase19()
    print("Lua:run pahse19()");
    
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:getTeamUnitCondition():removeAllCondition();

    boss:takeAnimation(0,"getup",false);
    boss:takeAnimationEffect(0,"empty",false);
    BattleControl:get():callLuaMethod(10103 ,"bossloop", 0.2);
    boss:setBaseDefence(100);
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 2);
    boss:setHP(20000);
end

function phase20()
    print("Lua:run pahse20()");

    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);

    boss:setBasePower(1000);
    boss:stopAllActions();

    local unit0 = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
    unit0:setAttackTimer(0.5);

    unit0:setBurstPoint(unit0:getBurstPoint()+50);
    unit0:getTeamUnitCondition():removeAllCondition();

    isroySkillSetup = 1;
    BattleControl:get():playScenario(1010307);
    BattleControl:get():setBreakBarEnable(true);
end

function bossloop()
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:takeAnimation(0,"charge_loop",true);
    boss:takeAnimationEffect(0,"charge_short",true);
    boss:setAutoExcuteAction(true);
    return 1;
end

function roySkillSetup()
    local unit1 = megast.Battle:getInstance():getPlayerTeam():addTeamUnitWithItem(101034211,1,5,0,0,0);
    unit1:setPosition(600,0);
    unit1:takeFront();
    unit1:moveTo(0.3,0,-20);
    unit1:setAutoZoder(false);
    unit1:setZOrder(10000);
    unit1:setBasePower(200);
    unit1:setBaseBreakPower(300);
    unit1:setAttackTimer(0.5);
    BattleControl:get():callLuaMethod(10103 ,"roySkillEvent", 0.3);

    BattleControl:get():callLuaMethod(10103 ,"stateChange", 4);
    BattleControl:get():playBGM("GS202_ARENASENTOU");
    
    return 1;
end

function roySkillEvent()
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5);
    unit:takeSkill(2);
    
    BattleControl:get():callLuaMethod(10103 ,"bossDamage", 0.2);
    BattleControl:get():callLuaMethod(10103 ,"bossDamage", 1.8);
    BattleControl:get():callLuaMethod(10103 ,"bossDamage", 2.0);
    BattleControl:get():callLuaMethod(10103 ,"bossDamage", 2.2);
    BattleControl:get():callLuaMethod(10103 ,"bossDamage", 2.4);
    
    return 1;
end

function stateChange()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5):takeBack();  
    megast.Battle:getInstance():setBattleState(kBattleState_waveend);  

    BattleControl:get():playScenario(1010308);
    return 1; 
end

function bossDamage()
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
    boss:takeAnimation(0,"damage",false);
    boss:takeAnimationEffect(0,"empty",false);
    boss:setAttackTimer(2);
    boss:setUnitState(kUnitState_none);

    return 1;
end

function phase21()
    print("Lua:run pahse21()");
    BattleControl:get():callLuaMethod(10103 ,"shiftPhase", 1.5);
    
    local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);

    boss:getTeamUnitCondition():addCondition(-3,21, -55, 99, 0, 0);
    
    BattleControl:get():showStatus();
    BattleControl:get():showTop();
end

function phase22()
    print("Lua:run pahse22()");
    statusUnLock();    
    megast.Battle:getInstance():setBattleLWFEnable(true);

    megast.Battle:getInstance():setBattleState(kBattleState_active);   
    --megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):excuteAction();
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5):excuteAction();
    
    BattleControl:get():callLuaMethod(10103 ,"roySkill", 3);
end

function shiftPhase()
    phaseTimer = 0;
    phase = phase + 1;
    print("Lua:pahse"..phase);

    if phase == 1 then
        phase1();
    end
    
    if phase == 2 then
        phase2();
    end
    
    if phase == 3 then
        phase3();
    end
    
    if phase == 4 then
        phase4();
    end
    
    if phase == 5 then
        phase5();
    end

    if phase == 6 then
        phase6();
    end
    
    if phase == 7 then
        phase7();
    end
    
    if phase == 8 then
        phase8();
    end
    
    if phase == 9 then
        phase9();
    end
    
    if phase == 10 then
        phase10();
    end
        
    if phase == 11 then
        phase11();
    end
    
    if phase == 12 then
        phase12();
    end
    
    if phase == 13 then
        phase13();
    end
    
    if phase == 14 then
        phase14();
    end
    
    if phase == 15 then
        phase15();
    end
    
    if phase == 16 then
        phase16();
    end
    
    if phase == 17 then
        phase17();
    end

    if phase == 18 then
        phase18();
    end
    
    if phase == 19 then
        phase19();
    end
    
    if phase == 20 then
        phase20();
    end
    
    if phase == 21 then
        phase21();
    end
    
    if phase == 22 then
        phase22();
    end
    
    return 1;
end

function superSummon()
   megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6):setPosition(-200,-30);

   megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):setPosition(300,70);
   megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):setBurstPoint(100);
   megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0):setHP(600);
   megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):setPosition(310,-60);

   local unit1 = megast.Battle:getInstance():getPlayerTeam():addTeamUnitWithItem(100014111,1,1,100581510,100601510,0);--クライドを追加
   local unit2 = megast.Battle:getInstance():getPlayerTeam():addTeamUnitWithItem(100024211,1,2,101642510,101221510,0);--コルセアを追加
   local unit3 = megast.Battle:getInstance():getPlayerTeam():addTeamUnitWithItem(100034311,1,3,101391510,101402510,0);--アルスを追加
   unit1:setOpacity(0);
   unit2:setOpacity(0);
   unit3:setOpacity(0);
   
   unit1:setPosition(200,0);
   unit2:setPosition(100,80);
   unit3:setPosition(100,-80);

   unit1:setBurstPoint(100);
   unit2:setBurstPoint(100);
   unit3:setBurstPoint(100);

   unit1:setBaseDefence(5000);
   unit2:setBaseDefence(5000);
   unit3:setBaseDefence(5000);

   return 1;
end

function deadGirius()
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(1);
    unit:setHP(0);
    
    return 1;
end

function statusLock()
    BattleControl:get():setStatusEnable(false);
    
    return 1;
end

function statusUnLock()
    BattleControl:get():setStatusEnable(true);

    return 1;
end

function gunanSkill()
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkill(1);
    end
    return 1;
end

function roySkill()    
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5):takeSkill(2);  
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(5):getActiveBattleSkill():setBreakValue(10000);
    end
    BattleControl:get():callLuaMethod(10103 ,"roySkill", 8);
    return 1;
end

function initPlayerTeam(team)
    print("initPlayerTeam");
   
    team:addTeamUnitWithItem(101012411,3,0,100181300,100014105,0);--レイアスを追加
    team:addTeamUnitWithItem(100111111,3,1,100051100,0,0);--ギリウスを追加

    return 0;
end

function initEnemyTeam(team , wave)
    print("initEnemyTeam");
    if wave == 3 then 
        if phase == 0 then
           BattleControl:get():callLuaMethod(10103 , "shiftPhase" , 0);
        end
        megast.Battle:getInstance():setBattleLWFEnable(false);
        return 1;
    end
    return 1;
end

function quest_takeIn(wave,unit)
    print("Lua:takeIn");
    
    if wave == 3 and unit:getisPlayer() == false then
       unit:setReady(true);
       return 0;
    end
    
    return 1;
end


function questStart()
    print("Lua:questStart");
    
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101114111 , 1, 4);
    unit:setBaseHP(9999);
    unit:setHP(9999);
    unit:setPosition(140,-70);
    unit:setDefaultPosition(140,-70);
    unit:setBasePower(310);
    unit:takeIn(1);    
     
    BattleControl:get():setBreakBarEnable(false);

    return 1;
end

function battleReady(wave)
    print("Lua:battleReady");
    if wave < 3 then
        for i = 0, 6 do
            local enemyUnit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
            if enemyUnit ~= nil then
                enemyUnit:setDamageDropSp(0);
                enemyUnit:setDeadDropSp(15);
            end
        end
    end
    return 1;
end

--注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    if wave == 3 then
        
        if phase < 4 then
            return 0;
        end     
        
    end
    
    return 1;
end

function quest_update(wave , delta ,time)
    if wave == 3 and phase == 7 then
        if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
            return 0;
        end
        phaseTimer = phaseTimer + delta;
        local boss = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(6);
        if boss:getBurstPoint() >= 100 or phaseTimer > 15 then
            boss:setBurstPoint(100);
            shiftPhase();
        end
    end
        
    return 1;
end

function deadUnit(wave , unit)
    if unit:getisPlayer() == true and unit:getIndex() == 0 then
        unit:setHP(1);
        return 0;
    end
    
    if unit:getisPlayer() == true and unit:getIndex() == 1 then
        if phase < 10 then
            unit:setHP(1);
            return 0;
        end
        
       if phase > 14 then
            unit:setHP(1);
            return 0;
        end
    end
    
    if unit:getisPlayer() == true and unit:getIndex() == 2 then
        unit:setHP(1);
        return 0;
    end
    
    if unit:getisPlayer() == true and unit:getIndex() == 3 then
        unit:setHP(1);
        return 0;
    end
    
    if unit:getisPlayer() == true and unit:getIndex() == 4 then
        unit:setHP(1);
        return 0;
    end
    
    if wave == 3 and phase == 15 then
        if unit:getisPlayer() == false then
            unit:setHP(1);
            unit:takeAnimation(0,"kneel",false);
            unit:stopAllActions();
            unit:setAutoExcuteAction(false);
            unit:takeAnimationEffect(0,"empty",false);
            unit:setUnitState(kUnitState_damage);
            unit:playDeadFocus();
        
            shiftPhase();
            return 0;
        end 
    end
    
    if wave == 3 and phase < 22 then
        if unit:getisPlayer() == false then
            unit:setHP(1);
            return 0;
        end 
    end
        
    return 1;
end

function waveEnd(wave,iswin)
    print("Lua:waveEnd "..wave);
    
    if wave == 3 then
       shiftPhase();
       if phase < 23  then
            return 0;
        end
    end
    
    return 1;
end

function waveReset(wave)
    print("Lua:waveReset "..wave);
    
    return 1;
end

function onTouchBegan()
    
    return 1;
end

function onTouchEnded(x , y)
    
    return 1;
end

function onTouchSkillEnded(index,isBurst)
       
    return 1;
end

function onTouchItem(index,itemIndex)
    
    return 1;
end

function useSkill(index, isBurst)
    if index == 0 then
        BattleControl:get():callLuaMethod(10103 , "gunanSkill" , 1.7);
    end
    
    return 1;
end

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem ".. index .. "," .. itemNo);
    
    return 1;
end

function scenarioOnButtonCallback(event)
    if event == "SHIFT_PHASE" then
        shiftPhase();
    end
    return 1;
end

function scenarioEndCallback(event)
    if phase == 9 then
        BattleControl:get():callLuaMethod(10103 ,"whiteout", 1.7 ,true);
    end
    
    if isroySkillSetup == 1 then
        print("roySkillSetup");
        roySkillSetup();
        isroySkillSetup = 0;
        return 1;
    end

    shiftPhase();

    return 1;
end
