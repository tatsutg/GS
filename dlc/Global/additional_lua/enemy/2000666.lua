--@additionalEnemy,2000669
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.3, id=2000666});
class:inheritFromUnit("unitBossBase")


--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    -- ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 20,
    ATTACK4 = 20,
    ATTACK5 = 20,
    ATTACK6 = 20
    -- ATTACK7 = 20
    -- ATTACK8 = 20
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    -- SKILL2 = 50,
    SKILL3 = 50
}

class.ACTIVE_SKILLS = {
    -- ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    -- ATTACK7 = 7,   
    -- ATTACK8 = 8,   
    SKILL1 = 8,
    -- SKILL2 = 9,
    SKILL3 = 10
}

class.SUBSPIDER_ID = 2000669

function class:setSubSpider()
    self.ENEMYS = {
      [self.SUBSPIDER_ID] = 50
  }
end



function class:setMessageBoxList()
  self.MESSAGE_BOX_LIST = {
    [0] = {
      MESSAGE = self.TEXT.SKILL_MESSAGE1,
      DURATION = 5,
      COLOR = Color.magenta
    },
    [1] = {
      MESSAGE = self.TEXT.SKILL_MESSAGE2,
      DURATION = 5,
      COLOR = Color.red
    },
    [2] = {
      MESSAGE = self.TEXT.SKILL_MESSAGE3,
      DURATION = 5,
      COLOR = Color.red
    },
    [3] = {
      MESSAGE = self.TEXT.SUMMON_MESSAGE1,
      DURATION = 5,
      COLOR = Color.yellow    
    },
    [4] = {
      MESSAGE = self.TEXT.START_MESSAGE1,
      DURATION = 5,
      COLOR = Color.red
    },
    [5] = {
      MESSAGE = self.TEXT.START_MESSAGE2,
      DURATION = 5,
      COLOR = Color.yellow
    },
    [6] = {
      MESSAGE = self.TEXT.START_MESSAGE3,
      DURATION = 5,
      COLOR = Color.yellow
    }
  }

  self.RAGE_MASSAGE_BOX = {
    [0] = {
      MESSAGE = self.TEXT.RAGE_MESSAGE1,
      DURATION = 5,
      COLOR = Color.red
    },
    [1] = {
      MESSAGE = self.TEXT.RAGE_MESSAGE2,
      DURATION = 5,
      COLOR = Color.yellow
    },
    [2] = {
      MESSAGE = self.TEXT.RAGE_MESSAGE3,
      DURATION = 5,
      COLOR = Color.yellow
    },
    [3] = {
      MESSAGE = self.TEXT.RAGE_MESSAGE4,
      DURATION = 5,
      COLOR = Color.yellow
    }
  }
end

function class:setBuffBoxList()
  self.BUFF_BOX_LIST = {
    [0] = {
      ID = 40075,
      BUFF_ID = 17,      --ダメージアップ
      VALUE = 70,        --効果量
      DURATION = 9999999,
      ICON = 26,
      EFFECT = 50009
    },
    [1] = {
      ID = 40076,
      BUFF_ID = 28,         --攻撃速度アップ
      VALUE = 30,        --効果量
      DURATION = 9999999,
      ICON = 7
    }
  }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.spValue = 20
  self.hitStop = 0.5
  self.flipFlg = false
  self.HP_TRIGGERS = {
    [75] = "HP_FLG_75",
    [30] = "HP_FLG_30"
  }
  -- if table.maxn(self.TEXT) == 0 then
  --   self.TEXT = {
  --     SKILL_MESSAGE1 = "闇の者よ...滅びよ",
  --     SKILL_MESSAGE2 = "生者は死者に...死者は死者のまま",
  --     SKILL_MESSAGE3 = "風前の灯には火を...",
  --     SUMMON_MESSAGE1 = "可愛い子らよ...愛を...",
  --     START_MESSAGE1 = "獣・人族キラー",
  --     START_MESSAGE2 = "クリティカル耐性",
  --     START_MESSAGE3 = "HP自然回復",
  --     RAGE_MESSAGE1 = "ダメージUP",
  --     RAGE_MESSAGE2 = "行動速度UP",
  --     RAGE_MESSAGE3 = "ヒットストップ無効",
  --     RAGE_MESSAGE4 = "ブレイク耐性DOWN"
  --   }
  -- end

  self:setBuffBoxList()
  self:setMessageBoxList()
  self:setSubSpider()
    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end

  return 1
end

function class:takeIdle(event)
  event.unit:setNextAnimationName("idle1");
  return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
  self:showMessageRange(self.MESSAGE_BOX_LIST,4,5)
  return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "flip" == event.spineEvent then
    self:flipHP()
  end

  return 1
end

-- 全プレイヤーユニットのHP反転
function class:flipHP()
  for i = 0,3 do
    local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
    if unit ~= nil then
      unit:setHP((unit:getCalcHPMAX() - unit:getHP()))
    end
  end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setReduceHitStop(2,self.hitStop)
  self:HPTriggersCheck(event.unit)
  return 1
end

--===================================================================================================================
-- HPトリガー関係
--===================================================================================================================
function class:HPTriggersCheck(unit)
  local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
  for i,v in pairs(self.HP_TRIGGERS) do
    if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
      if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
          self.HP_TRIGGERS[i] = nil;
          if self.hpMarkers[i] ~= nil then
              self.gameUnit:removeHpMarker(self.hpMarkers[i])
          end
      end
    end
  end
end

function class:excuteTrigger(unit,trigger)
  if trigger == "HP_FLG_75" then
    self:hp_75(unit)
  end

  if trigger == "HP_FLG_30" then
    self.hitStop = 1
    self:hp_30(unit)
  end
  return true
end

function class:hp_75(unit)
  self:summon(unit)
  self.flipFlg = true
end

function class:hp_30(unit)
  self:showMessage(self.RAGE_MASSAGE_BOX)
  self.hitStop = 1
  self:summon(unit)
  self:addBuff(unit,self.BUFF_BOX_LIST)
  self.flipFlg = true
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


    unit:takeAttack(tonumber(attackIndex));
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

    if 1 == event.index then
      self:showMessage(self.MESSAGE_BOX_LIST,0)
    end
    if 3 == event.index then
      self:showMessageRange(self.MESSAGE_BOX_LIST,1,2)
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

    if self.flipFlg then
      self.flipFlg = false
      skillIndex = "3"
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:addSP(unit)  
    unit:addSP(self.spValue);
    return 1;
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

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
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
-- 子蜘蛛関係
--===================================================================================================================
function class:summon(unit)
    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
             unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
             self:showMessage(self.MESSAGE_BOX_LIST,3)
             -- cnt = cnt + 1; 
             -- if cnt >= self.SUMMON_CNT_MAX then
                break;
             -- end
        end
    end
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