--[[
    クエストに紐づくスクリプト
    
    チュートリアルその２
    phase : 0 wave1開始スクリプト
    phase : 1 説明１開始
    phase : 2 １０秒戦う
    phase : 3 説明２
    phase : 4 グレーアウト解除
    phase : 5 スキル発動
    phase : 6 説明３
    phase : 7 バトル停止
    phase : 8 スキル発動
    phase : 9 説明４
    phase :10 バトル停止
    phase :11 テキスト終了　通常戦闘再開

  ]]
    
function phase1()
    print("Lua:run pahse1()");
    BattleControl:get():playScenario(1010202);
end

function phase2()
    BattleControl:get():callLuaMethod(10102 , "shiftPhase" , 5);
    print("Lua:run pahse2()");
end

function phase3()
    print("Lua:run pahse3()");
    BattleControl:get():playScenario(1010206);
    BattleControl:get():pause();
end

function phase4()
    print("Lua:run pahse4()");

    BattleControl:get():grayoutStatus(0, false, false);
end

function phase5()
    print("Lua:run pahse5()");

    BattleControl:get():showFocusGuide("//status_0","//skill_icon_panel_2",80,212,150,170,0);
    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
end

function phase6()
    print("Lua:run phase6()");            
    BattleControl:get():hideFocusGuide();
    BattleControl:get():playScenario(1010203);
end

function phase7()
    print("Lua:run pahse7()");
    BattleControl:get():pause();
end

function phase8()
    print("Lua:run pahse8()");
    
    BattleControl:get():showFocusGuide("//status_0","//skill_icon_panel_2",80,77,150,170,2);
    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
end

function phase9()
    print("Lua:run phase9()");
    BattleControl:get():resume();
    BattleControl:get():hideFocusGuide();
    BattleControl:get():playScenario(1010204);
end

function phase10()
    print("Lua:run pahse10()");
    BattleControl:get():pause();
end

function phase11()
    print("Lua:run pahse11()");
    BattleControl:get():resume();
    BattleControl:get():grayoutStatus(1, false, false);
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
    unit:excuteAction();
    
    local enemy = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(0);
    enemy:getTeamUnitCondition():removeAllCondition();
    enemy:setBasePower(200);

end

function phase31()
    print("Lua:run pahse31()");
    BattleControl:get():hideStatus();
    BattleControl:get():hideTop();
    BattleControl:get():playScenario(1010205);
end

function phase32() 
    print("Lua:run pahse32()");
    
    for i = 0, 6 do
        local unit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
        if unit ~= nil then
            unit:takeIn(1);
            unit:setSkillInvocationWeight(0);
        end
    end
    
    BattleControl:get():showStatus();
    BattleControl:get():showTop();
    megast.Battle:getInstance():setBattleState(kBattleState_ready);   
    BattleControl:get():callLuaMethod(10102 , "shiftPhase" , 2.5);
    megast.Battle:getInstance():setBattleLWFEnable(true);
    megast.Battle:getInstance():playLastBattle();

end

function phase33()
    print("Lua:run pahse33()");
    BattleControl:get():playBGM("GS201_SENTOU");

end

function gunanSkill()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkill(1);
    
    return 1;
end


function shiftPhase()
    phase = phase + 1;
    print("Lua:pahse"..phase);

    if phase == 1 then
        phase1();
    elseif phase == 2 then
        phase2();
    elseif phase == 3 then
        phase3();
    elseif phase == 4 then
        phase4();
    elseif phase == 5 then
        phase5();
    elseif phase == 6 then
        phase6();
    elseif phase == 7 then
        phase7();
    elseif phase == 8 then
        phase8();
    elseif phase == 9 then
        phase9();
    elseif phase == 10 then
        phase10();
    elseif phase == 11 then
        phase11();
    elseif phase == 31 then
        phase31();
    elseif phase == 32 then
        phase32();
    elseif phase == 33 then
        phase33();
    end

    return 1;
end

function quest_init()
    print("init");

    if megast.Battle:getInstance():getIsTutorial() == false then
        return 0;
    end

    phase = 0;

    return 1;
end

function initPlayerTeam(team)
    print("initPlayerTeam");
    team:addTeamUnitWithItem(101012411,3,0,100181300,100014105,0);--レイアスを追加
    team:addTeamUnitWithItem(100111111,1,1,0,0,0);--ギリウスを追加
    return 0;
end

function initEnemyTeam(team,wave)
    print("initEnemyTeam");
    if wave == 3 then 
        megast.Battle:getInstance():setBattleLWFEnable(false);
        BattleControl:get():callLuaMethod(10102 , "shiftPhase" , 1.7);
        return 1;
    end
    
    return 1;
end

function quest_takeIn(wave,unit)
    print("Lua:takeIn");

    if wave == 3 and phase == 30 then
        if unit:getisPlayer() == false then
            return 0;
        end
    end

    return 1;
end


function questStart()
    print("Lua:questStart");
    
    local enemy = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(0);
    enemy:setBurstPoint(100);
    enemy:setBaseHP(4000);
    enemy:setBasePower(3000);
    enemy:setHP(4000);
    enemy:getTeamUnitCondition():addCondition(-1,17,200, 6, 0, 0);

    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101114111 , 1, 4);
    unit:setBaseHP(9999);
    unit:setHP(9999);
    unit:setPosition(140,-70);
    unit:setDefaultPosition(140,-70);
    unit:setBasePower(310);
    unit:takeIn(1);    
    
    BattleControl:get():grayoutStatus(0, false, true);
    BattleControl:get():grayoutStatus(1, false, true);
    BattleControl:get():setBreakBarEnable(false);
    BattleControl:get():setBossSkillCounterEnable(false);

    return 1;
end

function battleReady(wave)
    print("Lua:battleReady");
    
    if wave == 3 then
        if phase < 32 then 
            return 0;
        end
    end    
        
    return 1;
end

--注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    if wave == 1 then
        if phase == 0 then
            shiftPhase();
        end
    
        if phase < 2 then 
            return 0;
        end
    end
    
    if wave == 3 then
        if phase < 33 then 
            return 0;
        end
    end
    
    return 1;
end

function quest_update(wave , delta ,time)
    
    return 1;
end

function deadUnit(wave , unit)
    if phase < 10 then
        unit:setHP(200);
        return 0;
    end
    
    if unit:getisPlayer() == true then
        unit:setHP(1);
        return 0;
    end
    return 1;
end

function waveEnd(wave,iswin)
    print("Lua:waveEnd "..wave);
    
    if wave == 2 then
        phase = 30;
    end
    
    return 1;
end

function onTouchBegan()
    
    return 1;
end

function onTouchEnded(x , y)
    
    return 1;
end

function onTouchSkillEnded(index,isBurst)
    if phase ~= 2 and phase < 10 then
        return 0;
    end
       
    return 1;
end

function onTouchItem(index,itemIndex)
    print("Lua:onTouchItem ".. index .. "," .. itemIndex);
        
    if phase == 2 then
        return 0;
    elseif phase == 5 then
        if itemIndex ~= 0 then
            return 0;
        end
    elseif phase == 8 then
        if itemIndex ~= 1 then
            return 0;
        end
    end
    
    return 1;
end

function useSkill(index, isBurst)
    if index == 0 then
        BattleControl:get():callLuaMethod(10102 , "gunanSkill" , 1.7);
    end
    
    return 1;
end

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem ".. index .. "," .. itemNo);
    
    if phase == 2 then
        return 0;
    elseif phase == 5 then
        if itemNo == 100181300 then
            BattleControl:get():resume();
            BattleControl:get():callLuaMethod(10102 , "shiftPhase" , 1.5);
        else
            return 0;
        end
    elseif phase == 8 then
        if itemNo == 100014105 and targetIndex == 1 then
            shiftPhase();
        else
            return 0;
        end
    end
    
    return 1;
end

function scenarioOnButtonCallback(event)
    if event == "SHIFT_PHASE" then
        shiftPhase();
    end
    
    return 1;
end

function scenarioEndCallback(event)
    if phase == 1 then
        shiftPhase();
    end
    if phase == 4 then
        shiftPhase();
    end
    if phase == 7 then
        shiftPhase();
    end
    if phase == 10 then
        shiftPhase();
    end
    if phase >= 30 then
        shiftPhase();
    end
    
    return 1;
end
