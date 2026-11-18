local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇リーゼ", version=1.3, id=2025830});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50
}
class.ATTACK_REEL = {
    [1] = {
        ATTACK1 = 100
    },
    [2] = {
        ATTACK2 = 100
    }
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

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 98, -- バリア
         VALUE = 3000000,
         DURATION = 6,
         ICON = 24
      }
   }
end


--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 5,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "やっちゃいますからねっ！",
         COLOR = Color.magenta
      })
   }


   self.HP50_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "こうなったら、奥の手ですっ！",
         COLOR = Color.magenta
      })
   }

   self.HP0_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP0_MESSAGE1 or "おばあちゃん…ごめん…",
         COLOR = Color.magenta
      })
   }

end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {

      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp0(status) end,
         HP = 0.1,
         used = false
      }

   }

    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            if self.TRIGGERS[index].HP ~= 0.1 then
                self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            end
        end
    end
end


function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self.isRage = true
      self.gameUnit:addSP(100)
   end
end

function class:hp0(status)
   if status == "use3" then
      self:showMessage(self.HP0_MESSAGE_LIST)
      self.isDead = true;
      self.gameUnit:setHP(0);
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.magicCircle = self.magicCircle:new();
    self.magicCircle:init(event,self);

    self.attackCounter = 0;

    self.hitstopReduceLevel = 2;
    self.hitStopReduceRate = 1;

   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   self.isDead = false;

   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

function class:startWave(event)
    self.magicCircle:startWave(event);
    return 1;
end

function class:run(event)
    self.magicCircle:run(event);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   self.magicCircle:update(event);
   self:reduceHitStop(event.unit);
    return 1;
end

function class:reduceHitStop(unit)
   unit:setReduceHitStop(self.hitstopReduceLevel, self.hitStopReduceRate);
end
---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_REEL[self.attackCounter % table.maxn(self.ATTACK_REEL) + 1]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    self.attackCounter = self.attackCounter + 1;
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        self.attackCheckFlg = false;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)

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


function class:addSP(unit)
   unit:addSP(self.spValue);
   return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   event.unit:setDamageRateOffset(1)
   event.unit:setBreakRate(1)
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
      self.skillCheckFlg = true;
      return self:skillReroll(event.unit);
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

    self.magicCircle:takeSkill(event);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage then
      self.isRage = false
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true
    if self.TRIGGERS[index].tag == "HP_FLG" then
        if self.TRIGGERS[index].HP ~= 0.1 then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
        end
    end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        if self.TRIGGERS[args.arg].HP ~= 0.1 then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
        end
    end
   return 1
end

function class:receive4(args)
    self.magicCircle:receive4(args);
    return 1;
end

function class:receive5(args)
    self.magicCircle:receive5(args);
    return 1;
end

function class:dead(event)
   if not self.isDead then
      event.unit:setHP(1);
      return 0;
   end
   return 1;
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
   for i,messageBox in ipairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end


--===============================================================================================================================================
-- 魔法陣クラス
--===============================================================================================================================================

class.magicCircle = {}--[!]これは定義のための箱です！！[!] 
--これを直接使わないで！ start時にself.magicCircle:newしてから使ってね！


--バフかけ対象の列挙
class.magicCircle.targetType = {
    myself = 1,
    party = 2,
    enemys = 3
}



class.magicCircle.BUFF_ARGS = {
    [1] = {
        ID = 107341,
        BUFF_ID = 21,
        VALUE = 30,
        DURATION = 20,--定数みたいな顔をしていますがその時々で書き換えられます
        ICON = 139
    }
}


--バフをかける対象　上記の列挙から選択してね！
class.magicCircle.buffTarget = class.magicCircle.targetType.enemys;
class.magicCircle.SP = 30;


--＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝接続部＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

--【クッソ重要】　magicCircleの内部にアクセスする場合
--絶対にこのnew叩いてから使うこと。
--self.magicCircleクラスをローカルのもので上書きします。
--この手順を飛ばすと、闇リーゼが複数いたときに同じ実態を参照して混線するよ！
function class.magicCircle:new()
    local newInstance = {}
    for k,v in pairs(self) do
        newInstance[k] = self[k];
    end
    return newInstance;
end

function class.magicCircle:init(event,parentClass)
    self.parent = parentClass;
    self.parentUnit = event.unit;
    self.shotCount = 0;

    self.magicTimer = 0;
    self.isMagic = false;

    self.shot1Orbit = nil;
    self.shot2Orbit = nil;
    self.shot3Orbit = nil;
    self.magicOrbit = nil;
end

function class.magicCircle:startWave(event)
    self:cleanUp();
    return 1;
end

function class.magicCircle:endWave(event)
    self:cleanUp();
    return 1;
end

function class.magicCircle:takeSkill(event)
    if event.index == 1 and self.shotCount > 0 then
        event.unit:setNextAnimationName("skill1_"..(self.shotCount + 1));
        event.unit:setNextAnimationEffectName("skill1_"..(self.shotCount + 1));
    end
end

function class.magicCircle:run(event)
    if event.spineEvent == "shot1" then
        self:shot1(event.unit);
    end

    if event.spineEvent == "shot2" then
        self:shot2(event.unit);
    end

    if event.spineEvent == "shot3" then
        self:shot3(event.unit);
    end

    if event.spineEvent == "s1loop1" then
        self:s1Loop1(event.unit);
    end

    if event.spineEvent == "s1loop2" then
        self:s1Loop2(event.unit);
    end

    if event.spineEvent == "magic" then
        self:magic(event.unit);
    end

    if event.spineEvent == "magicLoop" then
        self:magicLoop(event.unit);
    end

    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
    end

    if event.spineEvent == "hideMagic" then--他のリーゼから呼ばれる可能性がある　魔法陣を二つ以上重複させないため
        self:magicEnd();
    end
end

function class.magicCircle:update(event)
    self:countDown(event.deltaTime);
end

function class.magicCircle:receive4(args)
    self:setShotCount(args.arg);
    self:addShot(args.arg);
    return 1;
end

function class.magicCircle:receive5(args)
    self:startMagicCount();
    return 1;
end

--＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

function class.magicCircle:addSpecialBuff(unit)


    if self.buffTarget == self.targetType.self then
        self.parent:addBuffs(unit,self.BUFF_ARGS);
        return;
    end


    local targetParty = nil;
    if self.buffTarget == self.targetType.party then
        targetParty = unit:getTeam();
    end

    if self.buffTarget == self.targetType.enemys then
        targetParty = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
    end

    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil and targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS[1].ID) == nil then
            self.BUFF_ARGS[1].DURATION = self.magicTimer;
            self.parent:addBuffs(targetUnit,self.BUFF_ARGS);
        end
    end
    
end

function class.magicCircle:shot1(unit)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if self:isControllTarget(unit) then
        self:setShotCount(1);
        self:addShot(1);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,self.shotCount);
    end
end

function class.magicCircle:shot2(unit)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if self:isControllTarget(unit) then
        self:setShotCount(2);
        self:addShot(2);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,self.shotCount);
    end
end

function class.magicCircle:shot3(unit)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if self:isControllTarget(unit) then
        self:setShotCount(3);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,self.shotCount);
        self:addShot(3);
    end
end

function class.magicCircle:addShot(animationIndex)
    local orbit = self.parentUnit:addOrbitSystem("shot"..animationIndex,0);
    self["shot"..animationIndex.."Orbit"] = orbit;
    orbit:getSkeleton():setPosition(0,0);
    orbit:setPosition(0,0);
    if animationIndex == 3 then
        self.shot1Orbit:takeAnimation(0,"none",false);
        self.shot1Orbit = nil;
        self.shot2Orbit:takeAnimation(0,"none",false);
        self.shot2Orbit = nil;
        self.shotCount = 0;
    end
end

function class.magicCircle:s1Loop1(orbit)
    orbit:takeAnimation(0,"s1Loop1",true);
end

function class.magicCircle:s1Loop2(orbit)
    orbit:takeAnimation(0,"s1Loop2",true);
end

function class.magicCircle:magic(orbit)
    self:magicEnd();
    self:hideOtherMagicCircle();

    self.magicOrbit = self.parentUnit:addOrbitSystem("magic",0);
    self.shot3Orbit:takeAnimation(0,"none",false);
    self.shot3Orbit = nil;
    self.magicOrbit:setPosition(0,0);
    self.magicOrbit:getSkeleton():setPosition(0,0);

    if self:isControllTarget(orbit:getParentTeamUnit()) then
        self:startMagicCount();
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,5,self.shotCount);
    end

end

function class.magicCircle:magicLoop(orbit)
    orbit:takeAnimation(0,"magicLoop",true);
end

function class.magicCircle:addSP(unit)
    if not self.isMagic then
        return;
    end
    local targetParty = unit:getTeam();
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil then
            targetUnit:addSP(self.SP);
        end
    end
end

function class.magicCircle:startMagicCount()
    self.magicTimer = 20;
    self.isMagic = true;
end


function class.magicCircle:setShotCount(count)
    self.shotCount = count;
end

function class.magicCircle:countDown(delta)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if not self.isMagic then
        return;
    end
    self.magicTimer = self.magicTimer - delta;
    if self.magicTimer > 1 then
        self:addSpecialBuff(self.parentUnit);
    end
    if self.magicTimer <= 0 then
        self:magicEnd();
        self.isMagic = false;
    end
end

function class.magicCircle:cleanUp()
    self.shotCount = 0;

    self.magicTimer = 0;
    self.isMagic = false;

    self:magicEnd();

    if self.shot1Orbit ~= nil then
        self.shot1Orbit:takeAnimation(0,"none",false);
        self.shot1Orbit = nil;
    end

    if self.shot2Orbit ~= nil then
        self.shot2Orbit:takeAnimation(0,"none",false);
        self.shot2Orbit = nil;
    end

    if self.shot3Orbit ~= nil then
        self.shot3Orbit:takeAnimation(0,"none",false);
        self.shot3Orbit = nil;
    end


end

function class.magicCircle:hideOtherMagicCircle()
    for i = 0,4 do
        local target = megast.Battle:getInstance():getTeam(self.parentUnit:getisPlayer()):getTeamUnit(i);
        if target ~= nil and target ~= self.parentUnit and target:getBaseID3() == 200 then
            target:callLuaMethod("hideMagic",0.1);
        end
    end
end


function class.magicCircle:magicEnd()
    if self.magicOrbit ~= nil then
        self.magicOrbit:takeAnimation(0,"magicEnd",false);
        self.magicOrbit = nil;
    end
end


function class.magicCircle:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if megast.Battle:getInstance():isPvp() then 
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end

end


--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return;
            end
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local buff = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    buff:setGroupID(buffBox.GROUP_ID);
    buff:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       buff:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end


class:publish();

return class;