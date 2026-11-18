local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="シキ", version=1.8, id=102846412});

class.MARKING_BUFF_ID = 10284600;--シキのスキル攻撃がヒットした相手であることを示すバフのID マスターから設定 なので後で変える

class.CONDITION_AVOID_LIST = {
   [90] = {102,113},--毒に対して　毒回避率,全状態異常回避率
   [93] = {105,113},--暗闇に対して　暗闇回避率,全状態異常回避率
   [97] = {109,113} --燃焼に対して　燃焼回避率,全状態異常回避率
}

class.CONDITION_REGIST_LIST = {
   [90] = {53,112},--毒に対して　毒耐性,全状態異常耐性
   [93] = {60,112},--暗闇に対して　暗闇耐性,全状態異常耐性
   [97] = {57,112} --燃焼に対して　燃焼耐性,全状態異常耐性
}

class.CONDITION_RECEIVE_ID = {
   [90] = 5,
   [93] = 6,
   [97] = 7
}

function class:setBuffBoxList(duration)
   self.BADSTATUS_BOX_LIST = {
      [1] = {
         ID = 101291,
         BUFF_ID = 90, -- 毒
         VALUE = 2500,
         DURATION = 8,
         ICON = 80,
         GROUP_ID = 2026,
         PRIORITY = 250

      },
      [2] = {
         ID = 101292,
         BUFF_ID = 93, -- 暗闇
         VALUE = 40,
         DURATION = 8,
         ICON = 83,
         GROUP_ID = 2017,
         PRIORITY = 40
      },
      [3] = {
         ID = 101293,
         BUFF_ID = 97, -- 燃焼
         VALUE = 2500,
         DURATION = 8,
         ICON = 87,
         GROUP_ID = 2007,
         PRIORITY = 82500 + duration * 10000 --燃焼だけは効果時間によって優先度が変わる　秒数＊１００００の優先度なので追加秒＊１００００で
      }
   }

   self.BUFF_BOX_LIST = {
     [1] = {
      ID = 1028565121,
      BUFF_ID = 4001, -- カイガン
      VALUE = 0,
      DURATION = self.AURA_INTERVAL,
      ICON = 0
    }
   }

   self.KAIGAN_BUFF_BOX_LIST = {
     [1] = {
      ID = -1028565122,
      BUFF_ID = 17, -- ダメージ
      VALUE = 50,
      DURATION = self.AURA_INTERVAL,
      ICON = 26
    }
   }

   self.KAIGAN_ANIMATION = {
      attack1 = {
         main = "attack1_kaigan",
         ef = "2-attack1_kaigan"
      },
      skill1 = {
         main = "skill1_kaigan",
         ef = "2-skill1_kaigan"
      },
      skill2 = {
         main = "skill2_kaigan",
         ef = "2-skill2_kaigan"
      },
      back = {
         main = "back_kaigan"
      },
      front = {
         main = "front_kaigan"
      }
   }

   self.BOMB_WEIGHT = {
      bomb1 = 50,
      bomb2 = 50,
      bomb3 = 50
   }

   self.BOMB_LIST = {
      [1] = {
         animationName = "poisonbomb"
      },
      [2] = {
         animationName = "darknessbomb"
      },
      [3] = {
         animationName = "firebomb"
      }
   }

end

function class:setSurfaceBoxList()
   self.beforeMD = 0
   self.afterMD = 1
   self.SURFACE_BOX_LIST = {
      [self.beforeMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_01",
         SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
         SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
      },
      [self.afterMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_02",
         SKILL_NAME = self.TEXT.AFTER_MD or "魔導奥義「天地開闢」",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end


---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
   self.isAura = false
   self.timer = 0
   self.gameUnit = event.unit
   self.AURA_INTERVAL = 120
   self:setSurfaceBoxList()
self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

   self.kaiganBuffIconList = {checked = false,conds = {}}
   self.kaiganScriptIDList = {18,171}
   self.isKilled = false
   self.counter = 2
   self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,0)
   self:setBuffBoxList(0)

   return 1
end

---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
   if not self.kaiganBuffIconList.checked then
      self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,0)
   end
   if self:findWeapon(event.unit,50225400) then 
      self:setBuffBoxList(2)
   end
   return 1
end

function class:findWeapon(unit,weaponId)
  local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
  return buff ~= nil
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   if not self.isAura then
      self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,0)
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   end
   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   for i,v in ipairs(self.kaiganBuffIconList.conds) do
      self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,v)
   end
   if not self.isAura then
      self.kaiganBuffIconList.checked = false
      self.isKilled = false
   end   
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if not self.kaiganBuffIconList.checked then
      self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,0)
   end

   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   return 1
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
         -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self:removeCondition(unit,self.BUFF_BOX_LIST[1].ID)
         self:removeConditionAll(unit,self.KAIGAN_BUFF_BOX_LIST[1].ID)
         self:searchUnitEffect(unit,self.kaiganScriptIDList,4001,0)
         unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)

   if event.spineEvent == "md2Start" then
      self:setAura(event.unit)
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"Kaigan_loop",true);
   end
   if event.spineEvent == "hideEffect" then
      self:changeEffect(event.unit,"empty",false)
   end
   if event.spineEvent == "displayEffect" then
      self:changeEffect(event.unit,"Kaigan_loop",true)
   end
   -- 爆弾は同期させないとまずいかも
   if event.spineEvent == "bomb" and self:isHost() then
      self:selectBomb()
   end
   if event.spineEvent == "poison" then
      self.gameUnit:setParameter("targetID","90");
   end
   if event.spineEvent == "darkness" then
      self.gameUnit:setParameter("targetID","93");
   end
   if event.spineEvent == "fire" then
      self.gameUnit:setParameter("targetID","97");
   end

   if event.spineEvent == "sendPoison" then
      self:addBadStatus(self.gameUnit,self.BADSTATUS_BOX_LIST[1]);
   end
   if event.spineEvent == "sendDarkness" then
      self:addBadStatus(self.gameUnit,self.BADSTATUS_BOX_LIST[2]);
   end
   if event.spineEvent == "sendFire" then
      self:addBadStatus(self.gameUnit,self.BADSTATUS_BOX_LIST[3]);
   end
   return 1
end

function class:isHost()
   local bool = false
   if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
      bool = true
   end
   return bool
end

function class:selectBomb()
   local index = self.counter % 3 + 1
   local bombName = self.isAura and self.BOMB_LIST[index].animationName .. "2" or self.BOMB_LIST[index].animationName
   self.gameUnit:addOrbitSystemWithFile("10284ef",bombName)
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,index)
   self.counter = self.counter + 1
end

function class:receive1(args)
   local bombName = self.isAura and self.BOMB_LIST[args.arg].animationName .. "2" or self.BOMB_LIST[args.arg].animationName
   self.gameUnit:addOrbitSystemWithFile("10284ef",bombName)
   return 1
end


function class:changeEffect(unit,animationName,bool)
   if self.aura ~= nil and self.isAura then
      self.aura:takeAnimation(0,animationName,true);
   end
   self:switchUnitEffect(unit,bool)
end

function class:switchUnitEffect(unit,bool)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
    return 
  end

  for i = 0,(conditionSize - 1) do
     local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
     cond:setUnitEffectVisible(bool)
  end
end



function class:setAura(unit)
   self.gameUnit:addSPWithPvpCorrection(200)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"Kaigan_in",true);
      self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("Kaigan4","Kaigan_in");
   self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"Kaigan_in",true);
   self:auraPosition(unit)
   self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
   -- self:checkAnimation("back")
   return 1
end

---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
   self:checkAnimation("front")
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   self:changeEffect(event.unit,"Kaigan_loop",true)
   self:checkAnimation("attack" .. event.index)
   self:loopStart1(event.unit)---MD1オーラ失敗時に動く
   return 1 
end

function class:checkAnimation(animationName)
   if animationName == "skill3" then return end

   if self.isAura then
      self.gameUnit:setNextAnimationName(self.KAIGAN_ANIMATION[animationName].main)
      if self.KAIGAN_ANIMATION[animationName].ef then 
         self.gameUnit:setNextAnimationEffectName(self.KAIGAN_ANIMATION[animationName].ef)
      end
   end
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
   self:loopStart1(event.unit)---MD1オーラ失敗時に動く
   return 1;
end
---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
   self:loopStart1(event.unit)---MD1オーラ失敗時に動く
   return 1;
end

---MD1オーラ
function class:loopStart1(unit)
   if self.loopStart1FLG then
      self:setAura(unit)
   end
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)
   self:changeEffect(event.unit,"Kaigan_loop",true)
   if event.index == 3 then
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self.loopStart1FLG = true---オーラを出すためのフラグ
         self.isAura = true
         self.timer = 0
         self.isBeforeSkill = true
         self:addBuff(event.unit,self.BUFF_BOX_LIST)
         self:showMDTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
         for i,v in ipairs(self.kaiganBuffIconList.conds) do
            self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,v)
         end
      else
         event.unit:setNextAnimationName("skill3b")
         event.unit:setNextAnimationEffectName("2-skill3b")
         -- self:addBuff(event.unit,self.KAIGAN_BUFF_BOX_LIST)
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
      end
   end

   self:checkAnimation("skill" .. event.index)
   return 1
end

function class:setSurface(unit,surfaceBox)
   unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
   unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
   -- unit:setCutinVoice2(surfaceBox.VOICE);
   --unit:setCutinSE2(surfaceBox.SE);
end

function class:showMDTimer(unit,buffId)
   unit:createBattleStatusChangeTimeCount(3,1,"battle_kaigan_time_gray.png","battle_kaigan_time.png",0,"unit/battle_trans_skill/frame_kaigan.plist")
   unit:setTimerConditionId(buffId)
   unit:setBattleStatusTimerAutoInvisible(true)
end


--=====================================================================================================================
--状態異常系のパーツ
--=====================================================================================================================

function class:addBadStatus(unit,targetBuffBox)
   local targetList = self:findBadStatusTargets(unit);
   for k,v in pairs(targetList) do
      --不所持側に結果を伝えるための数値作成　
      local args = self:makeArgs(v._unit,v._time);

      --持ち主は同期いらんのでそのままかけちゃう
      self:parseArgs(args,targetBuffBox.BUFF_ID);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,self.CONDITION_RECEIVE_ID[targetBuffBox.BUFF_ID],args)
   end
end

--シキのスキル攻撃によってマーキングされているやつを探す
function class:findBadStatusTargets(unit)
   local result = {};
   for i=0,7 do
      local targetUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
      if targetUnit ~= nil then
         local cond = targetUnit:getTeamUnitCondition():findConditionWithID(self.MARKING_BUFF_ID);
         if cond ~= nil then
            if cond:getValue2() == unit:getIndex() then
               
               local targetTable = {_unit = targetUnit,_time = cond:getTime()};
               targetUnit:getTeamUnitCondition():removeCondition(cond);
               table.insert(result,targetTable);
            end
         end
      end
   end
   return result;
end



function class:makeArgs(targetUnit,time)
   --10000の位にターゲットとなった相手のインデックス
   local index = targetUnit:getIndex();

   --秒数を付け加える
   return index * 10000 + math.floor(time);
end


--もらった引数をもとにバフ掛けまでいっちゃう
function class:parseArgs(args,efid)
   local targetUnitIndex = math.floor(args/10000);
   local time = args%10000;
   local baseBuffBox = nil;

   --もらった効果IDのバフボックスを探すよ
   for k,v in pairs(self.BADSTATUS_BOX_LIST) do
      if v.BUFF_ID == efid then
         baseBuffBox = v;
      end
   end

   if baseBuffBox == nil then
      return;
   end

   --luaのテーブルは参照渡しなので元を汚さないように新規作成
   local newBuffBox = {
      ID = baseBuffBox.ID,
      BUFF_ID = baseBuffBox.BUFF_ID,
      VALUE = baseBuffBox.VALUE,
      DURATION = time,
      ICON = baseBuffBox.ICON,
      GROUP_ID = baseBuffBox.GROUP_ID,
      PRIORITY = baseBuffBox.PRIORITY
   }

   local targetUnit = megast.Battle:getInstance():getTeam(not self.gameUnit:getisPlayer()):getTeamUnit(targetUnitIndex);

   self:execAddBuff(targetUnit,newBuffBox);

end

function class:receive5(args)
   self:parseArgs(args.arg,90);--毒同期
   return 1
end

function class:receive6(args)
   self:parseArgs(args.arg,93);--暗闇同期
   return 1
end

function class:receive7(args)
   self:parseArgs(args.arg,97);--燃焼同期
   return 1
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
    self:addBuffSelector(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:addBuffSelector(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:addBuffSelector(unit,buffBox)
   end
end

function class:addBuffSelector(unit,buffBox)
   if buffBox.BUFF_TYPE == nil or buffBox.BUFF_TYPE == "mine" then
      self:execAddBuff(unit,buffBox)
   end

   if buffBox.BUFF_TYPE == "all" then
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
         if teamUnit ~= nil then
            self:addBuff(teamUnit,buffBox)
         end
      end
   end

   if buffBox.BUFF_TYPE == "other" then
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
         if teamUnit ~= nil and teamUnit ~= unit then
            self:addBuff(teamUnit,buffBox)
         end
      end
   end

end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;

    if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
      elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
         return;
      end
   end

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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end

function class:removeConditionAll(unit,buffId)
     while unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil do
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end

-- カイガンユニットについたバフアイコンを探したり変えたりする
function class:searchUnitEffect(unit,scriptidList,value1,afterIconID)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
     return 
  end

  for i = 0,(conditionSize - 1) do
      local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
      if cond == nil then
         return
      end
      for _,id in ipairs(scriptidList) do
         if cond:getScriptID() == id and cond:getValue1() == value1 then
            --初回起動時にデフォルトのアイコンIDを保存する
            if not self.kaiganBuffIconList.checked then
               self.isKilled = true
              table.insert(self.kaiganBuffIconList.conds,cond:getThumbnailID())
            end
            if afterIconID == 0 then
              self:switchBuffIcon(cond,afterIconID)        
            elseif afterIconID ~= nil and cond:getThumbnailID() == 0 then
              self:switchBuffIcon(cond,afterIconID)
              return
            end
         end
      end
  end
  if self.isKilled then
     self.kaiganBuffIconList.checked = true
  end
end

-- バフアイコン設定
function class:switchBuffIcon(cond,iconId)
   cond:setThumbnailID(iconId)
   megast.Battle:getInstance():updateConditionView()
end


class:publish();

return class;