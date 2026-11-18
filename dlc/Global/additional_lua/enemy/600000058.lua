--@additionalEnemy,600000043
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="イード", version=1.3, id=600000058});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK5 = 50,
    ATTACK6 = 0,
    ATTACK7 = 50
}
class.ATTACK_WEIGHTS_2 = {
    ATTACK5 = 50,
    ATTACK6 = 50,
    ATTACK7 = 50
}

--使用する奥義とその確率
class.SKILL_REAL = {
    [0] = 2,
    [1] = 2,
    [2] = 3
}

class.ACTIVE_SKILLS = {
    ATTACK5 = 1,
    ATTACK6 = 2,
    ATTACK7 = 3,                   
    SKILL2 = 4,
    SKILL3 = 5
}



class.TELOP_SPAN = 30;
class.BREAK_POINT_DEFAULT = 60000;

function class:setBuffBoxList()


   self.HP_30_Buff = {
      [1] = {
         ID = 501413,
         EFID = 28, -- 行動速度
         VALUE = 10,
         DURATION = 99999,
         ICON = 7
      }
   }
   self.BARRIER_BUFF_BOX_LIST = {
      [1] = {
        ID = 500211,
        EFID = 21,            --被ダメージカット
        VALUE = -50,
        DURATION = 999999,
        ICON = 20,
        EFSKELETON = "unit/animation/50159Barrier.json",
        ANIMATION = "bossBarrier1"
      }
   }


  self.DOWN_BUFF_BOX_LIST = {
      [1] = {
        ID = 5014110,
        EFID = 113, --耐性
        VALUE = -50,
        DURATION = 999999,
        ICON = 77
      },
      [2] = {
        ID = 5014111,
        EFID = 112, --回避率
        VALUE = -50,
        DURATION = 999999,
        ICON = 0
      }

  }

  self.TARGET_BUFF_BOX_LIST = {
       [1] = {
        ID = 501419,
        EFID = 17, -- ダメージ
        VALUE = 100,
        DURATION = 999999,
        ICON = 26
      }
  }

end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "水属性キラー",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "ブレイクダメージでバリア解除",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      }
   }

   self.ARTS_MESSAGE_LIST = {
      [2] = {
         MESSAGE = self.TEXT.ARTS_MESSAGE1 or "λ μα Δ Яωt",
         COLOR = Color.white,
         DURATION = 10,
         isPlayer = false        
      },
      [3] = {
         MESSAGE = self.TEXT.ARTS_MESSAGE2 or "βνη εε ЯπμZ αΣ ζДη χ",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false        
      }
   }

   self.BREAK_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.BREAK_MESSAGE1 or "バリア破壊：被ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      }
   }

   self.HP_TRIGGER_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP_TRIGGER_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      }
   }





    -- レイドメッセージ
    self.RAID_MESSAGES = {
        {
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red,
            DURATION = 10
        }        
    }

  -- テロップ
  self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
  self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
  self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end


function class:telop(deltaTime)
    if RaidControl:get() == nil then
      return false;
    end
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,4)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end                
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.HP_TRIGGERS = {
        [1] = {
            HP = 30,
            trigger = "HP30",
            isActive = true
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
   self.beforeDefeat = false;
   self.beforeDefeatTime = 0;
   self.forceAttackIndex = 0;
   self.skillCount = 0;
   self.defeatCountFetchTimer = 0;
   self.roomHP = 100;
   self.defeatCount = 0;
   self.comboCount = 0;
   self.comboEndAnimFlag = false;
   self.summonedIndex = {};
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   self.numbersOrbit = nil;
   self.breakPoint = self.BREAK_POINT_DEFAULT;
   self.isBarrier = true;



   self.telopTimer = 0

   self.hitStop = 0
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.stackBuffList = {}
   self.stackMessageList = {}
   self:showMessage(self.START_MESSAGE_LIST)
   self:addBuff(self.gameUnit,self.BARRIER_BUFF_BOX_LIST);

   self.subBar =  BattleControl:get():createSubBar();
   self.subBar:setWidth(200); --バーの全体の長さを指定
   self.subBar:setHeight(13);--バーの幅を指定
   self.subBar:setPercent(0); --バーの残量を0%に指定
   self.subBar:setVisible(false);
   event.unit:addSP(60);
   return 1
end

function class:startWave(event)
    event.unit:setDefaultPosition(-320,-30);
    event.unit:setPositionX(-320);
    event.unit:setPositionY(-30);
   return 1;
end

-- ---------------------------------------------------------------------------------
-- -- run
-- ---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
    end
    return 1;
end


-- ---------------------------------------------------------------------------------
-- -- executeAction
-- ---------------------------------------------------------------------------------
function class:excuteAction(event)
  self:checkTarget()
  self.absorbFlg = false;
  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:addBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
    self:showMessage(self.RAID_MESSAGES)
  end
  if self:getIsTarget() then
    BattleControl:get():showHateAll()
  else
    BattleControl:get():hideHateAll(); 
    self:removeBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  if RaidControl:get() == nil then
    return false;
  end
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(20, 0.99)

   self:telop(event.deltaTime)


   self:HPTriggersCheck(event.unit);

   event.unit:setPositionX(-320);
            
   event.unit:setPositionY(-30);
   event.unit:getSkeleton():setPosition(0,0);
   self:subBarControll(event.unit);
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

  if self.forceAttackIndex ~= 0 then
      attackIndex = self.forceAttackIndex;
      self.forceAttackIndex = 0;
  end


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


   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   self:execShowMessage(self.ARTS_MESSAGE_LIST[event.index]);
   return 1
end

function class:skillReroll(unit)
   local skillIndex = self.SKILL_REAL[self.skillCount % 3];

   self.skillCount = self.skillCount + 1;


   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end


function class:attackDamageValue(event)

    return event.value;
end

function class:takeDamage(event)
    event.unit:setNextAnimationName("damage_3");
    return 1;
end

function class:takeBreakeDamageValue(event)
   if event.unit:getBreakPoint() <= 0 then
      return event.value;
   end
   self.breakPoint = self.breakPoint - event.value;
   return event.value;
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

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:addBuffTimes(unit,buffs)
    for k,v in pairs(buffs) do
        local buff = unit:getTeamUnitCondition():findConditionWithID(v.ID);
        if buff ~= nil then
            buff:setTime(self.downTimer);
        end
    end
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
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.EFID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.EFID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
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

    if buffBox.EFSKELETON ~= nil then
        buff:addAnimationWithFile(buffBox.EFSKELETON,buffBox.ANIMATION);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
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
   -- for i,messageBox in ipairs(messageBoxList) do
   --    self:execShowMessage(messageBox)
   -- end
   --今回はどうしても配列が歯抜けになる使用上変なforになる
   for i=0,10 do
      if messageBoxList[i] ~= nil then
          self:execShowMessage(messageBoxList[i]);
      end
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
--HPトリガー
function class:HPTriggersCheck(unit)

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end
end


function class:excuteTrigger(unit,trigger)

    if trigger == "HP30" then
         self:HP30(unit);
        return true;
    end

    return false;
end


function class:HP30(unit)
   self:addBuff(unit,self.HP_30_Buff);
   self:showMessage(self.HP_TRIGGER_MESSAGE_LIST);
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end


function class:takeIdle(event)

        event.unit:setNextAnimationName("idle_3");
  
    return 1;
end

function class:subBarControll(unit)
    if not self.isBarrier then
        return;
    end

    local x = unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local y = unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.subBar:setPositionX(unit:getPositionX() + x);--位置を指定
    self.subBar:setPositionY(unit:getPositionY()+ y);
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * self.breakPoint/self.BREAK_POINT_DEFAULT);
    if self.breakPoint <= 0 and self.isBarrier then
        self.isBarrier = false;
        self.subBar:setVisible(false);
        self:removeBuffs(unit,self.BARRIER_BUFF_BOX_LIST);
        self:showMessage(self.BREAK_MESSAGE_LIST);
        self.ATTACK_WEIGHTS = class.ATTACK_WEIGHTS_2 -- バリア破壊後は麻痺を使うようになる
    end
end


--=====================================================================================================
--WARNING DO NOT DELETE !! WARNING DO NOT DELETE !! WARNING DO NOT DELETE !! WARNING DO NOT DELETE !! 
--=====================================================================================================
--ダウンロードバンドルにこいつのバリアエフェクトを反応させるために、addOrbitSystemWithFileしておきます。
--絶対に通らないけど、絶対に消しちゃダメ。
--これを消すと一括ダウンロードでもしない限りバリアがなくて落ちるよ！

function class:dlcDummy( ... )
    unit:addOrbitSystemWithFile("50159Barrier","attack1");
end
--=====================================================================================================
--WARNING DO NOT DELETE !! WARNING DO NOT DELETE !! WARNING DO NOT DELETE !! WARNING DO NOT DELETE !! 
--=====================================================================================================

class:publish();

return class;
