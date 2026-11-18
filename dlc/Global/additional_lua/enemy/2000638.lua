--@additionalEnemy,2000637,2000636,2000639
--@additionalItem,101922301,100732501
--[[
    試練の回廊 １６階/暗黒魔導オグナード
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
        ENEMY_ID = 2000638,
        -- EnemyTeamのindexの最大値
        MAX_ENEMY_INDEX = 6,
        -- 1回に召喚する最大数
        NUM_SUMMONED_ENEMIES_LIMIT = 3,
        -- 召喚するエネミーを変えるHPの割合
        PHASE_HP_RATE_TABLE = {
            [1] = 1.0,
            [2] = 0.7,
            [3] = 0.5,
            [4] = 0.2
        },
        -- 召喚するエネミーのID
        PHASE_ENEMY_ID_TABLE = {
            [1] = 0,
            [2] = 2000637, -- ファフニール
            [3] = 2000636, -- 竜牙兵
            [4] = 2000639  -- グロヴォーグ
        },
        -- エネミーが変わったときのメッセージ(複数)
        PHASE_MESSAGE_TABLE = {
            [1] = {},
            [2] = {summoner.Text:fetchByEnemyID(2000638).mess1, summoner.Text:fetchByEnemyID(2000638).mess2},
            [3] = {summoner.Text:fetchByEnemyID(2000638).mess1, summoner.Text:fetchByEnemyID(2000638).mess3},
            [4] = {summoner.Text:fetchByEnemyID(2000638).mess1, summoner.Text:fetchByEnemyID(2000638).mess4}
        },
        -- アイテムスキルID
        ITEM_ID_TABLE = {
            101922301, -- 神具『フロストクィル』Lv1
            100732501  -- 魔鎌エビルサイスLv1
        },
        currentPhaseNumber = 1,
        equipments = {},
        targetUnitPos = {
            x = nil,
            y = nil
        },
        orbitNames = {
            magic = "3skill2magic",
            sword = "3skill2sword",
            attackStart = "3attack1sword",
            attackFinish = "3attack1explode"
        },
        messages = {}
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

    -- event/開始時
    print(("Lua: Listening to event `start`"):format())
    function cls:start(unit)
        print(("Lua: Called `start`"):format())
        for i, itemId in ipairs(self.ITEM_ID_TABLE) do
            print(("Lua: item-skill-index is `%s`"):format(i - 1))
            print(("Lua: itemId is `%s`"):format(itemId))
            self.equipments[i] = unit:setItemSkill(i - 1, itemId)
        end
        self.hpMarkers = {
            {
                HP = 70,isUsed = false,MARKER = unit:addNumHpMarker(0.7)
            },
            {
                HP = 50,isUsed = false,MARKER = unit:addNumHpMarker(0.5)
            },
            {
                HP = 20,isUsed = false,MARKER = unit:addNumHpMarker(0.2)
            }
        }
        return 1
    end

    function cls:update(unit, dt)
        for _,marker in pairs(self.hpMarkers) do
            local hpPercent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if not marker.isUsed and hpPercent < marker.HP then
                marker.isUsed = true
                unit:removeHpMarker(marker.MARKER)
            end
        end
        return 1
    end

    -- event/Wave開始時
    print(("Lua: Listening to event `startWave`"):format())
    function cls:startWave(unit, waveNum)
        print(("Lua: Called `startWave`"):format())
        BattleControl:get():pushEnemyInfomationWithConditionIcon(summoner.Text:fetchByEnemyID(2000638).mess5, 42, 200, 0, 200, 5)
        BattleControl:get():pushEnemyInfomationWithConditionIcon(summoner.Text:fetchByEnemyID(2000638).mess6, 66, 200, 0, 0, 5)
        BattleControl:get():pushEnemyInfomationWithConditionIcon(summoner.Text:fetchByEnemyID(2000638).mess7, 60, 200, 200, 0, 5)
        BattleControl:get():pushEnemyInfomationWithConditionIcon(summoner.Text:fetchByEnemyID(2000638).mess8, 65, 0, 200, 200, 5)
        return 1
    end

    -- event/スキルか奥義を使ったとき
    print(("Lua: Listening to event `takeSkill`"):format())
    function cls:takeSkill(unit, index)
        print(("Lua: Called `takeSkill` with index `%s`"):format(index))
        if index == 1 then
            -- スキルときは装備スキルを使う
            self:useRandomEquipment(unit)
        elseif index == 2 then
            -- 奥義のとき新しいエネミーを召喚する
            local enemyId = self.PHASE_ENEMY_ID_TABLE[self.currentPhaseNumber]
            print(("Lua: currentPhaseNumber is `%s`"):format(self.currentPhaseNumber))
            print(("Lua: enemyId is `%s`"):format(enemyId))
            if enemyId ~= nil and enemyId ~= 0 then
                self:summonNewEnemy(enemyId)
            end
            self.targetUnitPos.x = nil
            self.targetUnitPos.y = nil
        end
        return 1
    end

    -- event/全ての行動
    print(("Lua: Listening to event `excuteAction`"):format())
    function cls:excuteAction(unit)
        local currentHPRate = unit:getHP()/unit:getCalcHPMAX()
        local hpRate = self.PHASE_HP_RATE_TABLE[self.currentPhaseNumber + 1]
        if hpRate ~= nil and currentHPRate <= hpRate then
            self.currentPhaseNumber = self.currentPhaseNumber + 1
            local messages = self.PHASE_MESSAGE_TABLE[self.currentPhaseNumber]
            if messages ~= nil and table.maxn(messages) >= 1 then
                self.messages = messages
                BattleControl:get():callLuaMethod(self.ENEMY_ID, "showMessage", 0)
            end
        end
        return 1
    end

    -- event/Spineからの呼び出し
    print(("Lua: Listening to event `run`"):format())
    function cls:run(unit, str)
        print(("Lua: Called `run` with `%s`"):format(str))
        if str == "swordAttack" then
            return self:swordAttack(unit)
        end
        local orbitName = str:match("addOrbit(%w+)")
        if orbitName ~= nil then
            return self:addOrbit(unit, orbitName)
        end
        return 1
    end

    -- 新しいエネミーを召喚する
    function cls:summonNewEnemy(enemyId)
        print(("Lua: Called `summonNewEnemy`"):format())
        local enemyIndex = nil
        local enemyTeam = megast.Battle:getInstance():getEnemyTeam()
        local numSummonedEnemies = 0
        -- 空いてるindexにエネミーを割り当てる
        for i = 0, self.MAX_ENEMY_INDEX do
            local target = enemyTeam:getTeamUnit(i)
            if target == nil then
                enemyTeam:addUnit(i, enemyId)
                numSummonedEnemies = numSummonedEnemies + 1
                if numSummonedEnemies >= self.NUM_SUMMONED_ENEMIES_LIMIT then
                    break
                end
            end
        end
        return self
    end

    -- ランダムに装備を使う
    function cls:useRandomEquipment(unit)
        print(("Lua: Called `useRandomEquipment`"):format())
        local lastIndex = table.maxn(self.equipments)
        if lastIndex < 1 then
            return false
        end
        local sampleIndex = LuaUtilities.rand(lastIndex) + 1
        local equipment = self.equipments[sampleIndex]
        unit:takeItemSkill(sampleIndex - 1)
        equipment:setCoolTimer(0)
        return true
    end

    function cls:addOrbit(unit, orbitName)
        print(("Lua: Called `addOrbit` with `%s`"):format(orbitName))
        local addObj = nil
        local setZOrder = 0
        if orbitName == self.orbitNames.magic then
            addObj = unit:addOrbitSystem(self.orbitNames.magic, 0)
            setZOrder = -1
        elseif orbitName == self.orbitNames.sword then
            addObj = unit:addOrbitSystem(self.orbitNames.sword, 0)
            setZOrder = 1
        end
        local targetUnit = unit:getTargetUnit()
        if targetUnit ~= nil  and addObj ~= nil then
            local tagetUnitZOrder = targetUnit:getZOrder()
            local inited = self.targetUnitPos.x or self.targetUnitPos.y or false
            if inited == false then
                local targetPosX = targetUnit:getPositionX()
                local targetPosY = targetUnit:getPositionY()
                self.targetUnitPos.x = targetPosX
                self.targetUnitPos.y = targetPosY
            end
            addObj.autoZorder = false
            addObj:setZOrder(tagetUnitZOrder + setZOrder)
            addObj:setPosition(self.targetUnitPos.x, self.targetUnitPos.y)
        end
        return 1
    end

    function cls:swordAttack(unit)
        print(("Lua: Called `swordAttack`"):format())
        local orbit = unit:addOrbitSystem(self.orbitNames.attackStart, 1)
        orbit:setHitCountMax(1)
        orbit:setEndAnimationName(self.orbitNames.attackFinish)
        local posX = unit:getPositionX()
        local posY = unit:getPositionY()
        print(("Lua: posX is `%s`"):format(posX))
        print(("Lua: posY is `%s`"):format(posY))
        orbit:setPosition(posX, posY)
        return 1
    end

    showMessage = function()
        print(("Lua: Called `showMessage`"):format())
        if table.maxn(cls.messages) >= 1 then
            local message = table.remove(cls.messages, 1)
            BattleControl:get():pushEnemyInfomation(message, 255, 255, 255, 3)
            if table.maxn(cls.messages) >= 1 then
                BattleControl:get():callLuaMethod(cls.ENEMY_ID, "showMessage", 1)
            end
        end
        return 1
    end

    register.regist(cls, id, cls.param.version)
    return 1
end
