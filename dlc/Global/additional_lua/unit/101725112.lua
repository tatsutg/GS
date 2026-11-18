--[[
    ミレニア
]]

local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    local DEBUG = true
    local LOG_LABEL = ""
    local log = function(str, ...) print((("Lua(%s): "):format(LOG_LABEL) .. str):format(...)) end
    local debug = function(...) if DEBUG then log(...) end end

    log("Called `new` with `%s`", id)

    local returnOne = function() return 1 end
    local returnDamage = function(self, unit, enemy, value) return value end
    local cls = {
        param = {
            version = 1.3,
            isUpdate = true
        },

        --====================================================================================================
        --メンバ変数的なものはここで定義する
        --====================================================================================================
        gameUnit = nil,
        uniqueID = id,
        skillUsedUnit = nil,
        recastState = 0,

        unitSkillStates = {},

        unitSkillState = {
            new = function(_index,_isSkill)
                local table = {
                    unit = function(this,team)
                        return team:getTeamUnit(this.index);
                    end,
                    index = _index,
                    isSkill = _isSkill
                };
                return table;
            end
        },

        --====================================================================================================
        --定数的なものはここで定義する。全て大文字のスネーク記法で
        --====================================================================================================
        DODGE_BUFF_ID = 101721,
        DODGE_BUFF_EFFECT_ID = 31,
        DODGE_BUFF_VALUE = 20,
        DODGE_BUFF_DURATION = 8,
        DODGE_BUFF_ICON = 16,

        CRITICAL_BUFF_ID = 101722,
        CRITICAL_BUFF_EFFECT_ID = 22,
        CRITICAL_BUFF_VALUE = 10,
        CRITICAL_BUFF_DURATION = 9999,
        CRITICAL_BUFF_ICON = 11,

        SKILL_BUFF_ID = 101723,
        SKILL_BUFF_EFFECT_ID = 0,
        SKILL_BUFF_VALUE = 1,
        SKILL_BUFF_DURATION = 9999,
        SKILL_BUFF_ICON = 30


        
    }

    -- デフォルトのイベントハンドラに関数を割り当てる
    for i, name in ipairs({
        "receive1",
        "start", "update", "dead", "run",
        "startWave", "endWave",
        "excuteAction",
        "takeIdle", "takeFront", "takeDamage", "takeBack", "takeBreake", "takeAttack", "takeSkill"
    }) do
        cls[name] = returnOne
    end
    for i, name in ipairs({"attackDamageValue","takeDamageValue" ,"takeBreakeDamageValue"}) do
        cls[name] = returnDamage
    end

    function cls:start(unit)
        self.gameUnit = unit;
        self.skillRecastFlg = false;
        return 1;
    end

    function cls:startWave(unit)
        
        return 1;
    end

    function cls:takeSkill(unit,index)
        if index == 1 then
            self:runDodgeBuff(unit);
            if self.recastState == 0 then
                self.recastState = 1;
            end

            if self.recastState == 2 then
                self.recastState = 0;
            end
        end

        return 1;
    end

    function cls:excuteAction(unit)
        local isControll = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
        if isControll and self.recastState < 2 then
            self:showIcon(unit);
            self:sendEvent(4,0);
        end
        return 1;
    end


    function cls:update(unit,deltaTime)
        
        
        if table.maxn(self.unitSkillStates) == 0 then
            self:initUnitSkillStates();
        end
        for i=1,table.maxn(self.unitSkillStates) do
            if self.unitSkillStates[i]:unit(self.gameUnit:getTeam()) ~= nil then
                if self.unitSkillStates[i]:unit(self.gameUnit:getTeam()):getUnitState() == kUnitState_skill then
                    if not self.unitSkillStates[i].isSkill then
                        
                        self.unitSkillStates[i].isSkill = true;

                        --自分自身はこの時点ではターゲットに含めない
                        --ミレニア本人がスキルを撃った直後にスキル使用判定を行うと最後にスキルを使った人が常にミレニア扱いとなり他のキャラにバフがかけられないため。
                        --代わりにrunDodgeBuffの中でバフをかけた後に使用判定を入れている
                        if self.unitSkillStates[i]:unit(self.gameUnit:getTeam()) ~= self.gameUnit then
                            self.skillUsedUnit = self.unitSkillStates[i].index;
                        end
                    end
                else
                    self.unitSkillStates[i].isSkill = false;
                end
            end
        end
        return 1;
    end

    function cls:initUnitSkillStates()
        for i = 0,7 do
            
            local teamUnit = self.gameUnit:getTeam():getTeamUnit(i);
            
            if teamUnit ~= nil then
                local skillState = self.unitSkillState.new(teamUnit:getIndex(),false);
                table.insert(self.unitSkillStates,skillState);
            end
        end
    end

    function cls:runDodgeBuff(unit)
        
        local isControll = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
        if self.skillUsedUnit ~= nil and isControll then
            local targetIndex = self.skillUsedUnit;
            self:addDodgeBuff(targetIndex);
            self:sendEvent(1,targetIndex);
        end


        --ミレニア本人がスキルを撃った直後にスキル使用判定を行うと最後にスキルを使った人が常にミレニア扱いとなり他のキャラにバフがかけられない。なのでバフをかけた後に使用判定を入れる
        self.skillUsedUnit = unit:getIndex();
        return 1;
    end

    function cls:runCriticalBuff(unit)
        local isControll = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
        if not isControll then
            return 1;
        end

        self:addCriticalBuff();
        self:sendEvent(2,0);
       
        return 1;
    end

    function cls:runSkillRecast(unit)
        local isControll = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
        if not isControll then
            return 1;
        end
        if self.recastState == 1 then
            self.recastState = 2;
            self:skillRecast(unit);
            self:sendEvent(3,0);
        end
        
        return 1;
    end

    function cls:addDodgeBuff(unitIndex)
        local targetUnit = self.gameUnit:getTeam():getTeamUnit(unitIndex);
        if targetUnit ~= nil then
            targetUnit:getTeamUnitCondition():addCondition(self.DODGE_BUFF_ID,self.DODGE_BUFF_EFFECT_ID,self.DODGE_BUFF_VALUE,self.DODGE_BUFF_DURATION,self.DODGE_BUFF_ICON);
            targetUnit:playSummary(summoner.Text:fetchByUnitID(101725112).text1,true);
        end
        return 1;
    end

    function cls:addCriticalBuff()
        for i = 0,7 do
            local teamUnit = self.gameUnit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                local buff = teamUnit:getTeamUnitCondition():findConditionWithID(self.CRITICAL_BUFF_ID);
                local buffValue = 0;
                if buff ~= nil then
                     buffValue = buff:getValue();
                end

                if buffValue >= 60 then
                    teamUnit:playSummary((summoner.Text:fetchByUnitID(101725112).text2):format(buffValue).."％",true);
                    
                else

                    teamUnit:playSummary((summoner.Text:fetchByUnitID(101724112).text2):format(buffValue + self.CRITICAL_BUFF_VALUE).."％",true);
                    local nextValue = buffValue + self.CRITICAL_BUFF_VALUE;
                    buff = teamUnit:getTeamUnitCondition():addCondition(self.CRITICAL_BUFF_ID,self.CRITICAL_BUFF_EFFECT_ID,nextValue,self.CRITICAL_BUFF_DURATION,self.CRITICAL_BUFF_ICON);
                    buff:setScriptID(37);
                    if nextValue < 60 then
                        buff:setNumber(nextValue/10);
                    else
                        buff:setNumber(10);
                    end
                end
            end
        end
        megast.Battle:getInstance():updateConditionView();
        return 1;
    end

    function cls:skillRecast(unit)
        unit:setSkillCoolTime(0);
        unit:playSummary(summoner.Text:fetchByUnitID(101725112).text3,true);
        local buff = unit:getTeamUnitCondition():findConditionWithID(self.SKILL_BUFF_ID);
            
        if buff ~= nil then
            unit:getTeamUnitCondition():removeCondition(buff);
        end
        return 1;
    end

    function cls:showIcon(unit)
        unit:getTeamUnitCondition():addCondition(self.SKILL_BUFF_ID,self.SKILL_BUFF_EFFECT_ID,self.SKILL_BUFF_VALUE,self.SKILL_BUFF_DURATION,self.SKILL_BUFF_ICON);
        
        return 1;
    end

    function cls:run(unit,str)
        -- if str == "runDodgeBuff" then
        --     self:runDodgeBuff(unit);
        -- end
        if str == "runCriticalBuff" then
            self:runCriticalBuff(unit);
        end

        if str == "runSkillRecast" then
            self:runSkillRecast(unit);
        end

        return 1;
    end
    
    function cls:receive1(intparam)
        self:addDodgeBuff(intparam);
        return 1;
    end

    function cls:receive2(intparam)
        self:addCriticalBuff();
        return 1;
    end

    function cls:receive3(intparam)
        self:skillRecast(self.gameUnit);
        return 1;
    end

    function cls:receive4(intparam)
        self:showIcon(self.gameUnit);
        return 1;
    end

    function cls:sendEvent(index,intparam)
        megast.Battle:getInstance():sendEventToLua(self.uniqueID,index,intparam);
    end


    register.regist(cls, id, cls.param.version)
    return 1
end

