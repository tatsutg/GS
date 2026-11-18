--@additionalEnemy,20163110
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="アルマ", version=1.3, id=20163201});
class:inheritFromUnit("unitBossBase");

class.TIME1 = 10;
class.TIME2 = 30;
class.timer = 0;

class.ATTACK_WEIGHTS = {
    ATTACK1 = 50
    -- ATTACK2 = 50
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

function class:setupMessage()
  -- self.INIT_MESSAGE_LIST = {
  --   [0] = {
  --     MESSAGE = self.TEXT.INIT_MESSAGE1 or "最大ダメージ9999",
  --     COLOR = Color.yellow,
  --     DURATION = 5
  --   }
  -- }

  -- self.HASTE_1_MESSAGE_LIST = {
  --   [0] = {
  --     MESSAGE = self.TEXT.HASTE1_MESSAGE1 or "さあ、走るわよ！",
  --     COLOR = Color.red,
  --     DURATION = 5
  --   },
  --   [1] = {
  --     MESSAGE = self.TEXT.HASTE1_MESSAGE2 or "ミキュオンの前進速度UP",
  --     COLOR = Color.cyan,
  --     DURATION = 5
  --   }
  -- }

  -- self.HASTE_2_MESSAGE_LIST = {
  --   [0] = {
  --     MESSAGE = self.TEXT.HASTE2_MESSAGE1 or "ミキュオンに負けてられないわ！",
  --     COLOR = Color.red,
  --     DURATION = 5
  --   },
  --   [1] = {
  --     MESSAGE = self.TEXT.HASTE2_MESSAGE1 or "ミキュオンの前進速度UP",
  --     COLOR = Color.cyan,
  --     DURATION = 5
  --   },    
  -- }
end

function class:setupBuff(value)
   local multi = value < 20 and 3000 or 20000

  --  self.BUFF_BOX = {
  --   [1] = {
  --     ID = 20163201,
  --     BUFF_ID = 98, -- ダメージ無効
  --     VALUE = value * multi,
  --     DURATION = 999999,
  --     ICON = 24,
  --     EFFECT = 1
  --   }
  -- }
end

function class:start(event)
  self.gameUnit = event.unit
   self.fromHost = false;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
  self.timer = 0;
  self.TIME1 = 10;
  self.TIME2 = 30;

   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
  self.spValue = 20
  -- self:setupMessage();
  self.HPDOWN_MESSAGE = {
    [1] = {
      MESSAGE = self.TEXT.HPDOWN_MESSAGE1 or "最大HP減少",
      COLOR = Color.yellow,
      DURATION = 5
    }
  }
  self.lv = 1;

  self.skillCount = 0
    self.BUFF_BOX_LIST = {
    [1] = {
       ID = 501441311,
       BUFF_ID = 21, -- 魔法ダメージ無効
       VALUE = -1000,
       DURATION = 999999,
       ICON = 22,
       SCRIPT = {
        SCRIPT_ID = 5
       }
    }
  }
  self:addBuff(event.unit,self.BUFF_BOX_LIST)
  return 1;
end

function class:calcHP(unit)
  local mikyuon = self:findUnitByBaseID(40144,false);
  if mikyuon ~= nil then
    self.lv = mikyuon:getLevel() -1;
    local HP = math.pow(self.lv,3) * 250 + 10000;
    unit:setBaseHP(HP);
    unit:setHP(HP);
    unit:setBaseBreakCapacity(self.lv * 3000)
    unit:setBreakPoint(self.lv * 3000)
    unit:getTeamUnitCondition():addCondition(20095201,13,self.lv * 30,99999,0);
  end
  self:setupBuff(self.lv)
end

function class:startWave(event)
  self:calcHP(event.unit);
  return 1;
end

function class:takeDamageValue(event)
  return event.value < 9999 and event.value or 9999;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
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
   self:attackActiveSkillSetter(event.unit,event.index);
   self:addSP(event.unit);
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
   if skillIndex ~= 1 then
      if self.skillCount % 2 == 0 then
         skillIndex = 2
      else
         skillIndex = 3
         self:showMessages(unit,self.HPDOWN_MESSAGE)
      end
      self:summon(unit,20163110)
      self.skillCount = self.skillCount + 1
   end

   if skillIndex == 3 then
      for i = 0, 7 do
          if unit:getTeam():getTeamUnit(i) ~= nil and unit:getTeam():getTeamUnit(i) ~= self.gameUnit then
             -- self:execAddBuff(unit:getTeam():getTeamUnit(i),self.BUFF_BOX[1])
          end
      end
    end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

function class:summon(unit,unitID)
   if megast.Battle:getInstance():isHost() then
      for i = 0, 4 do
          if unit:getTeam():getTeamUnit(i) == nil then
               unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
              break
          end
      end
   end
end

function class:update(event)
  event.unit:setReduceHitStop(2,0.7) --ヒットストップ無効

  self.timer = self.timer + event.deltaTime;
  -- if self.timer > self.TIME1 then
  --   self.TIME1 = 99999;
  --   self:showMessages(event.unit,self.HASTE_1_MESSAGE_LIST);
  -- end

  -- if self.timer > self.TIME2 then
  --   self.TIME2 = 99999;
  --   self:showMessages(event.unit,self.HASTE_2_MESSAGE_LIST);
  -- end

  return 1;
end

function class:showMessages(unit,messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

function class:findUnitByBaseID(targetID,isPlayerTeam)
    for i = 0,7 do
        local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
        if target ~= nil and target:getBaseID3() == targetID then
            return target;
        end
    end            
end

function class:dead(event)
    self:creanUpEnemy(event.unit);
    return 1;
end

function class:creanUpEnemy(unit)
    for i = 0, 5 do
        local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
        if enemy ~= nil then
            enemy:setHP(0);
        end
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