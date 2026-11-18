--[[
    クエストに紐づくスクリプト
    
  ]]
  
  
function miraSkill()
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4);
    if unit ~= nil then
        if unit:getUnitState() ~= kUnitState_skill then
            unit:takeSkill(1);
        end
    end
    return 1;
end

function miraBurst()
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4);
    if unit ~= nil then
        unit:takeSkillWithCutin(2);
        unit:setInvincibleTime(3);
    end
    return 1;
end
    
--初期化
function quest_init()
    print("init");
    mira_skill_timer = 1.0;
    mira_burst_timer = 30.0;

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
    megast.Battle:getInstance():setBattleLWFEnable(false);

    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101044111 , 20, 4);
    unit:setBaseHP(2500);
    unit:setHP(2500);
    unit:setPosition(100,-90);
    unit:setDefaultPosition(100,-90);
    unit:setBasePower(2500);
    unit:takeIn(1); 
    unit:setSkillInvocationWeight(25); 

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

    mira_burst_timer = mira_burst_timer - delta;
    mira_skill_timer = mira_skill_timer - delta;

    if mira_burst_timer < 0 then
        miraBurst();
        mira_burst_timer = 30.0;
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

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem ".. index .. "," .. itemNo);
    
    return 1;
end

--ユニットのスキル発動時
function useSkill(index, isBurst)
    if mira_skill_timer < 0 then
        BattleControl:get():callLuaMethod(10705 , "miraSkill" , 1.7);
        mira_skill_timer = 6;
    end

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
