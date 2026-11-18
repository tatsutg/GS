local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="てんぷれさん", version=1.3, id=00000000});
class:inheritFromUnit("unitBossBase");

class.SPEED = 5
class.LIMIT_X = 300
class.KAGEN_X = -300
class.ATTACK_INTERVAL = 5
class.MAX_SIZE = 8;
class.GROWTH_RATE_PAR_SEC = 7/120;
class.GROWTH_RATE_BY_ATTACK = 0.03;
class.SHRINK_RATE_BY_FREEZE = 0.7;--凍った時にサイズに掛け算する
class.KNOCK_BACK_DISTANCE_BY_FREEZE = 150;--最大サイズの時のノックバック距離
class.BACK_DISTANCE_WHEN_ATTACK = 200;--こっちはサイズ関係なし

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 3,
    ATTACK2 = 7
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
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


function class:calcBuffValue(base,size)
	return base * size/self.MAX_SIZE;
end


function class:start(event)
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

    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "怒り移行メッセージ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
	self.level = event.unit:getLevel();
	-- event.unit:setSize(3);
	self:addBuffs(event.unit,self.BUFF_ARGS);
	return 1;
end

function class:update(event)
	self:HPTriggersCheck(event.unit);
	self:growthWithTime(event.deltaTime);
	event.unit:setLocalZOrder(9000 + event.unit:getIndex());
	event.unit:getSkeleton():setScale(self.scale);
	event.unit:getSkeleton():setPosition(0,0);

	--行動不能時はカウントを進めない
	if event.unit:getUnitState() == kUnitState_damage or self:isStop(event.unit) then
		event.unit:setPositionX(self.posX);
		-- self:elapsed(event.unit,event.deltaTime)
		return 1;
	end

	self:speedControl(event.deltaTime);
	self:attackManager(event)
	self:positionManager(event.unit,event.deltaTime)
	return 1
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
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
	self.attackOK = false;
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

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
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end
---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  if not self:isStop(event.unit) then
  	self.scale = self.scale + self.GROWTH_RATE_BY_ATTACK;
  	if self.scale > self.MAX_SIZE then
  		self.scale = self.MAX_SIZE;
  	end
  end
  return event.value > 9999 and 9999 or event.value;
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
-- メッセージ表示系
--[[
showMessage(<table> messageBoxList,<number> index)
   messageBoxList : 
      必須。以下のようなメッセージ表示用のテーブルを用意して投げる
      TEKITOUNA_MESSAGES = [
         [0] = [
            <String> MESSAGE = 本文,
            <Color> COLOR = 色,
            <number> DURATION = 表示期間(秒)]

         ],
         [1] = ...
      ]
   index : 
      任意。messageBoxList[index]の内容を表示する。
      この引数がない場合、messageBoxListの全ての内容を表示する。
]]
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
   return
   end
   self:execShowMessage(messageBoxList[index])
end

--[[
showMessageRange(<table> messageBoxList,<number> start,<number> last)
   messageBoxList : 
      必須。
   start,last : 
      必須。messageBoxList[start]からmessageBoxList[last]の内容を表示する。
      この引数がない場合、何も表示しない。
]]
function class:showMessageRange(messageBoxList,start,last)
   for i = start,last do
      self:execShowMessage(messageBoxList[i])
   end
end

--[[
showMessageRange(<table> messageBox)
   敵側のメッセージ欄にmessageBoxの内容を表示する
]]
function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
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
  if self:isStop(event.unit) then
    return 0
  end

  event.unit.m_IgnoreHitStopTime = 999999;
  event.unit:takeFront();
  event.unit:setUnitState(kUnitState_none);
  return 0;
end

function class:isStop(unit)
  local freeze = unit:getTeamUnitCondition():findConditionValue(96);

  if freeze > 0 then
  	if not self.beforeFreeze then
  		self:takeFreeze();
  		self.beforeFreeze = true;
      -- summoner.Utility.messageByEnemy(""..self.scale);
  	end
    return true;
  end
  self.beforeFreeze = false;
  return false
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


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:attackManager(event)
	if self.attackTimer < self.ATTACK_INTERVAL then
		self.attackTimer = self.attackTimer + event.deltaTime
	else
		if self:sarchNearUnitDistance(event.unit) < self.attackRange * self.scale then
			self:addBuffs(event.unit,self.BUFF_ARGS);
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
  end
  if not self.isReverce then
  	  if unit:getUnitState() == kUnitState_none and self.posX < self.LIMIT_X then
	    self.posX = self.posX + ((self.SPEED + self.speed_mod_random) * deltaTime);
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

class:publish();

return class;