local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイドギアベール", version=1.6, id=600000072});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
   DEFAULT = {
      { ATTACK1 = 50,ATTACK4 = 50,ATTACK5 = 50 }
   },
   RAGE = {
      {ATTACK6 = 100},
      {ATTACK8 = 100},
      {ATTACK9 = 100},
      {ATTACK7 = 100},
      {ATTACK8 = 50,ATTACK9 = 50}
   }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
   DEFAULT = {
      { SKILL1 = 100 }
   },
   RAGE = {
      { SKILL2 = 100 }
   }
}

class.ACTIVE_SKILLS = {
   ATTACK1 = 1,
   ATTACK2 = 1,
   ATTACK3 = 1,
   ATTACK4 = 2,
   ATTACK5 = 3,
   ATTACK6 = 4,
   ATTACK7 = 5,
   ATTACK8 = 6,
   ATTACK9 = 7,
   ATTACK10 = 8,
   SKILL1 = 9,
   SKILL2 = 10
}

class.ANIMSTATE = {
   IDLE = "idle",
   DAMAGE = "damage"
}


--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
   {
      ID = 40001174,
      EFID = 13,         --攻撃力
      VALUE = 50,        --効果量
      DURATION = 9999999,
      ICON = 3
   },
   {
      ID = 40001173,
      EFID = 21,         --被ダメ
      VALUE = 50,        --効果量
      DURATION = 9999999,
      ICON = 139
   }
}
class.STUN_BUFF = {
      ID = 40001173,
      EFID = 89,         --気絶
      VALUE = 60,        --効果量
      DURATION = 50,
      ICON = 79
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
   self.START_MESSAGE_LIST = {
      self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"
      }),
      self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE2 or "魔族からの攻撃無効"
      })
   }
   self.RAGE_MESSAGE_LIST = {
      self:setMessageInfo({
         MESSAGE = self.TEXT.RAGE_MESSAGE1 or "我を…冒涜した罪は…重い……",
         COLOR = Color.magenta
      }),
      self:setMessageInfo({
         MESSAGE = self.TEXT.RAGE_MESSAGE2 or "攻撃力・被ダメージアップ",
      })
   }

   self.EXECUTION_BEFORE_LIST = {
      self:setMessageInfo({
         MESSAGE = self.TEXT.EXECUTION_BEFORE or "闇の中へ…沈め……",
         COLOR = Color.magenta
      })
   }
   self.EXECUTION_AFTER_LIST = {
      self:setMessageInfo({
         MESSAGE = self.TEXT.EXECUTION_AFTER1 or "闇の中で…滅せよ……",
         COLOR = Color.magenta
      }),
      self:setMessageInfo({
         MESSAGE = self.TEXT.EXECUTION_AFTER2 or "ダメージの大きいユニットを気絶＆奥義ゲージ低下",
      })
   }

   self.DEAD_MESSAGE_LIST = {
      self:setMessageInfo({
         MESSAGE = self.TEXT.DEAD_MESSAGE1 or "闇は……不滅……",
         COLOR = Color.magenta
      })
   }


   -- テロップ
   self.mes_telop1 = self.TEXT.telop1 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
   self.mes_telop2 = self.TEXT.telop2 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"

   -- レイドメッセージ
   self.RAID_MESSAGES = {
      {
         MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
         COLOR = Color.red,
         DURATION = 5
      }
   }
end


--===============================================================================================================================================
class.TELOP_SPAN = 30
function class:start(event)
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.isRage = false;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.attack10Flag = false;
   event.unit:setSPGainValue(0);
   event.unit:setNeedSP(100);
   event.unit:takeAnimation(1,"under_idle",true);

   self:setMessageBoxList()

   self.telopTimer = 0
   self.totalDamage = 0
   self.LIMIT = 5000000
   self.targetUnitList = {}

   event.unit:setHateRate_Heal(0)
   event.unit:setHateRate_Damage(0)
   self:initAttackWeight({DEFAULT = 100})
   self:initSkillWeight({DEFAULT = 100})

   self:showMessage(self.START_MESSAGE_LIST)
   self:setSubBar()
   return 1;
end

function class:setSubBar()
   self.subBar =  BattleControl:get():createSubBar();
   self.subBar:setWidth(200); --バーの全体の長さを指定
   self.subBar:setHeight(13);
   self.subBar:setPercent(0); --バーの残量を0%に指定
   self.subBar:setVisible(false);
   self.subBar:setPositionX(0);
   self.subBar:setPositionY(150);
end

function class:startWave(event)
   BattleControl:get():visibleHateTarget(false);
   BattleControl:get():setHateTargetIcon(14);
   event.unit:setEnableHate(true);
   event.unit:updateHateTarget();
   self:checkPlayersParty()
   return 1
end

function class:checkPlayersParty()
   for i = 0,3 do
      local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
      if unit ~= nil then
         local targetInfo = {unit = unit,dps = 0}
         table.insert(self.targetUnitList,unit:getIndex() + (unit:getBaseID3() * 10),targetInfo)
      end
   end
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
   local target = nil
   local val = 0
   for i,v in pairs(self.targetUnitList) do
      if v.unit == nil or v.unit:getHP() < 1 then
         v.dps = 0
      end
      if v.dps > val then
         val = v.dps
         target = v.unit
      end
   end

   if target == nil then
      for i = 0,4 do
         local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
         if unit ~= nil then
            return unit
         end
      end
   end

   return target
end

function class:update(event)
   event.unit:setReduceHitStop(100,1);--ヒットストップ無効Lv2　100%軽減
   self:fixPosition(event.unit);
   self:checkStyle(event.unit)
   self:telop(event.deltaTime)
   self:checkSubBar(event.unit)
   return 1;
end

function class:checkSubBar(unit)
   if self.LIMIT < self.totalDamage or self.used then
      self.subBar:setVisible(false);
      return
   end

   local bonex = unit:getPositionX() - 45;
   local boney = unit:getPositionY() + 250;
   self.subBar:setPositionX(bonex);
   self.subBar:setPositionY(boney);

   self.subBar:setPercent(100 * (self.LIMIT-self.totalDamage)/self.LIMIT);
   self.subBar:setVisible(true);
end

function class:telop(deltaTime)
   if self.TELOP_SPAN < self.telopTimer then
      self.telopTimer = 0
      local rand = LuaUtilities.rand(1,3)
      if rand == 1 then
         RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
      elseif rand == 2 then
         RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
      end
   else
      self.telopTimer = self.telopTimer + deltaTime
   end
end

function class:checkStyle(unit)
   if unit.m_breaktime > 0 or self.used then
      return
   end

   if self.totalDamage > self.LIMIT then
      self.attack10Flag = true;
      self.used = true
      BattleControl:get():visibleHateTarget(true);
   end
end

function class:takeIdle(event)
   self:switchAnimation(event.unit,self.ANIMSTATE.IDLE);
   return 1;
end

function class:takeDamage(event)
   self:switchAnimation(event.unit,self.ANIMSTATE.DAMAGE);
   return 1;
end

function class:takeDamageValue(event)
   if self.attack10Flag then
      return math.sqrt(event.value);
   end
   self:checkHate(event.unit,event.enemy,event.value)
   self.totalDamage = self.totalDamage + event.value
   return event.value;
end

function class:checkHate(unit,enemy,value)
   local enemyUnit = self:getAncestorUnit(enemy)
   local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
   if self.targetUnitList[index] == nil then
      table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = value})
   else
      self.targetUnitList[index].dps = self.targetUnitList[index].dps + value
   end
   unit:setHateTarget(self:checkTargetUnit())
   unit:updateHateTarget();
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
   if unit:getParentTeamUnit() == nil then
      return unit
   else
      return self:getAncestorUnit(unit:getParentTeamUnit())
   end
end

function class:excuteAction(event)
   if self.startPositionX == nil then
      self.startPositionX = event.unit:getPositionX();
      self.startPositionY = event.unit:getPositionY();
   end
   return 1;
end

function class:dead(event)
   self:showMessage(self.DEAD_MESSAGE_LIST)
   event.unit:takeAnimation(1,"out",false);
   return 1;
end

function class:run (event)
   if event.spineEvent == "addSP" then return self:addSP(event.unit) end
   if event.spineEvent == "2ndAddSP" then return self:addSP(event.unit) end
   if event.spineEvent == "rage" then return self:rage(event.unit) end
   return 1;
end

function class:takeAttack(event)
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
   if event.index == 5 then
      event.unit:setNextAnimationName("attack5-2")
      event.unit:setNextAnimationEffectName("1-attack5")
   end
   self:attackActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:attackReroll(unit)
   local attackIndex = self:getAttackIndex()

   if attackIndex == 1 then
      local target = unit:getTargetUnit();
      local distance = 0;
      if target ~= nil then
         distance = BattleUtilities.getUnitDistance(unit,target);
      end
      if distance >= 400 then
         unit:takeAttack(3);
      elseif distance >= 200 then
         unit:takeAttack(2);
      else
         unit:takeAttack(1);
      end
      return 0;
   end

   if self.attack10Flag and not self.isRage then
      attackIndex = 10;
   else
      self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
   end
   unit:takeAttack(tonumber(attackIndex));
   return 0;
end

function class:takeSkill(event)
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
      self.skillCheckFlg = true;
      return self:skillReroll(event.unit);
   end

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end

   self.skillCheckFlg = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillIndex = self:getSkillIndex()
   if self.isRage then
      self:showMessage(self.EXECUTION_AFTER_LIST)
      local tgt = self:checkTargetUnit()
      if tgt ~= nil and self.targetUnitList[tgt:getIndex() + (tgt:getBaseID3() * 10)] ~= nil then
         self.targetUnitList[tgt:getIndex() + (tgt:getBaseID3() * 10)].dps = 0
         self.targetUnitList[tgt:getIndex() + (tgt:getBaseID3() * 10)].unit:setBurstPoint(0)
         self:addBuff(self.targetUnitList[tgt:getIndex() + (tgt:getBaseID3() * 10)].unit,self.STUN_BUFF)
         unit:setHateTarget(self:checkTargetUnit())
         unit:updateHateTarget()
         self:resetDps()
      end
   else
      self:showMessage(self.EXECUTION_BEFORE_LIST)
   end
   unit:takeSkill(tonumber(skillIndex));
   return 0;
end

function class:resetDps()
   for _,lst in pairs(self.targetUnitList) do
      lst.dps = 0
   end
end
--===================================================================================================================

function class:fixPosition(unit)
   unit:getSkeleton():setPosition(0,0);
   if self.startPositionX ~= nil then
      unit:setPositionX(self.startPositionX);
      unit:setPositionY(self.startPositionY);
   end
end



--===================================================================================================================
--怒り関係

function class:rage(unit)
   if self:getIsHost() then
      self:getRage(unit);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
      self.attack10Flag = false;
   end
   return 1;
end

function class:getRage(unit)
   self:addRageBuff(unit);
   self.isRage = true;

   self:showMessage(self.RAGE_MESSAGE_LIST)
   self:initAttackWeight({RAGE = 100})
   self:initSkillWeight({RAGE = 100})
   unit:setSetupAnimationName("idle2");
   return 1;
end

function class:addRageBuff(unit)
   for i, v in ipairs(self.RAGE_BUFF_ARGS) do
      self:addBuff(unit, v);
   end
end

function class:addBuff(unit,args)
   if args.EFFECT ~= nil then
      unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
   else
      unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
   end
end

--===============================================================================================================================================

function class:switchAnimation(unit,state)
   if self.isRage then
      unit:setNextAnimationName(state.."2");
   end
   return 1;
end

--===============================================================================================================================================

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

--=====================================================================================================
function class:receive3(args)
   self:getRage(self.gameUnit);
   return 1;
end

function class:receive4(args)
   self:getFury(self.gameUnit);
   return 1;
end


function class:movePatternState(SET_LIST,stateBox)
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

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end

class:publish();

return class;
