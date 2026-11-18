local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒超シーリア", version=2.0, id=103767412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1035572120,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 30,
            ICON = 0
        },
        [2] = {
            ID = 1035572121,
            BUFF_ID = 17,
            VALUE = 30,
            DURATION = 99999,
            ICON = 26,
            MAX = 20
        },
        [3] = {
            ID = 1035572122,
            BUFF_ID = 142,
            VALUE = 0,
            DURATION = 99999,
            ICON = 229,
            GROUP_ID = 3615,
            PRIORITY = 0
        },
        [4] = {
            ID = 1035572123,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 231
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit
    self.orbitHpDefault = 1000
    if megast.Battle:getInstance():isPvp() then
        self.orbitHpDefault = 500
    end
    self.orbit = {}
    self.orbitHp = {}
    self.orbitDamageLv = {}
    for i = 1,4 do
        self.orbit[i] = nil
        self.orbitHp[i] = self.orbitHpDefault
        self.orbitDamageLv[i] = 1
    end
    self.beforeSummon = 1
    self.guardian = 1
    self.skill1FLG = false
    self.skill3FLG = false
    self.skill5FLG = false
    self.inWave = true
    return 1
end

function class:startWave(event)
    self.inWave = true
    return 1
end

function class:endWave(event)
    self.inWave = false
    self:allDead()
    return 1;
end

function class:allDead()
    for index = 1,4 do
        if self.orbit[index] ~= nil then
            self.orbitHp[index] = 0
            self.orbit[index]:takeAnimation(0,"S_dead",false)
            self.orbit[index] = nil
        end
    end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:allDead()
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:allDead()
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---真奥義→待機
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if self.skill3FLG and cond == nil then
        self.skill3FLG = false
        for index = 1,4 do
            if self.orbit[index] ~= nil then
                self.orbit[index]:getSkeleton():setOpacity(255)---透明化解除
                self.orbit[index]:takeAnimation(0,"S_in_d"..self.orbitDamageLv[index]-1,true)
            end
        end
    end
    if self.skill5FLG then
        self.skill5FLG = false
        local cond = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[3])
        cond:setRemoveOnResetState(true);
    end
    ---位置調整+数取得
    local count = 0
    for index = 1,4 do
        if self.orbit[index] ~= nil then
            count = count + 1
            if self.orbit[index]:getPositionX() > 350 then
                self.orbit[index]:setPositionX(350)
            elseif self.orbit[index]:getPositionX() < -350 then
                self.orbit[index]:setPositionX(-350)
            end
        end
    end
    local countStr = ""..count
    if event.unit:getParameter("376_Followers") ~= countStr then
        event.unit:setParameter("376_Followers",countStr);
        local cond = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
        cond:setNumber(count)
        megast.Battle:getInstance():updateConditionView();
    end
    --summoner.Utility.messageByEnemy(event.unit:getParameter("376_Followers"))
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    ---待機処理
    if event.spineEvent == "idle" then
        for index = 1,4 do
            if event.unit == self.orbit[index] then
                event.unit:takeAnimation(0,"S_idle_d"..self.orbitDamageLv[index]-1,true)
            end
        end
    end
    ---スキル→待機
    if event.spineEvent == "idle_skill1" then
        event.unit:takeAnimation(0,"S_idle_d0",true)
        event.unit:setPositionX(event.unit:getPositionX() - (281*event.unit:getFlip()))
    end

    ---スキル召喚
    if event.spineEvent == "skill1summon" then
        if self.inWave and self:isHost() then
            local index = self:summonCheck()
            if self.orbit[index] ~= nil then
                ---削除
                self.orbit[index]:takeAnimation(0,"S_dead",false)
            end
            self.orbit[index] = event.unit:addOrbitSystem("S_skill1",0);
            local x = self.orbit[index]:getPositionX();
            local y = self.orbit[index]:getPositionY();
            self.orbit[index]:setPosition((x + math.random(-50,50)),(y + math.random(-50,50)))
            self.orbit[index]:takeAnimation(0,"S_skill1",true)
            self.orbitHp[index] = self.orbitHpDefault
            self.orbitDamageLv[index] = 1
            self.beforeSummon = index
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1)
        end
    end
    ---真奥義召喚
    if event.spineEvent == "skill3summon" then
        if self.inWave and self:isHost() then
            for index = 1,4 do
                if self.orbit[index] ~= nil then
                    ---削除
                    self.orbit[index]:takeAnimation(0,"S_dead",false)
                end
                ---眷属召喚
                self.orbit[index] = event.unit:addOrbitSystem("S_idle_d0",0);
                self.orbit[index]:setOrbitType(4)
                self.orbit[index]:takeAnimation(0,"S_idle_d0",true)
                self:skill3SetPosition(index)
                self.orbit[index]:getSkeleton():setOpacity(0)---透明化
                self.orbitHp[index] = self.orbitHpDefault
                self.orbitDamageLv[index] = 1
                self.beforeSummon = index
            end
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,1)
        end
    end
    if event.spineEvent == "Library_skill5_sky" then
        event.unit:addOrbitSystem("skill5_sky");
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

function class:receive1(args)
    local index = self:summonCheck()
    if self.orbit[index] ~= nil then
        ---削除
        self.orbit[index]:takeAnimation(0,"S_dead",false)
    end
    self.orbit[index] = self.gameUnit:addOrbitSystem("S_skill1",0);
    self.orbit[index]:setOrbitType(4)
    self.orbit[index]:takeAnimation(0,"S_skill1",true)
    self.orbitHp[index] = self.orbitHpDefault
    self.orbitDamageLv[index] = 1
    self.beforeSummon = index
    return 1;
end

function class:receive2(args)
    for index = 1,4 do
        if self.orbit[index] ~= nil then
            ---削除
            self.orbit[index]:takeAnimation(0,"S_dead",false)
        end
        ---眷属召喚
        self.orbit[index] = self.gameUnit:addOrbitSystem("S_idle_d0",0);
        self.orbit[index]:setOrbitType(4)
        self.orbit[index]:takeAnimation(0,"S_idle_d0",true)
        self:skill3SetPosition(index)
        self.orbit[index]:getSkeleton():setOpacity(0)---透明化
        self.orbitHp[index] = self.orbitHpDefault
        self.orbitDamageLv[index] = 1
        self.beforeSummon = index
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skill1FLG = true
    elseif event.index == 3 then
        self.skill3FLG = true
        local cond = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        cond:setRemoveOnResetState(true);
    elseif event.index == 5 then
        self.skill3FLG = false
        event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
        local count = 0
        for index = 1,4 do
            if self.orbit[index] ~= nil then
                count = count + 1
                self.orbitHp[index] = 0
                self.orbit[index]:takeAnimation(0,"S_skill5_d"..self.orbitDamageLv[index]-1,false)
                self.orbit[index] = nil
                self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
            end
        end
        if count ~= 0 then
            self.skill5FLG = true
            self.BUFF_BOX_LIST[3].VALUE = 20 * count
            self.BUFF_BOX_LIST[3].PRIORITY = 20 * count
        end
    end
    return 1
end

function class:skill3SetPosition(index)
    if self.orbit[index] ~= nil then
        if index == 1 then
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() - (235*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 32)
        elseif index == 2 then
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() - (153*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 19)
        elseif index == 3 then
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() + (47*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 19)
        else
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() + (132*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 32)
        end
    end
end

function class:summonCheck()
    local index = 1
    ---空いている場所がある場合はそれを返す
    for i = 1,4 do
        if self.orbit[i] == nil then
            return i
        end
    end
    ---ダメージを受けているオービットがいる場合はそれを返す
    for i = 1,4 do
        if self.orbitHp[i] < self.orbitHpDefault then
            return i
        end
    end
    ---誰もダメージを受けてもいない場合は次の位置を返す
    index = self.beforeSummon + 1
    if index > 4 then
        index = 1
    end
    return index
end

function class:guardianCheck()
    ---ダメージを受けているオービットがいる場合はそれを返す
    for i = 1,4 do
        if self.orbitHp[i] < self.orbitHpDefault and self.orbit[i] ~= nil and self.orbitHp[i] > 0 then
            return i
        end
    end
    ---オービットがいる場合は適当に返す
    for i = 1,4 do
        if self.orbit[i] ~= nil and self.orbitHp[i] > 0 then
            return i
        end
    end
    ---いない場合は0を返す
    return 0
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local saveDamage = 0
    local barrier = event.unit:getTeamUnitCondition():findConditionWithType(98)
    if barrier ~= nil then
        if barrier:getValue() >= event.value then
            ---バリアHPがダメージより多い場合はそのまま返す
            return event.value
        else
            ---バリアHPがダメージより低い場合はバリアHP分だけ眷属処理からスキップさせる
            saveDamage = barrier:getValue()
            event.value = event.value - saveDamage
        end
    end
    local count = 0
    while event.value > 0 and self:guardianCheck() > 0 and count < 4 do
        count = count + 1
        local index = self:guardianCheck()
        self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() + (3*event.unit:getFlip()))
        self.orbitHp[index] = self.orbitHp[index] - event.value
        if self.orbitHp[index] <= 0 then
            event.value = self.orbitHp[index] * -1
            ---死亡処理
            self.orbitHp[index] = 0
            if self:isHost() then
                self.orbit[index]:takeAnimation(0,"S_dead",false)
                self.orbit[index] = nil
                self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
                megast.Battle:getInstance():sendEventToLua(self.scriptID,3,index)
            end
        else
            event.value = 0
            if self.orbitDamageLv[index] == 1 and self.orbitHp[index] < (self.orbitHpDefault * 2/3) then
                self.orbit[index]:takeAnimation(0,"S_damage_1",false)
                self.orbitDamageLv[index] = 2
            elseif self.orbitDamageLv[index] == 2 and self.orbitHp[index] < (self.orbitHpDefault * 1/3) then
                self.orbit[index]:takeAnimation(0,"S_damage_2",false)
                self.orbitDamageLv[index] = 3
            end
        end
    end
    local finalDamage = event.value + saveDamage
    return finalDamage
end

function class:receive3(args)
    if self.orbit[args.arg] ~= nil then
        self.orbit[args.arg]:takeAnimation(0,"S_dead",false)
        self.orbit[args.arg] = nil
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
    end
    return 1;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    return buff
end

class:publish();

return class;