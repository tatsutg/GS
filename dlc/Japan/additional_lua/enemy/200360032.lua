local instance = summoner.Bootstrap.createUnitClass({label="godzilla", version=1.3, id=500981013});

--=======================================================
--開始時に50万ダメージ分のバリアを張っている
--このバリアは時間とともに減少していき、１分後に０になる（１分経過しなくても50万削り切られたら普通に消える）
--ゴジラはノックバックも打ち上げも無効（updateで座標を固定）
--ゴジラにはヒットストップが効かない（メリアの時止めは効く）
--ゴジラはブレイクしない（ゲージを隠す）
--ゴジラは奥義カウンターが貯まらない（カウンターを閉じておく）
--=======================================================

--使用する通常攻撃とその確率
instance.attackWeights = {
    attack2 = 50
}

--使用する奥義とその確率
instance.skillWeights = {
    skill1 = 100
}

--攻撃や奥義に設定されるスキルの番号
instance.activeSkills = {
    attack1 = 1,
    attack2 = 2
}

instance.startPositionX = nil;
instance.startPositionY = nil;
instance.barrierUpdateTimer = 0;
instance.barrierTimer = 30;
instance.barrierRecastTimer = 999999;
instance.barrierValue = 500000;--２回目以降は下がります。barrierValue2をここに直接代入します
instance.barrierValue2 = 50000;
instance.subBar = nil;
instance.isBarrier = false;
instance.isRage = false;
instance.isRage2 = false;



--===================================================================================================================
--通常攻撃分岐//
--///////////

instance.attackCheckFlg = false;

function instance:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.attackWeights);
    local attackIndex = string.gsub(attackStr,"attack","");
    unit:takeAttack(tonumber(attackIndex));
    return 0;
end

function instance:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function instance:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.activeSkills["attack"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////

instance.skillCheckFlg = false;

function instance:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.skillWeights);
    local skillIndex = string.gsub(skillStr,"skill","");
    unit:takeskill(tonumber(skillIndex));
    return 0;
end

function instance:takeskill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function instance:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.activeSkills["skill"..index]);
end
--===================================================================================================================

function instance:start(event)
	event.unit:setSPGainValue(0);
	event.unit:setAttackTimer(7);

	self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); --バーの全体の長さを指定
    self.subBar:setHeight(13);
    self.subBar:setPercent(0); --バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBar:setPositionX(-300);
    self.subBar:setPositionY(250);

    BattleControl:get():setBreakBarEnable(false);
    BattleControl:get():setBossSkillCounterEnable(false);
	return 1;
end

function instance:excuteAction(event)
	if self.startPositionX == nil then
        self.startPositionX = event.unit:getPositionX();
    	self.startPositionY = event.unit:getPositionY();
    end
    return 1;
end

function instance:takeBreakeDamageValue(event)
	return 0;
end

function instance:attackDamageValue(event)
	local targetHP = event.enemy:getCalcHPMAX();
	local fixedDamage = math.ceil(targetHP*0.005);
    if self.isRage then
        fixedDamage = math.ceil(targetHP*0.0075);
    end
	return fixedDamage;
end

function instance:startWave(event)
	self:addBarrier(event.unit);
	self.subBar:setVisible(false);

	return 1;
end

function instance:update(event)

    if summoner.Utility.getUnitHealthRate(event.unit) < 0.5 and not self.isRage then
        self.isRage = true;
    end

    if summoner.Utility.getUnitHealthRate(event.unit) < 0.2 and not self.isRage2 then
        self.isRage2 = true;
        event.unit:setAttackDelay(10);
    end

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

    

    return 1;
end

function instance:checkBarrier(unit)
	local condValue = unit:getTeamUnitCondition():findConditionValue(98);
	if condValue > self.barrierValue * self.barrierTimer/30 then
		condValue = self.barrierValue * self.barrierTimer/30;
		unit:getTeamUnitCondition():addCondition(50098,98,condValue,9999,0);
	end
	if condValue <= 0 or self.barrierRecastTimer <= 0 then
		self:removeBarrier(unit);
	end
end

function instance:addBarrier(unit)
	self.isBarrier = true;
	unit:getTeamUnitCondition():addCondition(50098,98,self.barrierValue * self.barrierTimer/30,9999,0);
end

function instance:removeBarrier(unit)
	self.isBarrier = false;
	self.barrierRecastTimer = 15;
	self.barrierTimer = 0;
	self.barrierValue = self.barrierValue2;
	
	summoner.Utility.removeUnitBuffByID(unit,50098);
end

instance:publish();
