local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="赤ヴァル", version=1.3, id=2015429})
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50
}
class.ATTACK_WEIGHTS2 = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 3,
    ATTACK3 = 4,
    ATTACK4 = 6,
    
    SKILL1 = 1,
    SKILL2 = 5
}

--------[[メッセージ]]--------
function class:setMessageBoxList()

   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "麻痺時、被ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "氷結時、被ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      }
   }
   self.HP30_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      }     
   }

   self.SHOADOW_MESSAGE = self.TEXT.SHOADOW or "シャドウライトニングの構え"
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp40(status) end,
         HP = 40,
         used = false,
         isEnableSkip = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp25(status) end,
         HP = 25,
         used = false,
         isEnableSkip = false
      }
   }
   self.HP_TRIGGERS = {}
   self.hpMarkers = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
         self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
         if self.TRIGGERS[index].isEnableSkip then
            self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
            self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
         end
      end
   end
end

function class:hp40(status)
   if status == "use3" then
      self.isRage = true
      self.ct_time = 0
   end
end

function class:hp25(status)
   if status == "use3" then
      self.isRage = true
      self.ct_time = 0
   end
end


function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20152491,
         BUFF_ID = 21, -- 被ダメージ
         VALUE = 50,
         DURATION = 999999,
         ICON = 139
      },
      [2] = {
         ID = 20152492,
         BUFF_ID = 21, -- 被ダメージ
         VALUE = 50,
         DURATION = 999999,
         ICON = 139
      },
      [3] = {
         ID = 20152493,
         BUFF_ID = 28, -- 行動速度
         VALUE = 50,
         DURATION = 999999,
         ICON = 7
      }
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isRage = false
   self.skillExecFlag = false
   self.CHARGE_COOLTIME = 20
   self.ct_time = self.CHARGE_COOLTIME
   self.phase = 0
   self.currentAttackWeight = {}
   self:setTriggerList()
   self:setBuffBoxList()
   self:setMessageBoxList()

   -- self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit);
   -- self:checkBuff(event.unit)
   self.ct_time = self.ct_time - event.deltaTime
   return 1
end

-- function class:checkBuff(unit)
--   if not self.paralyzed and unit:getTeamUnitCondition():findConditionWithType(91) then
--     self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
--     self.paralyzed = true
--   elseif not unit:getTeamUnitCondition():findConditionWithType(91) then
--     self:execRemoveCondition(unit,self.BUFF_BOX_LIST[1].ID)
--     self.paralyzed = false
--   end

--   if not self.freezed and unit:getTeamUnitCondition():findConditionWithType(96) then
--     self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
--     self.freezed = true
--   elseif not unit:getTeamUnitCondition():findConditionWithType(96) then
--     self:execRemoveCondition(unit,self.BUFF_BOX_LIST[2].ID)
--     self.freezed = false
--   end
-- end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   event.unit:setNextAnimationName("out");
   return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
  self.chargeSkillFlag = false;
  self.skillChecker = false;
  return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
   self.chargeSkillFlag = false
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   -- if event.spineEvent == "Exc" then return self:Exc(event.unit) end
   if event.spineEvent == "chargeEnd2" then return self:chargeEnd2(event.unit) end
   if event.spineEvent == "addSP" then return self:addSP(event.unit) end
   if event.spineEvent == "charge" then return self:charge(event.unit) end
   return 1
end

-- function class:Exc(unit)
--    if self.skillExecFlag then
--        local posx = unit:getPositionX();
--        local ishost = megast.Battle:getInstance():isHost();
--        if ishost then
--            if posx > 0 then
--                self.skillExecFlag = true;
--                unit:takeBack();
--                megast.Battle:getInstance():sendEventToLua(190011510,5,1);
--                return 1;
--            else
--                self.skillExecFlag = false;
--                unit:takeAnimation(0,"charge_long",false);
--                unit:takeAnimationEffect(0,"charge_long",false);
--                megast.Battle:getInstance():sendEventToLua(190011510,6,1);
--                return 1;
--            end
--        end
--    end
-- end

function class:charge(unit)
   unit:takeAnimation(0,"charge_long",false);
   unit:takeAnimationEffect(0,"charge_long",false);
   return 1;
end

function class:chargeEnd2(unit)
   unit:takeAnimation(0,"charge_loop",true);
   unit:takeAnimationEffect(0,"charge_short",true);
   return 1;
end

function class:addSP(unit)  
   unit:addSP(self.spValue);
   return 1;
end

function class:receive5(arg)
   self:chargeskill(self.gameUnit);
   return 1
end
function class:receive6(arg)
   self:charge(self.gameUnit);
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   self.chargeSkillFlag = false
   if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
      self.attackCheckFlg = true;
      return self:attackReroll(event.unit);
   end
   self.attackCheckFlg = false;
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end

   self.fromHost = false;
   self:attackActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:attackReroll(unit)
   if self.ct_time <= 0 then
      self.currentAttackWeight = self.ATTACK_WEIGHTS2
   else
      self.currentAttackWeight = self.ATTACK_WEIGHTS
   end

   local attackStr = summoner.Random.sampleWeighted(self.currentAttackWeight);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   attackIndex = self:adjustIndex(unit,attackIndex)


   if attackIndex == "4" then
      self:chargeskill(unit)
      self.ct_time = self.CHARGE_COOLTIME
      megast.Battle:getInstance():sendEventToLua(self.scriptID,7,0);
   else
      unit:takeAttack(tonumber(attackIndex));
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   end
   return 0;
end

function class:receive7(args)
   self:chargeskill(self.gameUnit)
   self.ct_time = self.CHARGE_COOLTIME
   return 1
end

function class:adjustIndex(unit,index)
   if self.isRage then
      self.isRage = false
      return "4"
   end
   if self:isFar(unit) then
      return "3"
   end

   return index
end

function class:isFar(unit)
    local target = unit:getTargetUnit() 
    local distance = BattleUtilities.getUnitDistance(unit,target)
    if distance > 400 then
      return true
   end
   return false
end


function class:chargeskill(unit)

   unit:setBurstPoint(0);
   unit:takeAnimation(0,"charge_short",true);
   unit:takeAnimationEffect(0,"charge_short",true);
   self.chargeSkillFlag = true;
   unit:setUnitState(kUnitState_attack);
   
   BattleControl:get():pushEnemyInfomation(self.SHOADOW_MESSAGE,255,0,255,3);
   return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
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
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");


   if self.chargeSkillFlag then
      skillIndex = "1"
   else
      skillIndex = "2"    
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
         if not trigger.isEnableSkip then
            if not unit:isBreak() then
               self:execTrigger(index)
            end
         else
            self:execTrigger(index)
         end
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

   self.TRIGGERS[index].used = true
   if self.TRIGGERS[index].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
   end

   ---スキップ可でブレイク中の場合はHPギミック発動しない
   if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
      return;
   end

   self.TRIGGERS[index].action(action)
   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end
---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use3")
   if self.TRIGGERS[args.arg].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   end
   return 1
end
---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
   self.TRIGGERS[args.arg].used = true
   if self.TRIGGERS[args.arg].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   end
   return 1
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

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
   end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    
end

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end  
end



class:publish();

return class;