--バトルのセットアップ時
function questStart()
    print("Lua:questStart");
    --megast.Battle:getInstance():setBattleLWFEnable(false);
    for i = 0,3 do
        ---元々のユニット削除
        megast.Battle:getInstance():getPlayerTeam():removeUnit(i, true);
        ---未装備UIの表示が消えない不具合対策で実装,一度ミラを装備ありで召喚
        megast.Battle:getInstance():getPlayerTeam():addTeamUnitWithItem(108357312,120,i,100014100,0,0);
        ---ミラを削除,装備ありの状態なので未装備UIが非表示となる
        megast.Battle:getInstance():getPlayerTeam():removeUnit(i, true);
    end
    local index = 1;
    ---操作可能ユニットを召喚
    local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnitWithItem(108357312,120,index,0,0,0);
    --unit:setBaseHP(2500);
    --unit:setHP(2500);
    unit:setPosition(100,-90);
    unit:setDefaultPosition(100,-90);
    --unit:setBasePower(2500);
    ---おすすめAIをセット（真奥義発動ライブラリ）
    unit:setRecommendedAI(2);
    unit:takeIn(1);
    ---UIの所持スキル説明パネルを更新
    megast.Battle:getInstance():updateUnitBattleSkillDetailLayer();
    ---固有アビリティ
    ---アビリティ1
    local ability1 = unit:getTeamUnitCondition():addCondition(0,17,100,99999,0);
    ability1:setScriptID(59);
    ---アビリティ2
    local ability2 = unit:getTeamUnitCondition():addCondition(40364600,29,15,99999,0);
    ability2:setScriptID(520);
    ability2:setValue1(3)
    ability2:setValue2(40364600)
    ability2:setValue3(15)
    ability2:setValue4(34)
    ability2:setValue5(29)
    ---アビリティ3
    local ID = 52000 + (unit:getIndex() * 10);
    local ability3 = unit:getTeamUnitCondition():addCondition(ID,238,0,99999,0);
    ability3:setScriptID(520);
    ability3:setValue1(3);
    ability3:setValue2(40364600);
    ability3:setValue3(15);
    ability3:setValue4(34);
    ability3:setValue5(29);
    ---ダメージブーストLv1
    local damageBoost = unit:getTeamUnitCondition():addCondition(0,17,1,99999,0);
    damageBoost:setScriptID(349);
    ---info表示
    quest_2078310Class:onStart()
    return 1;
end

quest_2078310Class = {
    battleEnd = false,
    inWave = false
}

function quest_init()
    print("init");
    quest_2078310Class:setUpMessages()
    return 1;
end

function quest_2078310Class:onStart()
    self:showMessage(self.START_MESSAGE_LIST)
    return 1;
end

function quest_2078310Class:setUpMessages()
    self.TEXT = summoner.Text:fetchByQuestID(2078310);
    self.START_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "寄らば斬ります！寄らずとも斬ります！",
            COLOR = summoner.Color.green,
            DURATION = 7,
            isPlayer = true
        }
    }
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function quest_2078310Class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function quest_2078310Class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function quest_2078310Class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function quest_2078310Class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function quest_2078310Class:showFormatMessages(messages,count)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(string.format(v.MESSAGE,count),v.DURATION,v.COLOR);
    end
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("initPlayerTeam");

    return 1;
end

--エネミーのチームの初期化
function initEnemyTeam(team, wave)
    print("initEnemyTeam");
    megast.Battle:getInstance():getTeam(false):removeUnit(6);
    return 1;
end

--ユニットが生成された時
function quest_takeIn(wave,unit)
    print("Lua:takeIn");

    return 1;
end

--戦闘開始の準備ができた時
function battleReady(wave)
    print("Lua:battleReady");

    return 1;
end

--戦闘の開始命令 注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    ---スーパーダッシュ
    local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(1);
    unit:addSP(200)
    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)

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
