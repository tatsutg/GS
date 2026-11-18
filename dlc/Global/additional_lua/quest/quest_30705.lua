--@additionalItem,100611400,100481200
--[[
    クエストに紐づくスクリプト
    3-7 イリスコピー[1]
  ]]
    
--初期化
function quest_init()
    print("init");
    -- fen_skill_timer = 1.0;    --フェンのスキルクールタイム
    fen_cast_timer = 15.0;    --フェンの奥義クールタイム


    return 1;
end

--フェンのスキルを発動
-- function fenSkill()
--     megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeSkill(1);
--     return 1;
-- end

--フェンがアイテムを使用
function fenCast()
    -- local rand = math.random(2) - 1;
    -- megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeItemSkill(rand);

    local rand = math.random(100);
    if rand < 50 then
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeItemSkill(0);
    else
        megast.Battle:getInstance():getPlayerTeam():getTeamUnit(4):takeItemSkill(1);
    end

    return 1;
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("initPlayerTeam");
    
    return 1;
end

function addUnit()
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(101054311,1,4);
    unit:setBaseHP(15000);
    unit:setHP(15000);
    unit:setPosition(150,-50);
    unit:setDefaultPosition(150,-50);
    unit:setBasePower(10000);
    unit:setItemSkill(0,100611400);
    unit:setItemSkill(1,100481200);
    -- unit:setItemSkill(2,100722300);
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
    addUnit();
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

    fen_cast_timer = fen_cast_timer - delta;
    -- fen_skill_timer = fen_skill_timer - delta;
    
    if fen_cast_timer < 0 then
        fenCast();
        fen_cast_timer = 15.0;
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
    -- if fen_skill_timer < 0 then
    --     BattleControl:get():callLuaMethod(30705 , "fenSkill" , 1.7);
    --     fen_skill_timer = 6;
    -- end
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

    return 1;
end
