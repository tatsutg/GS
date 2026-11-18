local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="蒼騎士用設置兵器(グラーシーザ・絶)", version=1.3, id=501871250});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "pileLoop" then
        event.unit:takeAnimation(0,"idle",true);
        self.subBar:setVisible(true);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    event.unit:takeAnimation(0,"in",false)
    ---カメラ追従のオーラ
    self.pileAura = event.unit:addOrbitSystemCameraWithFile("50186ef","Pile_camera",true)
    self.pileAura:takeAnimation(0,"Pile_camera",true);
    --event.unit:getTeamUnitCondition():addCondition(0,31,-10000,99999,0);
    event.unit:setIsTakeShake(false)

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(100); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:pileSubBarControll(event.unit);---サブバー表示
    if event.unit:getHP() == 0 then
        self.subBar:setVisible(false);
        event.unit:getTeam():deadUnit(event.unit:getIndex());
    end
    return 1
end

---サブHP表示
function class:pileSubBarControll(unit)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY() - 25);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * unit:getHP()/unit:getCalcHPMAX());
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 0
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    return 0;
end
---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    return 0;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    return 0;
end
---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    return 0
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    return 0
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local paralyze = event.unit:getTeamUnitCondition():findConditionValue(91);
    local elementType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(600000932)
    if paralyze > 0 then
        event.value = event.value * 6
    end
    if cond ~= nil then
        if cond:getValue() == elementType then
            event.value = 1
        end
    end
    return event.value
end

class:publish();

return class;