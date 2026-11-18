local class = summoner.Bootstrap.createUnitClass({label="麻倉葉", version=1.9, id=107476112});


--------[[バフ]]--------
function class:setBuffBoxList(value)
    local BUFF_LIST = {
      ID = 107476112,
      BUFF_ID = 17, -- 物理ダメージ
      VALUE = 20 * value,
      DURATION = 15,
      ICON = 26,
      GROUP_ID = 1066,
      PRIORITY = 20 * value,
      SCRIPT = {
          SCRIPT_ID = 4
      }
    }
    return BUFF_LIST
end

function class:start(event)
    self.count = 0
    self.MAX = 6
    return 1
end

function class:run(event)
    if event.spineEvent == "skill2" then
        self.count = self.count >= self.MAX and self.MAX or self.count + 1
        for i = 0,6 do
            local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i)
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self:setBuffBoxList(self.count))
            end
        end
    end
    return 1
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
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    buff:setMaxConditionIconNumber(self.MAX)
    buff:setNumber(self.count)
    megast.Battle:getInstance():updateConditionView()
end
class:publish();

return class;