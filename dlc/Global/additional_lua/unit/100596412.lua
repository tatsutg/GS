local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒EDEN", version=1.3, id=100596412});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 98,
            VALUE = 0,
            DURATION = 30,
            ICON = 24,
            EFFECT = 1,
            GROUP_ID = 2000,
            PRIORITY = 0
        },
        [2] = {
            ID = 100596412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 215,
            COUNT = 0
        }

    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE or "start",
            COLOR = Color.yellow
        })
    }

end

function class:setBulletInfo(_bullet,_targetUnit,_uniqueID)
    local bulletInfo = {
        bullet = _bullet,
        targetUnit = _targetUnit,
        uniqueID = _uniqueID,
        frame = 0,
        angle = 0,
        posx = 0,
        posy = 0,
        speedkeisuu = 1,
        isPlayer = false
    }
    return bulletInfo
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.deadFLG = -1
    self.canonFLG = false
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self:setMessageBoxList()
    self:setBuffBoxList()
    self.myself = nil
    self.target = nil
    self.bullets = {}
    self.bulletinfo = {}
    if self.level == nil then
        self.level = 0
        self.gameUnit:setParameter("59_Armor",""..self.level);
    end
    self.isCannon = false
    event.unit:setAttackDelay(6);
    --self:showMessage(self.START_MESSAGE_LIST)
    self.damageRateTable = {
        [0] = {
            lightBall = 1/4
        },
        [1] = {
            lightBall = 1/10,
            hontai = 6/10
        },
        [2] = {
            lightBall = 1/11,
            hontai = 7/11
        },
        [3] = {
            lightBall = 1/19,
            hontai = 7/19,
            missile = 8/19
        },
        [4] = {
            hontai = 12/14,
            missile = 2/14
        },
        [5] = {
            hontai = 11/29,
            missile = 18/29
        },
        [6] = {
            hontai = 16/20,
            lightBall = 1/20
        }
    }
    event.unit:setSetupAnimationName("idle")
    self.BUFF_BOX_LIST[2].COUNT = self.level
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
    return 1
end

function class:startWave(event)
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i]);
        end
    end
    if self.deadFLG ~= -1 then
        self.level = self.deadFLG
        self.gameUnit:setParameter("59_Armor",""..self.level);
        if self.level > 0 then
            event.unit:setSetupAnimationName("idle_Lv"..self.level)
        else
            event.unit:setSetupAnimationName("idle")
        end
        self.BUFF_BOX_LIST[2].COUNT = self.level
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        self.deadFLG = -1
    end
    return 1
end

function class:bulletControll(bulletinstance)
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then

        local rand = math.random(360);
        bulletinstance.angle = rand;
        bulletinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
    end

    bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

    if framecnt <= 1 then


    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    end
    if framecnt < 600 then
        sp = 2;
        local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.isPlayer):getTeamUnit(bulletinstance.targetUnit);
        if bullettarget ~= nil then
            local targetangle = self:getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bullettarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - bulletinstance.angle;

            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 1 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                bulletinstance.angle = bulletinstance.angle + dir;
            end

        end
    else
        bulletinstance.bullet:takeAnimation(0,"hit",false);
    end

    self:moveByFloat(bulletinstance,self:calcXDir(self:degToRad(bulletinstance.angle),sp * unitManagerDeltaTime/0.016666667),self:calcYDir(self:degToRad(bulletinstance.angle),sp * unitManagerDeltaTime/0.016666667));

end

function class:calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function class:calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function class:move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end

function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))

end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.BUFF_BOX_LIST[2].COUNT = self.level
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
    self.canonFLG = false
    if self.level > 0 then
        event.unit:setNextAnimationName("attack1_Lv"..self.level)
        event.unit:setNextAnimationEffectName("4-attack1_Lv"..self.level)
        local oneShotRate = self.damageRateTable[self.level].hontai
        event.unit:setDamageRateOffset(oneShotRate)
        event.unit:setBreakRate(oneShotRate)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    if event.index < 3 and self.level == 3 then
        local oneShotRate = self.damageRateTable[event.index + 3].hontai
        event.unit:setDamageRateOffset(oneShotRate)
        event.unit:setBreakRate(oneShotRate)
    end
    if self.level > 0 then
        event.unit:setSetupAnimationName("idle_Lv"..self.level)
    end
    if event.index < 3 and self.level > 0 then
        event.unit:setNextAnimationName("skill"..event.index.."_Lv"..self.level)
        event.unit:setNextAnimationEffectName("4-skill"..event.index.."_Lv"..self.level)
    elseif event.index == 3 and self.level < 3 then
        self.BUFF_BOX_LIST[1].VALUE = (4000 + self.level * 2000)
        self:teamAddBuff(self.BUFF_BOX_LIST[1])
        local level = self.level + 1
        event.unit:setNextAnimationName("skill"..event.index.."_Lv"..level)
        event.unit:setNextAnimationEffectName("4-skill"..event.index.."_Lv"..level)
    elseif  event.index == 3 and self.level == 3 then
        self.BUFF_BOX_LIST[1].VALUE = (4000 + self.level * 2000)
        self:teamAddBuff(self.BUFF_BOX_LIST[1])
        event.unit:setNextAnimationName("skill3_Cannon")
        event.unit:setNextAnimationEffectName("4-skill3_Cannon")
        local oneShotRate = self.damageRateTable[event.index + 3].hontai
        event.unit:setDamageRateOffset(oneShotRate)
        event.unit:setBreakRate(oneShotRate)
        self.canonFLG = true
    end
    return 1
end
----// takeIdle //-----------------------------------------------------------------------------

---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.level > 0 then
        event.unit:setNextAnimationName("idle_Lv"..self.level)
    end
    return 1;
end
----// takeBack //-----------------------------------------------------------------------------

---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.level > 0 then
        event.unit:setNextAnimationName("back_Lv"..self.level)
    end
    return 1;
end
----// takeFront //-----------------------------------------------------------------------------

---------------------------------------------------------------------------------
function class:takeFront(event)
    if self.level > 0 then
        event.unit:setNextAnimationName("front_Lv"..self.level)
    end
    return 1;
end
----// takeCast //-----------------------------------------------------------------------------

---------------------------------------------------------------------------------
function class:takeCast(event)
    if self.level > 0 then
        event.unit:setNextAnimationName("cast_Lv"..self.level)
    end
    return 1;
end

----// takeDamage //-----------------------------------------------------------------------------
-- 条件 : ひるみ時。攻撃を受けた時ではない。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.level > 0 then
        event.unit:setNextAnimationName("damage_Lv"..self.level)
    end
    return 1
end

function class:dead(event)
    self.deadFLG = self.level
    self.level = 0
    self.gameUnit:setParameter("59_Armor",""..self.level);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self.deadFLG = self.level
    self.level = 0
    self.gameUnit:setParameter("59_Armor",""..self.level);
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "shot" then self:shot(event.unit) end
    if event.spineEvent == "onDestroy" then self:onDestroy(event.unit) end
    if event.spineEvent == "levelUp" then self:levelUp(event.unit) end
    if event.spineEvent == "missile_rain_attack1" then self:missileRain(event.unit) end
    if event.spineEvent == "missile_rain_skill1" then self:missileRainSkill1(event.unit) end
    if event.spineEvent == "missile_rain_skill2" then self:missileRainSkill2(event.unit) end
    return 1
end

function class:shot(unit)
    --ターゲット不在なら球は出せない
    if unit:getTargetUnit() == nil then
        return 0;
    end

    local shot = unit:addOrbitSystem("4shine",1)
    local oneShotRate = self.damageRateTable[self.level].lightBall
    if self.canonFLG then
        oneShotRate = self.damageRateTable[6].lightBall
        shot:setDamageRateOffset(oneShotRate)
    else
        shot:setDamageRateOffset(oneShotRate * 6)
    end
    shot:setBreakRate(oneShotRate)
    shot:setHitCountMax(1)
    shot:setEndAnimationName("hit")
    -- shot:EnabledFollow = true;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("EF_spack");
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_spack");
    shot:setPosition(x,y+yb);
    shot:takeAnimation(0,"3shine",true);
    local tama = self:setBulletInfo(shot,unit:getTargetUnit():getIndex(),0);
    tama.isPlayer = unit:getisPlayer();
    table.insert(self.bullets,tama)
end

function class:onDestroy(unit)
    local  atari = 0;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i
        end

    end
    if atari ~= 0 then
        table.remove(self.bullets,atari);
    end
end

function class:levelUp(unit)
    self.level = self.level + 1
    unit:setParameter("59_Armor",""..self.level);
    self.BUFF_BOX_LIST[2].COUNT = self.level
    self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
    if self.level > 0 then
        unit:setSetupAnimationName("idle_Lv"..self.level)
    end
end

function class:missileRain(unit)
    local shot = unit:addOrbitSystem("missile_rain_attack1",0)
    local oneShotRate = self.damageRateTable[self.level].missile
    shot:setDamageRateOffset(oneShotRate * 6)
    shot:setBreakRate(oneShotRate)
end

function class:missileRainSkill1(unit)
    local shot = unit:addOrbitSystem("missile_rain_skill1",0)
    local oneShotRate = self.damageRateTable[4].missile
    shot:setDamageRateOffset(oneShotRate)
    shot:setBreakRate(oneShotRate)
end

function class:missileRainSkill2(unit)
    local shot = unit:addOrbitSystem("missile_rain_skill2",0)
    local oneShotRate = self.damageRateTable[5].missile
    shot:setDamageRateOffset(oneShotRate)
    shot:setBreakRate(oneShotRate)
end


---------------------------------------------------------------------------------
-- endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    for i = 1,table.maxn(self.bullets) do
        self.bullets[i].bullet:takeAnimation(0,"hit",false);
    end
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
    for _,messageBox in ipairs(messageBoxList) do
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

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView()
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

function class:teamAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(self.gameUnit:getisPlayer())
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

class:publish();

return class;