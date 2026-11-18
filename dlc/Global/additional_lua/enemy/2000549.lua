--@additionalEnemy,2000546,2000547,2000547,2000547
--[[
    6-5-5 破望秘魔リオン
]]

local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    print(("Lua: Called `new` with `%s`"):format(id))

    local returnOne = function() return 1 end
    local returnDamage = function(self, unit, enemy, value) return value end
    local cls = {
        param = {
            version = 1.3,
            isUpdate = true
        },
        -- ハルフゥ、シェイド、シェイド、シェイド
        SUMMON_ENEMY_ID_LIST = {2000546, 2000547, 2000547, 2000547},
        -- 1回に召喚する最大数
        NUM_SUMMONED_ENEMIES_LIMIT = 3,
        -- EnemyTeamのindexの最大値
        MAX_ENEMY_INDEX = 6
    }

    -- デフォルトのイベントハンドラに関数を割り当てる
    for i, name in ipairs({
        "receive1",
        "start", "update", "dead", "run",
        "startWave", "endWave",
        "excuteAction",
        "takeIdle", "takeFront", "takeDamage", "takeBack", "takeBreake", "takeAttack", "takeSkill"
    }) do
        cls[name] = returnOne
    end
    for i, name in ipairs({"takeDamageValue", "attackDamageValue", "takeBreakeDamageValue"}) do
        cls[name] = returnDamage
    end

    -- スキルか奥義を使ったとき
    function cls:takeSkill(unit, index)
        if index == 2 then
            -- 奥義のとき新しいエネミーを召喚する
            self:summonNewEnemy()
        end
        return 1
    end

    -- 新しいエネミーを召喚する
    function cls:summonNewEnemy()
        local enemyIndex = nil
        local enemyTeam = megast.Battle:getInstance():getEnemyTeam()
        local numSummonedEnemies = 0
        -- 空いてるindexにエネミーを割り当てる
        for i = 0, self.MAX_ENEMY_INDEX do
            local target = enemyTeam:getTeamUnit(i)
            if target == nil then
                enemyTeam:addUnit(i, self:getRandomEnemyId())
                numSummonedEnemies = numSummonedEnemies + 1
                if numSummonedEnemies >= self.NUM_SUMMONED_ENEMIES_LIMIT then
                    break
                end
            end
        end
        return self
    end

    -- ランダムにエネミーIDを取得する
    function cls:getRandomEnemyId()
        local lastIndex = table.maxn(self.SUMMON_ENEMY_ID_LIST)
        local sampleIndex = LuaUtilities.rand(lastIndex) + 1
        local enemyId = self.SUMMON_ENEMY_ID_LIST[sampleIndex]
        return enemyId
    end

    register.regist(cls, id, cls.param.version)
    return 1
end
