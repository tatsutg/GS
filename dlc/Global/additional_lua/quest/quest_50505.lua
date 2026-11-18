--[[
    クエストに紐づくスクリプト
    5−5 真グラード[EX] ＆ 真ニーア[EX]
  ]]
    
--初期化
function quest_init()
    print("init");
    tagSkillFLG = false;    --開始直後のみ同時攻撃させる為のフラグ
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

function glardSkill()
    megast.Battle:getInstance():getEnemyTeam():getTeamUnit(4):takeSkillWithCutin(2);
    return 1;
end

function nierSkill()
    megast.Battle:getInstance():getEnemyTeam():getTeamUnit(1):takeSkillWithCutin(2);
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

    --バトル開始の直後にグラードとニーアの奥義を発動させる。バトルスタートからおおよそ５秒後。
    if time > 1.5 then
        if tagSkillFLG == false then
            tagSkillFLG = true;
            glardSkill();
            BattleControl:get():callLuaMethod(50505,"nierSkill",1.25)
        end
    end

    fen_cast_timer = fen_cast_timer - delta;    
    if fen_cast_timer < 0 then
        --fenCast();
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
