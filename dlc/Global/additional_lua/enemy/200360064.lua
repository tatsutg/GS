local class = summoner.Bootstrap.createUnitClass({label="godzilla", version=1.3, id=500981013});

--=======================================================
--開始時に50万ダメージ分のバリアを張っている
--このバリアは時間とともに減少していき、１分後に０になる（１分経過しなくても80万削り切られたら普通に消える）
--ゴジラはノックバックも打ち上げも無効（updateで座標を固定）
--ゴジラにはヒットストップが効かない（メリアの時止めは効く）
--ゴジラはブレイクしない（ゲージを隠す）
--ゴジラは奥義カウンターが貯まらない（カウンターを閉じておく）
--=======================================================

--使用する通常攻撃とその確率
class.attackWeights = {
    attack1 = 50,
    attack2 = 50
}

--使用する奥義とその確率
class.skillWeights = {
    skill1 = 100
}

--攻撃や奥義に設定されるスキルの番号
class.activeSkills = {
    attack1 = 1,
    attack2 = 2
}

class.startPositionX = nil;
class.startPositionY = nil;
class.barrierUpdateTimer = 0;
class.barrierTimer = 30;
class.barrierRecastTimer = 999999;
class.barrierValue = 500000;--２回目以降は下がります。barrierValue2をここに直接代入します
class.barrierValue2 = 50000;
class.subBar = nil;
class.isBarrier = false;
class.GUIDRA_DAMAGE_GODZILLA = 15000;
class.GUIDRA_DAMAGE_PLAYER = 100;


--===================================================================================================================
--通常攻撃分岐//
--///////////

class.attackCheckFlg = false;

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.attackWeights);
    local attackIndex = string.gsub(attackStr,"attack","");
    unit:takeAttack(tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.activeSkills["attack"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////

class.skillCheckFlg = false;

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.skillWeights);
    local skillIndex = string.gsub(skillStr,"skill","");
    unit:takeskill(tonumber(skillIndex));
    return 0;
end

function class:takeskill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.activeSkills["skill"..index]);
end
--===================================================================================================================

function class:run (event)
    if event.spineEvent == "payHP" then
        self:payHP(self.gameUnit,self.GUIDRA_DAMAGE_GODZILLA);
        for i = 0,4 do
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if uni ~= nil then
                self:payHP(uni,self.GUIDRA_DAMAGE_PLAYER);
            end
        end
    end
    return 1;
end

function class:start(event)
	event.unit:setSPGainValue(0);
	event.unit:setAttackTimer(7);
    
	self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); --バーの全体の長さを指定
    self.subBar:setHeight(13);
    self.subBar:setPercent(0); --バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBar:setPositionX(-300);
    self.subBar:setPositionY(250);
    self.gameUnit = event.unit;
    self.HPTrigger50 = true;
    self.guidraSummoned = false;

    BattleControl:get():setBreakBarEnable(false);
    BattleControl:get():setBossSkillCounterEnable(false);
	return 1;
end

function class:excuteAction(event)
	if self.startPositionX == nil then
        self.startPositionX = event.unit:getPositionX();
    	self.startPositionY = event.unit:getPositionY();
    end
    return 1;
end

function class:takeBreakeDamageValue(event)
	return 0;
end

function class:attackDamageValue(event)
	local targetHP = event.enemy:getCalcHPMAX();
	local fixedDamage = math.ceil(targetHP*0.03);
    if event.enemy:getHP() - fixedDamage <= 1 then
        return event.enemy:getHP() - 1;
    end
	return fixedDamage;
end

function class:startWave(event)
	self:addBarrier(event.unit);
	self.subBar:setVisible(false);
	return 1;
end

function class:update(event)
	event.unit:setDefaultPosition(-200,-30);
    event.unit:setPositionX(-200);
    event.unit:setPositionY(-30);
	if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
		return 1;
	end
    event.unit:getSkeleton():setPosition(0,0);

    event.unit:setReduceHitStop(100,1);

    self.barrierUpdateTimer = self.barrierUpdateTimer + event.deltaTime;
    self.barrierTimer = self.barrierTimer - event.deltaTime;
    self.barrierRecastTimer = self.barrierRecastTimer - event.deltaTime;

    if self.barrierRecastTimer <= 0 then
    	self.barrierRecastTimer = 999999;
    	self.barrierTimer = 30;
    	self:addBarrier(event.unit);
    end

    if self.barrierTimer < 0 then
    	if self.isBarrier then
    		self:removeBarrier(event.unit);
    	end
    	self.subBar:setVisible(false);

    	return 1;
    end
    if self.barrierUpdateTimer > 0.2 then
    	self.barrierUpdateTimer = 0;
    	self:checkBarrier(event.unit);
    	local condValue = event.unit:getTeamUnitCondition():findConditionValue(98);
    	self.subBar:setVisible(true);
    	self.subBar:setPercent(100 * condValue/self.barrierValue);
    end

    self:HPTriggerCheck(event.unit);

    return 1;
end

function class:checkBarrier(unit)
	local condValue = unit:getTeamUnitCondition():findConditionValue(98);
	if condValue > self.barrierValue * self.barrierTimer/30 then
		condValue = self.barrierValue * self.barrierTimer/30;
		unit:getTeamUnitCondition():addCondition(50098,98,condValue,9999,0);
	end
	if condValue <= 0 or self.barrierRecastTimer <= 0 then
		self:removeBarrier(unit);
	end
end

function class:addBarrier(unit)
	self.isBarrier = true;
	unit:getTeamUnitCondition():addCondition(50098,98,self.barrierValue * self.barrierTimer/30,9999,0);
end

function class:removeBarrier(unit)
	self.isBarrier = false;
	self.barrierRecastTimer = 15;
	self.barrierTimer = 0;
	self.barrierValue = self.barrierValue2;
    if not self.guidraSummoned then
        self:summonGuidra(unit);
        self.guidraSummoned = true;
    end
	
	summoner.Utility.removeUnitBuffByID(unit,50098);
end

function class:summonGuidra(unit)
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill1119","attack2");
end

function class:payHP(unit,value)
	local hp = unit:getHP();
	local targetHP = (hp - value) > 0 and (hp - value) or 1
    unit:setHP(targetHP);
    unit:takeDamagePopup(unit,value);
end

function class:HPTriggerCheck(unit)
    local HPRate = unit:getHP()/unit:getCalcHPMAX();
    if HPRate <= 0.5 and self.HPTrigger50 then
        self:summonGuidra(unit);
        self.HPTrigger50 = false;
    end
end

class:publish();
