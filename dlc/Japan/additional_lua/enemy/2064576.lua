local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡_8層_HARD_蒼騎士用設置兵器(グラーシーザ)", version=2.5, id=2064576});

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
    --self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
    --    deBuffDmgVal = 5.0,
    --    elementDmgVal = 0.2
    --})
    --self:dump(self.GD)

    event.unit:takeAnimation(0,"in",false)
    ---カメラ追従のオーラ
    self.pileAura = event.unit:addOrbitSystemCameraWithFile("50186ef","Pile_camera",true)
    self.pileAura:takeAnimation(0,"Pile_camera",true);
    --event.unit:getTeamUnitCondition():addCondition(0,31,-10000,99999,0);
    event.unit:setIsTakeShake(false)

    ---サブHP表示用
    self.damage = 0
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(100); ---バーの残量を0%に指定
    self.subBar:setVisible(false);

    self.dmgValBuffID = 503601500
    event.unit:setSize(1);
    event.unit:setHPBarHeightOffset(250);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:pileSubBarControl(event.unit);---サブバー表示
    if event.unit:getHP() == 0 then
        self.subBar:setVisible(false);
        event.unit:getTeam():deadUnit(event.unit:getIndex());
    end
    return 1
end

---サブHP表示
function class:pileSubBarControl(unit)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY() - 25);
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    --self.subBar:setPercent(100 * (unit:getCalcHPMAX() - self.damage)/unit:getCalcHPMAX());
    self.subBar:setPercent(100 * (unit:getHP()/unit:getCalcHPMAX()));
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
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 0
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    return 0
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    -- 燃焼ダメージ以外固定ダメージ
    event.value = 1
    --summoner.Utility.messageByEnemy("EXHP : " .. math.floor(event.unit:getCalcHPMAX() - self.damage))
    return event.value
end



class:publish();

return class;