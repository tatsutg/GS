local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レオーネ", version=1.3, id=2014649});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 400
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 5
}

class.MAGIA_DRIVE = 4

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 20146491,
         BUFF_ID = 0, -- MDアイコンのみ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 189
      },
      [1] = {
         ID = 20146492,
         BUFF_ID = 0, -- 奥義ゲージアイコンのみ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 36
      }
   }
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "ダメージ完全無効",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

   self.HP30_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義ゲージ速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.TALK_LIST = {}
   self.TALK_LIST[1] = {
      BASE_ID = 250,
      PLYORITY = 2,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK3_MESSAGE1 or "レオーネ様、もう少しの辛抱です",
            COLOR = Color.cyan,
            DURATION = 3,
            isPlayer = true
         }
      }
   }

   self.TALK_LIST[2] = {
      BASE_ID = 248,
      PLYORITY = 1,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK1_MESSAGE1 or "ボクが、助けます",
            COLOR = Color.red,
            DURATION = 3,
            isPlayer = true
         }
      }
   }

   self.TALK_LIST[3] = {
      BASE_ID = 249,
      PLYORITY = 3,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK2_MESSAGE1 or "お姫ちゃん、待っててね…！",
            COLOR = Color.green,
            DURATION = 3,
            isPlayer = true
         }
      }
   }

   self.TALK_LIST[4] = {
      BASE_ID = 266,
      PLYORITY = 1,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK4_MESSAGE1 or "ボクが、助けます",
            COLOR = Color.red,
            DURATION = 3,
            isPlayer = true
         }
      }
   }

   self.TALK_LIST[5] = {
      BASE_ID = 267,
      PLYORITY = 4,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK5_MESSAGE1 or "レオーネ！今、助けるから！",
            COLOR = Color.cyan,
            DURATION = 3,
            isPlayer = true
         }
      }
   }


   
end

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
         action = function (status) self:hp30(status) end,
         HP = 30,
         used = false
      },
      [3] = {
         tag = "OTHER",
         action = function (status) self:hp1(status) end,
         HP = 1,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         trigger.hpMarker = self.gameUnit:addNumHpMarker(trigger.HP * 0.01)
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp50(status)
   if status == "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
   end
end

function class:hp30(status)
   if status == "use3" then
      self.isFury = true
      self.spValue = 40
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
   end
end

function class:hp1(status)
   if status == "use3" then
      self.timer = self.AURA_INTERVAL + 1
      self:showEffect(self.gameUnit)
      self:removeCondition(self.gameUnit,self.BUFF_BOX_LIST[1].ID)
      self.aura:takeAnimation(0,"empty",true);
      megast.Battle:getInstance():setBattleState(kBattleState_none);
      megast.Battle:getInstance():waveEnd(true);
   end
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

   self.hitStop = 0
   self.timer = 0
   self.aura = nil
   self.isRage = false
   self.isFury = false
   self.isAura = false
   self.currentTime = 0
   self.currentTalkTime = 0
   self.talkListIndex = 1
   self.AURA_INTERVAL = 99999
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.isRage = true
   self.gameUnit:addSP(100)
   -- self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self:sarchTalkTarget()
   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

function class:showEffect(unit)
   self.iFlag = false
   self:switchUnitEffect(unit,true)
   if self.isAura and self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_loop",true);
   end
end

-- 特殊会話用関数
function class:sarchTalkTarget()
   --　優先度。優先度が高いものほど小さい数になる（最優先のplyorityは1）。優先度が同じならランダム
   local ply = 9
   local talk = {}
   local randomTalk = {}
   for i=0,7 do
      local target = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i,true);
      for i,v in ipairs(self.TALK_LIST) do
         if target ~= nil and v.BASE_ID == target:getBaseID3() then
            if ply > v.PLYORITY then
               randomTalk = {}
               ply = v.PLYORITY
               talk = v.TALKS
            end
            if ply == v.PLYORITY then
               table.insert(randomTalk,v.TALKS)
            end
         end
      end
   end

   if #randomTalk > 0 then
      talk = randomTalk[math.random(#randomTalk)]
   end


   if ply ~= 9 then
      self.currentTalkList = {}
      for ii,vv in ipairs(talk) do table.insert(self.currentTalkList,vv) end
      return true
   end

   return false
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "md6Start" then
      self:setAura(event.unit)
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
   end

   if event.spineEvent == "invisible" then
      self.iFlag = true
      self:switchUnitEffect(event.unit,false)
      if self.aura ~= nil then
         self.aura:takeAnimation(0,"empty",true);
      end

   end

   if event.spineEvent == "showEffec" then 
      self:showEffect(event.unit)
   end   
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_6","MD_in");
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  --常にダメージ無効
   return 0
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   -- event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit)
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   self:invisible(event.unit)
   self:callTalk(event.deltaTime)
   return 1
end

function class:checkHP(unit)
   if unit:getHP() == 1 and not self.TRIGGERS[3].used then
      self:execTrigger(3)
   end
end

function class:invisible(unit)
   if self.iFlag then
      self:switchUnitEffect(unit,false)
   end
end

function class:switchUnitEffect(unit,bool)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
    return 
  end

  for i = 0,(conditionSize - 1) do
     local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
     cond:setUnitEffectVisible(bool)
  end
end

function class:callTalk(deltaTime)
   if self.currentTalkList == nil then
      return
   end

   if table.maxn(self.currentTalkList) < self.talkListIndex then
      self.currentTalkList = nil
      return
   end

   self.currentTalkTime = self.currentTalkTime - deltaTime
   if 0 > self.currentTalkTime then
      self.currentTalkTime = self.currentTalkList[self.talkListIndex].DURATION
      self:execShowMessage(self.currentTalkList[self.talkListIndex])
      self.talkListIndex = self.talkListIndex + 1
   end
end

function class:auraPosition(unit)
   if self.aura == nil then
      return
   end

   local vec = unit:getisPlayer() and 1 or -1
   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
   local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
   self.aura:setPosition(targetx,targety);
   self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
   self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
   if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      if self.AURA_INTERVAL < self.timer then
         self.isAura = false
         self.timer = 0
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   self:showEffect(event.unit)
   self:checkHP(event.unit)
   self:addSP(event.unit);
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

function class:addSP(unit)  
   unit:addSP(self.spValue);
   return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   self:showEffect(event.unit)
   self:checkHP(event.unit)
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
   if event.index == 3 then
      self:setupSkill3(event.unit)
   end
   return 1
end

function class:setupSkill3(unit)
   if not self.isAura then
      self.isAura = true
      unit:setActiveSkill(self.MAGIA_DRIVE)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[0])
   else
      unit:setNextAnimationName("skill3_2")
      unit:setNextAnimationEffectName("2skill3_2")
   end
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage or self.isFury then
      self.isRage = false
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
   for i,messageBox in pairs(messageBoxList) do
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
   if self.TRIGGERS[index].hpMarker ~= nil then
      self.gameUnit:removeHpMarker(self.TRIGGERS[index].hpMarker)
   end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   self.TRIGGERS[args.arg].used = true
   self.gameUnit:removeHpMarker(self.TRIGGERS[args.arg].hpMarker)
   return 1
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
   for i,buffBox in pairs(buffBoxList) do
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
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end


class:publish();

return class;