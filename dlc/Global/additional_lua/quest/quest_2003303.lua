--[[
    ハロウィンイベントクエスト３　世界が混ざり合う夜
  ]]
    
--初期化
function quest_init()
    print("init");
    return 1;
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    

    return 1;
end

--エネミーのチームの初期化
function initEnemyTeam(team, wave)
    print("initEnemyTeam");
    print("initPlayerTeam");
    
    return 1;
end

function ragnaSkill()
    print("*****************ragna takeSkill3");
    local ragna = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4);
    if ragna ~= nil then
        ragna:takeSkill(1);
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
    if wave < 2 then
        return 1;
    end
    skill_timer = 1.0;
    skill3_timer = 5;
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(100615112,70,4);
    unit:setBaseHP(80000);
    unit:setHP(80000);
    unit:setEvolutionStage(2);
    unit:setPosition(100,-90);
    unit:setDefaultPosition(100,-90);
    unit:setBasePower(3000);
    unit:setNextAnimationName("idle");
    -- unit:takeIn(1);
    unit:excuteAction();
    megast.Battle:getInstance():setBattleState(kBattleState_active);
    return 1;
end

--戦闘の開始命令 注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    megast.Battle:getInstance():setBattleState(kBattleState_active);
    return 1;
end

--戦闘中のupdate
function quest_update(wave,delta,time)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    if skill_timer == nil then
        return 1;
    end
    skill_timer = skill_timer - delta;
    skill3_timer = skill3_timer - delta;
    if skill3_timer <= 0 then
        skill3_timer = 15;
        local ragna = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4);
        if ragna ~= nil then
            ragna:takeSkill(2);
            ragna:setBurstState(kBurstState_active);
            
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
    if skill_timer < 0 then
        BattleControl:get():callLuaMethod(2000324 , "ragnaSkill" , 0.7);
        skill_timer = 6;
    end
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
