local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="リヴィエラ", version=1.3, id=102495312});

function class:setBuffBoxList()
   self.OUGI_BUFF_BOX_LIST = {
      [0] = {
         ID = 1024963125,
         BUFF_ID = 22, -- クリティカル
         VALUE = 10,
         DURATION = 9999,
         ICON = 11,
         COUNT = 1,
         COUNT_MAX = 5
      }
   }
end

function class:checkParametor(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end

function class:startDash(unit)
    unit:addSPWithPvpCorrection(self.SP_VALUE);
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
   self.timer = 0
   self.ougiBuffValue = 10
   self:setBuffBoxList()

   self.SP_VALUE = 100
   if megast.Battle:getInstance():getBattleState() == kBattleState_active and not megast.Battle:getInstance():isPvp() then
      if not self:checkParametor(event.unit,"startDash") then
         self:startDash(event.unit);
         event.unit:setParameter("startDash","TRUE");
      end
   end
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if not megast.Battle:getInstance():isPvp() then
        event.unit:setParameter("startDash","TRUE");
        self:startDash(event.unit);
    end
   return 1;
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if event.index == 2 then
      self:addBuff(event.unit,self.OUGI_BUFF_BOX_LIST)
   end
   return 1
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

class:publish();

return class;
