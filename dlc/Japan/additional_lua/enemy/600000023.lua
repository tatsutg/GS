--[[
    神殿/冥蟲
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local unit = Bootstrap.createEnemyClass({label="冥蟲火", version=1.3, id=600000023})
unit:inheritFromEnemy(600000018);

--この蜘蛛に対する有効属性
unit.ELEMENT_TYPE = kElementType_Aqua;
unit.MESSAGE_COLOR = summoner.Color.red;
unit.ICON = 38
unit:publish()
return unit