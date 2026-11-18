--[[
    神殿/冥蟲
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local unit = Bootstrap.createEnemyClass({label="冥蟲闇", version=1.3, id=600000027})
unit:inheritFromEnemy(600000018);

--この蜘蛛に対する有効属性
unit.ELEMENT_TYPE = kElementType_Dark;
unit.MESSAGE_COLOR = summoner.Color.magenta;
unit.ICON = 42
unit:publish()
return unit
