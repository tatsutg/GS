local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="UnitName", version=1.3, id=102475511});

class.RANK_LIST = {
	[0] = 1,
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 1,
	[5] = 2,
	[6] = 2,
	[7] = 2,
	[8] = 2,
	[9] = 3,
	[10] = 3,
	[11] = 3,
	[12] = 3,
	[13] = 3
}

class.COUNT_MAX = 13;


class.SKILL2_BUFF_ARGS = {
    {
        ID = 102476512,
        EFID = 25,         --ブレイクダメージアップ
        VALUE = 8,        --効果量
        DURATION = 9999999,
        ICON = 9,
        SCRIPT = 8
    }
}

class.SKILL3_BUFF_ARGS = {
    {
        ID = 102476511,
        EFID = 17,         --ダメージアップ
        VALUE = 200,        --効果量
        DURATION = 9999999,
        ICON = 26,
        SCRIPT = 58,
        REMOVE = true
    }
}

class.CT_BUFF_ARGS = {
    {
        ID = 102472,
        EFID = 29,         --ダメージアップ
        VALUE = 8,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}

function class:start(event)
	self.deadCount = 0;
	event.unit:setParameter("247_DeadCount",""..self.deadCount);
	self.friendsTargets = {};
	self.friendCheckTimer = 0;
	self.numbersOrbit = nil;
	self.gameUnit = event.unit;
	self.SPValue = 20;
	return 1;
end

function class:startWave(event)
	self.friendsTargets = {};
	self:checkFriends(event.unit);
	return 1;
end

function class:update(event)
	self.friendCheckTimer = self.friendCheckTimer + event.deltaTime;
	if self.friendCheckTimer >= 0.2 then
		self.friendCheckTimer = self.friendCheckTimer - 0.2;
		self:checkFriends(event.unit);
	end

	if self.numbersOrbit == nil then
        self.numbersOrbit = event.unit:addOrbitSystemWithFile("10247num","0");
        self.numbersOrbit:takeAnimation(0,"none",true);
        self.numbersOrbit:takeAnimation(1,"none2",true);
        self.numbersOrbit:setZOrder(10011);
    end
    if self.numbersOrbit ~= nil then
        self:numbersControll(event.unit);
    end
	return 1;
end

function class:numbersControll(unit)
    local isPlayer = unit:getisPlayer();
    local xpos = unit:getAnimationPositionX()+20 < 400 and unit:getAnimationPositionX()+20 or 400;
    if not isPlayer then
        xpos = unit:getAnimationPositionX()-70 > -400 and unit:getAnimationPositionX()-70 or -400;
        self.numbersOrbit:getSkeleton():setScaleX(-1);
    end
    self.numbersOrbit:setPosition(xpos,unit:getAnimationPositionY()+50);
    self.numbersOrbit:takeAnimation(0,self:intToAnimationNameOne(self.deadCount),true);
    self.numbersOrbit:takeAnimation(1,self:intToAnimationNameTen(self.deadCount),true);
end

function class:intToAnimationNameOne(int)
    local temp = int%10;
    if int == 0 then
        return "none";
    end
    return ""..temp;
end

function class:intToAnimationNameTen(int)
    local temp = math.floor(int/10);
    if temp == 0 then
        return "none2";
    end
    return ""..temp.."0";
end

function class:takeSkill(event)
	self:removeConditions(event.unit);
	if event.index == 2 then
		self:skill2Action(event.unit);
	end
	if event.index == 3 then
		self:skill3Action(event.unit);
	end
	return 1;
end

function class:takeAttack(event)
	self:removeConditions(event.unit);
	return 1;
end

function class:removeConditions(unit)
	for k,v in pairs(self.SKILL2_BUFF_ARGS) do
        Utility.removeUnitBuffByID(unit,v.ID);
    end
end

function class:checkFriends(unit)
	if not self:getIsControll(unit) then
	    return;
	end

	for i = 0,7 do
	    local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i,true);
	    if teamUnit ~= nil then
	    	self:makeFriends(teamUnit,false,i,unit);
	    end
	end

	for i = 0,3 do
	    local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
	    if teamUnit ~= nil then
	    	self:makeFriends(teamUnit,true,i,unit);
	    end
	end

end

function class:makeFriends(teamUnit,isPlayerTeam,index,unit)
	--敵のPTと味方のPTという本来重複する番号のものを一つの配列で片付けたいがためのオフセット
	local playerOffset = isPlayerTeam and 10 or 0;
	local unitIndex = unit:getIndex();

	--プレイヤー側と敵側双方にアルティが出現した時のことを考えてプレイヤー側のアルティ識別インデックスにはオフセットをかける
	if unit:getisPlayer() then
		unitIndex = unitIndex + 10;
	end

	--アルティのお友達になってよ　友達予約。このパラメータで監視下にあるターゲットが消失したかどうかを見る
	if teamUnit:getParameter("alties"..unitIndex.."Friend") == "" then
		teamUnit:setParameter("alties"..unitIndex.."Friend","false");

		--アルティの友達予約したはずのインデックスに、アルティの友達予約がないユニットが入っていた場合前その位置にいたユニットが死亡したと判断する
		--アルティの友達になった場合はtrueが入っているので、友達予約済み（配列に存在するindex）でまだ死亡確認が取れていない(中身がfalse)ものについてのみ判断
		--この友達予約テーブルはwaveStartで初期化されるのでwave遷移で誤作動することはないはず……
		if self.friendsTargets[index+playerOffset] == false then
			self:countUpFriends(unit);
			
		end
		self.friendsTargets[index+playerOffset] = false;
	end

	--消失することなく普通に死亡確認が取れた場合
    if teamUnit:getHP() <= 0 and teamUnit:getParameter("alties"..unitIndex.."Friend") == "false" then
    	teamUnit:setParameter("alties"..unitIndex.."Friend","true");
		self:countUpFriends(unit);
		self.friendsTargets[index+playerOffset] = true;--友達予約が成功したのでtrueを入れて置く
    end
end

function class:countUpFriends(unit)
	self.deadCount = self.deadCount + 1;
	unit:setParameter("247_DeadCount",""..self.deadCount);
	if self.deadCount > self.COUNT_MAX then
		self.deadCount = self.COUNT_MAX;
		unit:setParameter("247_DeadCount",""..self.deadCount);
	end
	self:addBuffs(unit,self.CT_BUFF_ARGS,self.deadCount);
	self:introduceFriend(unit);
end

function class:introduceFriend(unit)
	megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.deadCount);
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:skill2Action(unit)
	local rank = self.RANK_LIST[self.deadCount];
	
	if rank <= 1 then
		return;
	end
	unit:setNextAnimationName("skill2_"..rank);
	unit:setNextAnimationEffectName("2-skill2_"..rank);
end

function class:skill3Action(unit)
	if self.deadCount < 13 then
		return;
	end
	unit:setNextAnimationName("skill3_2");
end

function class:addBuffs(unit,buffs,rate)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v,rate);
    end
end

function class:addBuff(unit,args,rate)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE * rate,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE * rate,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end
    if args.REMOVE then
    	buff:setRemoveOnResetState(true);
    end
end

function class:HPtoSP(unit)
	for i = 0,3 do
	    local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
	    if teamUnit ~= nil and teamUnit ~= unit then
	    	teamUnit:setHP(teamUnit:getHP() - teamUnit:getCalcHPMAX()/10);
	    	if teamUnit:getHP() <= 0 then
	    		teamUnit:setHP(1);
	    	end
	    	teamUnit:addSPNonPvpCorrection(self.SPValue);
	    end
	end
end

function class:addSkill2Buff(unit)
	if self.deadCount <= 0 then
		return;
	end
	self:addBuffs(unit,self.SKILL2_BUFF_ARGS,self.deadCount);
end

function class:addSkill3Buff(unit)
	if self.deadCount < 13 then
		return;
	end
	if self.deadCount <= 0 then
		return;
	end
	-- self:HPtoSP(unit);
	self:addBuffs(unit,self.SKILL3_BUFF_ARGS,1);
end

function class:run(event)
	if event.spineEvent == "addBuff" then
		self:addSkill2Buff(event.unit);
	end

	if event.spineEvent == "addBuff2" then
		self:addSkill3Buff(event.unit);
	end

	return 1;
end

function class:receive1(args)
	self.deadCount = args.arg;
	self.gameUnit:setParameter("247_DeadCount",""..self.deadCount);
	self:addBuffs(self.gameUnit,self.CT_BUFF_ARGS,self.deadCount);
    return 1;
end

class:publish();

return class;