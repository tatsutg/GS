--@additionalEnemy,600000043
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド植物", version=1.3, id=600000041});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100,
    SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,                    
    SKILL2 = 6,
    SKILL3 = 7
}

class.SUMMON_WAITS = {
    [600000043] = 100
}

class.TELOP_SPAN = 30;
class.BATTLE_POINT_VALUE = 5000;
class.BATTLE_POINT_VALUE_FIXED = 100000;
class.RAID_BOSS_RATE = 1.6;
class.COMBO_CHAIN_DURATION = 13;
class.skill2FixedDamage = 100;

function class:setBuffBoxList()
   self.HP_50_Buff = {
      [1] = {
         ID = 501411,
         EFID = 17, -- 攻撃
         VALUE = 50,
         DURATION = 99999,
         ICON = 26
      },
      [2] = {
         ID = 501414,
         EFID = 28, -- 行動速度
         VALUE = 25,
         DURATION = 99999,
         ICON = 7
      }
   }

   self.HP_20_Buff = {
      [1] = {
         ID = 501413,
         EFID = 9, -- ゲージ加速
         VALUE = 50,
         DURATION = 99999,
         ICON = 36
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
         MESSAGE = self.TEXT.START_MESSAGE1 or "状態異常中のボスへのダメージがアップ",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE4 or "子分：燃焼時以外ダメージ無効",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false        
      }
   }

   self.HP_TRIGGER_MESSAGE_LIST1 = {
      [1] = {
         MESSAGE = self.TEXT.HP_MESSAGE1 or "与ダメージアップ",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.HP_MESSAGE2 or "行動速度アップ",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.HP_TRIGGER_MESSAGE_LIST2 = {
      [1] = {
         MESSAGE = self.TEXT.HP_MESSAGE3 or "奥義ゲージ増加速度アップ",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.DEFEAT_MESSAGES = {
      [1] = {
         MESSAGE = self.TEXT.DEFEAT_MESSAGE1 or "子分撃破により状態異常耐性ダウン",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.DEFEAT_MESSAGES2 = {
      [1] = {
         MESSAGE = self.TEXT.DEFEAT_MESSAGE2 or "さんが子分を撃破して状態異常耐性ダウン",
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
            HP = 50,
            trigger = "HP50",
            isActive = true
        },
        [2] = {
            HP = 20,
            trigger = "HP20",
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
   self.defeatTime = 0;
   self.comboTimer = 0;
   self.defeatCountFetchTimer = 0;
   self.roomHP = 100;
   self.defeatCount = 0;
   self.comboCount = 0;
   self.comboEndAnimFlag = false;
   self.summonedIndex = {};
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   self.numbersOrbit = nil;
   self.isHpZero = false;
   self.forceClearTimer = 0;
   self.isClear = false;

   self.telopTimer = 0

   self.hitStop = 0
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.stackBuffList = {}
   self.stackMessageList = {}
   -- self:showMessage(self.START_MESSAGE_LIST)
   -- self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
   return 1
end

function class:startWave(event)
    self:setStartTime(event.unit);
  
   self:showMessage(self.START_MESSAGE_LIST);
   return 1;
end

-- ---------------------------------------------------------------------------------
-- -- run
-- ---------------------------------------------------------------------------------
function class:run(event)
    -- if event.spineEvent == "addSP" then
    --     self:addSP(event.unit);
    -- end
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
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,1)
   self:clearCheck(event.unit,event.deltaTime);

   if self.numbersOrbit == nil then
      self:setupNumbers(event);
   end
  if self.numbersOrbit ~= nil then
      self:numbersControll(event.unit);
  end
     


   self:telop(event.deltaTime)
   self:periodFetch(event.unit,event.deltaTime);
   self:fetchdefeatTime(event.unit);

   self:deadCheck(event.unit,event.deltaTime);
   self:HPTriggersCheck(event.unit);
   return 1
end

function class:setupNumbers(event)
   self.numbersOrbit = event.unit:addOrbitSystemWithFile("defeatNum","0");

   self.numbersOrbit:setPosition(-160,350);
   self.numbersOrbit:setScaleX(1.45)
   self.numbersOrbit:setScaleY(1.45)
   self.numbersOrbit:setZOrder(10011)

   self.numbersOrbit:takeAnimation(0,"none",true);
   self.numbersOrbit:takeAnimation(1,"none2",true);
   self.numbersOrbit:takeAnimation(2,"none3",true);
   self.numbersOrbit:takeAnimation(3,"none4",true);
   self.numbersOrbit:setZOrder(10011);
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
   self:summon(event.unit,2);
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

    if event.index == 2 then
        self.absorbFlg = true;
    end
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:summon(event.unit,2);
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


function class:attackDamageValue(event)
    if self.absorbFlg then
        local baseDamage = self.isTarget and self.skill2FixedDamage * 2 or self.skill2FixedDamage;
        local damage = event.enemy:getHP() - baseDamage > 1 and baseDamage or event.enemy:getHP() -1;
        -- event.unit:takeHeal(damage);
        return damage;
    end
    return event.value;
end

function class:takeDamage(event)
    self.absorbFlg = false;
    return 1;
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
    if trigger == "HP50" then
         self:HP50(unit);
        return true;
    end

    if trigger == "HP20" then
         self:HP20(unit);
        return true;
    end

    return false;
end

function class:HP50(unit)
   self:addBuff(unit,self.HP_50_Buff);
   self:showMessage(self.HP_TRIGGER_MESSAGE_LIST1);
end

function class:HP20(unit)
   self:addBuff(unit,self.HP_20_Buff);
   self:showMessage(self.HP_TRIGGER_MESSAGE_LIST2);
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end


function class:summon(unit,num)
   local summonedCount = 0;
   for i = 0,1 do
      local target = unit:getTeam():getTeamUnit(i);
      if target == nil and not self.summonedIndex[i] then
         unit:getTeam():addUnit(i,summoner.Random.sampleWeighted(self.SUMMON_WAITS));--指定したインデックスの位置に指定したエネミーIDのユニットを出す
         self.summonedIndex[i] = true;
         summonedCount = summonedCount + 1;
         if summonedCount >= num then
            break;
         end
      end
   end
   self.delaySummonIndexes = {};
end


 function class:numbersControll(unit)
     self.numbersOrbit:takeAnimation(0,self:intToAnimationNameOne(self.comboCount),true);
     self.numbersOrbit:takeAnimation(1,self:intToAnimationNameTen(self.comboCount),true);
     self.numbersOrbit:takeAnimation(2,self:intToAnimationNameHandled(self.comboCount),true);
     self.numbersOrbit:takeAnimation(3,self:intToAnimationNameThousant(self.comboCount),true);
 end

function class:intToAnimationNameOne(num)
   local temp = num%10;
   if num == 0 then
      return "none";
   end
   return ""..temp;
end

function class:intToAnimationNameTen(num)
   local temp = num%100;
   temp = math.floor(temp/10);

   if temp == 0 and num < 100 then
      return "none2";
   end
   return ""..temp.."0";
end

function class:intToAnimationNameHandled(num)
   local temp = num%1000;
   temp = math.floor(temp/100);
   if temp == 0 and num < 1000 then
      return "none3";
   end
   return ""..temp.."00";
end

function class:intToAnimationNameThousant(num)
   local temp = math.floor(num/1000);
   if temp == 0 then
      return "none4";
   end
   return ""..temp.."000";
end

--===================================================================================================================
--撃破チェック
--===================================================================================================================

--1秒に１度走る定期的な同期
function class:periodFetch(unit,deltaTime)
   self.defeatCountFetchTimer = self.defeatCountFetchTimer + deltaTime;
   if self.defeatCountFetchTimer < 1 then
      return;
   end
   self.defeatCountFetchTimer = self.defeatCountFetchTimer - 1;

   self:fetchDefeatCount(unit);
end

function class:deadCheck(unit,deltaTime)

    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return;
    end


    for i=0,3 do
         local target = unit:getTeam():getTeamUnit(i,true);--死んでても生きてても第二引数がtrueなら取得可能ォ

         if target ~= nil and target:getHP() <= 0 then
           
            if self.summonedIndex[i] == true then
               self.comboCount = self.comboCount + 1;
               self.comboTimer = 0;
               self:onDefeat(unit);
               self.summonedIndex[i] = false;
            end
         end
    end

    self:comboTimerCheck(deltaTime);
    
    return;
end

function class:comboTimerCheck(deltaTime)   
   self.comboTimer = self.comboTimer + deltaTime;
   
   if self.comboTimer >= self.COMBO_CHAIN_DURATION - 4 and not self.comboEndAnimFlag then
      self.comboEndAnimFlag = true;
      self.numbersOrbit:takeAnimation(4,"vanish",true);
   end

   if self.comboTimer < self.COMBO_CHAIN_DURATION - 4 and self.comboEndAnimFlag then
      self.comboEndAnimFlag = false;
      self.numbersOrbit:takeAnimation(4,"normal",true);
   end

   if self.comboTimer >= self.COMBO_CHAIN_DURATION then
      self.comboCount = 0;
   end
end


function class:onDefeat(unit)
   

   self:fetchDefeatCount(unit);--送る直前にも万一他の人が増やしてたらまずいのでとにかく一度持ってきて自分のdefeatCountを部屋のもので上書き
   self.defeatCount = self.defeatCount + 1;
   self:sendDefeatCount(self.defeatCount);

   self:sendDefeatTime(unit);
   local point = self:calcPoint(unit);
   RaidControl:get():addBattlePoint(point/self.RAID_BOSS_RATE,0);
   self:showPointMessage(point);
   self:showMessage(self.DEFEAT_MESSAGES);
   self:defeatDebuff(unit);
   return;
end

function class:defeatDebuff(unit)
  -- summoner.Utility.messageByPlayer("デバッグ用　☆現在部屋全体で"..self.defeatCount.."体殺ったよォ☆")
  self.DOWN_BUFF_BOX_LIST[1].VALUE = self.defeatCount * -1;
   self.DOWN_BUFF_BOX_LIST[2].VALUE = self.defeatCount * -1;
   self:addBuff(self.gameUnit,self.DOWN_BUFF_BOX_LIST);
end




function class:calcPoint(unit)
    local rate = self.comboCount;
    local result = rate * self.BATTLE_POINT_VALUE + self.BATTLE_POINT_VALUE_FIXED;
    return result;
end

function class:showPointMessage(point)
    local pointStr = self.TEXT.POINT_MESSAGE or "+%d万pt"
    summoner.Utility.messageByEnemy(string.format(pointStr,point/10000),10,summoner.Color.yellow);
end

function class:clearCheck(unit,deltaTime)
   if self.isClear then
      return;
   end

   if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return;
   end

   if unit:getHP() <= 0 then
      self.isHpZero = true;
   end



   if self.isHpZero then
      self.forceClearTimer = self.forceClearTimer + deltaTime;
   end

   -- if self.forceClearTimer >= 5 then
   --    megast.Battle:getInstance():waveEnd(true);
   --    self.isClear = true;
   -- end


   return 1;
end

--==================================================================================================================================================
--ルーム同期


function class:setStartTime(unit)
    self:setDefeatTime(RaidControl:get():getCurrentRaidTime());

end

function class:sendDefeatTime(unit)
    --持ってくる前に討伐成功の事実をまず自分の中で保持　fetchしてもまだ部屋に何もないかもしれないからね
    self:setDefeatTime(RaidControl:get():getCurrentRaidTime());
    --現状部屋の最新のものについて取得　ここで一旦部屋にあるものを持ってくる
    self:fetchdefeatTime(unit);

    --直前で取得した記録よりも今の時間が新しい場合のみ送ることができる
    if self.defeatTime <= RaidControl:get():getCurrentRaidTime() then
        self:setDefeatTime(RaidControl:get():getCurrentRaidTime());
       
        local playerName = BattleControl:get():getPlayerName();
        local byteCode = self:toByteCode(playerName);
        RaidControl:get():setCustomValue("playerName",byteCode);
        RaidControl:get():setCustomValue("defeatTime",""..self.defeatTime);
    end
end

function class:setDefeatTime(time)
    self.defeatTime = math.floor(time);
end

function class:fetchdefeatTime(unit)


    local tempActTime = tonumber(RaidControl:get():getCustomValue("defeatTime"));
    
    if tempActTime ~= "" and tempActTime ~= "error" and tempActTime ~= nil then
        -- summoner.Utility.messageByEnemy(""..tempActTime,5,summoner.Color.red); --デバッグ用　時間確認したいときは叩き起こして
    else
        -- summoner.Utility.messageByEnemy("ない"..self.defeatTime,5,summoner.Color.red);  --デバッグ用　そもそも取れなかった場合自分が正義ぞ
        return;
    end


    tempActTime = math.floor(tempActTime);


    if tempActTime > self.defeatTime then
        self:setDefeatTime(tempActTime);
        local playerNameByteCode = RaidControl:get():getCustomValue("playerName");
        local playerName = self:toUnicode(playerNameByteCode);


        local DefeatMessageWithPlayerName = {
            [1] = {
               MESSAGE = playerName..self.DEFEAT_MESSAGES2[1].MESSAGE,
               COLOR = Color.yellow,
               DURATION = 10,
               isPlayer = false
            }
        }

        self:fetchDefeatCount(unit);
        if playerName ~= BattleControl:get():getPlayerName() then
          self:showMessage(DefeatMessageWithPlayerName);
        end
  
    end
end

function class:toByteCode(str)
    local i = 1;
    local result = "";
    for i=1, string.len(str) do
     result = result.." "..str:byte(i);
    end
    return result;
end

function class:toUnicode(str)
    local result = "";
    for i in str:gmatch("%d+") do

        local code = tonumber(i);
        local tmp = str.char(code);
        result = result..tmp;
    end
    return result;
end

function class:sendDefeatCount(count)
   --これが呼ばれる直前でfetchDefeatCountが呼ばれているから確認もなしにセットしちゃって大丈夫なんだよ。
   RaidControl:get():setCustomValue("defeatCount",""..self.defeatCount);
   
end

function class:fetchDefeatCount(unit)
   local tempCount = tonumber(RaidControl:get():getCustomValue("defeatCount"));
    
      if tempCount ~= "" and tempCount ~= "error" and tempCount ~= nil then
        -- summoner.Utility.messageByEnemy(""..tempCount,5,summoner.Color.red); --デバッグ用　時間確認したいときは叩き起こして
      else
        -- summoner.Utility.messageByEnemy("ない"..self.defeatCount,5,summoner.Color.red);  --デバッグ用　そもそも取れなかった場合自分が正義ぞ
         return;
      end

      if self.defeatCount < tempCount then
         self.defeatCount = tempCount;
         self:defeatDebuff(unit);
      end


end


class:publish();

return class;
