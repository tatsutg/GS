local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="イフリート", version=1.3, id=2007931});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
  ATTACK1 = 50,
  ATTACK2 = 50
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

-- HP減少量（割合）
class.SHAVE_RATIO = 0.1

function class:setBuffBoxList()
self.BUFF_BOX_LIST = {
  [0] = {
    ID = 10001,
    BUFF_ID = 97, -- 燃焼
    VALUE = 100,
    DURATION = 5,
    ICON = 87
    }
  }
end

function class:setMessageBoxList()
self.MESSAGE_BOX_LIST = {
  [0] = {
    MESSAGE = self.TEXT.START_MESSAGE1 or "我に挑むか...",
    COLOR = Color.red,
    DURATION = 5
  },
  [1] = {
    MESSAGE = self.TEXT.DEAD_MESSAGE1 or "実に...愉しい闘いだった...",
    COLOR = Color.red,
    DURATION = 5
  }
}
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
  self.fromHost = false;
  self.gameUnit = nil;
  self.spValue = 20;
  self.attackCheckFlg = false;
  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  event.unit:setSkillInvocationWeight(0);

  self.isSliced = false
  self:setBuffBoxList()
  self:setMessageBoxList()
  self.isBurn = false
  self.gameUnit = event.unit;
  event.unit:setSPGainValue(0);
  return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
  self:firstImpact(event.unit)
  event.unit:addSP(event.unit:getNeedSP());
  return 1;
end

function class:firstImpact(unit)
  self:showMessage(self.MESSAGE_BOX_LIST,0)
  -- if self:getIsHost() then
  --   unit:takeSkill(2)
  -- end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  -- 開幕でHPを削る
  if not self.isSliced then
    if "slice" == event.spineEvent then
      for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
          local shavedHPValue = localUnit:getHP() - (localUnit:getHP() * self.SHAVE_RATIO)
          localUnit:setHP(shavedHPValue)
        end  
      end
      self.isSliced = true

    end
  end
  return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
  self:showMessage(self.MESSAGE_BOX_LIST,1)
  megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
  return 1
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

  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  self.fromHost = false;
  self:skillActiveSkillSetter(event.unit,event.index);
  return 1
end

function class:skillReroll(unit)
  local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
  local skillIndex = string.gsub(skillStr,"SKILL","");

  unit:takeSkill(tonumber(skillIndex));
  megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
  return 0;
end



function class:addSP(unit)

  unit:addSP(self.spValue);
  
  return 1;
end


--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフの指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
  if index == nil then 
      self:addBuffRange(unit,buffBoxList,0,table.maxn(buffBoxList))
      return
  end
  self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
  for i = start,finish do
      summoner.Utility.messageByEnemy(i,5,Color.cyan);
      self:execAddBuff(unit,buffBoxList[i])
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
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
if index == nil then 
  self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
  return
end
self:execShowMessage(messageBoxList[index])
end

function class:showMessageRange(messageBoxList,start,finish)
for i = start,finish do
  self:execShowMessage(messageBoxList[i])
end
end

function class:execShowMessage(messageBox)
summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end

--=====================================================================================================================================
function class:getIsHost()
  return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
  self:showMessage(self.MESSAGE_BOX_LIST,1)
  return 1;
end


class:publish();

return class;