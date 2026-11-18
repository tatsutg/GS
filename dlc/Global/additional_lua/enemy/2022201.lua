local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ドラゴン", version=1.3, id=2022201});

class.MESSAGE_BOX_LIST = {
    
}



class.RAGE_BUFFS = {
    {
        ID = 500111,
        BUFF_ID = 22,
        VALUE = 100,
        DURATION = 99999,
        ICON = 11
    },
    {
        ID = 500112,
        BUFF_ID = 21,
        VALUE = -80,
        DURATION = 99999,
        ICON = 20
    },
    {
        ID = 500113,
        BUFF_ID = 28,
        VALUE = 20,
        DURATION = 99999,
        ICON = 7
    }
}

class.ATTACK_BOX_LIST = {
   [1] = {
        ANIMATION_NUMBER = 1,
        ACTIVE_SKILL = 1
    },
   [2] = {
        ANIMATION_NUMBER = 2,
        ACTIVE_SKILL = 2
   },
   [3] = {
        ANIMATION_NUMBER = 3,
        ACTIVE_SKILL = 3
   },
   [4] = {
        ANIMATION_NUMBER = 4,
        ACTIVE_SKILL = 4
   },
   [5] = {
        ANIMATION_NUMBER = 5,
        ACTIVE_SKILL = 5,
        ORDER_LIST = {
            {
               ORDER = "callMethod",
               SETTING = {
                  METHOD = "CTZero"
               }
            }
        }
   }
}

class.SKILL_BOX_LIST = {
   [1] = {
        ANIMATION_NUMBER = 1,
        ACTIVE_SKILL = 6
   },
   [2] = {
      ANIMATION_NUMBER = 2,
      ACTIVE_SKILL = 7
   }
   
}

class.ATTACK_CONTROLLER = {
   --アタックリール１ 通常
    [1] = {
        [1] = {
            {
                TABLE_INDEX =1,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =2,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =3,
                WEIGHT = 100
            }

        },
        [2] = {
            {
                TABLE_INDEX =1,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =3,
                WEIGHT = 100
            }
        },
        [3] = {
            {
                TABLE_INDEX =1,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =3,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =4,
                WEIGHT = 100
            }
        }
    },

    --アタックリール2 怒り
    [2] = {
        [1] = {
            {
                TABLE_INDEX =1,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =2,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =3,
                WEIGHT = 100
            }
        },
        [2] = {
            {
                TABLE_INDEX =5,
                WEIGHT = 100
            }
        },
        [3] = {
            {
                TABLE_INDEX =1,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =3,
                WEIGHT = 100
            },
            {
                TABLE_INDEX =4,
                WEIGHT = 100
            }
        }
    }


}

class.ATTACK_SEQUENCE = {
    --
    [1] = {
        [1] = {
            NEXT_REEL = 1
        }
    },
    [2] = {
        [1] = {
            NEXT_REEL = 2
        }
    }

}


class.SKILL_CONTROLLER = {
   --スキルリール１
   [1] = {
      [1] = {
         {
            TABLE_INDEX = 1,
            WEIGHT = 100
         }
      }
   },

   --スキルリール２　
   [2] = {
      [1] = {
         {
            TABLE_INDEX = 2,
            WEIGHT = 100
         }
      }
   }
}

class.SKILL_SEQUENCE = {
    [1] = {
        [1] = {
            NEXT_REEL = 1
        } 
    },
    [2] = {
        [1] = {
            NEXT_REEL = 2
        } 
    }
}


-- addBuffする、showMessageする、色々する
class.FUNC_TABLE = {
   ver = 1,
   update = {
        -- [1] = {
        --     TAG = "hp",
        --     TIMING = 50,
        --     USED = false,
        --     ORDER_LIST = {
        --         {
        --             ORDER = "changeAttackReel",
        --             SETTING = {
        --                 INDEX = 3
        --             }
        --         },
        --         {
        --             ORDER = "changeSkillReel",
        --             SETTING = {
        --                 INDEX = 2
        --             }
        --         },
        --         {
        --             ORDER = "setAttackReelIndex",
        --             SETTING = {
        --                INDEX = 1--最初に戻す
        --             }   
        --         }
        --     }
        -- }
   },
   takeSkill = {
     
   },
   takeBreak = {
     
   } 
}

function class:getRage()
   if self.isRage then
      return;
   end
   self.attackSequenceID = 2;
   self:attackSequenceForceReset();
   self.skillSequenceID = 2;
   self:skillSequenceForceReset();
   self.isRage = true;
   self:addBuffs(self.gameUnit,self.RAGE_BUFFS);
   self:showMessageAll(self.RAGE_MESSAGES);
end

function class:endRage()
   if not self.isRage then
      return;
   end
   self.attackSequenceID = 1;
   self:attackSequenceForceReset();
   self.skillSequenceID = 1;
   self:skillSequenceForceReset();
   self.isRage = false;
   self:removeBuffs(self.gameUnit,self.RAGE_BUFFS);
   self:showMessageAll(self.END_RAGE_MESSAGES);
end

function class:CTZero()
   self.isCTDown = true;
end

function class:takeDamageValue(event)
   if self.isBattleEnd then
      return 1;
   end
   return event.value;
end

function class:takeBreake(event)
   if self.isRage and self:getIsHost() then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
      self:endRage();
   end
   return 1;
end


function class:run(event)
    if event.spineEvent == "getRage" then
        if not self:getIsHost() then
            return 1;
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        self:getRage();
    end

    if event.spineEvent == "fire" then
        event.unit:addOrbitSystemInsightRotation("fireball","empty",1,300,350,360,0);
    end
    
    return 1;
end


function class:initValues(event)
   self.isRage = false;
   self.beforeFleese = false;
   self.timeLimit = 300;
   self.isCTDown = false;

   self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "庇うキラー",
            COLOR = Color.yellow,
            DURATION = 8
        }
    }

    self.RAGE_MESSAGES = {
        {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "怒り状態：氷結またはブレイクで解除",
            COLOR = Color.red,
            DURATION = 8
        },
        {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "クリティカル率アップ",
            COLOR = Color.yellow,
            DURATION = 8
        },
        {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "攻撃速度アップ",
            COLOR = Color.yellow,
            DURATION = 8
        },
        {
            MESSAGE = self.TEXT.RAGE_MESSAGE4 or "ダメージ軽減",
            COLOR = Color.yellow,
            DURATION = 8
        }
    }

    self.END_RAGE_MESSAGES = {
        {
            MESSAGE = self.TEXT.END_RAGE_MESSAGE1 or "怒り状態解除",
            COLOR = Color.cyan,
            DURATION = 8
        }
    }

    self.TIMEUP_MESSAGES = {
        [1] = {
            MESSAGE = self.TEXT.TIMEUP_MESSAGE1 or "タイムアップ！",
            COLOR = Color.red,
            DURATION = 15
        },
        [2] = {
            MESSAGE = self.TEXT.TIMEUP_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.red,
            DURATION = 15
        }
    }

    self:showMessageAll(self.START_MESSAGES);
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    self.gameUnit:addSP(40);
end

function class:attackDamageValue(event)
    if self.isCTDown then

         event.enemy:resetSkillCoolTime();

    end
    if self.isBattleEnd then
        return 9999999;
    end
    return event.value;
end

function class:takeIdle(event)
   if not self.isRage  then
      event.unit:setNextAnimationName("zcloneNidle");
   end
   return 1;
end

-- parser0001.lua
-- local parser = summoner.import("parser" .. string.format("%04d",self.TABLE.var))

function class:start(event)
   self.fromHost = false;
   self.gameUnit = nil;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;

   self.currentAttckReel = 1;
   self.currentAttackIndex = 1;
   self.currentAttack = nil;
   self.currentSkillReel = 1;
   self.currentSkillIndex = 1;
   self.currentSkill = nil;
   self.attackSequenceID = 1;
   self.currentAttackSequenceIndex = 1;
   self.attackForceResetFlg = true;

    self.skillSequenceID = 1;
   self.currentSkillSequenceIndex = 1;
   self.skillForceResetFlg = true;


   self.hitstopReduceLevel = 2;
   self.hitStopReduceRate = 1;

   self.gameUnit = event.unit

  
   self:setList2()
   self:initValues(event)
   table.sort(self.FUNC_TABLE.update, function(a,b) return a.TIMING > b.TIMING end)
   self:createHpTable(self.FUNC_TABLE.update)
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   return 1
end

function class:startWave(event)
   self:getRage();
   return 1;
end

function class:createHpTable(triggers)
   self.HP_TRIGGERS = {}
   self.triggerCount = 1
   for index,trigger in pairs(triggers) do
      if string.upper(trigger.TAG) == "HP" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end




function class:update(event)
   self:HPTriggersCheck(event.unit)
   self:reduceHitStop(event.unit)
   self:fleezeCheck(event.unit);
   self:countDown(event.deltaTime);
   return 1
end


function class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 then
        self.gameUnit:addSP(100);
        -- self.gameUnit:setInvincibleTime(10);
        self.forceSkillIndex = 2;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self.isBattleEnd = true;
        self:showMessageAll(self.TIMEUP_MESSAGES);
        -- for i = 0,3 do
        --      local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        --      if teamUnit ~= nil then
        --         teamUnit:setHP(0)
        --      end 
        -- end
        -- megast.Battle:getInstance():endBattle(false);
    end
end

function class:fleezeCheck(unit)
   if not self:getIsHost() then
      return;
   end
   local freeze = unit:getTeamUnitCondition():findConditionWithType(96);
   if freeze ~= nil and not self.beforeFreeze then
      self.beforeFreeze = true;
      megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
      self:endRage();
   else
      self.beforeFreeze = false;
   end
end


function class:reduceHitStop(unit)
   unit:setReduceHitStop(self.hitstopReduceLevel, self.hitStopReduceRate);
end

function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,order in ipairs(self.HP_TRIGGERS) do
      if order.TIMING >= hpRate and not order.USED then
         self:execTrigger(index)
      end
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.HP_TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self:readOrderList(self.HP_TRIGGERS[index].ORDER_LIST);

   self.HP_TRIGGERS[index].USED = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end


function class:receive3(args)
   for i,v in ipairs(self.HP_TRIGGERS[args.arg].ORDER_LIST) do
      self.ORDER_TABLE[v.ORDER](v.SETTING)
   end
   return 1
end


function class:execFuncAction(funcName)
   for i,v in pairs(self.FUNC_TABLE[funcName]) do
      self.ORDER_TABLE[v.ORDER](v.SETTING)
   end
   return 1
end

function class:setList2()
  self.ORDER_TABLE = {
     showMessage = function (messageBox) self:showMessage(self.MESSAGE_BOX_LIST[messageBox.INDEX]) end,
     addBuff = function (buffBox) self:execAddBuff(self.gameUnit,buffBox) end,
     spValue = function (setting) self.spValue = setting.SP end,
     changeAttackReel = function (setting) self.currentAttckReel = setting.INDEX end,
     changeSkillReel = function (setting) self.currentSkillReel = setting.INDEX end,
     takeInvincible = function (setting) self.gameUnit:setInvincibleTime(setting.TIME) end,
     callMethod = function(setting) self[setting.METHOD](self) end,
     hitStop = function(setting) self:reduceHitStopLevelChange(setting) end,
     setSP = function(setting) self.gameUnit:setBurstPoint(setting.VALUE) end,
     setAttackReelIndex = function(setting) self.currentAttackIndex = setting.INDEX end,
     setSkillReelIndex = function(setting) self.currentSkillIndex = setting.INDEX end,
     changeAttackReelAtRandom = function (setting) self:changeAttackReelAtRandom(setting) end,
     changeSkillReelAtRandom = function (setting) self:changeSkillReelAtRandom(setting) end,
     attackSequenceChange = function (setting)
        self.attackSequenceID = setting.INDEX;
        self:attackSequenceForceReset();
     end,
     skillSequenceChange = function (setting)
        self.skillSequenceID = setting.INDEX;
        self:skillSequenceForceReset();
     end,
     checkHP = function (setting)  end,--ダミー　一応インデックスとしては必要だから書いてある　他と違ってcheck系の処理はfor文に差し込まれる　実際の処理はクラス内のcheckHPを参照
     rand = function (setting)  end--ダミー　一応インデックスとしては必要だから書いてある　他と違ってcheck系の処理はfor文に差し込まれる　実際の処理はクラス内のrandを参照
  }
end


function class:changeAttackReelAtRandom(setting)
    local weightTable = {
        [1] = {
            INDEX = setting.INDEX1,
            WEIGHT = setting.RATE1
        },
        [2] = {
            INDEX = setting.INDEX2,
            WEIGHT = setting.RATE2
        }
    }
    if setting.INDEX3 ~= nil then
        weightTable[3] = {
            INDEX = setting.INDEX3,
            WEIGHT = setting.RATE3
        }
    end

    if setting.INDEX4 ~= nil then
        weightTable[4] = {
            INDEX = setting.INDEX4,
            WEIGHT = setting.RATE4
        }
    end

    local key = self:sampleWeightedForController(weightTable);
    self.currentAttckReel = weightTable[key].INDEX;

end

function class:changeSkillReelAtRandom(setting)

    local weightTable = {
        [1] = {
            INDEX = setting.INDEX1,
            WEIGHT = setting.RATE1
        },
        [2] = {
            INDEX = setting.INDEX2,
            WEIGHT = setting.RATE2
        }
    }
    if setting.INDEX.INDEX3 ~= nil then
        weightTable[3] = {
            INDEX = setting.INDEX3,
            WEIGHT = setting.RATE3
        }
    end

    if setting.INDEX.INDEX4 ~= nil then
        weightTable[4] = {
            INDEX = setting.INDEX4,
            WEIGHT = setting.RATE4
        }
    end

    local key = self:sampleWeightedForController(weightTable);
    self.currentSkillReel = weightTable[key].INDEX;

end



--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:execShowMessage(messageBoxList)
   return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
   for i,messageBox in ipairs(messageBoxList) do
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
-- バフ関係
--===================================================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end

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

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

function class:reduceHitStopLevelChange(setting)
   self.hitstopReduceLevel = setting.LEVEL;
   self.hitStopReduceRate = setting.VALUE;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////



function class:attackBranch(unit)
   if self.attackForceResetFlg then
      self.attackForceResetFlg = false;
      self:attackSequenceForceReset();
   end
   if table.maxn(self.ATTACK_CONTROLLER[self.currentAttckReel]) < self.currentAttackIndex then
      self:attackSequenceControll();
      self.currentAttackIndex = 1;
   end
   local tableIndex = self:sampleWeightedForController(self.ATTACK_CONTROLLER[self.currentAttckReel][self.currentAttackIndex]);
   local  nowIndex = self.currentAttackIndex;
   self:excutionAttackAction(unit,self.currentAttackIndex,tableIndex);
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,nowIndex * 1000 + tableIndex);
   self.currentAttackIndex = self.currentAttackIndex + 1;
   return 0;
end

function class:excutionAttackAction(unit,atIndex,index)
   self.currentAttack = self.ATTACK_BOX_LIST[self.ATTACK_CONTROLLER[self.currentAttckReel][atIndex][index].TABLE_INDEX];

   if self.currentAttack.ORDER_LIST ~= nil then
      self:readOrderList(self.currentAttack.ORDER_LIST);
   end

   if self.currentAttack.SKILL then
      self.skillCheckFlg = true;
      self.attackCheckFlg = false;
      self.currentSkill = self.currentAttack;--強引にattack内でskillを打たせたい時　この中身はskillと同じものが入っているので対応できる
  
      unit:takeSkill(self.currentAttack.ANIMATION_NUMBER);
   else
      unit:takeAttack(self.currentAttack.ANIMATION_NUMBER);
   end
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        
         event.unit:takeIdle();
        return 0;
    end
    self.attackCheckFlg = false;
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit);
    self:addSP(event.unit);
    if event.index ~= 5 and not self.isRage then
       self.isCTDown = false;
       event.unit:setNextAnimationName("zcloneNattack"..event.index);
    end
    return 1
end

function class:attackActiveSkillSetter(unit)
    unit:setActiveSkill(self.currentAttack.ACTIVE_SKILL);
end


function class:attackSequenceControll()
   self.currentAttackSequenceIndex = self.currentAttackSequenceIndex + 1;
   if self.currentAttackSequenceIndex > table.maxn(self.ATTACK_SEQUENCE[self.attackSequenceID]) then
      self.currentAttackSequenceIndex = 1;
   end
   self.currentAttckReel = self.ATTACK_SEQUENCE[self.attackSequenceID][self.currentAttackSequenceIndex].NEXT_REEL;
   
   if self.ATTACK_SEQUENCE[self.attackSequenceID][self.currentAttackSequenceIndex].ORDER_LIST ~= nil then
      self:readOrderList(self.ATTACK_SEQUENCE[self.attackSequenceID][self.currentAttackSequenceIndex].ORDER_LIST);
   end
end

function class:attackSequenceForceReset()

   self.currentAttackSequenceIndex = 1;
   self.currentAttackIndex = 1;
   self.currentAttckReel = self.ATTACK_SEQUENCE[self.attackSequenceID][self.currentAttackSequenceIndex].NEXT_REEL;
   if self.ATTACK_SEQUENCE[self.attackSequenceID][self.currentAttackSequenceIndex].ORDER_LIST ~= nil  then
      self:readOrderList(self.ATTACK_SEQUENCE[self.attackSequenceID][self.currentAttackSequenceIndex].ORDER_LIST);
   end
end


--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--/////////



function class:skillBranch(unit)
    self.attackForceResetFlg = true;
   if table.maxn(self.SKILL_CONTROLLER[self.currentSkillReel]) < self.currentSkillIndex then
      self:skillSequenceControll();
      self.currentSkillIndex = 1;
   end
   local tableIndex = self:sampleWeightedForController(self.SKILL_CONTROLLER[self.currentSkillReel][self.currentSkillIndex]);

   local nowIndex = self.currentSkillIndex;

   self:excutionSkillAction(unit,self.currentSkillIndex,tableIndex);
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,nowIndex * 1000 + tableIndex);
   self.currentSkillIndex = self.currentSkillIndex + 1;
   return 0;
end

function class:excutionSkillAction(unit,skIndex,index)
   self.currentSkill = self.SKILL_BOX_LIST[self.SKILL_CONTROLLER[self.currentSkillReel][skIndex][index].TABLE_INDEX];

   if self.currentSkill.ORDER_LIST ~= nil then
      self:readOrderList(self.currentSkill.ORDER_LIST);
   end

   unit:takeSkill(self.currentSkill.ANIMATION_NUMBER);
end


function class:takeSkill(event)
   self.isCTDown = false;
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then

      self.skillCheckFlg = true;
      return self:skillBranch(event.unit);
   end
   
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end
   
   if self.currentSkill.CUTIN and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(self.currentSkill.ANIMATION_NUMBER,1);
        return 0;
   end
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   if not self.currentSkill.DEACTIVE then
      event.unit:setBurstState(kBurstState_active);
   end
   self:skillActiveSkillSetter(self.gameUnit);
   if not self.isRage  then
      event.unit:setNextAnimationName("zcloneNskill"..event.index);
   end
   return 1
end

function class:skillActiveSkillSetter(unit)

    unit:setActiveSkill(self.currentSkill.ACTIVE_SKILL);

end

function class:skillSequenceControll()
   self.currentSkillSequenceIndex = self.currentSkillSequenceIndex + 1;
   if self.currentSkillSequenceIndex > table.maxn(self.SKILL_SEQUENCE[self.skillSequenceID]) then
      self.currentSkillSequenceIndex = 1;
   end
   self.currentSkillReel = self.SKILL_SEQUENCE[self.skillSequenceID][self.currentSkillSequenceIndex].NEXT_REEL;
   
   if self.SKILL_SEQUENCE[self.skillSequenceID][self.currentSkillSequenceIndex].ORDER_LIST ~= nil then
      self:readOrderList(self.SKILL_SEQUENCE[self.skillSequenceID][self.currentSkillSequenceIndex].ORDER_LIST);
   end
end

function class:skillSequenceForceReset()

   self.currentSkillSequenceIndex = 1;
   self.currentSkillIndex = 1;
   self.currentSkillReel = self.SKILL_SEQUENCE[self.skillSequenceID][self.currentSkillSequenceIndex].NEXT_REEL;
   if self.SKILL_SEQUENCE[self.skillSequenceID][self.currentSkillSequenceIndex].ORDER_LIST ~= nil  then
      self:readOrderList(self.SKILL_SEQUENCE[self.skillSequenceID][self.currentSkillSequenceIndex].ORDER_LIST);
   end
end


function class:addSP(unit)
    self.gameUnit:addSP(self.spValue);
    
    return 1;
end



function class:readOrderList(oderList)
    for i,v in ipairs(oderList) do
         if not self:judge(v) then--check系命令で弾かれた場合、その命令以降のオーダーは実行されなくなる
            -- summoner.Utility.messageByEnemy("じゃっじ");
            --ただし弾かれてもFAILEDがあれば実行　else に相当
            if v.SETTING["FAILED"] ~= nil then
                self:readOrderList(v.SETTING["FAILED"]);
            end
            break;
         end
         self.ORDER_TABLE[v.ORDER](v.SETTING)
      end
end

function class:judge(order)
    if order.ORDER == "checkHP" then
        local hpRate = summoner.Utility.getUnitHealthRate(self.gameUnit) * 100;
        if hpRate > order.SETTING.HP then
            return false;
        end
    end

    if order.ORDER == "rand" then
        local rand = Random.range(0, 100) + 1;
        if rand > order.SETTING.BORDER then
            return false;
        end
    end
    return true;
end


--===================================================================================================================

--===================================================================================================================
--マルチ同期//
--//////////
function class:receive1(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:takeSkillFromHost(self.gameUnit,args.arg);
    return 1;
end


function class:receive3(args)
    self:getRage();
    return 1;
end

function class:receive4(args)
    self:endRage();
    return 1;
end

function class:takeAttackFromHost(unit,index)

  
    self.fromHost = true;
    local tableIndex = index % 1000;
    local attackIndex = math.floor(index/1000);
    self:excutionAttackAction(unit,attackIndex,tableIndex);
end

function class:takeSkillFromHost(unit,index)

    self.fromHost = true;
    local tableIndex = index % 1000;
    local skillIndex = math.floor(index/1000);
    self:excutionSkillAction(unit,skillIndex,tableIndex);
end

--===================================================================================================================

function class:sampleWeightedForController(weightedList)
    local totalWeight = 0
    local keyValuePairs = {}
    for key, targetTable in pairs(weightedList) do
        totalWeight = totalWeight + targetTable.WEIGHT;
    end
    if totalWeight < 1 then
        return nil
    end
    local randomNumber =  Random.range(0, totalWeight) + 1
    local currentWeight = 0
    for key, targetTable in pairs(weightedList) do
        currentWeight = currentWeight + targetTable.WEIGHT;
        if currentWeight >= randomNumber then
            return key;
        end
    end
end


function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

class:publish();

return class;