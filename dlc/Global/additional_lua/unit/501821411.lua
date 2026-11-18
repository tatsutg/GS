local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="春のピキュオン祭りピキュオン", version=2.0, id=501821411});
class:inheritFromUnit("unitBossBase");

class.SPEED = 5
class.LIMIT_X = 300
class.KAGEN_X = -300
class.ATTACK_INTERVAL = 5
class.MAX_SIZE = 8;
class.GROWTH_RATE_PAR_SEC = 7/480;---レキュオンの1/4
class.GROWTH_RATE_BY_ATTACK = 0.01;---レキュオンの1/3
class.SHRINK_RATE_BY_FREEZE = 0.7;--凍った時にサイズに掛け算する
class.KNOCK_BACK_DISTANCE_BY_FREEZE = 150;--最大サイズの時のノックバック距離
class.BACK_DISTANCE_WHEN_ATTACK = 200;--こっちはサイズ関係なし

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK1=50},
        {ATTACK2=50},
        {ATTACK1=50, ATTACK2=50}
    }
}
--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        {SKILL2=50}
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--バフ内容　VALUEはcalcBuffValueのなかでいじられる　最大サイズ時の効果を記載
class.BUFF_ARGS = {
    {
        ID = 501491,
        EFID = 17,         --ダメージアップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 501492,
        EFID = 13,         --ダメージアップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 3
    }
}

class.BUFF_BOX_LIST = {
    [1] = {
        ID = 501821411,
        BUFF_ID = 89,---気絶
        VALUE = 100,
        DURATION = 99999,
        ICON = 79
    },
    [2] = {
        ID = 501821411,
        BUFF_ID = 0,---気絶解除
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    },
    [3] = {
        ID = 5018214110,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    },
    [4] = {
        ID = 5018214110,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 0,
        ICON = 0
    }
}

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()

    self.FIXED_DAMAGE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.FIXED_DAMAGE_MESSAGE1 or "ピキュ！", COLOR = Color.yellow})
    }

end

function class:calcBuffValue(base,size)
	return base * size/self.MAX_SIZE;
end


function class:start(event)
    event.unit:setAttackDelay(8);---アタックディレイ
	event.unit:getSkeleton():setScale(1);
	-- event.unit:setAttackDelay(999999);
	event.unit:setAutoZoder(false);
	event.unit:setLocalZOrder(9000 + event.unit:getIndex());
	self.size = 1;
	self.speed = 1;
	self.attackTimer = 1;
	self.posX = 0
	self.speed_mod_random = 0;
	self.reverceSpeed = 0;
	self.first = true;
	self.level = 0;
	self.scale = 1;
	self.attackRange = 150;
	self.speedChangeTimer = 0;
	self.isReverce = false;
    ---ブレイク関係変数
    self.breakFLG = false
    self.posXDefault = 0

    self:setMessageBoxList()

    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.attackOK = false;
    self.beforeFreeze = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        -- [0] = {
        --     HP = 50,
        --     trigger = "getRage",
        --     isActive = true
        -- }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self.fesLevel = event.unit:getLevel() - 1
    event.unit:setBaseHP(self.fesLevel^2 * 10000 + 10000)
    return 1;
end

function class:startWave(event)
	self.level = event.unit:getLevel();
	-- event.unit:setSize(3);
	--self:addBuffs(event.unit,self.BUFF_ARGS);
	return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
	self:HPTriggersCheck(event.unit);
    if not self:breakCheck(event.unit) then
        self:growthWithTime(event.deltaTime);
    end
	event.unit:setLocalZOrder(9000 + event.unit:getIndex());
	event.unit:getSkeleton():setScale(self.scale);
	event.unit:getSkeleton():setPosition(0,0);

    ---ボスブレイク時処理
    if not self.breakFLG and self:breakCheck(event.unit) then
        self.breakFLG = true
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        event.unit:setPositionX(self.posXDefault);
        self.posX = self.posXDefault
        self.scale = 1
    elseif self.breakFLG and not self:breakCheck(event.unit) then
        self.breakFLG = false
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
    end
    --summoner.Utility.messageByEnemy(self.scale)

	--行動不能時はカウントを進めない
	if event.unit:getUnitState() == kUnitState_damage or self:breakCheck(event.unit) then
		event.unit:setPositionX(self.posX);
		return 1;
	end

	self:speedControl(event.deltaTime);
	self:attackManager(event)
	self:positionManager(event.unit,event.deltaTime)
	return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackOK then
        event.unit:excuteAction();
        return 0;
    end

    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1") ---EFのアニメーション名に気をつける
    end

    self.attackOK = false;
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:enemyAddBuff(event.unit,self.BUFF_BOX_LIST[3])
    self.infoFLG = true
    self:addSP(event.unit);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end
--[[
function class:attackBranch(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
	if not self.attackOK then
		event.unit:excuteAction();
		return 0;
	end
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackOK = false;
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self:enemyAddBuff(event.unit,self.BUFF_BOX_LIST[3])
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end
]]--
function class:skillBranch(unit)
    local skillIndex = self:getSkillIndex()

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    self:enemyAddBuff(event.unit,self.BUFF_BOX_LIST[3])
    self.infoFLG = true
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index == 1 then
        self:addSP(event.unit);
    end
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if event.enemy:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID) ~= nil then
        ---庇うユニットを探す
        local FLG = false
        for i = 0,7 do
            local teamUnit = event.enemy:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond ~= nil then
                    FLG = true
                end
            end
        end
        if FLG then
            ---庇うユニットがいる場合
            for i = 0,6 do
                local myTeamUnit = event.enemy:getTeam():getTeamUnit(i)
                if myTeamUnit ~= nil then
                    self:fixedDamage(myTeamUnit)
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[3].ID)
                end
            end
        else
            ---いない場合
            self:fixedDamage(event.enemy)
            event.enemy:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[3].ID)
        end
    end
    return event.value
end

function class:enemyAddBuff(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:fixedDamage(unit)
    local rate = 0.2 + (self.scale - 1.0) * 0.1
    local time = 1 + self.fesLevel / 15
    unit:setHP(unit:getHP() - (unit:getCalcHPMAX() * rate ) )
    unit:getTeamUnitCondition():addConditionWithWeight(0,89,100,time,79,rate * 100);
    if self.infoFLG then
        self:execShowConsecutiveMessage(self.FIXED_DAMAGE_MESSAGE_LIST[1],math.floor(self.scale))
        self.infoFLG = false
    end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  if not self:breakCheck(event.unit) then
  	self.scale = self.scale + self.GROWTH_RATE_BY_ATTACK;
  	if self.scale > self.MAX_SIZE then
  		self.scale = self.MAX_SIZE;
  	end
  end
  return event.value > 99999 and 99999 or event.value;
end


--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessage(self.RAGE_MESSAGES);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowConsecutiveMessage(messageBox,num)
    local fixedMessage = ""
    for i = 1,num do
        fixedMessage = fixedMessage..messageBox.MESSAGE
    end
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(fixedMessage,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(fixedMessage,messageBox.DURATION,messageBox.COLOR);
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
-- バフ、デバフ追加系
--[[
addBuffs(<event.unit> unit,<table> buffs)
   unit :
      必須。バフを与える対象
   buffs :
      必須。以下のようなバフ用の配列を用意して投げる
      RAGE_BUFFS = {
         {
            <number> ID = 必須。一意のID
            <number> EFID = 必須。バフの効果ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> VALUE = 必須。バフ効果量
            <number> DURATION = 必須。持続時間
            <number> ICON = 必須。アイコンID。IDの一覧は企画*多部署連携用シート.バフ・デバフアイコン参照
            <number> EFFECT = 任意。エフェクトID。IDの一覧は企画*多部署連携用シート.スキル効果アニメーション参照
            <number> SCRIPT = 任意。skill_effect内の関数用ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> SCRIPTVALUE1 = 任意。skill_effectの第一引数の値
         }
      }
]]
function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,self:calcBuffValue(args.VALUE,self.scale),args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,self:calcBuffValue(args.VALUE,self.scale),args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end

--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


function class:excuteAction(event)
    self:enemyAddBuff(event.unit,self.BUFF_BOX_LIST[4])
    self.infoFLG = false
  if self:breakCheck(event.unit) then
    return 0
  end

  event.unit.m_IgnoreHitStopTime = 999999;
  event.unit:takeFront();
  event.unit:setUnitState(kUnitState_none);
  return 0;
end

function class:takeFreeze()
	self.scale = self.scale * self.SHRINK_RATE_BY_FREEZE > 1 and self.scale * self.SHRINK_RATE_BY_FREEZE or 1;
	local dist = self.KNOCK_BACK_DISTANCE_BY_FREEZE * self.scale/self.MAX_SIZE;
	self.posX = self.posX - (dist + Random.range(0,dist * 2));
	self.isReverce = false;
end

function class:run(event)
	if event.spineEvent == "backStart" then
		self.isReverce = true;
		self.reverceSpeed = self.BACK_DISTANCE_WHEN_ATTACK * 2 + Random.range(0,self.BACK_DISTANCE_WHEN_ATTACK);
	end

	if event.spineEvent == "backEnd" then
		self.isReverce = false;
	end
	return 1;
end

function class:takeDamage(event)
    self.isReverce = false;
    return 1;
end

function class:attackManager(event)
	if self.attackTimer < self.ATTACK_INTERVAL then
		self.attackTimer = self.attackTimer + event.deltaTime
	else
		if self:sarchNearUnitDistance(event.unit) < self.attackRange * self.scale then
			--self:addBuffs(event.unit,self.BUFF_ARGS);
			event.unit:takeAttack(1)
			self.attackOK = true;
			-- event.unit:setActiveSkill(1)
			self.attackTimer = self.attackTimer - self.ATTACK_INTERVAL
		else
			self.attackTimer = self.attackTimer - 1;
		end
	end
end

function class:sarchNearUnitDistance(unit)
	local dist = 99999999;
	for i = 0,4 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        
        if target ~= nil then
            local tgtDist = self:getTargetDistance(unit,target);
            if tgtDist < dist then
            	dist = tgtDist;
            end
        end
    end
    return dist;
end

function class:getTargetDistance(unit,target)
    return target:getPositionX() - unit:getPositionX();
end

function class:positionManager(unit,deltaTime)
  --移動の処理
  if self.posX == 0 and self.first then
    self.posX = unit:getPositionX();
    self.first = false
      self.posXDefault = unit:getPositionX();
  end
  if not self.isReverce then
  	  if unit:getUnitState() == kUnitState_none and self.posX < self.LIMIT_X then
	    self.posX = self.posX + ((self.SPEED + self.speed_mod_random) * deltaTime / 2);
	  end
  else
  	if self.posX > self.KAGEN_X then
	    self.posX = self.posX - ((self.reverceSpeed ) * deltaTime);
	end
  end
  

  unit:setPositionX(self.posX)
end

function class:speedControl(deltaTime)
	if self.speedChangeTimer < 1 then
		self.speedChangeTimer = self.speedChangeTimer + deltaTime;
		return;
	end
	self.speedChangeTimer = self.speedChangeTimer - 1;
	self.speed_mod_random = Random.range(0,20);
end

function class:growthWithTime(deltaTime)
	self.scale = self.scale + self.GROWTH_RATE_PAR_SEC * deltaTime;
	if self.scale > self.MAX_SIZE then
		self.scale = self.MAX_SIZE;
	end
end

function class:breakCheck(unit)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:isBreak() then
                return true
            end
        end
    end
    return false
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
    return buff
end

function class:movePatternState(SET_LIST,stateBox)
    --summoner.Utility.messageByEnemy(stateBox.actCount.."/"..self.gameUnit:getBurstPoint())
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

class:publish();

return class;