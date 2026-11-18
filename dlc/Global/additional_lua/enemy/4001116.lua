local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = Bootstrap.createEnemyClass({label="不滅の神殿／ダークコロック", version=1.8, id=4001116})

class.MESSAGE_TIME = 3
class.MESSAGE_COLOR = Color.white

-- 召喚されたとき
function class:start(event)
    event.unit:getSkeleton():setScale(2) -- 大きさを2倍に
    local randNum = Random.range(1, 4)
    local message = self.TEXT["START_MESSAGE_" .. randNum]
    if message ~= nil then
        Utility.messageByEnemy(message, self.MESSAGE_TIME, self.MESSAGE_COLOR)
    end
    return 1
end

-- 奥義
function class:takeSkill(event)
    local message = self.TEXT["SKILL_MESSAGE"]
    if message ~= nil and event.index == 2 then
        Utility.messageByEnemy(message, self.MESSAGE_TIME, self.MESSAGE_COLOR)
    end
    return 1
end

-- 倒れたとき
function class:dead(event)
    local message = self.TEXT["DEAD_MESSAGE"]
    if message ~= nil then
        Utility.messageByEnemy(message, self.MESSAGE_TIME, self.MESSAGE_COLOR)
    end
    return 1
end

-- ヒットストップ無効
function class:update(event)
    event.unit:setReduceHitStop(2, 1)
    return 1
end

class:publish()
return class
