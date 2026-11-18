local class = summoner.Bootstrap.createUnitClass({label="アンジェラス", version=2.0, id=103066112});


function class:start(event)
    self.dragonFire = self:createNewDragonFireClass();
    self.dragonFire:init(event,self);
    return 1;
end

function class:run(event)
    self.dragonFire:run(event);
    return 1;
end

function class:update(event)
    self.dragonFire:update(event);

    return 1;
end

function class:takeSkill(event)
    self.dragonFire:takeSkill(event);
    return 1;
end

function class:endWave(event)
    self.dragonFire:waveEnd(event);
    return 1;
end

function class:dead(event)
    self.dragonFire:dead(event);
    return 1;
end

function class:changeOut(event)
    self.dragonFire:dead(event);
    return 1;
end

function class:receive1(args)
   self.dragonFire:receive1(args);
   return 1
end
function class:receive2(args)
   self.dragonFire:receive2(args);
   return 1
end
function class:receive3(args)
   self.dragonFire:receive3(args);
   return 1
end

function class:receive4(args)
   self.dragonFire:receive4(args);
   return 1
end

function class:receive5(args)
   self.dragonFire:receive5(args);
   return 1
end

function class:receive6(args)
   self.dragonFire:receive6(args);
   return 1
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
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
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

--==========================================================================================================================
--龍炎クラス
--==========================================================================================================================
--宣言


--コンストラクタ的な　dragonFireClassそのものを使わないでね！　奴は定義用の箱なんだ。こいつを叩いて、複製して使ってね！
function class:createNewDragonFireClass()
    local newDragonFireClass = {};
    for k,v in pairs(self.dragonFireClass) do
        newDragonFireClass[k] = v
        --summoner.Utility.messageByEnemy(k);
    end

    return newDragonFireClass;
end


class.dragonFireClass = {};
class.dragonFireClass.MAX_CNT = 8;
class.dragonFireClass.DURATION = 60;
class.dragonFireClass.DRAGON_BUFF_VALUE = -5;


class.dragonFireClass.ICON_BUFF = {
   ID = 1030601,
   BUFF_ID = 0,
   VALUE = 1,
   DURATION = 9999,
   ICON = 202,
   NUMBER = 0,
   MAX = 8
}

--==========================================================================================================================
--接続部

function class.dragonFireClass:init(event,_class)
    self.fireTables = {};
    self.parentGameUnit = event.unit;
    self.parent = _class;
    self.fireTotalCnt = 0;
    self.fullArtsBaseDamage = event.unit:getBurstSkill2():getDamageRate();
    self.dragonBuffLevel = 0;
    self.gameUnit = event.unit
    self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
    self.buffCheckTimer = 0;
end

function class.dragonFireClass:run(event)
    if event.spineEvent == "addFireSkill1" then self:addDragonFire(event.unit,1) end
    if event.spineEvent == "addFireSkill21" then self:addDragonFire(event.unit,21) end
    if event.spineEvent == "addFireSkill22" then self:addDragonFire(event.unit,22) end
    if event.spineEvent == "addFireSkill23" then self:addDragonFire(event.unit,23) end
    if event.spineEvent == "fireStateEnd" then self:endState(event.unit) end
    if event.spineEvent == "fireRelease" then self:releaseAll() end
end

function class.dragonFireClass:checkSkillAnimation(event)
    if event.index ~= 3 then
       return;
    end
    local cnt = table.maxn(self.fireTables)
    if cnt > 0 then
       self:changeSkillAnimation(cnt);
    end
end

function class.dragonFireClass:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    if self.parent:isController(self.parentGameUnit) then
        self:countDown(event.deltaTime);
    end
    self:checkDragonBuff(event.deltaTime);
end

function class.dragonFireClass:takeSkill(event)
    self:checkSkillAnimation(event);
    local burstSkill = self.parentGameUnit:getBurstSkill2();
    if burstSkill == nil then
        return;
    end
    burstSkill:setDamageRate(self.fullArtsBaseDamage);
end

function class.dragonFireClass:waveEnd(event)
    self:resetAll();
end

function class.dragonFireClass:dead(event)
    self:resetAll();
    megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,6,0);
end

function class.dragonFireClass:receive1(args)
    local hash = args.arg;
    local fireType = math.floor(hash/100)
    local count = hash%100;

    self:innnerAddDragonFire(self.parentGameUnit,fireType,count);

end

function class.dragonFireClass:receive2(args)
    self:release(args.arg);
end

function class.dragonFireClass:receive3(args)
    self:remove(args.arg);
end

function class.dragonFireClass:receive4(args)
    self.dragonBuffLevel = args.arg;
    self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
    self:addDragonBuff(args.arg);
end

function class.dragonFireClass:receive5(args)
    self:fullBurst(args.arg);
end

function class.dragonFireClass:receive6(args)
    self:resetAll();
end
--==========================================================================================================================
--実装部


--所持者のみが通る場所ここから

function class.dragonFireClass:addDragonFire(unit,fireType)
    if not self.parent:isController(self.parentGameUnit) then
        return;
    end

    self:innnerAddDragonFire(unit,fireType,self.fireTotalCnt);
    
    local hash = fireType * 100 + self.fireTotalCnt;
    megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,1,hash);

    self.fireTotalCnt = self.fireTotalCnt + 1;


    self:checkOld();

    local buffLevel = table.maxn(self.fireTables);    
    megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,buffLevel);
    self.dragonBuffLevel = buffLevel;
    self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
    self:addDragonBuff(buffLevel);
end


function class.dragonFireClass:checkOld()
    if not self.parent:isController(self.parentGameUnit) then
        return;
    end
    local targetID = -1;
    if table.maxn(self.fireTables) > self.MAX_CNT then
        targetID = self:sarchOldestFire().id;
    end
    if targetID > -1 then
        
        self:release(targetID);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,2,targetID);

        local buffLevel = table.maxn(self.fireTables);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,buffLevel);
        self.dragonBuffLevel = buffLevel;
        self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
        self:addDragonBuff(buffLevel);
    end
end

function class.dragonFireClass:countDown(deltaTime)
    
    if not self.parent:isController(self.parentGameUnit) then
        return;
    end

    for i,v in pairs(self.fireTables) do
        v.timer = v.timer + deltaTime;
        if v.timer > self.DURATION then
            megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,3,v.id);
            self:remove(v.id);

            local buffLevel = table.maxn(self.fireTables);
            megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,buffLevel);
            self.dragonBuffLevel = buffLevel;
            self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
            self:addDragonBuff(buffLevel);
        end
    end
end

function class.dragonFireClass:releaseAll()
    if not self.parent:isController(self.parentGameUnit) then
        return;
    end

    local buffLevel = table.maxn(self.fireTables);

    megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,5,buffLevel);
    self:fullBurst(buffLevel);
    
end

function class.dragonFireClass:sarchOldestFire()
    local target = nil;
    local index = 999;
    for i,v in pairs(self.fireTables) do
        if v.id < index then
            target = v;
            index = v.id;
        end
    end

    return target;
end

--所持者のみが通る場所ここまで

function class.dragonFireClass:checkDragonBuff(deltaTime)
    self.buffCheckTimer = self.buffCheckTimer + deltaTime;
    if self.buffCheckTimer > 1 then
        self.buffCheckTimer = self.buffCheckTimer - 1;
        self:addDragonBuff(self.dragonBuffLevel);
    end
end

function class.dragonFireClass:innnerAddDragonFire(unit,fireType,count)

    local chaseBone = "";

    if fireType == 1 then
        chaseBone = "ef_graund_wave_A_red";
    end

    if fireType == 21 then
        chaseBone = "ef_graund_wave_A_red";
    end

    if fireType == 22 then
        chaseBone = "ef_graund_wave_A_red2";
    end

    if fireType == 23 then
        chaseBone = "ef_graund_wave_A_red3";
    end

    local x = self.parentGameUnit:getPositionX();
    local y = self.parentGameUnit:getPositionY();
    local xb = self.parentGameUnit:getSkeleton():getBoneWorldPositionX(chaseBone);
    local yb = self.parentGameUnit:getSkeleton():getBoneWorldPositionY(chaseBone);

    local totalX = x + xb;
    local totalY = y + yb;


    totalX = self.parentGameUnit:getisPlayer() and totalX or totalX * -1;

    totalX = math.floor(totalX);
    totalY = math.floor(totalY);

    -- summoner.Utility.messageByEnemy(xb);
    
    local fire = self:createDragonFire(unit,totalX,totalY,count);
    
    table.insert(self.fireTables,fire);

end


function class.dragonFireClass:createDragonFire(unit,positionX,positionY,uniqueID)
    local newDragonFire = {
        orbit = nil,
        state = 0,
        id = uniqueID,
        timer = 0
    }
    newDragonFire.orbit = unit:addOrbitSystem("fire_in",0);
    newDragonFire.orbit:setOrbitType(4)
    newDragonFire.orbit:takeAnimation(0,"fire_in",true);
    newDragonFire.orbit:setPosition(positionX,positionY);
    newDragonFire.orbit:setActiveSkill(1);
    newDragonFire.orbit:setDamageRateOffset(7/self.parentGameUnit:getBurstSkill():getDamageRate());
    newDragonFire.orbit:setBreakRateOffset(0);
    newDragonFire.orbit:setSkillEffectEnabled(false);
    if unit:getTeamUnitCondition():findConditionWithID(50235000) ~= nil then
        newDragonFire.timer = - 10;
    end

    -- newDragonFire.orbit:getActiveBattkeSkill():setAttributeType(2);
    return newDragonFire;
end



function class.dragonFireClass:endState(orbit)
    local target = nil;
    for i,v in pairs(self.fireTables) do
        if v.orbit == orbit then
            target = v;
        end
    end

    if target.state == 0 then
        target.orbit:takeAnimation(0,"fire_loop",true);
    end
end



function class.dragonFireClass:remove(id)
    local target = nil;
    local targetIndex = 0;
    for i,v in pairs(self.fireTables) do
        if v.id == id then
            target = v;
            targetIndex = i;
            self:execRemove(target);
        end
    end

    table.remove(self.fireTables,targetIndex)
    
end

function class.dragonFireClass:release(id)
    local target = nil;
    local targetIndex = 0;
    for i,v in pairs(self.fireTables) do
        if v.id == id then
            target = v;
            targetIndex = i;
            self:execRelease(target);
        end
    end

    table.remove(self.fireTables,targetIndex)
    local buffLevel = table.maxn(self.fireTables);
    if self.parent:isController(self.parentGameUnit) then
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,buffLevel);
        self.dragonBuffLevel = buffLevel;
        self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
        self:addDragonBuff(buffLevel);
    end
end

function class.dragonFireClass:execRelease(fire)
    fire.orbit:takeAnimation(0,"fire_end2",false);
end

function class.dragonFireClass:execFullRelease(fire)
    fire.orbit:takeAnimation(0,"fire_end",false);
end

function class.dragonFireClass:execRemove(fire)
    fire.orbit:takeAnimation(0,"fire_remove",false);
end


function class.dragonFireClass:fullBurst(level)
    level = level > 8 and 8 or level;
    self.dragonBuffLevel = 0;
    self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
    self:addDragonBuff(0);
    local buffTable = {
       ID = 1030610 + self.parentGameUnit:getIndex(),
       BUFF_ID = 61,
       VALUE = self.DRAGON_BUFF_VALUE * level,
       DURATION = 8,
       ICON = 43
    }
    for i=0,7 do
        local tgt = megast.Battle:getInstance():getTeam(not self.parentGameUnit:getisPlayer()):getTeamUnit(i);
        if tgt ~= nil then
            if level > 0 then
                self.parent:execAddBuff(tgt,buffTable);
            else
                local buff = tgt:getTeamUnitCondition():findConditionWithID(buffTable.ID);
                if buff ~= nil then
                    tgt:getTeamUnitCondition():removeCondition(buff);
                end
            end
        end
    end

    local burstSkill = self.parentGameUnit:getBurstSkill2();
    if burstSkill == nil then
        return;
    end

    burstSkill:setDamageRate(self.fullArtsBaseDamage + level * 150);

    for i,v in pairs(self.fireTables) do
        
        self:execFullRelease(v);
        
    end

    self.fireTables = {};
    
    self.parentGameUnit:addSPWithPvpCorrection(level * 25);

    local buff = self.parentGameUnit:getTeamUnitCondition():findConditionWithID(self.ICON_BUFF.ID);
    if buff ~= nil then
        self.parentGameUnit:getTeamUnitCondition():removeCondition(buff);
    end

end

function class.dragonFireClass:resetAll()
    for i,v in pairs(self.fireTables) do
        
        self:execRelease(v);
        
    end

    self.fireTables = {};
    self:addDragonBuff(0);
    self.dragonBuffLevel = 0;
    self.gameUnit:setParameter("306_Dragon",""..self.dragonBuffLevel);
end


function class.dragonFireClass:changeSkillAnimation(cnt)
    if cnt > 5 then
        cnt = 5
    end
    self.parentGameUnit:setNextAnimationName("skill3"..cnt);
    self.parentGameUnit:setNextAnimationEffectName("skill3"..cnt);
end


function class.dragonFireClass:addDragonBuff(count)
    
    count = count > 8 and 8 or count;
    local buffTable = {
       ID = 103060 + self.parentGameUnit:getIndex(),
       BUFF_ID = 61,
       VALUE = self.DRAGON_BUFF_VALUE * count,
       DURATION = 9999,
       ICON = 43
   }
   for i=0,7 do
        local tgt = megast.Battle:getInstance():getTeam(not self.parentGameUnit:getisPlayer()):getTeamUnit(i);
        if tgt ~= nil then
            if count > 0 then
                self.parent:execAddBuff(tgt,buffTable);
            else
                local buff = tgt:getTeamUnitCondition():findConditionWithID(buffTable.ID);
                if buff ~= nil then
                    tgt:getTeamUnitCondition():removeCondition(buff);
                end
            end
        end
    end

    self.ICON_BUFF.NUMBER = count;

    if count > 0 then
        self.parent:execAddBuff(self.parentGameUnit,self.ICON_BUFF);
    else
        local buff = self.parentGameUnit:getTeamUnitCondition():findConditionWithID(self.ICON_BUFF.ID);
        if buff ~= nil then
            self.parentGameUnit:getTeamUnitCondition():removeCondition(buff);
        end
    end



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