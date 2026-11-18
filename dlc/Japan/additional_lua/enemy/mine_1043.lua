local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉱山_ツァイバーE_SX-602型", version=1.3, id="mine_1042"});
class:inheritFromUnit("unitBossBase");

---鉱山ツァイバーEの召喚用
--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 0,
    SKILL2 = 3
}

class.cutInSkill = {
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1053215931,---リーダー以外
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [2] = {
            ID = 1053215932,---リーダー用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }

    self.SKILL_BUFF_BOX = {
        [1] = {
            ID = 104301,
            BUFF_ID = 93,  --暗闇効果
            VALUE = 80,
            DURATION = 10 + self.floor * 0.2,
            ICON = 83,
            WEIGHT = 30,
            GROUP_ID = 2017,
            PRIORITY = 80
        },
        [2] = {
            ID = 104302,
            BUFF_ID = 22,  --状態異常時クリティカル率UP
            VALUE = 100,
            DURATION = 30,
            ICON = 11,
            SCRIPT = {
                SCRIPT_ID = 432,
                VALUE1 = 2,
                VALUE2 = 93,
                VALUE3 = 93
            }
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "ダークコロック：クリティカルダメージ無効"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "ダークコロック：毒状態のとき被ダメージ・BE量アップ"
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    ---鉱山ギミック
    self.floor = megast.Battle:getInstance():getCurrentMineFloor();

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    --HP
    self:setUnitHP(event.unit)
    --ATK
    event.unit:setBasePower(1000 + self.floor * 20)

    ---SX-602型固有のもの
    self.bullets = {}
    self.bulletsIDCounter = 0
    self.bulletinfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                posx = 0,
                posy = 0,
                limitx = 0,
                limity = 0,
                parent = _bullet:getTeamUnit(),
                yield = true
            }
        end
    }
    return 1
end

function class:setUnitHP(unit)
    local bossHP = self:getBossHP()
    local hp = bossHP * 0.2
    unit:setBaseHP(hp)
    unit:setHP(hp)
end

function class:getBossHP()
    local bossHP = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getSize() == 3 then
                bossHP = myTeamUnit:getCalcHPMAX()
            end
        end
    end
    return bossHP
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])
    local condLeader = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
    --if condLeader ~= nil and megast.Battle:getInstance():getWaveNum() <= 3 then
    --    self:showMessage(self.START_MESSAGE_LIST)
    --end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])
    self:findFriends(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])

    --local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.SKILL_BUFF_BOX[2].ID);
    --if event.unit:getUnitState() ~= kUnitState_skill and cond ~= nil then
    --    event.unit:getTeamUnitCondition():removeCondition(cond);
    --end

    ---SX-602型固有のもの
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i]);
        end
    end
    return 1
end

function class:findXCondition(unit,x)
    local cnt = 0;
    local badStatusList = {
        x
    }
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
end

function class:findLeader(buffBoxFlg,buffBoxLeader)
    local FLG = false
    local myTeam = megast.Battle:getInstance():getTeam(false);
    ---バフがあるか確認
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                local condLeader = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
                if condLeader ~= nil then
                    FLG = true
                end
            end
        end
    end
    if FLG then
        ---ある場合
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                    local condLeader = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
                    if condLeader ~= nil then
                        myTeamUnit:setInvincibleTime(0)
                        local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                        if cond ~= nil then
                            myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                        end
                    end
                    break;
                end
            end
        end
    else
        ---ない場合
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                    ---Indexでリーダー決定
                    if myTeamUnit == self.gameUnit then
                        self.gameUnit:setInvincibleTime(0)
                        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                        if cond ~= nil then
                            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
                        end
                        self:execAddBuff(self.gameUnit,buffBoxLeader)
                    end
                    break;
                end
            end
        end
    end
end

function class:findFriends(buffBoxFlg,buffBoxLeader)
    local condLeader = self.gameUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
    if condLeader then
        self.gameUnit:setAttackDelay(6)
        local count = 0
        local myTeam = megast.Battle:getInstance():getTeam(false);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() and myTeamUnit ~= self.gameUnit then
                    count = count + 1
                    if count == 1 then
                        myTeamUnit:setAttackDelay(11)
                    elseif count >= 2 then
                        myTeamUnit:setAttackDelay(17)
                    end
                    myTeamUnit:setInvincibleTime(99999)
                    local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                    if cond == nil then
                        self:execAddBuff(myTeamUnit,buffBoxFlg)
                    end
                end
            end
        end
        self.nowFriends = count + 1
    end
end

function class:bulletControll(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local xdir = 0;
    local ydir = 0;
    print(bulletinstance.posx);
    local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.bullet:getTeamUnit():getisPlayer()):getTeamUnit(bulletinstance.targetUnit);
    local reversalFLG = bullettarget:getisPlayer();
    if bullettarget ~= nil and bulletinstance.yield then
        local thisx = currentbullet:getPositionX();
        local thisy = currentbullet:getPositionY();
        local targetx = bullettarget:getPositionX();

        --相手ユニットが敵側ならX軸の移動量を反転させる
        if reversalFLG then
            targetx = targetx + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");
        else
            targetx = targetx + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
        end

        local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN") + bullettarget:getSkeleton():getPositionY();
        xdir = targetx - thisx;
        ydir = targety - thisy;
        bulletinstance.limitx = bulletinstance.limitx + xdir;
        bulletinstance.limity = bulletinstance.limity + ydir;
    end

    self:moveByFloat(bulletinstance,xdir,ydir);
    return 1;
end

function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "lock" then return self:lock(event.unit) end
    if event.spineEvent == "lockCompleat" then return self:lockCompleat(event.unit) end
    if event.spineEvent == "explosion" then return self:explosion(event.unit) end
    if event.spineEvent == "missile" then return self:missile(event.unit) end
    if event.spineEvent == "onDestroy" then return self:onDestroy(event.unit) end
    return 1;
end

function class:lock(unit)
    local lock = unit:addOrbitSystem("LockOn")
    lock:setHitCountMax(1)
    local x = unit:getPositionX()
    local y = unit:getPositionY()
    lock:setPosition(x-100,y)
    local tama = self.bulletinfo.new(lock,unit:getTargetUnit():getIndex(),0)
    table.insert(self.bullets,tama)
    return 1;
end

function class:lockCompleat(unit)
    local  atari = 1
    for i = 1,table.maxn(self.bullets) do
        print("Destroy on lock compleat")
        if self.bullets[i].bullet == unit then
            self.bullets[i].yield = false;
        end
    end
    return 1;
end

function class:explosion(unit)
    local  atari = 0
    local  x = 0;
    local  y = 0;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i
        end
    end

    print(atari);
    if atari == 0 then
        return 0;
    end

    local explode = unit:getTeamUnit():addOrbitSystem("Explode");
    x = unit:getPositionX();
    local target = explode:getTargetUnit();
    if target ~= nil then
        y = target:getPositionY();
    end

    explode:setPosition(x,y);
    return 1;
end

function class:missile(unit)
    print("missile");
    local  atari = 0
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i
        end
    end

    print(atari);
    if atari == 0 then
        return 0;
    end

    local  parentx = unit:getTeamUnit():getPositionX();
    local  parenty = unit:getTeamUnit():getPositionY();
    local  thisx = unit:getPositionX();
    local thisy = unit:getPositionY();
    local distance = thisx - parentx;
    local hight = thisy - parenty;
    local miso = nil;
    if not unit:getTeamUnit():getisPlayer() then
        distance = distance * -1;
    end

    print(distance);
    if distance >= -128 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile0");
    elseif distance >= -192 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile1");
    elseif distance >= -256 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile2");
    elseif distance >= -320 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile3");
    elseif distance >= -384 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile4");
    elseif distance >= -448 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile5");
    elseif distance >= -512 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile6");
    elseif distance >= -576 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile7");
    elseif distance >= -640 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile8");
    elseif distance >= -704 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile9");
    else
        miso = unit:getTeamUnit():addOrbitSystem("Missile10");
    end

    if not(miso == nil) then
        if unit:getTeamUnit():getisPlayer() then
            miso:setPosition(parentx+distance%64,parenty+hight);
        else
            miso:setPosition(parentx-distance%64,parenty+hight);
        end
    end
    return 1;
end

function class:onDestroy(unit)
    local  atari = 1
    for i = 1,table.maxn(self.bullets) do
        print("onDestroy")
        if self.bullets[i].bullet == unit then
            atari = i
        end

    end
    table.remove(self.bullets,atari);
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    ---SX-602型固有のもの
    local  atari = 1
    for i = 1,table.maxn(self.bullets) do
        print("Destroy by dead")
        if self.bullets[i].bullet:getTeamUnit() == self.unit then
            atari = i
            self.bullets[i].bullet:takeAnimation(0,"animation",false);
            self.bullets[i].bullet:remove();
        end
    end
    table.remove(self.bullets,atari);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            --self:execAddBuff(myTeamUnit,self.SKILL_BUFF_BOX[1]);
        end
    end

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    --------------------------------------------------------------------------------------
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    --self:execAddBuff(event.unit,self.SKILL_BUFF_BOX[2]);

    self.skillCheckFlg = false;
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self:findXCondition(event.unit,90) then
    end

    ---暗闇状態
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(93);
    local cond2 = event.unit:getTeamUnitCondition():findConditionWithType(131); --ナイトメア
    if cond ~= nil or cond2 ~= nil then
    elseif cond == nil or cond2 == nil then
        event.value = event.value * 0.1
    end

    ---SX-602型固有のもの
    local  atari = 1
    for i = 1,table.maxn(self.bullets) do
        print("Destroy by damage")
        if self.bullets[i].bullet:getTeamUnit() == event.unit then
            atari = i
            self.bullets[i].bullet:remove();
        end
    end
    table.remove(self.bullets,atari);

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
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

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3

    local action = "use" .. receiveNumber

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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

    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond)
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
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

    ---グループID関係2
    if buff ~= nil then
        if buffBox.GROUP_ID ~= nil then
            buff:setGroupID(buffBox.GROUP_ID);
            buff:setPriority(buffBox.PRIORITY);
        end
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

class:publish();

return class;