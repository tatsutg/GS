local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ワーグル", version=1.3, id=102455512});

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 1024555121,
         BUFF_ID = 13, -- 攻撃力
         VALUE = 3,
         DURATION = 9999,
         ICON = 3,
         COUNT = 1,
         COUNT_MAX = 10
      },
      [1] = {
         ID = 1024555122,
         BUFF_ID = 25, -- ブレイク
         VALUE = 3,
         DURATION = 9999,
         ICON = 9,
         COUNT = 1,
         COUNT_MAX = 10
      }
   }
end

function class:start(event)
   self:setBuffBoxList()
   self.buffValue = 3
   return 1
end

function class:takeSkill(event)
   if event.index == 1 then
      self:addBuff(event.unit,self.BUFF_BOX_LIST)
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
    -- 最後だけ60UP
    if buffBox.COUNT >= 10 then
       buffBox.VALUE = self.buffValue * 20
    end

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
            buffBox.VALUE = self.buffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end
end

class:publish();

return class;