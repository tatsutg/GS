local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ガナン", version=1.3, id=100020904});

class.ATTACK_CONTROLLER = {
   --アタックリール１ デフォルト状態
   [1] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 1,
            WEIGHT = 100,
            ACTIVE_SKILL = 1
         },
         [2] = {
            ANIMATION_NUMBER = 1,
            WEIGHT = 100,
            ACTIVE_SKILL = 2,
            SKILL = true,
            DEACTIVE = true
         }
      }
   },
   [2] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 1,
            WEIGHT = 100,
            ACTIVE_SKILL = 1,
            ACTION = {
               {
                  order = "spValue",
                  setting = {
                     SP = 100
                  }
               }
            }
         }
      }
   },
   [3] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 4,
            SKILL = true,
            ACTION = {
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "いくぜ？" or class.TEXT.ATTACK311,
                     DURATION = 10,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               }
            }
         }
      },
      [2] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 5,
            SKILL = true,
            CUTIN = true,
            ACTION = {
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "耐えてみな" or class.TEXT.ATTACK321,
                     DURATION = 5,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               },
               {
                  order = "takeInvincible",
                  setting = {
                     TIME = 5
                  }
               }
            }
         }
      },
      [3] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 7,
            ACTION = {
               {
                  order = "setSP",
                  setting = {
                     VALUE = 0
                  }
               },
               {
                  order = "callMethod",
                  setting = {
                     METHOD = "attack2Start"
                  }
               },
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "止めねぇと後悔するぜ？" or class.TEXT.ATTACK331,
                     DURATION = 5,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               }
            }
         }
      }
   },
   [4] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 1,
            WEIGHT = 100,
            ACTIVE_SKILL = 1,
            ACTION = {
               {
                  order = "spValue",
                  setting = {
                     SP = 100
                  }
               }
            }
         }
      }
   },
   [5] = {--後から追加したので先に来るパターンだけど５
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 7,
            ACTION = {
               {
                  order = "setSP",
                  setting = {
                     VALUE = 0
                  }
               },
               {
                  order = "callMethod",
                  setting = {
                     METHOD = "attack2Start"
                  }
               },
               {
                  order = "callMethod",
                  setting = {
                     METHOD = "firstAttack2"
                  }
               },
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "止めねぇと後悔するぜ？" or class.TEXT.ATTACK331,
                     DURATION = 5,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               }
            }
         }
      }
   }

}


class.SKILL_CONTROLLER = {
   --スキルリール１
   [1] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 3
         }
      }
   },
   [2] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 5,
            CUTIN = true,
            ACTION = {
               {
                  order = "changeSkillReel",
                  setting = {
                     INDEX = 3
                  }
               },
               {
                  order = "setAttackReelIndex",
                  setting = {
                     INDEX = 1
                  }
               },
               {
                  order = "setSkillReelIndex",
                  setting = {
                     INDEX = 0--これから自分がスキルを打って＋１される分をあらかじめ差し引き
                  }
               },
               {
                  order = "takeInvincible",
                  setting = {
                     TIME = 5
                  }
               },
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "耐えてみな" or class.TEXT.ATTACK321,
                     DURATION = 5,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               }
            }
         }
      }
   },
   [3] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 3
         }
      },
      [2] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 4,
            ACTION = {
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "いくぜ？" or class.TEXT.SKILL321,
                     DURATION = 5,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               }
            }
         }
      },
      [3] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 3
         }
      },
      [4] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 5,
            CUTIN = true,
            ACTION = {
               {
                  order = "showMessage",
                  setting = {
                     MESSAGE = "耐えてみな" or class.TEXT.SKILL341,
                     DURATION = 5,
                     COLOR = Color.red,
                     isPlayer = false
                  }
               },
               {
                  order = "takeInvincible",
                  setting = {
                     TIME = 5
                  }
               }
            }
         }
      }
   },
   [4] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 6,
            CUTIN = true,
            ACTION = {
               {
                  order = "callMethod",
                  setting = {
                     METHOD = "specialSkill"
                  }
               },
               {
                  order = "takeInvincible",
                  setting = {
                     TIME = 10
                  }
               }

            }
         }
      }
   },
   [5] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 3,
            ACTION = {
               {
                  order = "takeInvincible",
                  setting = {
                     TIME = 20
                  }
               }
            }
         }
      },
      [2] = {
         [1] = {
            ANIMATION_NUMBER = 2,
            WEIGHT = 100,
            ACTIVE_SKILL = 3
         }
      },
      [3] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 8,
            CUTIN = true
         }
      },
      [4] = {--自害用
         [1] = {
            ANIMATION_NUMBER = 1,
            WEIGHT = 100,
            ACTIVE_SKILL = 2,
            ACTION = {
               {
                  order = "callMethod",
                  setting = {
                     METHOD = "onEnd"
                  }
               }
            }
         }
      }
   },
   [6] = {
      [1] = {
         [1] = {
            ANIMATION_NUMBER = 3,
            WEIGHT = 100,
            ACTIVE_SKILL = 6,
            CUTIN = true,
            ACTION = {
               {
                  order = "callMethod",
                  setting = {
                     METHOD = "specialSkill"
                  }
               },
               {
                  order = "takeInvincible",
                  setting = {
                     TIME = 10
                  }
               },
               {
                  order = "changeSkillReel",
                  setting = {
                     INDEX = 1
                  }
               },
               {
                  order = "changeAttackReel",
                  setting = {
                     INDEX = 1
                  }
               },
               {
                  order = "setAttackReelIndex",
                  setting = {
                     INDEX = 1
                  }
               },
               {
                  order = "setSkillReelIndex",
                  setting = {
                     INDEX = 1
                  }
               }

            }
         }
      }
   }
}


-- addBuffする、showMessageする、色々する
class.FUNC_TABLE = {
   ver = 1,
   update = {
      {
         tag = "hp",
         timing = 100,
         used = false,
         orderList = {
            {
               order = "hitStop",
               setting = {
                  LEVEL = 2,
                  VALUE = 0.5
               }
            },{
               order = "showMessage",
               setting = {
                  MESSAGE = "命中率・攻撃力アップ" or class.TEXT.UPDATE91,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },{
               order = "showMessage",
               setting = {
                  MESSAGE = "クリティカル耐性アップ" or class.TEXT.UPDATE92,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            }
         }
      },
      {
         tag = "hp",
         timing = 90,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "行動速度アップ" or class.TEXT.UPDATE11,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },{
               order = "hitStop",
               setting = {
                  LEVEL = 1000,
                  VALUE = 1
               }
            },
            {
               order = "changeSkillReel",
               setting = {
                  INDEX = 6
               }
            },
            {
               order = "changeAttackReel",
               setting = {
                  INDEX = 5
               }
            },
            {
               order = "setAttackReelIndex",
               setting = {
                  INDEX = 1
               }
            },
            {
               order = "setSkillReelIndex",
               setting = {
                  INDEX = 1
               }
            }
         }
      },
      {
         tag = "hp",
         timing = 80,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "奥義ゲージ速度アップ" or class.TEXT.UPDATE81,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },{
               order = "spValue",
               setting = {
                  SP = 30
               }
            }
         }
      },
      {
         tag = "hp",
         timing = 70,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "与ダメージアップ" or class.TEXT.UPDATE21,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },{
               order = "addBuff",
               setting = {
                  ID = 1011161111,
                  BUFF_ID = 17,
                  VALUE = 50,
                  DURATION = 999999,
                  ICON = 26
               }
            }
         }
      },
      {
         tag = "hp",
         timing = 60,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "ガハハハ！エンジン掛かってきたぜぇ！" or class.TEXT.UPDATE31,
                  DURATION = 10,
                  COLOR = Color.red,
                  isPlayer = false
               }
            },
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "被ダメージ軽減" or class.TEXT.UPDATE312,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "クリティカル率アップ" or class.TEXT.UPDATE313,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },
            {
               order = "addBuff",
               setting = {
                  ID = 1011161112,
                  BUFF_ID = 21,
                  VALUE = -50,
                  DURATION = 999999,
                  ICON = 21
               }
            },{
               order = "addBuff",
               setting = {
                  ID = 1011161113,
                  BUFF_ID = 22,
                  VALUE = 100,
                  DURATION = 999999,
                  ICON = 11
               }
            },{
               order = "takeInvincible",
               setting = {
                  TIME = 5
               }
            },{
               order = "setSP",
               setting = {
                  VALUE = 100
               }
            },
            {
               order = "changeSkillReel",
               setting = {
                  INDEX = 2
               }
            },
            {
               order = "changeAttackReel",
               setting = {
                  INDEX = 2
               }
            },
            {
               order = "setAttackReelIndex",
               setting = {
                  INDEX = 1
               }
            },
            {
               order = "setSkillReelIndex",
               setting = {
                  INDEX = 1
               }
            }

         }
      },
      {
         tag = "hp",
         timing = 50,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "クリティカルダメージアップ" or class.TEXT.UPDATE41,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },{
               order = "addBuff",
               setting = {
                  ID = 1011161114,
                  BUFF_ID = 17,
                  VALUE = 50,
                  DURATION = 999999,
                  ICON = 26,
                  SCRIPT_ID = 22
               }
            }

         }
      },
      {
         tag = "hp",
         timing = 40,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "言い残すことはあるか？" or class.TEXT.UPDATE41,
                  DURATION = 5,
                  COLOR = Color.red,
                  isPlayer = false
               }
            },{
               order = "addBuff",
               setting = {
                  ID = 1011161115,
                  BUFF_ID = 17,
                  VALUE = 50,
                  DURATION = 999999,
                  ICON = 26,
                  SCRIPT_ID = 22
               }
            },{
               order = "spValue",
               setting = {
                  SP = 0
               }
            },
            {
               order = "setSP",
               setting = {
                  VALUE = 0
               }
            },
            {
               order = "changeSkillReel",
               setting = {
                  INDEX = 4
               }
            },
            {
               order = "changeAttackReel",
               setting = {
                  INDEX = 3
               }
            },
            {
               order = "setAttackReelIndex",
               setting = {
                  INDEX = 3
               }
            },
            {
               order = "setSkillReelIndex",
               setting = {
                  INDEX = 1
               }
            }

         }
      },
      {
         tag = "hp",
         timing = 30,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "クリティカルダメージアップ" or class.TEXT.UPDATE61,
                  DURATION = 10,
                  COLOR = Color.yellow,
                  isPlayer = false
               }
            },{
               order = "addBuff",
               setting = {
                  ID = 1011161116,
                  BUFF_ID = 17,
                  VALUE = 50,
                  DURATION = 999999,
                  ICON = 26,
                  SCRIPT_ID = 22
               }
            }

         }
      },
      {
         tag = "hp",
         timing = 1,
         used = false,
         orderList = {
            {
               order = "showMessage",
               setting = {
                  MESSAGE = "置き土産だ、受け取りな" or class.TEXT.UPDATE71,
                  DURATION = 10,
                  COLOR = Color.red,
                  isPlayer = false
               }
            },
            {
               order = "changeSkillReel",
               setting = {
                  INDEX = 5
               }
            },
            {
               order = "changeAttackReel",
               setting = {
                  INDEX = 4
               }
            },
            {
               order = "setAttackReelIndex",
               setting = {
                  INDEX = 1
               }
            },
            {
               order = "setSkillReelIndex",
               setting = {
                  INDEX = 1
               }
            },
            {
               order = "callMethod",
               setting = {
                  METHOD = "takeFinalFlg"
               }
            },
            {
               order = "takeInvincible",
               setting = {
                  TIME = 20
               }
            }

         }
      }


   },
   takeSkill = {
      
   },
   takeBreak = {
     
   }
}

function class:firstAttack2()
   self.isFirst = true;
end

function class:attack2Start()
   self.gameUnit:setBurstPoint(0)
   self.isTame = true
   self.dps = 0
   self.subBar:setVisible(true)
   self.isVisible = true
   self.spCount = 5
end


function class:specialSkill()
   self.isFirst = false;
   self.subBar:setVisible(false);
   self.isVisible = false;
   self.isTame = false;
end


function class:takeFinalFlg()
   self.finalFlg = true;
end

function class:onEnd()
   self.gameUnit:setHP(0);
end

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 17, -- ダメージ
         VALUE = 50,
         DURATION = 999999,
         ICON = 26
      },
      [2] = {
         ID = 20157502,
         BUFF_ID = 21, -- 被ダメ軽減
         VALUE = 90,
         DURATION = 999999,
         ICON = 5
      }, 
      [3] = {
         ID = 20157503,
         BUFF_ID = 17, -- クリティカル
         VALUE = 100,
         DURATION = 999999,
         ICON = 11
      },
      [4] = {
         ID = 20157504,
         BUFF_ID = 17, -- クリティカルダメージ
         VALUE = 50,
         DURATION = 999999,
         ICON = 26,
         SCRIPT = {
            SCRIPT_ID = 22
         }
      },
      [5] = {
         ID = 20157504,
         BUFF_ID = 17, -- クリティカルダメージ
         VALUE = 50,
         DURATION = 999999,
         ICON = 26,
         SCRIPT = {
            SCRIPT_ID = 22
         }
      },
      [9] = {
         ID = 20111705,
         BUFF_ID = 0, -- アイコンのみ
         VALUE = 0,
         DURATION = 999999,
         ICON = 199
      },
      [10] = {
         ID = 20111706,
         BUFF_ID = 17, -- ダメージ
         VALUE = 30,
         DURATION = 999999,
         ICON = 26
      }
   }
end

function class:initValues(event)
   self.finalFlg = false;
   self.BAR_HP = 380000
   self:subBars()
   self.spCount = 5
   self:setBuffBoxList()
   self.isTame = false
   self.isVisible = false;
   self.AURA_INTERVAL = 999999;
   self.BASE_BUFF_VALUE = 30
   self.isFirst = true;
end

function class:subBars()
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(150); --バーの全体の長さを指定
    self.subBar:setHeight(10);--バーの幅を指定
    self.subBar:setPercent(0); --バーの残量を0%に指定
    self.subBar:setVisible(false);
end

function class:auraPosition(unit)
   if self.aura == nil then
      return
   end

   local vec = unit:getisPlayer() and 1 or -1
   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
   local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
   self.aura:setPosition(targetx,targety);
   self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
   self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
   if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      if self.AURA_INTERVAL < self.timer then
         self.isAura = false
         self.timer = 0
         self:removeCondition(unit,self.BUFF_BOX_LIST[9])
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
end

function class:weaponCheck(unit)
    local weaponDamage =  self.dps;
    self:subBarPosition(unit,weaponDamage);
    if weaponDamage >= self.BAR_HP and megast.Battle:getInstance():isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit,self.spCount);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,self.spCount);
        self.spCount = 5
    end
end

function class:receive6(args)
   self:weaponBreak(self.gameUnit,args.arg)
   self.spCount = 5
   return 1
end


function class:weaponBreak(unit,spCount)
   if self.isFirst then
      self.isFirst = false;
      self.currentAttckReel = 1;
      self.currentSkillReel = 1;
   end
    self.subBar:setVisible(false);
    self.isVisible = false
    self.dps = 0
    local sp = unit:getBurstPoint();
    local maxSP = unit:getNeedSP();
    local cnt = 5 - math.floor(sp/(maxSP/5));
    if cnt> 0 then
      -- summoner.Utility.messageByEnemy("Need" .. cnt,6,Color.cyan);
      -- summoner.Utility.messageByEnemy("Value" .. self.BUFF_BOX_LIST[10].VALUE,6,Color.cyan);

       self.BUFF_BOX_LIST[10].VALUE = self.BASE_BUFF_VALUE * cnt
       self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[10])
    end
    self.gameUnit:setBurstPoint(0)
    unit:takeAnimation(0,"damage2",false)
end

function class:subBarPosition(unit,damage)
   local vec = unit:getisPlayer() and 1 or -1
   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
   local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.subBar:setPosition(targetx,targety + 125);
    -- self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.BAR_HP - damage)/self.BAR_HP);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "start" then
      self:setAura(event.unit)
      self.isAura = true
      self.timer = 0
      self:execAddBuff(event.unit,self.BUFF_BOX_LIST[9])
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"loop",true);
   end
   if event.spineEvent == "startTagOfWar" then

   end
   if event.spineEvent == "addSP" then
      event.unit:addSP(20)
      self.spCount = self.spCount - 1
   end
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("gannanAura","in");
   self.aura:takeAnimation(0,"in",true);
   self:auraPosition(unit)
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.isTame then
      self.dps = self.dps + event.value
   end
   if not self.finalFlg then
      if event.unit:getHP() - event.value <= 0 then
         self.finalFlg = true;
         event.unit:setInvincibleTime(20)
         return event.unit:getHP() - 1;
      end
   end
   return event.value
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

   self.hitstopReduceLevel = 0;
   self.hitStopReduceRate = 0;

   self.gameUnit = event.unit
   self.hpMarkers = {
      {
         HP = 90,isUsed = false,MARKER = event.unit:addNumHpMarker(0.9)
      },
      {
         HP = 80,isUsed = false,MARKER = event.unit:addNumHpMarker(0.8)
      },
      {
         HP = 70,isUsed = false,MARKER = event.unit:addNumHpMarker(0.7)
      },
      {
         HP = 60,isUsed = false,MARKER = event.unit:addNumHpMarker(0.6)
      },
      {
         HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
      },
      {
         HP = 40,isUsed = false,MARKER = event.unit:addNumHpMarker(0.4)
      },
      {
         HP = 30,isUsed = false,MARKER = event.unit:addNumHpMarker(0.3)
      },
      {
         HP = 1,isUsed = false,MARKER = event.unit:addNumHpMarker(0.01)
      }
   }



   self:setList2()
   self:initValues(event)
   table.sort(self.FUNC_TABLE.update, function(a,b) return a.timing > b.timing end)
   self:createHpTable(self.FUNC_TABLE.update)
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   return 1
end

function class:createHpTable(triggers)
   self.HP_TRIGGERS = {}
   self.triggerCount = 1
   for index,trigger in pairs(triggers) do
      if string.upper(trigger.tag) == "HP" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end




function class:update(event)
   self:HPTriggersCheck(event.unit)
   self:reduceHitStop(event.unit)


   self:auraTimer(event.deltaTime,event.unit)
   self:auraPosition(event.unit)
   if self.isVisible then
      self:weaponCheck(event.unit)
   end
   for _,marker in pairs(self.hpMarkers) do
      local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
      if not marker.isUsed and hpPercent < marker.HP then
         marker.isUsed = true
         event.unit:removeHpMarker(marker.MARKER)
      end
   end
   return 1
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
      if order.timing >= hpRate and not order.used then
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

   for i,v in ipairs(self.HP_TRIGGERS[index].orderList) do
      self.ORDER_TABLE[v.order](v.setting)
   end

   self.HP_TRIGGERS[index].used = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end


function class:receive3(args)
   for i,v in ipairs(self.HP_TRIGGERS[args.arg].orderList) do
      self.ORDER_TABLE[v.order](v.setting)
   end
   return 1
end

function class:takeBreake(event)
   if self.isFirst then
      self.isFirst = false;
      self.currentAttckReel = 1;
      self.currentSkillReel = 1;
   end
   self.subBar:setVisible(false);
   self.isVisible = false;
   self.isTame = false;
   return 1
end

function class:takeDamage(event)
   self.subBar:setVisible(false);
   self.isVisible = false;
   self.isTame = false;
   return 1
end

function class:execFuncAction(funcName)
   for i,v in pairs(self.FUNC_TABLE[funcName]) do
      self.ORDER_TABLE[v.order](v.setting)
   end
   return 1
end

function class:setList2()
  self.ORDER_TABLE = {
     showMessage = function (messageBox) self:showMessage(messageBox) end,
     addBuff = function (buffBox) self:execAddBuff(self.gameUnit,buffBox) end,
     spValue = function (setting) self.spValue = setting.SP end,
     changeAttackReel = function (setting) self.currentAttckReel = setting.INDEX end,
     changeSkillReel = function (setting) self.currentSkillReel = setting.INDEX end,
     takeInvincible = function (setting) self.gameUnit:setInvincibleTime(setting.TIME) end,
     callMethod = function(setting) self[setting.METHOD](self) end,
     hitStop = function(setting) self:reduceHitStopLevelChange(setting) end,
     setSP = function(setting) self.gameUnit:setBurstPoint(setting.VALUE) end,
     setAttackReelIndex = function(setting) self.currentAttackIndex = setting.INDEX end,
     setSkillReelIndex = function(setting) self.currentSkillIndex = setting.INDEX end
  }
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


function class:reduceHitStopLevelChange(setting)
   self.hitstopReduceLevel = setting.LEVEL;
   self.hitStopReduceRate = setting.VALUE;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////



function class:attackBranch(unit)
   if table.maxn(self.ATTACK_CONTROLLER[self.currentAttckReel]) < self.currentAttackIndex then
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
   self.currentAttack = self.ATTACK_CONTROLLER[self.currentAttckReel][atIndex][index];

   if self.currentAttack.ACTION ~= nil then
      for i,v in ipairs(self.currentAttack.ACTION) do
         self.ORDER_TABLE[v.order](v.setting)
      end
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
    return 1
end

function class:attackActiveSkillSetter(unit)
    unit:setActiveSkill(self.currentAttack.ACTIVE_SKILL);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--/////////



function class:skillBranch(unit)

   if table.maxn(self.SKILL_CONTROLLER[self.currentSkillReel]) < self.currentSkillIndex then
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
   self.currentSkill = self.SKILL_CONTROLLER[self.currentSkillReel][skIndex][index];

   if self.currentSkill.ACTION ~= nil then
      for i,v in ipairs(self.currentSkill.ACTION) do
         self.ORDER_TABLE[v.order](v.setting)
      end
   end

   unit:takeSkill(self.currentSkill.ANIMATION_NUMBER);
end


function class:takeSkill(event)
  
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
   return 1
end

function class:skillActiveSkillSetter(unit)

    unit:setActiveSkill(self.currentSkill.ACTIVE_SKILL);

end


function class:addSP(unit)
    self.gameUnit:addSP(self.spValue);
    
    return 1;
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

class:publish();

return class;