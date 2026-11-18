local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="リシュリー", version=1.3, id=20085201});

class.TIME1 = 10;
class.TIME2 = 30;
class.timer = 0;



function class:start(event)
  self.timer = 0;
  self.TIME1 = 10;
  self.TIME2 = 30;
  self:setupMessage();
  self.lv = 1;
  self:calcHP(event.unit);
  
  return 1;
end

function class:calcHP(unit)
  local mikyuon = self:findUnitByBaseID(40121,false);
  if mikyuon ~= nil then
    self.lv = mikyuon:getLevel();
    local HP = math.pow(10,self.lv/20) * 10000;
    unit:setBaseHP(HP);
    unit:setHP(HP);
    unit:getTeamUnitCondition():addCondition(20095201,13,self.lv * 30,99999,0);
  end
end

function class:startWave(event)
  self:showMessages(event.unit,self.INIT_MESSAGE_LIST);
  return 1;
end

function class:takeDamageValue(event)
  return event.value < 9999 and event.value or 9999;
end

function class:takeBreakeDamageValue(event)
  
  local rate = 1000/math.pow(10,(self.lv-1)/20);
  if rate < 1 then
    return event.value;
  end
  return event.value * rate;
end

function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        event.unit:takeSkill(3);
        return 0
    end
    self.skillCheckFlg = false;
    event.unit:setActiveSkill(1);
    return 1
end

function class:setupMessage()
  self.INIT_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.INIT_MESSAGE1 or "最大ダメージ9999",
      COLOR = Color.yellow,
      DURATION = 5
    }
  }

  self.HASTE_1_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.HASTE1_MESSAGE1 or "さあ、走るわよ！",
      COLOR = Color.red,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.HASTE1_MESSAGE2 or "ミキュオンの前進速度UP",
      COLOR = Color.cyan,
      DURATION = 5
    }
  }

  self.HASTE_2_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.HASTE2_MESSAGE1 or "ミキュオンに負けてられないわ！",
      COLOR = Color.red,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.HASTE2_MESSAGE1 or "ミキュオンの前進速度UP",
      COLOR = Color.cyan,
      DURATION = 5
    },    
  }
end

function class:update(event)
  event.unit:setReduceHitStop(2, 1) --ヒットストップ無効

  self.timer = self.timer + event.deltaTime;
  if self.timer > self.TIME1 then
    self.TIME1 = 99999;
    self:showMessages(event.unit,self.HASTE_1_MESSAGE_LIST);
  end

  if self.timer > self.TIME2 then
    self.TIME2 = 99999;
    self:showMessages(event.unit,self.HASTE_2_MESSAGE_LIST);
  end

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

class:publish();

return class;