--[[
    クエストに紐づくスクリプト
    
    チュートリアルその１
    phase : 0 wave1開始
    phase : 1 説明１開始
    phase : 2 ユニットをハイライト
    phase : 3 ガナン登場
    phase : 4 敵出現
    phase : 5 ちょっと待つ
    phase : 6 バトル開始
    phase : 7 スキルシナリオ 一時停止
    phase : 8 ユニットアイコンハイライト
    phase : 9 スキル使用可能 アイコンフォーカス
    phase :10 スキル発動 再開
    phase :11 スキル説明後半
    phase :12 スキルゲージハイライト
    phase :13 wave1終了

    phase :20 wave2開始
    phase :21 説明２開始
    phase :22 属性シンボル点滅
    phase :23 ハイライト戻す
    phase :24 ポップアップ消去
    phase :25 バトル開始
    phase :26 wave2終了

    phase :30 wave3開始(バトル開始)
    phase :31 敵が死んだので説明３−１開始
    phase :32 少しだけ動かす
    phase :33 説明３−２
    phase :34 奥義発動待ち
    phase :35 少しだけ動かす（奥義発動中）
    phase :36 説明３−３
    phase :37 wave3終了

  ]]
    
function phase2()
    print("Lua:run pahse2()");

    BattleControl:get():showOverlay();
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
    if unit ~= nil then
        BattleControl:get():focusNode(unit);
        BattleControl:get():showFocusFrame(unit,0,65,200,200);
    end
end

function phase3()
    print("Lua:run pahse3()");

    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
    BattleControl:get():hideFocusFrame();
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101114111 , 1, 4);
    unit:setPosition(150,-50);
    unit:setDefaultPosition(150,-50);
    unit:setBasePower(280);
    unit:takeIn();
end

function phase4()
    print("Lua:run pahse4()");

    for i = 0, 6 do
        local unit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
        if unit ~= nil then
            unit:takeIn(1);
            unit:setSkillInvocationWeight(0);
        end
    end
end

function phase5()
    print("Lua:run pahse5()");

   BattleControl:get():callLuaMethod(10101 , "shiftPhase" , 1);
end

function phase7()
    print("Lua:run pahse7()");

    BattleControl:get():pause();
    BattleControl:get():playScenario(1010102);
end

function phase8()
    print("Lua:run pahse8()");
    
    BattleControl:get():setStatusEnable(true);
    BattleControl:get():grayoutStatus(0, false, true);
    BattleControl:get():showOverlay();
    BattleControl:get():focusNode("//status_0" , "")
    BattleControl:get():showFocusFrame("//status_0","//face_panel",75,80,150,175);
end

function phase9()
    print("Lua:run pahse9()");

    local x = BattleControl:get():getNodePositionX("//status_0","//face_panel");
    local y = BattleControl:get():getNodePositionY("//status_0","//face_panel");
    local scale = BattleControl:get():getNodeScale("//status","");
    local width = 150;
    local height = 170;
    BattleControl:get():hideFocusFrame();    
    BattleControl:get():showFocusGuide("//status_0","//layout",x,y,width,height,0);
            
end

function phase10()
    print("Lua:run phase10()");
    BattleControl:get():resetFocus();
    BattleControl:get():resume();
    BattleControl:get():hideFocusGuide();
    BattleControl:get():hideOverlay();
end


function phase11()
    print("Lua:run phase11()");
    BattleControl:get():playScenario(1010103);
end

function phase12()
    print("Lua:run phase12()");
    BattleControl:get():showOverlay();
    BattleControl:get():focusNode("//status_0","//charge_bg");
    BattleControl:get():focusNode("//status_0","//charge_2");
    BattleControl:get():showFocusFrame("//status_0","//charge_bg",60,10,160,40);
end

function phase13()
    print("Lua:run phase13()");
    megast.Battle:getInstance():waveEnd(true);
    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
    BattleControl:get():hideFocusFrame();
end


--wave2 start

function phase22()
    print("Lua:run phase22()");
    
    BattleControl:get():showOverlay();

    local playerUnit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
    if playerUnit ~= nil then
        BattleControl:get():focusNode(playerUnit:getElementIcon());
        BattleControl:get():showFocusFrame(playerUnit:getElementIcon(),50,50,110,110);
    end
    for i = 0, 6 do
        local enemyUnit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
        if enemyUnit ~= nil then
            BattleControl:get():focusNode(enemyUnit:getElementIcon());
            BattleControl:get():showFocusFrame(enemyUnit:getElementIcon(),50,50,110,110);
        end
    end
    BattleControl:get():focusNode("//status_0","//elemental_icon");
    BattleControl:get():showFocusFrame("//status_0","//elemental_icon",50,50,90,90);

    megast.Battle:getInstance():setBattleState(kBattleState_pause);
end

function phase23()
    print("Lua:run phase23()");
    
    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
    BattleControl:get():hideFocusFrame();
end

function phase26()
    print("Lua:run phase26()");
    
    megast.Battle:getInstance():setBattleState(kBattleState_ready);
end

--wave2 end

--wave3 start
function phase31()
    print("Lua:run phase31()");        
    BattleControl:get():callLuaMethod(10101 , "scenario" , 1);
end

function scenario()
    BattleControl:get():playScenario(1010105);
    BattleControl:get():pause();
    megast.Battle:getInstance():setBattleState(kBattleState_pause);
    return 1;
end

function phase33()
    print("Lua:run phase33()");
    BattleControl:get():hideScenario(3);
    BattleControl:get():focusSP();
    BattleControl:get():resumeSP();
    BattleControl:get():callLuaMethod(10101 , "focusOugi" , 3);
    
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(0);
    unit:setBurstPoint(95);
    
    for i = 0, 6 do
       local enemyUnit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
       if enemyUnit ~= nil then
            enemyUnit:setDeadDropSp(1);
       end
    end
end

function focusOugi()
    BattleControl:get():showFocusFrame("//status_0","//unit_bg",80,150,160,70);
    return 1;
end

function phase34()
    print("Lua:run phase34()");
    
    megast.Battle:getInstance():setBattleState(kBattleState_pause);
    local x = BattleControl:get():getNodePositionX("//status_0","//face_panel");
    local y = BattleControl:get():getNodePositionY("//status_0","//face_panel");
    local scale = BattleControl:get():getNodeScale("//status","");
    local width = 150;
    local height = 170;
    
    BattleControl:get():showBurstGuide(0);
    BattleControl:get():showFocusGuide("//status_0","//layout",x,y,width,height,1);
    BattleControl:get():hideFocusFrame();
    BattleControl:get():hideOverlay();
    BattleControl:get():resetFocus();
end

function phase35()
    print("Lua:run phase35()");
    
    BattleControl:get():resume();
    BattleControl:get():hideFocusGuide();
    BattleControl:get():hideFocusFrame();

    for i = 0, 6 do
        local enemyUnit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
        if enemyUnit ~= nil then
            --enemyUnit:setHP(600);
        end
    end

    --BattleControl:get():playScenario(1010114);
end

function phase37()
    print("Lua:run phase37()");
    
    megast.Battle:getInstance():waveEnd(true);
end

--wave3 end


function shiftPhase()
    phase = phase + 1;
    print("Lua:pahse"..phase);

    if phase == 2 then
        phase2();
    elseif phase == 3 then
        phase3();
    elseif phase == 4 then
        phase4();
    elseif phase == 5 then
        phase5();
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
    elseif phase == 12 then
        phase12();
    elseif phase == 13 then
        phase13();
    elseif phase == 22 then
        phase22();
    elseif phase == 23 then
        phase23();
    elseif phase == 26 then
        phase26();
    elseif phase == 31 then
        phase31();
    elseif phase == 33 then
        phase33();
    elseif phase == 34 then
        phase34();
    elseif phase == 35 then
        phase35();
    elseif phase == 37 then
        phase37();
    end

    return 1;
end

function gunanSkill()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkill(1);
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

    local unit = team:addTeamUnitWithItem(101012411,1,0,100181300,100014105,0);
    
    return 0;
end

function initEnemyTeam(team,wave)
    print("initEnemyTeam");

    return 1;
end

function quest_takeIn(wave,unit)
    print("Lua:takeIn");

    if wave == 1 and phase == 0 then
        if unit:getisPlayer() == false then
            return 0;
        end
    end
    
    return 1;
end


function questStart()
    print("Lua:questStart");
    
    BattleControl:get():grayoutStatus(0, true, true);
    BattleControl:get():setBreakBarEnable(false);
    BattleControl:get():setBossSkillCounterEnable(false);

    return 1;
end

function battleReady(wave)
    print("Lua:battleReady");
    
    if wave == 1 then
        if phase == 0 then 
            BattleControl:get():playScenario(1010101);
            phase = 1;
        end
    end
    
    if wave < 3 then
        for i = 0, 6 do
            local enemyUnit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
            if enemyUnit ~= nil then
                enemyUnit:setDamageDropSp(0);
                enemyUnit:setDeadDropSp(0);
            end
        end
    end
    
    if wave == 3 then
        for i = 0, 6 do
            local enemyUnit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
            if enemyUnit ~= nil then
                enemyUnit:setDeadDropSp(100);
            end
        end
    end

    return 1;
end

--注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    if wave == 1 then
        if phase < 6 then 
            return 0;
        end
    
        if phase == 6 then 
            BattleControl:get():callLuaMethod(10101 , "shiftPhase" , 5.4);
            return 1;
        end
    elseif wave == 2 then
        if phase <= 20 then
            BattleControl:get():playScenario(1010104);
            phase = 21;
            return 0;
        end

        if phase < 26 then
            return 0;
        end
    elseif wave == 3 then
        if phase < 30 then
            phase = 30;
            return 0;
        end

        if phase == 31 or phase == 33 or phase == 34 or phase == 36 then
            return 0;
        end
    end
    return 1;
end

function quest_update(wave , delta ,time)
    
    return 1;
end

function deadUnit(wave , unit)
    if unit:getisPlayer() == true then
        unit:setHP(1000);
        return 0;
    else
        if phase == 30 then
            shiftPhase();
        end
    end
    
    if phase < 9 then
        unit:setHP(300);
        return 0;
    end
    
    return 1;
end

function waveEnd(wave,iswin)
    print("Lua:waveEnd "..wave);
    
    if wave == 1 and phase < 12 then
        BattleControl:get():callLuaMethod(10101 , "shiftPhase" , 1.5);
        megast.Battle:getInstance():setBattleState(kBattleState_pause);
        return 0;
    end
    
    if phase == 35 then
        BattleControl:get():playScenario(1010114);
        shiftPhase();
        return 0;
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
    if phase < 9 then
        return 0;
    end
    if phase == 9 then
        shiftPhase();
    end
    if phase == 34 then
        if isBurst == true then
            shiftPhase();
        else
            BattleControl:get():showBurstGuide(0);
            return 0;
        end
    end
    
    if phase < 34 then
        if isBurst == true then
            return 0;
        end
    end
       
       
    return 1;
end

function onTouchItem(index,itemIndex)
    
    return 0;
end

function useSkill(index, isBurst)
    BattleControl:get():callLuaMethod(10101 , "gunanSkill" , 1.7);
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
    if phase < 5 then
        phase = 4;
        shiftPhase();
        return 1;
    end
    
    if phase < 9 then
        phase = 8;
        shiftPhase();
        return 1;
    end
    
    if phase < 13 then
        phase = 12;
        shiftPhase();
        return 1;
    end
    
    if phase < 25 then
        phase = 25;
        shiftPhase();
        return 1;
    end
    
    if phase == 36 then
        megast.Battle:getInstance():setBattleState(kBattleState_active);
        shiftPhase();
    end
    
    return 1;
end
