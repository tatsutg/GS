local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴォルフリート", version=2.7, id=104376312});
class:inheritFromUnit("104377312");

class.BURST2_ADD_SP_VALUE = 70;
class.BURST2_RATE_EFFECT_ID = 20437801;

class:publish();

return class;