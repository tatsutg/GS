--@additionalEnemy,1001302
--[[
    クエストに紐づくスクリプト
    ゴルネコ強襲 中級
    ルール
    1体倒されるごとに1体追加し、最大50体倒すまでWave1が続く
]]

local table = table

local megast = megast
local kBattleState_active = kBattleState_active
local BattleControl = BattleControl
local LuaUtilities = LuaUtilities

-- 初期化
function quest_init()
    print("Lua: init")

    -- class Quest
    -- クラス定数、変数
    Quest = {
        -- int クエストID
        QUEST_ID = 1001302,
        -- int 召喚するエネミーのenemy_id
        ENEMY_ID = 1001302,
        -- int エネミーの上限
        NUM_ENEMIES_LIMIT = 50,
        -- int 最初から召喚されているエネミーの数
        INITIAL_ENEMIES = 6,
        -- int enemyTeamの最大インデックス
        MAX_ENEMY_INDEX = 7,
        -- string 撃破数表示の文言
        DEAD_ENEMY_TEXT = summoner.Text:fetchByQuestID(1001302).DEAD_ENEMY_TEXT,
        -- Quest 自分のインスタンス
        _instance = nil
    }

    -- コンストラクタ
    function Quest:new()
        local mt = {__index = self}
        local vars = {
            -- int 召喚するエネミーのenemy_idの配列、複数設定できるように配列にしておく
            summonEnemyIdList = {self.ENEMY_ID},
            -- int 討伐したエネミーの数
            numDeadEnemies = 0,
            -- int 召喚したエネミーの数
            numSummonedEnemies = self.INITIAL_ENEMIES
        }
        local instance = setmetatable(vars, mt)
        return instance
    end

    -- シングルトンなのでgetInstanceを介してインスタンスを取得する
    function Quest:getInstance()
        if self._instance == nil then
            self._instance = self:new()
        end
        return self._instance
    end

    -- 撃破したエネミー数を加算する
    function Quest:addDeadEnemy(numDeadEnemies)
        self.numDeadEnemies = self.numDeadEnemies + numDeadEnemies
        return self
    end

    -- バトル画面の左に撃破数を表示する
    function Quest:slideInNumDeadEnemies()
        BattleControl:get():pushEnemyInfomation(self.numDeadEnemies .. self.DEAD_ENEMY_TEXT, 255, 255, 255, 1)
        return self
    end

    -- delay秒後にコールされる関数名を登録する
    function Quest:setCallbackToCpp(funcName, delay)
        BattleControl:get():callLuaMethod(self.QUEST_ID, funcName, delay)
        return self
    end

    -- 新しいエネミーを召喚する
    function Quest:summonNewEnemy()
        local enemyIndex = nil
        local enemyTeam = megast.Battle:getInstance():getEnemyTeam()
        -- 空いてるindexを探す
        for i = 0, self.MAX_ENEMY_INDEX do
            local target = enemyTeam:getTeamUnit(i)
            if target == nil then
                enemyIndex = i
                break
            end
        end
        enemyTeam:addUnit(enemyIndex, self:getRandomEnemyId())
        self.numSummonedEnemies = self.numSummonedEnemies + 1
        return self
    end

    -- ランダムにエネミーIDを取得する
    function Quest:getRandomEnemyId()
        local lastIndex = table.maxn(self.summonEnemyIdList)
        local sampleIndex = LuaUtilities.rand(lastIndex) + 1
        local enemyId = self.summonEnemyIdList[sampleIndex]
        return enemyId
    end

    -- まだ召喚できる場合は真を返す
    function Quest:isAbleToSummon()
        return self.numSummonedEnemies < self.NUM_ENEMIES_LIMIT
    end

    -- 撃破数が目標値に達したら真を返す
    function Quest:hasEnded()
        return self.numDeadEnemies >= self.NUM_ENEMIES_LIMIT
    end

    -- /class Quest

    return 1
end

-- プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("Lua: initPlayerTeam")
    return 1
end

-- エネミーのチームの初期化
function initEnemyTeam(team, wave)
    print("Lua: initEnemyTeam")
    return 1
end

-- ユニットが生成された時
function quest_takeIn(wave, unit)
    print("Lua: takeIn")
    return 1
end

-- バトルのセットアップ時
function questStart()
    print("Lua: questStart")
    return 1
end

-- 戦闘開始の準備ができた時
function battleReady(wave)
    print("Lua: battleReady")
    return 1
end

-- 戦闘の開始命令 注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    return 1
end

-- 戦闘中のupdate
function quest_update(wave, delta, time)
    return 1
end

-- ユニットが倒れた時
function deadUnit(wave, unit)
    -- エネミー倒した後少し待ってから追加エネミー召喚
    if unit:getisPlayer() == false then
        local funcName = "summon"
        local delay = 1 + LuaUtilities.rand(10)/10
        Quest:getInstance():addDeadEnemy(1):slideInNumDeadEnemies():setCallbackToCpp(funcName, delay)
    end
    return 1
end

-- エネミー追加
function summon()
    if Quest:getInstance():isAbleToSummon() then
        Quest:getInstance():summonNewEnemy()
        return 1
    else
        return 0
    end
end

-- 戦闘が終了した時
function waveEnd(wave, iswin)
    if iswin == true then
        -- 目標のエネミー召喚数に達してない場合はウェーブを終わらせない。
        if not Quest:getInstance():hasEnded() then
            megast.Battle:getInstance():setBattleState(kBattleState_active)
            return 0
        end
    end
    return 1
end

-- 画面タッチ時
function onTouchBegan()
    return 1
end

-- 画面タッチ終了時
function onTouchEnded(x, y)
    return 1
end

-- スキルボタンのタッチ終了時
function onTouchSkillEnded(index, isBurst)
    return 1
end

-- アイテムボタンタッチ時
function onTouchItem(index, itemIndex)
    return 1
end

-- ユニットのスキル発動時
function useSkill(index, isBurst)
    return 1
end

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem " .. index .. "," .. itemNo)
    return 1
end

-- シナリオのイベントコールバック
function scenarioOnButtonCallback(event)
    return 1
end

-- シナリオの終了時コールバック
function scenarioEndCallback(event)
    return 1
end
