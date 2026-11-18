local Bootstrap, Color, Random, Utility,Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = summoner.Bootstrap.createEnemyClass({label="名前", version=1.3, id="mine_5010"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50
}

class.ATTACK_WEIGHTS_ATTACK = {
   ATTACK4 = 50,
   ATTACK5 = 50,
   ATTACK6 = 50
}
class.ATTACK_WEIGHTS_BARRIER = { 
   ATTACK1 = 50,
   ATTACK2 = 50,
   ATTACK3 = 50
}
class.ATTACK_WEIGHTS_BREAK = {
   ATTACK3 = 100
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 1000,
    SKILL3 = 100
}
class.SKILL_WEIGHTS_ATTACK = {
   SKILL4 = 50,
   SKILL5 = 50
}
class.SKILL_WEIGHTS_BARRIER = {
   SKILL2 = 50,
   SKILL3 = 50
}
class.SKILL_WEIGHTS_BREAK = {
   SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9,
    SKILL4 = 10,
    SKILL5 = 11,
    SKILL6 = 12,
    SKILL7 = 20
}

class.CONST = {
   ATTACK = 1,
   BARRIER = 2,
   BORDER = 150000,
   BREAK_SMALL = 1,
   BREAK_MIDDLE = 2,
   BREAK_LARGE = 3,
   CUT_NORMAL = 0.5,
   CUT_STRONG = 0.2,
   M_ELEMENT = 1,
   M_ELEMENT_BUFF = 2,
   M_ELEMENT_KILLER = 3,
   TURN = 10,
   SPAN_ELEMENT = 20,
   SPEND_VALUE = {
      ATTACK4 = 40000,
      ATTACK5 = 55000,
      ATTACK6 = 80000,
      SKILL4 = 400000,
      SKILL5 = 1000000
   }
}

class.STATE = {
   battleMode = 2,
   breakMode = 1,
   element = 0
}

class.BREAK = {
   [1] = {
      animationName = "break_small",
      factor = 2,
      func = function(this,unit) this.breakSmall(this,unit) end
   },
   [2] = {
      animationName = "break",
      factor = 2,
      func = function(this,unit) this.breakNormal(this,unit) end
   },
   [3] = {
      animationName = "break_large",
      factor = 99,
      func = function(this,unit) this.breakLarge(this,unit) end
   }
}

class.ELEMENT = {
   [0] = {
      animationName = "none",
      activeSkill_2 = 8,
      activeSkill_3 = 9,
      value = 0,
      strong = 99,
      weak = 99,
      messageBox = {}
   },
   [kElementType_Fire] = {
      animationName = "red",
      activeSkill_4 = 10,
      activeSkill_5 = 15,
      value = 0,
      strong = kElementType_Earth,
      weak = kElementType_Aqua,
      isShowedMessage = false
   },
   [kElementType_Aqua] = {
      animationName = "blue",
      activeSkill_4 = 11,
      activeSkill_5 = 16,
      value = 0,
      strong = kElementType_Fire,
      weak = kElementType_Earth,
      isShowedMessage = false
   },
   [kElementType_Earth] = {
      animationName = "green",
      activeSkill_4 = 12,
      activeSkill_5 = 17,
      value = 0,
      strong = kElementType_Aqua,
      weak = kElementType_Fire,
      isShowedMessage = false
   },
   [kElementType_Light] = {
      animationName = "light",
      activeSkill_4 = 13,
      activeSkill_5 = 18,
      value = 0,
      strong = 99,
      weak = kElementType_Dark,
      isShowedMessage = false     
   },
   [kElementType_Dark] = {
      animationName = "dark",
      activeSkill_4 = 14,
      activeSkill_5 = 19,
      value = 0,
      strong = 99,
      weak = kElementType_Light,
      isShowedMessage = false
   }
}
function class.breakSmall(this,unit)
   unit:setSkin("Break_small")
   -- this.setBreak(this)
   this.breakCount = 0
   this.STATE.breakMode = this.CONST.BREAK_MIDDLE
   this.breakCapacity = this.gameUnit:getBaseBreakCapacity() * this.BREAK[this.STATE.breakMode].factor
end
function class.breakNormal(this,unit)
   unit:takeAnimation(0,"break",false)
   unit:takeAnimationEffect(0,"break",false)
   this.setBreak(this)
   this.STATE.breakMode = this.CONST.BREAK_LARGE
   this.SKILL_WEIGHTS = this.SKILL_WEIGHTS_BREAK
   this.ATTACK_WEIGHTS = this.ATTACK_WEIGHTS_BREAK
   this.subBar:setVisible(false)
end
function class.breakLarge(this,unit)
   unit:setSkin("Break_large")
   this.setBreak(this)
end

function class.setBreak(this)
   this.breakCount = 0
   this.modeChangeCount = 0
   this.STATE.element = 0
   this:execRemoveCondition(this.gameUnit,50072)
   this:execRemoveCondition(this.gameUnit,50073)
   megast.Battle:getInstance():setBossCounterElement(this.STATE.element)
   for i,v in ipairs(this.ELEMENT) do
      v.value = 0
   end
end

-- 1:攻撃 2:防御
class.BATTLEMODE = {
   [1] = {
      animationName = "barrier_off",
      excuteAction = function(this) return this.a_funcExcuteAction(this) end,
      takeIdle = function(this) return this.a_funcTakeIdle(this) end,
      takeBack = function(this) return this.a_funcTakeBack(this) end,
      takeDamage = function(this) return this.a_funcTakeDamage(this) end
   },
   [2] = {
      animationName = "barrier_in",
      excuteAction = function(this) return this.b_funcExcuteAction(this) end,
      takeIdle = function(this) return this.b_funcTakeIdle(this) end,
      takeBack = function(this) return this.b_funcTakeBack(this) end,
      takeDamage = function(this) return this.b_funcTakeDamage(this) end
   }
}

function class.a_funcTakeDamage(this)
   if this.STATE.element ~= 0 then
      this.gameUnit:setNextAnimationName("zclone"..this.ELEMENT[this.STATE.element].animationName.."damage_S");
   else 
      this.gameUnit:setNextAnimationName("damage_S")
   end
   return 1
end

function class.b_funcTakeDamage(this)
   if this.STATE.element ~= 0 then
      this.gameUnit:setNextAnimationName("zclone"..this.ELEMENT[this.STATE.element].animationName.."damage_B");
   else 
      this.gameUnit:setNextAnimationName("damage_B")
   end
   return 1
end

function class.a_funcTakeBack(this)
   if this.STATE.element ~= 0 then
      this.gameUnit:setNextAnimationName("zclone"..this.ELEMENT[this.STATE.element].animationName.."back2");
   else 
      this.gameUnit:setNextAnimationName("back2")
   end
   return 1
end

function class.b_funcTakeBack(this)
   if this.STATE.element ~= 0 then
      this.gameUnit:setNextAnimationName("zclone"..this.ELEMENT[this.STATE.element].animationName.."back1");
   else 
      this.gameUnit:setNextAnimationName("back1")
   end
   return 1
end

function class.a_funcTakeIdle(this)
   this.gameUnit:takeAnimation(0,"idle2",true)

   if this.STATE.element ~= 0 then
      this.gameUnit:takeAnimation(0,"zclone"..this.ELEMENT[this.STATE.element].animationName.."idle2",true);
      return 0
   end
   return 1
end

function class.b_funcTakeIdle(this)
   if this.STATE.breakMode == this.CONST.BREAK_LARGE then
      this.gameUnit:setNextAnimationEffectName("Empty")
      return 1
   end
   this.gameUnit:takeAnimationEffect(0,"idle1",true)

   if this.STATE.element ~= 0 then
      this.gameUnit:takeAnimation(0,"zclone"..this.ELEMENT[this.STATE.element].animationName.."idle",true);
      if this.STATE.breakMode ~= this.CONST.BREAK_LARGE then
         this.gameUnit:takeAnimationEffect(0,"zclone"..this.ELEMENT[this.STATE.element].animationName.."idle1",true);
      end
      return 0
   end
   return 1
end

function class.a_funcExcuteAction(this)
   this.gameUnit:setAttackDelay(0)
   if this.ELEMENT[this.STATE.element].value <= 0 then
      this.modeChangeCount = 0;
      this.STATE.element = 0
      this.STATE.battleMode = this.CONST.BARRIER
      this.ATTACK_WEIGHTS = this.ATTACK_WEIGHTS_BARRIER
      this.SKILL_WEIGHTS = this.SKILL_WEIGHTS_BARRIER
      this:execRemoveCondition(this.gameUnit,50072)
      this:execRemoveCondition(this.gameUnit,50073)
      megast.Battle:getInstance():setBossCounterElement(this.STATE.element)
      this.gameUnit:takeAnimation(0,"barrier_in",false);
      this.gameUnit:showPopText(summoner.Text:fetchByUnitID(500161013).text2);
      this.gameUnit:setAttackDelay(this.attackDelay);
      for i,v in ipairs(this.ELEMENT) do v.value = 0 end
      if this.STATE.breakMode ~= this.CONST.BREAK_LARGE then
         this.gameUnit:takeAnimationEffect(0,"zclone".. this.ELEMENT[this.STATE.element].animationName .."barrier_in",false);
         this.gameUnit:setSetupAnimationNameEffect("setUpBarrier");
      end
      this.gameUnit:setSetupAnimationName("setUp1");
      return 0;
   end
   this.gameUnit:setSetupAnimationName("setUp2");
   return 1
end

function class.b_funcExcuteAction(this)
   this.gameUnit:setSetupAnimationName("setUp1")
   this.modeChangeCount = this.modeChangeCount + 1
   if this.modeChangeCount > this.CONST.TURN and this.STATE.element ~= 0 then
      this.modeChangeCount = 0
      this.STATE.battleMode = this.CONST.ATTACK
      this.ATTACK_WEIGHTS = this.ATTACK_WEIGHTS_ATTACK
      this.SKILL_WEIGHTS = this.SKILL_WEIGHTS_ATTACK
      this.subBar:setVisible(false)
      this.gameUnit:takeAnimation(0,"zclone" .. this.ELEMENT[this.STATE.element].animationName .. "barrier_off",false)
      this.gameUnit:setSetupAnimationNameEffect("")
      this.gameUnit:showPopText(summoner.Text:fetchByUnitID(500161013).text1)
      if this.STATE.breakMode ~= this.CONST.BREAK_LARGE then
         this.gameUnit:takeAnimationEffect(0,"zclone".. this.ELEMENT[this.STATE.element].animationName .."barrier_off",false)      
      end
      return 0
   end
   return 1
end

--------[[バフ]]--------
function class:setBuffBoxList(floor)
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 15, -- 防御力
         VALUE = 100,
         DURATION = 999999,
         ICON = 5
      }
   }
   self.BUFF_BOX_LIST_BOMB = {
      [1] = {
         ID = 20157502,
         BUFF_ID = 21, -- 被ダメージ
         VALUE = 100,
         DURATION = 999999,
         ICON = 139
      }      
   }
   --タイムアップ
   self.TIMEUP_BUFF_BOX_LIST = {
     [1] = {
         ID = 5000033,
         BUFF_ID = 17,      --ダメージ
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 26
     },
     [2] = {
         ID = 5000036,
         BUFF_ID = 13,      --攻撃力
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 3
     }
   }

   self.BUFF_BOX_LIST_REGIST = {}
   self.BUFF_BOX_LIST_KILLER = {}
   self.REGISTS = {{ID=61,ICON=38},{ID=62,ICON=39},{ID=63,ICON=40},{ID=64,ICON=41},{ID=65,ICON=42}}
   for i,v in ipairs(self.REGISTS) do 
      local t = {ID = 50072,BUFF_ID = v.ID,VALUE = 1000,DURATION = 999999,ICON = v.ICON}
      local tk = {ID = 50073,BUFF_ID = 17,VALUE = floor,DURATION = 999999,ICON = 26,SCRIPT={SCRIPT_ID = 14,VALUE1=i}}
      table.insert(self.BUFF_BOX_LIST_REGIST,i,t)
      table.insert(self.BUFF_BOX_LIST_KILLER,i,tk)
   end
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 5,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "一定ダメージで属性変更",
         COLOR = Color.white
      })
   }

   self.HP80_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP80_MESSAGE1 or "フラグ何かあれば"
      })
   }

   self.DECAY_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.DECAY_MESSAGE1 or "属性エネルギー消費:フィニス=マキナの出力減衰",
         COLOR = Color.white
      })
   }

   self.ELEMENT_MESSAGE_LIST = {
      [kElementType_Fire] = {
         [self.CONST.M_ELEMENT] = self:setMessageInfo(
            {
            MESSAGE = self.TEXT.ELEMENT_FIRE or "炎属性エネルギー",
            COLOR = Color.red
         }),
         [self.CONST.M_ELEMENT_BUFF] = self:setMessageInfo(
            {
            MESSAGE = self.TEXT.ELEMENT_BUFF_FIRE or "炎属性耐性アップ",
            COLOR = Color.red
         }),
         [self.CONST.M_ELEMENT_KILLER] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_KILLER_FIRE or "炎属性キラー",
            COLOR = Color.red
         })
      },
      [kElementType_Earth] = {
         [self.CONST.M_ELEMENT] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_EARTH or "樹属性エネルギー",
            COLOR = Color.green
         }),
         [self.CONST.M_ELEMENT_BUFF] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_BUFF_EARTH or "樹属性耐性アップ",
            COLOR = Color.green
         }),
         [self.CONST.M_ELEMENT_KILLER] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_KILLER_EARTH or "樹属性キラー",
            COLOR = Color.green
         })         
      },
      [kElementType_Aqua] = {
         [self.CONST.M_ELEMENT] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_AQUA or "水属性エネルギー",
            COLOR = Color.cyan
         }),
         [self.CONST.M_ELEMENT_BUFF] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_BUFF_AQUA or "水属性耐性アップ",
            COLOR = Color.cyan
         }),
         [self.CONST.M_ELEMENT_KILLER] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_KILLER_AQUA or "水属性キラー",
            COLOR = Color.cyan
         })
      },
      [kElementType_Light] = {
         [self.CONST.M_ELEMENT] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_LIGHT or "光属性エネルギー",
            COLOR = Color.yellow
         }),
         [self.CONST.M_ELEMENT_BUFF] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_BUFF_LIGHT or "光属性耐性アップ",
            COLOR = Color.yellow
         }),
         [self.CONST.M_ELEMENT_KILLER] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_KILLER_LIGHT or "光属性キラー",
            COLOR = Color.yellow
         })
      },
      [kElementType_Dark] = {
         [self.CONST.M_ELEMENT] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_DARK or "闇属性エネルギー",
            COLOR = Color.magenta
         }),
         [self.CONST.M_ELEMENT_BUFF] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_BUFF_DARK or "闇属性耐性アップ",
            COLOR = Color.magenta
         }),
         [self.CONST.M_ELEMENT_KILLER] = self:setMessageInfo({
            MESSAGE = self.TEXT.ELEMENT_KILLER_DARK or "闇属性キラー",
            COLOR = Color.magenta
         })
      }
   }

   self.DEAD_MESSAGE_LIST  = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.DEAD or "フィニス＝マキナ起動",
         COLOR = Color.white
      })
   }

   -- 時間経過強化時メッセージ
   self.TIMEUP_BUFF_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      },
      [2] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      }
  }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TID_TIME_UP = 2
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp80(status) end,
         HP = 80,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [self.TID_TIME_UP] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
         used = false
      }
   
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp80(status)
   if status == "use3" then
      self:showMessage(self.HP80_MESSAGE_LIST)
      self.breakCapacity = self.gameUnit:getBaseBreakCapacity() * self.BREAK[self.STATE.breakMode].factor
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP80_MESSAGE_LIST)
   end
end

function class:timeUp(status)
   if status == "use3" then
      self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
      self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
      self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
   end
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
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   event.unit:setSkin("Nomal")
   self.breakCount = 0
   self.modeChangeCount = 0
   self.breakCapacity = event.unit:getBaseBreakCapacity() * self.BREAK[self.STATE.breakMode].factor
   self.totalChangeElements = {}
   self.attackDelay = event.unit:getAttackDelay()

   self.isRage = false
   self.isFury = false
   self.isDead = false
   self.deathCount = 0
   self.LIMIT = 8
   self.elementTimer = 0
   local floor = megast.Battle:getInstance():getCurrentMineFloor();
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList(14 * math.pow(floor,0.5) + 6)
   -- self:setBuffBoxList(30)
   self:showMessage(self.START_MESSAGE_LIST)
   self.funnelController:new(self,event.unit);
   self.homingShotController:new(self,event.unit);

    -- 5階層毎にヒットストップ耐性20％上昇(最大100％)
    self.hitStopReduceRate = math.floor((floor - 1) / 5) * 0.2;
    if self.hitStopReduceRate > 1.0 then self.hitStopReduceRate = 1.0; end



   --テロップ用変数
   self.telopSpan = 60
   self.showMessageTimer = 0
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self:subBars()
   return 1
end

function class:subBars()
   self.gameUnit:setSetupAnimationNameEffect("setUpBarrier");
   self.subBar = BattleControl:get():createSubBar();
   self.subBar:setWidth(200); --バーの全体の長さを指定
   self.subBar:setHeight(13);
   self.subBar:setPercent(0); --バーの残量を50%に指定
   self.subBar:setVisible(false);
   self.subBar:setPositionX(-100);
   self.subBar:setPositionY(150);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   self.funnelController:funnelRunScript(event)
   self.homingShotController:homingShotRunScript(event);
   if event.spineEvent == "laserHit2" then self:laserHit2(event.unit) end
   if event.spineEvent == "addSP" then self:addSP(event.unit) end
   return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   -- self:HPTriggersCheck(event.unit)
   self:controllSubBar(event.unit)
   self:checkDeath(event.unit,event.deltaTime)
   self.funnelController:onUpdate(event.deltaTime)
   self.homingShotController:onUpdate(event.deltaTime)
   self:attack5ArmControll(event.unit);
   self:setReduceHitStop(event.unit);
   self:telopCheck(event.deltaTime)
   self:setTimeUp()
   if megast.Battle:getInstance():getBattleState() == kBattleState_active then
      self.elementTimer = self.elementTimer + event.deltaTime
   end
   return 1
end

function class:checkDeath(unit,deltaTime)
   if self.isDead then
      if self.deathCount < self.LIMIT then
         self.deathCount = self.deathCount + deltaTime
         return
      end
      unit:setHP(0)
   end
end

function class:checkElement()
   if self.STATE.battleMode == self.CONST.ATTACK or self.STATE.breakMode == self.CONST.BREAK_LARGE or self.elementTimer < self.CONST.SPAN_ELEMENT then return end
   self.elementTimer = 0
   local el = 0
   local ei = 0
   for i,v in ipairs(self.ELEMENT) do
      if v.value > el and v.value > self.CONST.BORDER then
         el = v.value
         ei = i
      end
   end
   self.STATE.element = ei
   megast.Battle:getInstance():setBossCounterElement(self.STATE.element)
   if self.STATE.element ~= 0 then
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_REGIST[self.STATE.element])
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_KILLER[self.STATE.element])
      self:checkElementMessage(self.STATE.element)
   end
end
function class:checkElementMessage(elementType)
   if elementType ~= 0 then
      self:execShowMessage(self.ELEMENT_MESSAGE_LIST[elementType][self.CONST.M_ELEMENT_BUFF])
      self:execShowMessage(self.ELEMENT_MESSAGE_LIST[elementType][self.CONST.M_ELEMENT_KILLER])
      if not self.ELEMENT[elementType].isShowedMessage then
         self.ELEMENT[elementType].isShowedMessage = true
         self:showMessage(self.DECAY_MESSAGE_LIST)
         table.insert(self.totalChangeElements,elementType)
      end
   end
end

function class:controllSubBar(unit)
   if self.subBar ~= nil then
      if self.STATE.breakMode ~= self.CONST.BREAK_LARGE and self.STATE.battleMode == self.CONST.BARRIER then
         self.subBar:setVisible(true)
         local bonex = unit:getSkeleton():getBoneWorldPositionX("R_barrier_hand_root") - 205;
         local boney = unit:getPositionY() + 100;
         self.subBar:setPosition(bonex,boney);
         self.subBar:setPercent(100 * (self.breakCapacity - self.breakCount)/self.breakCapacity);
      end
   end
end

-- 一定時間ごとにテロップを流す
function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
       self.showMessageTimer = 0
       self:showMessage(self.START_MESSAGE_LIST)
    else
       self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end

-- 300秒経ったらタイムアップ
function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TID_TIME_UP].used then
      self:execTrigger(self.TID_TIME_UP)
   end
end

function class:setReduceHitStop(unit)
    unit:setReduceHitStop(2, self.hitStopReduceRate);
end


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   if not self.isDead then
      self.isDead = true
      event.unit:setInvincibleTime(7.1)
      self.skillCheckFlg = true
      self.BUFF_BOX_LIST_BOMB[1].VALUE = self.BUFF_BOX_LIST_BOMB[1].VALUE - (#self.totalChangeElements * 30)
      for i = 0,3 do
         local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
         if teamUnit ~= nil then
            self:execAddBuff(teamUnit,self.BUFF_BOX_LIST_BOMB[1])
         end 
      end
      self:showMessage(self.DEAD_MESSAGE_LIST)
      event.unit:takeSkill(7)
      event.unit:setHP(1)
      return 0
    end
   return 1
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
   self:checkElement()
   if self.STATE.breakMode == self.CONST.BREAK_LARGE then
      event.unit:setSkin("Break_large")
   end
   if event.unit.m_breaktime > 0 then return 1 end

   event.unit:setAttackDelay(self.attackDelay)
   self.isAttack5 = false;
   return self.BATTLEMODE[self.STATE.battleMode].excuteAction(self)
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
   return self.BATTLEMODE[self.STATE.battleMode].takeIdle(self)
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
   return self.BATTLEMODE[self.STATE.battleMode].takeBack(self)
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   return self.BATTLEMODE[self.STATE.battleMode].takeDamage(self)
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.STATE.element = 0
   megast.Battle:getInstance():setBossCounterElement(self.STATE.element)
   self:execRemoveCondition(self.gameUnit,50072)
   self:execRemoveCondition(self.gameUnit,50073)
   for i,v in ipairs(self.ELEMENT) do
      v.value = 0
   end
   return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   return self:calcDamageValue(event.enemy:getActiveBattleSkill() or event.enemy,event.value)
end

function class:calcDamageValue(active,value)
   if self.STATE.breakMode == self.CONST.BREAK_LARGE then return value end

   if active:getElementType() ~= 0 and self.STATE.battleMode == self.CONST.BARRIER then
      self.ELEMENT[active:getElementType()].value = self.ELEMENT[active:getElementType()].value + value
   end
   return value
end
---------------------------------------------------------------------------------
-- takeBreakeDamageValue
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
   if self.STATE.battleMode == self.CONST.ATTACK then return event.value end

   return self:calcBreakValue(event.enemy:getActiveBattleSkill() or event.enemy,event.value)
end

function class:calcBreakValue(active,value)
   if self.STATE.breakMode == self.CONST.BREAK_LARGE then return value end

   local tVal = self:checkAttenuation(value,active:getElementType())
   if active:getElementType() ~= 0 and self.STATE.battleMode == self.CONST.BARRIER then
      self.ELEMENT[active:getElementType()].value = self.ELEMENT[active:getElementType()].value + tVal
      self.breakCount = self.breakCount + tVal
   end
   self:checkBarrierBreak(self.breakCount)
   return tVal
end

function class:checkAttenuation(value,elementType)
   if elementType == self.ELEMENT[self.STATE.element].weak then return value end
   if elementType == self.ELEMENT[self.STATE.element].strong then return value * self.CONST.CUT_STRONG end
   return value * self.CONST.CUT_NORMAL
end

function class:checkBarrierBreak(value)
   if value > self.breakCapacity then
      self.BREAK[self.STATE.breakMode].func(self,self.gameUnit)
   end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   if event.unit.m_breaktime > 0 then return 0 end

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
   if event.index == 2 then 
      self.funnelController:addFunnel() 
   else
      self.funnelController:funnelAttack(self.STATE.battleMode,self.CONST)
   end

   if event.index == 5 then
      self.isAttack5 = true;
   end
   self:setAttackActiveSkill(event.unit,event.index)
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if self.STATE.breakMode == self.CONST.BREAK_LARGE and attackIndex == 6 then
      attackIndex = 5
   end

   self:spendingEnergy(self.CONST.SPEND_VALUE["ATTACK"..attackIndex] or 0)
   unit:takeAttack(tonumber(attackIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   return 0;
end

function class:spendingEnergy(spendValue)
   self.ELEMENT[self.STATE.element].value = self.ELEMENT[self.STATE.element].value - spendValue
   return self.ELEMENT[self.STATE.element].value
end


function class:setAttackActiveSkill(unit,index)
   unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK" .. index])
   if index == 6 then return end
   if index <= 3 then
      self:setAnimationBarrier(unit,"attack",index)
   else
      self:setAnimationAttack(unit,"attack",index)
   end
end

function class:setAnimationAttack(unit,attackType,index)
   if self.STATE.element ~= 0 then
      unit:setNextAnimationName("zclone"..self.ELEMENT[self.STATE.element].animationName..attackType..index)
      unit:setNextAnimationEffectName("zclone".. self.ELEMENT[self.STATE.element].animationName .."1-"..attackType..index);
   end
end

function class:setAnimationBarrier(unit,attackType,index)
   if index == 3 and self.STATE.breakMode == self.CONST.BREAK_LARGE then
      if attackType == "skill" then
         unit:setNextAnimationEffectName("1-skill3break");
      end
      if attackType == "attack" then
         unit:setNextAnimationName("attack3break");
         unit:setNextAnimationEffectName("Empty")
      end

   elseif self.STATE.element ~= 0 and not (index == 3 and attackType == "skill") then
      unit:setNextAnimationName("zclone" .. self.ELEMENT[self.STATE.element].animationName .. attackType..index)
      if self.STATE.breakMode ~= self.CONST.BREAK_LARGE then
         unit:setNextAnimationEffectName("zclone".. self.ELEMENT[self.STATE.element].animationName .."1-"..attackType..index);
      end
   end
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

   -- if event.index == 3 and not self.skillCheckFlg2 then
   --    self.skillCheckFlg2 = true;
   --    event.unit:takeSkillWithCutin(3,1);
   --    return 0;
   -- end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:setSkillActiveSkill(event.unit,event.index)
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   self:spendingEnergy(self.CONST.SPEND_VALUE["SKILL"..skillIndex] or 0)
   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

function class:setSkillActiveSkill(unit,index)
   if self.ELEMENT[self.STATE.element]["activeSkill_"..index] ~= nil then
      unit:setActiveSkill(self.ELEMENT[self.STATE.element]["activeSkill_"..index])
   else
      unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL" .. index])
   end
   if index == 7 then return end

   if index == 2 or index == 3 then
      self:setAnimationBarrier(unit,"skill",index)
   else
      self:setAnimationAttack(unit,"skill",index)
   end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
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
function class:addBuff(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
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

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end  
end
--=====================================================================================================================================

--ファンネル制御

--=====================================================================================================================================
class.funnelController = {};


--=====================================================================================================================================
--接続部　
--=====================================================================================================================================

function class.funnelController:new(parentClass,unit)
    --こいつのなかでのselfはclass.funnelControllerのことを指しているよ！
    self.parent = parentClass;
    self.parentGameUnit = unit;
    self.funnelTotalCount = 0;
    self.funnelCount = 0;
    self.funnelMaxCount = 8;
    self.rotation = 0;
    self.funnels = {};
    self.attackExcution = false;
    self.funnelStates = {
        start = 1,
        idle = 2,
        attackMove = 3,
        attack1 = 4,
        attack2 = 5,
        dead = 6
    }
    self.animationNames = {
        [1] = "funnelIdle",
        [2] = "funnelIdle",
        [3] = "funnelIdle",
        [4] = "funnelLaser",
        [5] = "funnelAttack",
        [6] = "funnelDead"
    }

    self.funnelControlActions = {
        [1] = self.funnelControlStart,
        [2] = self.funnelControlIdle,
        [3] = self.funnelControlAttackMove,
        [4] = self.funnelControlAttack1,
        [5] = self.funnelControlAttack2,
        [6] = self.funnelControlDead
    }

    -- summoner.Utility.messageByEnemy(self.parentGameUnit:getBaseID3());
    -- summoner.Utility.messageByEnemy(self.parent.gameUnit:getBaseID3());
end

function class.funnelController:addFunnel()
    if self.funnelCount >= self.funnelMaxCount then
        return;
    end
    table.insert(self.funnels,self:createFunnelStruct(self));
end

function class.funnelController:onUpdate(deltaTime)
    self:updateControl(deltaTime);
    self.rotation = self.rotation + deltaTime * 45;
end

function class.funnelController:funnelRunScript(event)
    if event.spineEvent == "funnelStateEnd" then self:funnelStateEnd(event.unit) end
    if event.spineEvent == "laserHit" then self:laserHit() end
    return 1;
end

function class.funnelController:funnelAttack(battleMode,CONST)
   if battleMode == CONST.ATTACK then
      self:funnelAttack2()
   else
      self:funnelAttack1()
   end
end

function class.funnelController:funnelAttack1()
    for i,v in pairs(self.funnels) do
       v.state = self.funnelStates.attack1;
       v.orbit:takeAnimation(0,self.animationNames[v.state],true);
       v.orbit:setActiveSkill(2);
       self.attackExcution = false;
    end
end

function class.funnelController:funnelAttack2()
    for i,v in pairs(self.funnels) do
       v.state = self.funnelStates.attackMove;
       v.orbit:takeAnimation(0,self.animationNames[v.state],true);
       v.orbit:setActiveSkill(7);
    end
end

--=====================================================================================================================================
--ファンネル制御クラス部
--=====================================================================================================================================

function class.funnelController:createFunnelStruct(funnelController)
    local _orbit = self.parentGameUnit:addOrbitSystem("funnelIdle",0)
    _orbit:setHitCountMax(999);
    _orbit:setEndAnimationName("funnelDead")
    _orbit:takeAnimation(0,"funnelIdle",true);

    local x = self.parentGameUnit:getPositionX()
    local y = self.parentGameUnit:getPositionY()
    local offsetX = -80;
    local offsetY = 400;

    self.funnelTotalCount = self.funnelTotalCount + 1;
    self.funnelCount = self.funnelCount + 1;

    local funnelStruct = {
        orbit = _orbit,
        position = Vector2:new(x + offsetX,y + offsetY),
        movement = Vector2:new(1,0),
        deg = 0,
        speed = 200,
        state = 1,
        actionTimer = 0,
        targetUnit = nil,
        uniqueID = self.funnelTotalCount,
        order = 0
    }
    
    _orbit:setPosition(funnelStruct.position.x,funnelStruct.position.y);

    self:reloadOrders();

    return funnelStruct;
end


function class.funnelController:updateControl(deltaTime)
    for i,v in pairs(self.funnels) do
        self.funnelControlActions[v.state](self,deltaTime,v);
    end
end

function class.funnelController:funnelControlStart(deltaTime,funnelStruct)
    local breakSpeed = 70;
    funnelStruct.actionTimer = funnelStruct.actionTimer + deltaTime;
    funnelStruct.speed = funnelStruct.speed - deltaTime * breakSpeed;
    if funnelStruct.speed <= 0 then
        self:funnelStateEnd(funnelStruct.orbit);
    end
    self:funnelMove(funnelStruct,deltaTime);
end

function class.funnelController:funnelControlIdle(deltaTime,funnelStruct)
    local parentx = self.parentGameUnit:getPositionX();
    local parenty = self.parentGameUnit:getPositionY() + 300;
    local deg = self.rotation;

    local myDeg = deg + 360/self.funnelCount * funnelStruct.order;

    local rad = self.parent:degToRad(deg + myDeg);
    local normalizeX = math.cos(rad);
    local normalizeY = math.sin(rad);

    local distance = 200;

    local positionX = parentx + normalizeX * distance;
    local positionY = parenty + normalizeY * distance;



    local targetVector = Vector2:new(positionX,positionY);
    local vec = self:getChaseVector(funnelStruct,targetVector);



    funnelStruct.speed = vec.magnitude * 5;
    
    funnelStruct.movement = vec:normalize();

    

    self:funnelMove(funnelStruct,deltaTime);

end

function class.funnelController:funnelControlAttackMove(deltaTime,funnelStruct)
    local x = self.parentGameUnit:getTargetUnit():getPositionX();
    local y = self.parentGameUnit:getTargetUnit():getPositionY();
    local xb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionY("MAIN");
    
    local positionX = x + xb;
    local positionY = y + yb;



    local targetVector = Vector2:new(positionX,positionY);
    local vec = self:getChaseVector(funnelStruct,targetVector);



    funnelStruct.speed = vec.magnitude * 5;
    
    funnelStruct.movement = vec:normalize();

    if vec.magnitude < 100 then
        self:funnelStateEnd(funnelStruct.orbit);
    end
    

    self:funnelMove(funnelStruct,deltaTime);
end

function class.funnelController:funnelControlAttack1(deltaTime,funnelStruct)
    if self.parentGameUnit:getTargetUnit() == nil then
        return;
    end
    local x = self.parentGameUnit:getTargetUnit():getPositionX();
    local y = self.parentGameUnit:getTargetUnit():getPositionY();
    local xb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionY("MAIN");
    local deg = self.parent:getDeg(funnelStruct.position.x,funnelStruct.position.y,x+xb,y+yb);
    
    funnelStruct.orbit:setRotation(360 - deg);
end

function class.funnelController:funnelControlAttack2(deltaTime,funnelStruct)
    if self.parentGameUnit:getTargetUnit() == nil then
        return;
    end
    local x = self.parentGameUnit:getTargetUnit():getPositionX();
    local y = self.parentGameUnit:getTargetUnit():getPositionY();
    local xb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionY("MAIN");
    
    local positionX = x + xb;
    local positionY = y + yb;



    local targetVector = Vector2:new(positionX,positionY);
    local vec = self:getChaseVector(funnelStruct,targetVector);



    funnelStruct.speed = vec.magnitude * 5;
    
    funnelStruct.movement = vec:normalize();
    

    self:funnelMove(funnelStruct,deltaTime);
end

function class.funnelController:funnelControlDead(deltaTime,funnelStruct)
    local hit = 0;
    for i,v in pairs(self.funnels) do
        if v == funnelStruct then
            hit = i;
        end
    end
    table.remove(self.funnels,hit);
end

function class.funnelController:funnelMove(funnelStruct,deltaTime)
    local moment = Vector2.multiplies(funnelStruct.movement,funnelStruct.speed * deltaTime);
    funnelStruct.position = Vector2.adds(funnelStruct.position,moment);
    funnelStruct.orbit:setPosition(funnelStruct.position.x,funnelStruct.position.y);
end

function class.funnelController:getChaseVector(funnelStruct,targetVector)
    local v = Vector2.subtracts(targetVector,funnelStruct.position);
    return v;
end

function class.funnelController:reloadOrders()
    for i,v in pairs(self.funnels) do
        v.order = self:getOrder(v);
    end
end

function class.funnelController:getOrder(funnelStruct)
    local preCnt = 0;
    local id = funnelStruct.uniqueID;
    for i,v in pairs(self.funnels) do
        if v ~= funnelStruct and v.uniqueID < id then
            preCnt = preCnt + 1;
        end
    end
    return preCnt + 1;
end


function class.funnelController:funnelStateEnd(orbit)
    local target = nil;
    for i,v in pairs(self.funnels) do
        if v.orbit == orbit then
            target = v;
        end
    end

    if target.state == self.funnelStates.start then
        target.state = self.funnelStates.idle;
    end

    if target.state == self.funnelStates.attack1 then
        target.state = self.funnelStates.idle;
        orbit:setRotation(0);
    end

    if target.state == self.funnelStates.attack2 then
        target.state = self.funnelStates.idle;
    end

    if target.state == self.funnelStates.attackMove then
        target.state = self.funnelStates.attack2;
    end

    target.orbit:takeAnimation(0,self.animationNames[target.state],true);
end

function class.funnelController:laserHit()
    if self.parentGameUnit:getTargetUnit() == nil then
        return;
    end
    if self.attackExcution then
        return;
    end
    self.attackExcution = true;
    local hit = self.parentGameUnit:addOrbitSystem("laserHit",0);
    local x = self.parentGameUnit:getTargetUnit():getPositionX();
    local y = self.parentGameUnit:getTargetUnit():getPositionY();
    local xb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionY("MAIN");
    hit:setActiveSkill(2);
    
    hit:setPosition(x + xb , y + yb);
    hit:setDamageRateOffset(self.funnelCount);
   
end

--=====================================================================================================================================

--ホーミングショット制御

--=====================================================================================================================================
class.homingShotController = {};


--=====================================================================================================================================
--接続部
--=====================================================================================================================================

function class.homingShotController:new(parentClass,unit)
    --こいつのなかでのselfはclass.homingDhotControllerのことを指しているよ！
    self.parent = parentClass;
    self.parentGameUnit = unit;
    self.shots = {};
    self.attackExcution = false;

    self.shotStates = {
        start = 1,
        homing = 2,
        dead = 3
    }

    self.shotControlActions = {
        [1] = self.shotControlStart,
        [2] = self.shotControlHoming,
        [3] = self.shotControlDead
    }
end


function class.homingShotController:onUpdate(deltaTime)
    self:updateControl(deltaTime);
end

function class.homingShotController:homingShotRunScript(event)

    if event.spineEvent == "onDestroyball" then self:shotStateEnd(event.unit) end
    if event.spineEvent == "onDestroyMissile" then self:shotStateEnd(event.unit) end
    if event.spineEvent == "ball" then self:addBall() end
    if event.spineEvent == "missile" then self:addMissile() end
    return 1;
end


function class.homingShotController:addShot(startAnimation,endAnimation,hitCount,startBone,phase1Time,startVector,speed,homingDeg,isrotation)
    table.insert(self.shots,self:createShotStruct(startAnimation,endAnimation,hitCount,startBone,phase1Time,startVector,speed,homingDeg,isrotation));
end



--=====================================================================================================================================
--ホーミングショットクラス部
--=====================================================================================================================================


function class.homingShotController:updateControl(deltaTime)
    for i,v in pairs(self.shots) do
        self.shotControlActions[v.state](self,deltaTime,v);
    end
end


function class.homingShotController:createShotStruct(startAnimation,endAnimation,hitCount,startBone,_phase1Time,startVector,_speed,_homingDeg,_isrotation)
    local _orbit = self.parentGameUnit:addOrbitSystem(startAnimation,1)
    _orbit:setHitCountMax(hitCount);
    _orbit:setEndAnimationName(endAnimation)
    _orbit:takeAnimation(0,startAnimation,true);

    local x = self.parentGameUnit:getPositionX()
    local y = self.parentGameUnit:getPositionY()
    local xb = self.parentGameUnit:getSkeleton():getBoneWorldPositionX(startBone);
    local yb = self.parentGameUnit:getSkeleton():getBoneWorldPositionY(startBone);

    local shotStruct = {
        orbit = _orbit,
        position = Vector2:new(x + xb,y + yb),
        movement = startVector,
        speed = _speed,
        state = 1,
        actionTimer = 0,
        targetUnit = nil,
        limitDegPs = _homingDeg,
        phase1Time = _phase1Time,
        isrotation = _isrotation
    }
    
    _orbit:setPosition(shotStruct.position.x,shotStruct.position.y);

    return shotStruct;
end

function class.homingShotController:shotStateEnd(orbit)

    local target = nil;
    local index = 0;
    for i,v in pairs(self.shots) do
        if v.orbit == orbit then
            target = v;
            index = i;
        end
    end

    table.remove(self.shots,index);
    
end


function class.homingShotController:shotControlStart(deltaTime,shotStruct)
    shotStruct.actionTimer = shotStruct.actionTimer + deltaTime;
    if shotStruct.actionTimer > shotStruct.phase1Time then
        shotStruct.state = 2;
    end
    self:shotMove(shotStruct,deltaTime);
    if shotStruct.isrotation then
       local deg = self.parent:getDeg(0,0,shotStruct.movement.x,shotStruct.movement.y);
       shotStruct.orbit:setRotation(360 - deg);
    end
end


function class.homingShotController:shotControlHoming(deltaTime,shotStruct)
    if self.parentGameUnit:getTargetUnit() == nil then
        return;
    end
    local x = self.parentGameUnit:getTargetUnit():getPositionX();
    local y = self.parentGameUnit:getTargetUnit():getPositionY();
    local xb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = self.parentGameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionY("MAIN");
    
    local positionX = x + xb;
    local positionY = y + yb;

    local sign = 1;


    local targetVector = Vector2:new(positionX,positionY);
    local vec = self:getChaseVector(shotStruct,targetVector);
    vec = vec:normalize();

    local clossProduct = self.parent:closs(shotStruct.movement,vec);

    if clossProduct < 0 then
      sign = -1;
    end


    local limitDeg = shotStruct.limitDegPs * deltaTime * sign;
    local rad = self.parent:degToRad(limitDeg);
   


    -- local differ = Vector2.subtracts(nVec,shotStruct.movement);


   local rotationX = shotStruct.movement.x * math.cos(rad) - shotStruct.movement.y * math.sin(rad)
   local rotationY = shotStruct.movement.x * math.sin(rad) + shotStruct.movement.y * math.cos(rad)


   shotStruct.movement = Vector2:new(rotationX,rotationY);
   shotStruct.movement = shotStruct.movement:normalize();
    

    self:shotMove(shotStruct,deltaTime);
    if shotStruct.isrotation then
       local deg = self.parent:getDeg(0,0,shotStruct.movement.x,shotStruct.movement.y);
       shotStruct.orbit:setRotation(360 - deg);
    end
end


function class.homingShotController:shotMove(shotStruct,deltaTime)
    local moment = Vector2.multiplies(shotStruct.movement,shotStruct.speed * deltaTime);
    shotStruct.position = Vector2.adds(shotStruct.position,moment);
    shotStruct.orbit:setPosition(shotStruct.position.x,shotStruct.position.y);
end

function class.homingShotController:getChaseVector(shotStruct,targetVector)
    local v = Vector2.subtracts(targetVector,shotStruct.position);
    return v;
end

function class.homingShotController:addBall()
    local vec = Vector2:new((Random.range(200) - 100)/100,(Random.range(200) - 100)/100);
    self:addShot("ball","ballExplosion",1,"L_barrier_hand_root",2,vec,200,90,false);
end

function class.homingShotController:addMissile()
    local vec = Vector2:new(math.cos(self.parent:degToRad(45)),math.sin(self.parent:degToRad(45)));
    self:addShot("missile","missileExplosion",1,"C_weapon_maingun",2,vec,900,90,true);
end


--=====================================================================================================================================
--アームコントロール
--=====================================================================================================================================


function class:attack5ArmControll(unit)
   if not self.isAttack5 then
      return;
   end
    self:boneRotation(unit,"R_weapon_gunbarrel_upper",360);
    self:boneRotation(unit,"R_weapon_arm_gunbarre_center",360);
    self:boneRotation(unit,"R_weapon_gunbarrel_lower",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_upper",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_canter",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_lower",360);
   
end

function class:boneRotation(unit,boneName,maxdeg)
    unit:getSkeleton():setBoneRotation(boneName,self:calcDeg(unit,boneName));
    return 1;
end

function class:calcDeg(unit,boneName)
    local target = unit:getTargetUnit();
    if target ~= nil then
        local x = unit:getPositionX();
        local y = unit:getPositionY();
        local xb = unit:getSkeleton():getBoneWorldPositionX(boneName);
        local yb = unit:getSkeleton():getBoneWorldPositionY(boneName);
        local tx = target:getPositionX();
        local ty = target:getPositionY();
        local txb = target:getSkeleton():getBoneWorldPositionX("MAIN");
        local tyb = target:getSkeleton():getBoneWorldPositionY("MAIN");
        return self:getDeg(x+xb,y+yb,tx+txb,ty+tyb);

    end
    return 0;
end

function class:laserHit2(unit)
   
   
   local bulletTarget = unit:getTargetUnit();

   if bulletTarget ~= nil then
       local hit = unit:addOrbitSystem("laserHit",0);
       local x = bulletTarget:getPositionX();
       local y = bulletTarget:getPositionY();
       local xb = bulletTarget:getSkeleton():getBoneWorldPositionX("MAIN");
       local yb = bulletTarget:getSkeleton():getBoneWorldPositionY("MAIN");
       hit:setPosition(x + xb , y + yb);
   end

   
   return 1;
end

--=====================================================================================================================================
--数学系
--=====================================================================================================================================

function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))

end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end


function class:degToRad(deg)
    return deg * 3.14159/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14159;
end

function class:dot(vec1,vec2)
   return vec1.x * vec2.x + vec1.y * vec2.y;
end

function class:closs(vec1,vec2)
   return vec1.x * vec2.y - vec1.y * vec2.x;
end



class:publish();

return class;