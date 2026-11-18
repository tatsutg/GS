--[[
   ゼイオルグイベントクエスト20
  ]]
    
--初期化
function quest_init()
    print("init");
    zayorg_skill_timer = 1.0;     --ゼイオルグのスキルクールタイム
    zayorg_burst_timer = 30.0;    --ゼイオルグの奥義クールタイム
    return 1;
end

--ゼイオルグのスキルを発動
function zayorgSkill()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkill(1);
    return 1;
end

--ゼイオルグの奥義を発動
function zayorgBurst()
    megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkillWithCutin(2);
    return 1;
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("initPlayerTeam");
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101064411,1,4);--ゼイオルグ
    unit:setBaseHP(45000);
    unit:setHP(45000);
    unit:setPosition(100,-50);
    unit:setDefaultPosition(100,-50);
    unit:setBasePower(10000);
    unit:takeIn();
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
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    
    zayorg_burst_timer = zayorg_burst_timer - delta;
    zayorg_skill_timer = zayorg_skill_timer - delta;
    if zayorg_burst_timer < 0 then
        zayorgBurst();
        zayorg_burst_timer = 30.0;
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
    if zayorg_skill_timer < 0 then
        BattleControl:get():callLuaMethod(2001424 , "zayorgSkill" , 1.7);
        zayorg_skill_timer = 6;
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

function quest_castItem(index, itemNo, targetIndex)    
    return 1;
end