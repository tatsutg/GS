--[[
    神殿/冥蟲
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local unit = Bootstrap.createEnemyClass({label="冥蟲火", version=1.3, id=600000018})

--この蜘蛛に対する有効属性
unit.ELEMENT_TYPE = kElementType_Fire;
unit.MESSAGE_COLOR = summoner.Color.red;
unit.ICON = 38

function unit:start(event)
	local rand = LuaUtilities.rand(3) + 1;
	local message = self.TEXT["mess"..rand];
	event.unit:takeAnimation(1,"fire",true);--オーラアニメーションをつけるだけ
	summoner.Utility.messageByEnemy(message,10,self.MESSAGE_COLOR);
	return 1;
end

function unit:update(event)
    event.unit:setReduceHitStop(2, 1)
    return 1
end

--==============================================================================================
--属性周りの処理
--==============================================================================================

function unit:takeDamageValue(event)
	--有効属性以外は１ダメージ
	-- if not self:elementCheck(event.enemy) then
	-- 	return 1;
	-- end

	return 1;	
end

-- function unit:elementCheck(enemy)
-- 	local element = enemy:getElementType();--敵ユニット自身の属性
-- 	local activeSkill = enemy:getActiveBattleSkill();--敵の使用してきたスキルの内容

-- 	--敵がスキルつきの攻撃をしてきならスキルの属性を見る
--     if activeSkill ~= nil then
--         element = activeSkill:getElementType();
--     end

--     return element == self.ELEMENT_TYPE;
-- end

--==============================================================================================
--自爆の処理
--==============================================================================================

function unit:run(event)
	if event.spineEvent == "suicide" then self:suicide(event.unit) end
	return 1;
end

function unit:suicide(unit)
	summoner.Utility.messageByEnemy(self.TEXT.DEAD1,10,self.MESSAGE_COLOR,self.ICON);
	summoner.Utility.messageByEnemy(self.TEXT.DEAD2,10,self.MESSAGE_COLOR);
	unit:setHP(0);
end


unit:publish()
return unit
