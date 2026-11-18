local class = summoner.Bootstrap.createUnitClass({label="エリス", version=1.3, id=107545112});


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = -1,
        BUFF_ID = 17,   -- ダメージ
        VALUE = 80,
        DURATION = 10,
        ICON = 26
    }
end

function class:start()
    self:setBuffBoxList()
    self.MAX = 6
    self.count = 1
    return 1
end

function class:run(event)
    if event.spineEvent == "skill2" then
        self:execAddBuff(event.unit,self.BUFF_LIST)
    end
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION * self.count,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION * self.count,buffBox.ICON);
    end
    buff:setNumber(self.count)
    megast.Battle:getInstance():updateConditionView()

    self.count = self.count >= self.MAX and self.MAX or self.count + 1
end




class:publish();

return class;