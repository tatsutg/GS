local class = summoner.Bootstrap.createUnitClass({label="てんぷれさん", version=1.5, id=00000000});


class.WIND_ARTS_DAMAGE = 260;
class.WIND_ARTS_BREAK = 3000;

class.CRI_BUFF = {
   ID = 101381,
   BUFF_ID = 22,
   VALUE = 100,
   DURATION = 20,
   ICON = 11
}

class.PT_BUFF = {
   ID = 101382,
   BUFF_ID = 17,
   VALUE = 100,
   DURATION = 20,
   ICON = 26
}

class.MODE_BUFF0 = {
    ID = 101383,
    BUFF_ID = 7,
    VALUE = 300,
    DURATION = 9999,
    ICON = 205
}

class.MODE_BUFF1 = {
    ID = 101383,
    BUFF_ID = 10,
    VALUE = 3,
    DURATION = 9999,
    ICON = 206
}

class.ICON_BUFF1 = {
    ID = 0,
    BUFF_ID = 0,
    VALUE = 1,
    DURATION = 10,
    ICON = 327
}

class.ICON_BUFF2 = {
    ID = 0,
    BUFF_ID = 0,
    VALUE = 1,
    DURATION = 10,
    ICON = 328
}

function class:start(event)
    self.gameUnit = event.unit;
    self.isBacume = false;
    self.BacumeUnits = {};
    self.bacumeSpeed = 10;
    self.mode = 0;
    event.unit:setParameter("138_WaterTree",""..self.mode)
    self.skill2FLG = false

    return 1;
end

function class:startWave(event)
    --self:execAddBuff(event.unit,self["MODE_BUFF"..self.mode]);
    return 1;
end

function class:takeIdle(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("idle_earth");
    end
    return 1;
end

function class:takeFront(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("front_earth");
    end
    return 1;
end

function class:takeBack(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("back_earth");
    end

    return 1;
end

function class:takeAttack(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("attack"..event.index.."_earth");
        event.unit:setNextAnimationEffectName("attack"..event.index.."_earth");
    end
    event.unit:setDamageRateOffset(1);

    return 1;
end

function class:takeSkill(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("skill"..event.index.."_earth");
        event.unit:setNextAnimationEffectName("skill"..event.index.."_earth");
    end
    event.unit:setDamageRateOffset(1);

    if event.index ==2 then
        self.skill2FLG = true
    end
    if event.index ==3 then
        self.skill2FLG = false
    end

    return 1;
end

function class:run(event)
    if event.spineEvent == "Suction" then return self:Suction(event.unit) end
    if event.spineEvent == "SuctionEnd" then return self:SuctionEnd(event.unit) end
    if event.spineEvent == "setElement" then return self:setElement(event.unit) end
    if event.spineEvent == "dualElement" then 
        if self:isController(event.unit) then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.mode);
            self:modeChange(event.unit,self.mode);
        end
    end

    if event.spineEvent == "addBuff" then 
        if self:isController(event.unit) then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
            self:execSkill3Buff(event.unit);
        end
    end
    if event.spineEvent == "damageRate" then 
        event.unit:setDamageRateOffset(0.5);
    end

    if event.spineEvent == "waterfall" then
        local orb = event.unit:addOrbitSystem("waterfall",0)
        event.unit:setDamageRateOffset(0.5);
        orb:setDamageRateOffset(0.5);
    end
    return 1;
end

function class:attackElementRate(event)
    local skillType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if skillType ~= 2 then
        return event.value;
    end

    local skill = event.unit:getActiveBattleSkill();

    if skill == nil or skill:isBurst2() then
        return event.value;
    end

    local el = event.enemy:getElementType();
    if el == kElementType_Aqua then
        event.value = megast.Battle:getInstance():getElementalRate(3,2) + 0.3;
    end
    if el == kElementType_Fire then
        event.value = megast.Battle:getInstance():getElementalRate(2,1) + 0.3;
    end
    return event.value;
end


--version1.1
function class:update(event)
    --吸引中ならアップデートで吸引する
    if self.isBacume then
        for i = 1,table.maxn(self.BacumeUnits) do

            local targetUnit = megast.Battle:getInstance():getTeam(not event.unit:getisPlayer()):getTeamUnit(self.BacumeUnits[i]);
            if targetUnit ~= nil then
                local targetx = targetUnit:getPositionX();
                local thisx = event.unit:getPositionX();
                local distance = thisx - targetx;
                local oneFrame = 0.016666666;
                local moveSpeed = self.bacumeSpeed * event.deltaTime/oneFrame; --フレームレートで吸引距離が変わらないようにするためdeltaを60fpsで割って掛け算
                
                
                local sign = 1; --距離が＋かーか。１か−１になる
                if distance < 0 then
                    sign = -1;
                end
                
                
                targetUnit:setPosition(targetx + moveSpeed * sign,targetUnit:getPositionY());
                
            end
        end
    end
    if self.skill2FLG then
        self.skill2FLG = false
        self:execAddBuff(event.unit,self.ICON_BUFF1):setRemoveOnResetState(true);
        self:execAddBuff(event.unit,self.ICON_BUFF2):setRemoveOnResetState(true);
    end
    return 1;
end

function class:attackDamageValue(event)
    event.value = event.value - event.value * (event.enemy:getTeamUnitCondition():findConditionValue(63) / 100);
    return event.value;
end

function class:takeDamage(event)
    self:SuctionEnd(event.unit);
    if self.mode == 1 then
        event.unit:setNextAnimationName("damage_earth");
    end
    return 1;
end

--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return;
            end
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        if buffBox.BUFF_ID == 7 then
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,self.gameUnit,buffBox.ICON,buffBox.EFFECT);
        else
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
        end
    else
        if buffBox.BUFF_ID == 7 then
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,self.gameUnit,buffBox.ICON);
        else
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
        end
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
    return buff;
end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       newCond:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
end


function class:Suction(unit)

    print("吸引開始");
    self.isBacume = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if uni ~= nil then
            print("target is not nil");
            table.insert(self.BacumeUnits,i);
        end
    end
    return 1;
end

function class:SuctionEnd(unit)
    self.isBacume = false;
    self.BacumeUnits = {};
    return 1;
end

function class:setElement(unit)
    unit:setElementType(kElementType_Earth);
    return 1;
end

function class:modeChange(unit,mode)
    self.mode = mode; --マルチ同期用　明示的にここでセットし直してずれてても安心にする
    unit:setParameter("138_WaterTree",""..self.mode)
    if self.skill3DamageRate == nil then
        self.skill3DamageRate = unit:getBurstSkill2():getDamageRate();
        self.skill3BreakRate = unit:getBurstSkill2():getBreakValue();
    end

    if self.mode == 1 then
        self.mode = 0;
        unit:setParameter("138_WaterTree",""..self.mode)
        unit:getBurstSkill2():setDamageRate(self.skill3DamageRate);
        unit:getBurstSkill2():setBreakValue(self.skill3BreakRate);
        unit:getBurstSkill2():setElementType(2);
    else
        self.mode = 1;
        unit:setParameter("138_WaterTree",""..self.mode)
        unit:getBurstSkill2():setDamageRate(self.WIND_ARTS_DAMAGE);
        unit:getBurstSkill2():setBreakValue(self.WIND_ARTS_BREAK);
        unit:getBurstSkill2():setElementType(3);
    end

    self:execAddBuff(unit,self["MODE_BUFF"..self.mode]);
end

function class:execSkill3Buff(unit)
    self:execAddBuff(unit,self.CRI_BUFF);
    for i=0,7 do
        local tgt = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
        if tgt ~= nil and tgt:getElementType() == 2 then
            self:execAddBuff(tgt,self.PT_BUFF);
        end
    end
end

function class:receive1(args)
   self:modeChange(self.gameUnit,args.arg);
   return 1
end

function class:receive2(args)
   self:execSkill3Buff(self.gameUnit);
   return 1
end

function class:isController(unit)
   local isHost = megast.Battle:getInstance():isHost();
   local isPlayer = unit:getisPlayer();

   if unit:isMyunit() or not isPlayer and isHost then
      return true;
   end   
   return false;
end

class:publish();

return class;