local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グラード", version=1.3, id=200040804});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
   ATTACK1 = 50,
   ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
   SKILL2 = 1
}

class.SKILL_WEIGHTS_80 = {
   SKILL2 = 3,
   SKILL3 = 1
}

class.SKILL_WEIGHTS_50 = {
   SKILL2 = 4,
   SKILL3 = 2,
   SKILL3_2 = 1
}

class.SKILL_WEIGHTS_30 = {
   SKILL3 = 1,
   SKILL3_2 = 2
}

class.ACTIVE_SKILLS = {
   ATTACK1 = 1,
   SKILL1 = 2,
   SKILL2 = 4,
   SKILL3 = 6
}

class.ACTIVE_SKILL_80 = {
   ATTACK1 = 1,
   SKILL1 = 2,
   SKILL2 = 4,
   SKILL3 = 6
}

class.ACTIVE_SKILL_50 = {
   ATTACK1 = 1,
   SKILL1 = 2,
   SKILL2 = 5,
   SKILL3 = 6,
   SKILL3_2 = 7
}

class.ACTIVE_SKILL_30 = {
   ATTACK1 = 1,
   SKILL1 = 3,
   SKILL2 = 5,
   SKILL3 = 6,
   SKILL3_2 = 7
}

class.INFO_WEIGHTS = {
   INFO1 = 1,
   INFO2 = 1,
   INFO3 = 1
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 17, -- ダメージ
         VALUE = 30,
         DURATION = 999999,
         ICON = 26
      },
      [2] = {
         ID = 20157502,
         BUFF_ID = 28, -- 行動速度
         VALUE = 20,
         DURATION = 999999,
         ICON = 7
      },
      [3] = {
         ID = 20157503,
         BUFF_ID = 17, -- ダメージ
         VALUE = 30,
         DURATION = 999999,
         ICON = 26
      },
      [9] = {
         ID = 20157504,
         BUFF_ID = 99, -- HP吸収
         VALUE = 100,
         DURATION = 999999,
         ICON = 23
      },
      [10] = {
         ID = 20157505,
         BUFF_ID = 13, -- ダメージ(攻撃力)
         VALUE = 30,
         DURATION = 999999,
         ICON = 3
      },
      [11] = {
         ID = 20157506,
         BUFF_ID = 0, -- ダメージ(攻撃力)
         VALUE = 0,
         DURATION = 999999,
         ICON = 3
      }
   }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 5,
      isPlayer = messageBox.isPlayer or false,
      span = messageBox.span or 2.5
   }
   return message
end

function class:setMessageBoxList()
   -- ロイ関係のメッセージ
   self.D_START_MESSAGE_LIST = {
      [1] = {
         page = 1,
         isShowed = false,
         messages = {
            [1] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE1 or "ロイ…てめぇだけは俺が潰す！",
               COLOR = Color.magenta,
               isPlayer = false
            }),
            [2] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE2 or "やれるものならやってみるがいい",
               COLOR = Color.cyan,
               isPlayer = true
            }),
            [3] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE3 or "ああ…やってやる…やってやるよ！",
               COLOR = Color.magenta,
               isPlayer = false
            })
         }
      },
      [2] = {
         page = 1,
         isShowed = false,
         messages = {
            [1] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE21 or "今日こそ決着つけようぜ",
               COLOR = Color.magenta,
               isPlayer = false
            }),
            [2] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE22 or "悪いが貴様に負ける気はしない",
               COLOR = Color.cyan,
               isPlayer = true
            }),
            [3] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE23 or "チッ…その態度が…",
               COLOR = Color.magenta,
               isPlayer = false
            }),
            [4] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE24 or "気に食わねえんだよ！",
               COLOR = Color.magenta,
               isPlayer = false
            })
         }
      },
      [3] = {
         page = 1,
         isShowed = false,
         messages = {
            [1] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE31 or "さぁ…楽しませてくれよ！",
               COLOR = Color.magenta,
               isPlayer = false
            }),
            [2] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE32 or "貴様の相手をしている暇はない",
               COLOR = Color.cyan,
               isPlayer = true
            }),
            [3] = self:setMessageInfo({
               MESSAGE = self.TEXT.START_MESSAGE33 or "ケッ！粋がるのは今のうちだぞ！",
               COLOR = Color.magenta,
               isPlayer = false
            })
         }
      }
   }

   self.D_START_MESSAGE_LIST2 = {
      page = 1,
      isShowed = false,
      messages = {
         [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE42 or "命中率・攻撃力アップ",
            span = 0.06
         }),
         [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.INFO_MESSAGE21 or "ロイに対するダメージアップ",
            span = 0.06,
            COLOR = Color.red
         }),
         [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.INFO_MESSAGE22 or "ロイのダメージアップ",
            isPlayer = true,
            span = 0.06,
            COLOR = Color.red
         })
      }
   }

   self.START_MESSAGE_LIST = {
      --[1] = self:setMessageInfo({
      --   MESSAGE = self.TEXT.START_MESSAGE41 or "おい、大丈夫か？死相が出てるぜ？",
      --   COLOR = Color.magenta
      --}),
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE42 or "命中率・攻撃力アップ"
      })
   }

   self.HP80_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP80_MESSAGE1 or "行動速度アップ"
      })
   }

   self.HP65_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP65_MESSAGE1 or "奥義ゲージ速度アップ"
      })
   }

   self.HP50_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE2 or "ダメージアップ"
      })
   }
   self.DOOM_MESSAGE_LIST2 = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "見えるぜえ？テメーの死に様がよお！",
         COLOR = Color.magenta
      })
   }

   self.HP45_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP45_MESSAGE1 or "行動速度アップ"
      })
   }

   self.HP30_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "おいおい、全然効かねえぞお？",
         COLOR = Color.magenta
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE2 or "不死身：ブレイク時のみ解除"
      }),
      [3] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE3 or "被ダメージ回復：ブレイク時のみ解除"
      })
   }

   self.HP10_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP10_MESSAGE1 or "とっておきだ…くたばりな",
         COLOR = Color.magenta
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP10_MESSAGE2 or "ダメージアップ"
      })
   }

   self.ITEM_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.ITEM_MESSAGE1 or "魔骸翼使召喚"
      })
   }

   self.DOOM_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.DOOM_MESSAGE1 or "おい、大丈夫か？ 死相が出てるぜ？",
         COLOR = Color.magenta
      })
   }

   self.INFO_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.INFO_MESSAGE1 or "被ダメージ回復：ブレイク時のみ解除"
      })
   }

   self.DEAD_MESSAGE_LIST1 = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.DEAD_MESSAGE1 or "この俺が！？ ありえねえ…",
         COLOR = Color.magenta
      })
   }

   self.DEAD_MESSAGE_LIST2 = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.DEAD_MESSAGE21 or "クソ…やっぱりテメーは、気に入らねえ…",
         COLOR = Color.magenta
      })
   }

   self.OUGI_MESSAGE_LIST = {
      [2] = {
         [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.OUGI_MESSAGE1 or "ダメージ吸収率アップ"
         })
      },
      [3] = {
         [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SINOUGI_MESSAGE1 or "ビビんなって！ もっと楽しもうぜえ？",
            COLOR = Color.magenta
         }),
         [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.SINOUGI_MESSAGE2 or "ダメージ吸収率大アップ"
         })
      },
      [4] = {
         [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SINOUGI_MESSAGE21 or "ククク…ハハハ…ハーッハッハッアア！",
            COLOR = Color.magenta
         }),
         [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.SINOUGI_MESSAGE22 or "ダメージ吸収率大アップ"
         })
      }
   }

end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp80(status) end,
         HP = 80,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp65(status) end,
         HP = 65,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [4] = {
         tag = "HP_FLG",
         action = function (status) self:hp45(status) end,
         HP = 45,
         used = false
      },
      [5] = {
         tag = "HP_FLG",
         action = function (status) self:hp30(status) end,
         HP = 30,
         used = false
      },
      [6] = {
         tag = "HP_FLG",
         action = function (status) self:hp10(status) end,
         HP = 10,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   self.hpMarkers = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
         self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
      end
   end
end

function class:hp80(status)
   if status == "use3" then
      self:showMessage(self.HP80_MESSAGE_LIST)
      self.gameUnit:addSP(100)
      self.isRage = true
      self.rageActiveSkill = 7
      self.hitStop = 1
      self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_80
      self.ACTIVE_SKILLS = self.ACTIVE_SKILL_80
   end
end

function class:hp65(status)
   if status == "use3" then
      self:showMessage(self.HP65_MESSAGE_LIST)
      self.spValue = 25
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
      self.DOOM_MESSAGE_LIST = self.DOOM_MESSAGE_LIST2
      self.gameUnit:addSP(100)
      self.isRage = true
      self.isOugiC = true
      self.isUpperSP = true
      self.rageActiveSkill = 8
      self.DOOM_SPAN = 45
      self.DOOM_COUNT_MAX = 15
      self.isHP50 = true
      self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_50
      self.ACTIVE_SKILLS = self.ACTIVE_SKILL_50
   end
end

function class:hp45(status)
   if status == "use3" then
      self:showMessage(self.HP45_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
   end
end

function class:hp30(status)
   if status == "use3" then
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[9])
      self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_30
      self.ACTIVE_SKILLS = self.ACTIVE_SKILL_30
   end
end

function class:hp10(status)
   if status == "use3" then
      self.isLast = true
      --self.gameUnit:setInvincibleTime(7)
      self.rageActiveSkill = 8
      self:showMessage(self.HP10_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
      self.gameUnit:addSP(100)
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.DOOM_SPAN = 60
class.DOOM_COUNT_MAX = 20
class.DOOM_TARGET_SHOW_TIME = 10
class.ITEM_SPAN = 20

function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isRage = false
   self.isFury = false
   self.hitStop = 0.6
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self.isShowedInfo = true
   self.isHP50 = false

   --ロイとかのセリフ関係
   self.CURRENT_MESSAGE_BOX_LIST = {isShowed = true}
   self.messageDelay = 2
   if self:findUnit(103) then
      local str = summoner.Random.sampleWeighted(self.INFO_WEIGHTS);
      local index = string.gsub(str,"INFO","");
      self:delayMessageListCreator(self.D_START_MESSAGE_LIST[tonumber(index)])
      self:delayMessageListCreator(self.D_START_MESSAGE_LIST2)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[11])
      for _,v in pairs(self:getUnits(103)) do
         self:execAddBuff(v,self.BUFF_BOX_LIST[10])
      end
   else
      self:showMessage(self.START_MESSAGE_LIST)
   end


   --死の宣告関係
   event.unit:setHateRate_Heal(0)
   event.unit:setHateRate_Damage(0)
   self.targetIndexList = {}
   self.doomSelectTimer = 0
   self.doomCount = self.DOOM_COUNT_MAX
   self.isSelected = false
   self.targetUnit = nil

   --アイテム使用関係
   self.itemTimer = 0
   self.itemOrbit = nil
   return 1
end

function class:findUnit(unitID)
   for i = 0, 7 do
      local localUnit =  megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if localUnit ~= nil and localUnit:getBaseID3() == unitID then
         return true
      end
   end
   return false
end

function class:getUnits(unitID)
   local list = {}
   for i = 0, 7 do
      local localUnit =  megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if localUnit ~= nil and localUnit:getBaseID3() == unitID then
         table.insert(list,localUnit)
      end
   end
   return list
end

-- 表示するメッセージの準備
function class:delayMessageListCreator(messageBoxList)
   if not self.CURRENT_MESSAGE_BOX_LIST.isShowed then
      local index = #self.CURRENT_MESSAGE_BOX_LIST.messages
      for i,v in ipairs(messageBoxList.messages) do
         table.insert(self.CURRENT_MESSAGE_BOX_LIST.messages,index + i,v)
      end
   else
      self.CURRENT_MESSAGE_BOX_LIST = messageBoxList
   end
   self.showingMessage = true
end

-- ターゲット手動設定のための準備
function class:startWave(event)
   BattleControl:get():visibleHateTarget(true);
   BattleControl:get():setHateTargetIcon(14);
   event.unit:setEnableHate(true);
   event.unit:updateHateTarget();
   self:checkPlayersParty()
   return 1
end

-- 初期化
function class:checkPlayersParty()
   for i = 0,3 do
      local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
      if unit ~= nil then
         local targetInfo = {index = unit:getIndex(),dps = 0}
         table.insert(self.targetIndexList,unit:getIndex() + (unit:getBaseID3() * 10),targetInfo)
      end
   end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "loopStart" then
      if self.doom ~= nil then self.doom:takeAnimation(0,"auraLoop",true)
      end
   end
   if event.spineEvent == "auraEnd" then
      if self.doom ~= nil then  self.doom:takeAnimation(0,"none",true)
      end
   end

   if event.spineEvent == "end" then self.isFury = false end
   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   if event.unit.m_breaktime <= 0 then
      event.unit:setHP(1)
      return 0
   end


   if self:findUnit(103) then
      self:showMessage(self.DEAD_MESSAGE_LIST2)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,6,2);
   else
      self:showMessage(self.DEAD_MESSAGE_LIST1)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1);
   end


   return 1
end


function class:receive6(args)
   if args.arg == 1 then
      self:showMessage(self.DEAD_MESSAGE_LIST1)
   else
      self:showMessage(self.DEAD_MESSAGE_LIST2)
   end
   return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   if event.enemy:getBaseID3() == 103 then
      return event.value * 1.3
   end
   return event.value
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit)
   if megast.Battle:getInstance():getBattleState() == kBattleState_active and event.unit.m_breaktime <= 0 then
      self:checkDelayMessage(event.deltaTime)
      self:checkDoom(event.deltaTime)
      if megast.Battle:getInstance():isHost() then
         self:checkItem(event.deltaTime)
      end
   end

   if self.isFury then
      event.unit:addSP(100)
   end
   if not self.isShowedInfo and event.unit.m_breaktime <= 0 and self.TRIGGERS[5].used then
      self.isShowedInfo = true
      self:showMessage(self.INFO_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[9])
      megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
   end
   return 1
end

function class:receive8(args)
   self:showMessage(self.INFO_MESSAGE_LIST)
   self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[9])
   return 1
end

-- ロイがいると特殊会話発生
function class:checkDelayMessage(deltaTime)
   if self.showingMessage then
      self:showDelayMessage(self.CURRENT_MESSAGE_BOX_LIST,deltaTime)
   end
end

function class:showDelayMessage(messageBoxList,deltaTime)
   if messageBoxList.isShowed then return end

   if self.messageDelay > messageBoxList.messages[messageBoxList.page].span or messageBoxList.page == 1 then
      self:execShowMessage(messageBoxList.messages[messageBoxList.page])
      self.messageDelay = 0
      messageBoxList.page = messageBoxList.page + 1
   else
      self.messageDelay = self.messageDelay + deltaTime
   end

   if messageBoxList.page > #messageBoxList.messages then
      self.showingMessage = false
      self.messageDelay = 0
      messageBoxList.isShowed = true
   end
end

-- 一定時間ごとに死の宣告をする
function class:checkDoom(deltaTime)
   if not self.isSelected then
      self:selectDoom(deltaTime)
   else
      local target = self:getTargetUnit()
      if target~= nil then
         self:doomCountdown(target:getIndex(),deltaTime)
      end
   end
end

function class:selectDoom(deltaTime)
   if self.DOOM_SPAN > self.doomSelectTimer then
      self.doomSelectTimer = self.doomSelectTimer + deltaTime
   else
      if megast.Battle:getInstance():isHost() then
         self:execSelectDoom()
      end
   end
end


function class:execSelectDoom()
   local target = self:getTargetUnit()
   self.isSelected = true
   self.doomSelectTimer = 0
   if target ~= nil then
      self:touchDoomOrbit(target)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,4,target:getIndex());
   end
end

function class:touchDoomOrbit(unit)
   if self.doom ~= nil then
      self.doom:takeAnimation(0,"auraIn",true)
   else
      self.doom = self.gameUnit:addOrbitSystemWithFile("deathCountDown","auraIn")
      self.doom:takeAnimation(0,"auraIn",true)
   end
   self.doomDummy = self.gameUnit:addOrbitSystemWithFile("deathCountDown","dummy")
   self.doomDummy:setActiveSkill(10)
   self.doom:getSkeleton():setScaleX(-1);
   self:setDoomPosition(unit,self.doom)
   self:setDoomPosition(unit,self.doomDummy)
   self:showMessage(self.DOOM_MESSAGE_LIST)
end

function class:receive4(args)
   self.isSelected = true
   self.doomSelectTimer = 0
   self:touchDoomOrbit(megast.Battle:getInstance():getTeam(true):getTeamUnit(args.arg))
   return 1
end



function class:doomCountdown(targetInfo,deltaTime)
   local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(targetInfo)
   if self.doom ~= nil then
      if self.doomCount > 0 then
         self.doomCount = self.doomCount - deltaTime
         if target ~= nil then
            self:setDoomPosition(target,self.doom)
         end
         self:viewDoomCount(math.floor(self.doomCount),1)
         self.targetUnit = target
      else
         if target ~= nil then
            target:setHP(0)
         end
         self.doom:takeAnimation(0,"auraOut",true)
         self:initDoom()
      end
   end
end

function class:setDoomPosition(unit,target)
   local vec = unit:getisPlayer() and 1 or -1
   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
   local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
   target:setPosition(targetx,targety);
   target:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
   target:setZOrder(unit:getZOrder() + 1)
end

function class:initDoom()
   self.isSelected = false
   self.doomCount = self.DOOM_COUNT_MAX
   self.doomSelectTimer = 0
   for _,v in pairs(self.targetIndexList) do
      v.dps = 0
   end
   if self.doom ~= nil then
      self.doom:takeAnimation(1,"none",true)
      self.doom:takeAnimation(2,"none",true)
   end
end

function class:viewDoomCount(doomTime,layer)
   if layer < 0 then return end

   local cardinal = 10 ^ layer
   local multiply = 0
   if doomTime - cardinal >= 0 then
      multiply =  tonumber(string.match(tostring(doomTime),"^."))
   end
   local animationNum = cardinal * multiply
   local animationStr = animationNum ~= 0 and tostring(animationNum) or string.format( "%0" .. (layer + 1) .."d", 0 )
   local nokori = doomTime - animationNum

   self.doom:takeAnimation(layer+1,animationStr,true)
   self:viewDoomCount(nokori,layer - 1)
end

--アイテム
function class:checkItem(deltaTime)
   if  megast.Battle:getInstance():isHost() then
      if self.itemTimer <= self.ITEM_SPAN then
         self.itemTimer = self.itemTimer + deltaTime
      else
         self.isItemCharged = true
         megast.Battle:getInstance():sendEventToLua(self.scriptID,7,0);
      end
   end
end

function class:receive7()
   self.isItemCharged = true
   return 1
end
---------------------------------------------------------------------------------
-- takeItem
---------------------------------------------------------------------------------
function class:takeItem()
   self.itemOrbit = self.gameUnit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2010","attack1")
   self.itemOrbit:setActiveSkill(10)
   self:showMessage(self.ITEM_MESSAGE_LIST)
   return 1
end

------------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   local enemyUnit = self:getAncestorUnit(event.enemy)
   local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)

   if not self.isSelected then
      self:addTakeDamage(enemyUnit,index,event.value)
      self:setDoomTarget(event.unit)
   end
   return event.value
end

function class:addTakeDamage(enemyUnit,index,value)
   if self.targetIndexList[index] == nil then
      table.insert(self.targetIndexList,index,{index = enemyUnit:getIndex(),dps = value})
   else
      self.targetIndexList[index].dps = self.targetIndexList[index].dps + value
   end
end

function class:setDoomTarget(unit)
   local target = self:getTargetUnit()
   if target ~= nil then
      --ヘイトは全部手動で設定する！！！！！！！
      unit:setHateTarget(target)
      unit:updateHateTarget();
   end
end

-- オービットが攻撃してるかもしれないのでご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
   if unit:getParentTeamUnit() == nil then
      return unit
   else
      return self:getAncestorUnit(unit:getParentTeamUnit())
   end
end

-- 与ダメが最も大きいやつをターゲットにする
function class:getTargetUnit()
   local targetIndex = self:findAliveUnit()
   local val = 0
   for _,v in pairs(self.targetIndexList) do
      --if v.unit == nil or v.unit:getHP() < 1 then
      --   v.dps = 0
      --end
      if v.dps > val then
         val = v.dps
         targetIndex = v.index
      end
   end
   if targetIndex ~= nil then
      return megast.Battle:getInstance():getTeam(true):getTeamUnit(targetIndex)
   else
      return nil
   end
end

--とりあえず生きてるユニットのindexを設定する
function class:findAliveUnit()
   for i = 0,3 do
      local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
      if unit ~= nil then
         return unit:getIndex()
      end
   end
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.isShowedInfo = false
   if self.doom ~= nil then
      self.doom:takeAnimation(0,"auraRelease",true)
   end
   self:initDoom()
   self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[9].ID)
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


   if self.isItemCharged and megast.Battle:getInstance():isHost() then
      self.isItemCharged = false
      self.itemTimer = 0
      self:takeItem()
      megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
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


function class:receive5(args)
   self:takeItem()
   return 1
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

   if self.isFury or self.isLast then
      if not self.skillCheckFlg2 then
         self.skillCheckFlg2 = true;
         event.unit:takeSkillWithCutin(3,1);
         return 0;
      end
   end

   if self.isOugiC and event.index == 2 then
      if not self.skillCheckFlg2 then
         self.skillCheckFlg2 = true;
         event.unit:takeSkillWithCutin(2,1);
         return 0;
      end
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self.isShowedOugiMessage = false


   local infoIndex = 0

   if self.isUpperSP then
      self.isUpperSP = false
      infoIndex = 4
      event.unit:setActiveSkill(8)
   end
   if self.isRage then
      self.isRage = false
   elseif self.isFury then
      event.unit:setActiveSkill(self.rageActiveSkill)
      self.gameUnit:setInvincibleTime(7)
   else
      self:skillActiveSkillSetter(event.unit,event.index);
   end


   if infoIndex == 0 then
      if event.index == 2 then
         infoIndex = 2
      end
      if event.index == 3 then
         infoIndex = 3
      end
   end

   if self.isHP50 and event.index ~= 1 then
      self.isHP50 = false
      infoIndex = 4
   end

   if infoIndex ~= 0 and not self.isShowedOugiMessage then
      self.isShowedOugiMessage = true
      self:showMessage(self.OUGI_MESSAGE_LIST[infoIndex])
   end

   -- 【MEGA_D-9763】ボスの技の予告に、attackDamageValue のロイ（getBaseID3() == 103）だけの倍率を入れる（味方のロイに、その 1 体だけ。表示専用。古いアプリには無いので確かめてから呼ぶ）
   if event.unit.announceSkillRate then for i = 0, 3 do local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i); if u ~= nil and u:getBaseID3() == 103 then event.unit:announceSkillRate(1.3, u) end end end
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if skillStr == "SKILL3_2" then
      skillIndex = 3
      self.isUpperSP = true
   end
   if self.isRage or self.isFury then
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   self.TRIGGERS[args.arg].used = true
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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
   local buff;
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

class:publish();

return class;
