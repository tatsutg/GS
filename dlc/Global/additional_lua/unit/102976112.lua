local class = summoner.Bootstrap.createUnitClass({label="炎ロイ", version=1.3, id=102976112});

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1029761121,
         BUFF_ID = 17, -- 奥義ダメージ
         VALUE = 50,
         DURATION = 9,
         ICON = 26,
         SCRIPT = {
            SCRIPT_ID = 58
         }
      }

   }
end

function class:start(event)
   self.isCounter = false
   self:setBuffBoxList()
   return 1
end

function class:startWave(event)
   self.isCounter = false
   return 1
end

function class:run(event)
   if event.spineEvent == "waitStart" then
      self.isCounter = true
      self.isDamaged = false
   end

   if event.spineEvent == "waitEnd" then
      self.isCounter = false
      if self.isDamaged then
         self.isDamaged = false
         self:execSkillAction(event.unit)
      end
   end
   return 1
end

function class:takeDamageValue(event)
   if self.isCounter then
      self.isDamaged = true
      return 0
   end
   return event.value
end

function class:takeBreakeValue(event)
   if self.isCounter then
      return 0
   end
   return event.value
end

function class:execSkillAction(unit)
   self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
end

function class:takeDamage(event)
   self.isCounter = false
   return 1
end

function class:takeAttack(event)
   self.isCounter = false
   return 1
end

function class:takeSkill(event)
   self.isCounter = false
   if event.index == 3 then
      if self:checkSize(event.unit,3) then
         self:BigBoss(event.unit)
      end
   end
   return 1
end

function class:BigBoss(unit)
   unit:setNextAnimationName("skill3_Boss")
   unit:setNextAnimationEffectName("2-skill3_Boss")
end

-- 敵のサイズをチェックする。雑魚は1、ボスは3
function class:checkSize(unit,size)
   local targetUnit = unit:getTargetUnit()
   if targetUnit ~= nil and targetUnit:getSize() == size then
      return true
   end
   return false
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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
end

class:publish();

return class;