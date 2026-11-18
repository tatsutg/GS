local class = summoner.Bootstrap.createUnitClass({label="リオティス", version=1.3, id=101356412});



function class:start(event)
   self.isLightning = false
   self.timer = 0
   self.AURA_INTERVAL = 60
   self.OGI_DEFAULT = 150
   self.OGI_ADD = 200
   self.skill3FLG = false
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1013564121,
         BUFF_ID = 17, -- 光ダメージ
         VALUE = 50,
         DURATION = 30,
         ICON = 26,
         GROUP_ID = 3580,
         PRIORITY = 50,
         SCRIPT = {
            SCRIPT_ID = 70,
            VALUE1 = 4
         }
      },
      [2] = {
         ID = 1013564122,
         BUFF_ID = 17, -- 魔法ダメージ
         VALUE = 50,
         DURATION = 30,
         ICON = 29,
         GROUP_ID = 1008,
         PRIORITY = 50,
         SCRIPT = {
            SCRIPT_ID = 5
         }
      },
      [3] = {
         ID = 1013564123,
         BUFF_ID = 0, -- アイコンだけ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 218
      }
   }
   event.unit:setParameter("135_Raitei","0")

   return 1
end

function class:update(event)
   if self.skill3FLG then
      self.skill3FLG = false
      event.unit:addSPWithPvpCorrection(50)
   end
   if self.isLightning and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      if self.timer > self.AURA_INTERVAL then
         self.timer = 0
         self.isLightning = false
         event.unit:setParameter("135_Raitei","0")
      else
         self.timer = self.timer + event.deltaTime
      end
   end
   return 1
end

function class:run(event)
   if event.spineEvent == "skillEffect" then
      if self.isLightning then
         self:skill1(event.unit,0.1)
      else
         self:skill1(event.unit,0.05)
      end
   end
   if event.spineEvent == "skill3" then
      --event.unit:addSPWithPvpCorrection(50)
   end
   return 1
end

function class:checkAnim(unit,animName)
   if self.isLightning then
      unit:setNextAnimationName(animName.."_lightning")
   end
end

function class:takeCast(event) self:checkAnim(event.unit,"cast") return 1 end
function class:takeIdle(event) self:checkAnim(event.unit,"idle") return 1 end
function class:takeBack(event) self:checkAnim(event.unit,"back") return 1 end
function class:takeFront(event) self:checkAnim(event.unit,"front") return 1 end
function class:takeDamage(event) self:checkAnim(event.unit,"damage") return 1 end


function class:takeAttack(event)
   if self.isLightning then
      self:checkAnim(event.unit,"attack1")
   end
   return 1
end

function class:takeSkill(event)
   if self.isLightning then
      event.unit:setNextAnimationName("skill"..event.index.."_lightning")
      event.unit:setNextAnimationEffectName("3-skill"..event.index.."_lightning")
   end

   if event.index == 2 then
      if self.isLightning then
         event.unit:getBurstSkill():setDamageRate(self.OGI_ADD)
      else
         event.unit:getBurstSkill():setDamageRate(self.OGI_DEFAULT)
      end
   end

   if event.index == 3 then
      if not self.isLightning then
         self.isLightning = true
         self:execAddBuff(event.unit,self.BUFF_BOX_LIST[3])
         event.unit:setParameter("135_Raitei","1")
         self.skill3FLG = true
      else
         self:removeCondition(event.unit,self.BUFF_BOX_LIST[3].ID)
         event.unit:setParameter("135_Raitei","0")
         self.timer = self.AURA_INTERVAL
         for i = 0,6 do
            local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i);
            if teamUnit ~= nil then
               self:execAddBuff(teamUnit,self.BUFF_BOX_LIST[1])
               self:execAddBuff(teamUnit,self.BUFF_BOX_LIST[2])
            end
         end
      end
   end
   return 1
end

function class:skill1(unit,value)
   for i = 0,6 do
      local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
      if teamUnit ~= nil then
         teamUnit:takeHeal(unit:getCalcAttack()*value,unit)
      end
   end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
   local buff  = nil;
   if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
      elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
         return;
      end
   end

   if buffBox.EFFECT ~= nil then
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
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

   if buffBox.GROUP_ID ~= nil then
      buff:setGroupID(buffBox.GROUP_ID);
      buff:setPriority(buffBox.PRIORITY);
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