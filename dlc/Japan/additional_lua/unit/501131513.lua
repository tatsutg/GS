--[[
    神殿/冥蟲
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local unit = Bootstrap.createUnitClass({label="冥蟲水", version=1.3, id=501131513})
unit:inheritFromUnit(501121513);

--この蜘蛛に対する有効属性
unit.ELEMENT_TYPE = kElementType_Aqua;
unit.MESSAGE_COLOR = summoner.Color.cyan;

unit:publish()
return unit
