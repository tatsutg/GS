local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="SX-202型", version=1.3, id=4002101});

class.myID = 4002101
class.flgID = 40021004

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 40021011,---リーダー以外
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [2] = {
            ID = 40021012,---リーダー用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 40021013,---フェーズ2用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [4] = {
            ID = 40021014,---フェーズ3用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
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
    self.SUMMON_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "SX-202型が加勢した",
            COLOR = Color.red
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
    }

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
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        phase2_summon = 2,
        phase3_summon = 3
    })
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    --self.spValue = 20;---addSPの量
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    --[[
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    ]]--

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    self.bullets = {}
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "lock" then
        self:lock(event.unit)
    end
    if event.spineEvent == "lockCompleat" then
        self:lockCompleat(event.unit)
    end
    if event.spineEvent == "explosion" then
        self:explosion(event.unit)
    end
    if event.spineEvent == "missile" then
        self:missile(event.unit)
    end
    if event.spineEvent == "onDestroy" then
        self:onDestroy(event.unit)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            if self.bullets[i] then
                self:bulletControll(self.bullets[i]);
            end
        end
    end
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])
    self:findFriends(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])
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
            if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.flgID) == nil then
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
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.flgID) == nil then
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
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.flgID) == nil then
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
        --self.gameUnit:setAttackDelay(6)
        local count = 0
        local myTeam = megast.Battle:getInstance():getTeam(false);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.flgID) == nil and myTeamUnit ~= self.gameUnit then
                    count = count + 1
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
---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    local  atari = 1
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            if self.bullets[i].bullet:getTeamUnit() == event.unit then
                self.bullets[i].bullet:takeAnimation(0,"animation",false);
                self.bullets[i].bullet:remove();
                self.bullets[i] = nil
                --table.remove(self.bullets,i);
            end
        end
    end
    return 1;
end
---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if megast.Battle:getInstance():isHost() then
        for i = 1,table.maxn(self.bullets) do
            if self.bullets[i] then
                if self.bullets[i].bullet:getTeamUnit() == event.unit then
                    self.bullets[i].bullet:takeAnimation(0,"animation",false);
                    self.bullets[i].bullet:remove();
                    self.bullets[i] = nil
                end
            end
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
        if megast.Battle:getInstance():getWaveNum() <= 3 then
            local cond1 = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID);
            local cond2 = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID);
            if self.nowFriends == 1 and cond1 == nil and cond2 == nil then
                ---フェーズ2召喚
                self:multipleSummon(event.unit,self.myID,self.GD.phase2_summon,self.BUFF_BOX_LIST[3])
                self:showMessage(self.SUMMON_MESSAGE_LIST)
                megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1)
            elseif self.nowFriends == 1 and cond1 ~= nil and cond2 == nil then
                ---フェーズ3召喚
                if megast.Battle:getInstance():getWaveNum() <= 2 then
                    self:multipleSummon(event.unit,self.myID,self.GD.phase3_summon,self.BUFF_BOX_LIST[4])
                    self:showMessage(self.SUMMON_MESSAGE_LIST)
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1)
                end
            end
        end
        return 1
    else
        return 0
    end
end

function class:receive4(args)
    local  atari = 1
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            if self.bullets[i].bullet:getTeamUnit() == self.gameUnit then
                self.bullets[i].bullet:takeAnimation(0,"animation",false);
                self.bullets[i].bullet:remove();
                self.bullets[i] = nil
            end
        end
    end
    return 1
end

function class:receive6(args)
    self:showMessage(self.SUMMON_MESSAGE_LIST)
    return 1
end

function class:summon(unit,unitID,buff)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)
                self:execAddBuff(unit:getTeam():getTeamUnit(i),buff)
                unit:getTeam():getTeamUnit(i):setInvincibleTime(10)
                megast.Battle:getInstance():sendEventToLua(self.scriptID,5,i*10 + (buff.ID-40021010))
                break
            end
        end
    end
end

function class:multipleSummon(unit,unitID,Num,buff)
    for i = 1,Num do
        self:summon(unit,unitID,buff)
    end
end

function class:receive5(args)
    local buffNumber = args.arg % 10
    local i = (args.arg - buffNumber) / 10
    if self.gameUnit:getTeam():getTeamUnit(i) ~= nil then
        self:execAddBuff(self.gameUnit:getTeam():getTeamUnit(i),self.BUFF_BOX_LIST[buffNumber])
        self.gameUnit:getTeam():getTeamUnit(i):setInvincibleTime(10)
    end
    return 1
end

function class:takeSkill(event)
    event.unit:setActiveSkill(event.index);
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
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
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

---SX系統用ギミック---
function class:lock(unit)
    local lock = unit:addOrbitSystem("LockOn")
    lock:setHitCountMax(1)
    local x = unit:getPositionX()
    local y = unit:getPositionY()
    lock:setPosition(x-100,y)
    local tama = self:setBulletInfo(lock,unit:getTargetUnit():getIndex(),0)
    table.insert(self.bullets,tama)
    return 1;
end

function class:setBulletInfo(_bullet,_targetUnit,_uniqueID)
    local bulletInfo = {
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
    return bulletInfo
end

function class:lockCompleat(unit)
    local atari = 1
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            if self.bullets[i].bullet == unit then
                self.bullets[i].yield = false;
            end
        end
    end
    return 1;
end

function class:explosion(unit)
    local  atari = 0
    local  x = 0;
    local  y = 0;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            if self.bullets[i].bullet == unit then
                atari = i
            end
        end
    end
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
    local  atari = 0
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            if self.bullets[i].bullet == unit then
                atari = i
            end
        end
    end
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
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            if self.bullets[i].bullet == unit then
                self.bullets[i] = nil
            end
        end
    end
    --table.remove(self.bullets,atari);
    return 1;
end

function class:bulletControll(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local xdir = 0;
    local ydir = 0;
    print(bulletinstance.posx);
    local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.bullet:getTeamUnit():getisPlayer()):getTeamUnit(bulletinstance.targetUnit);
    if bullettarget ~= nil and bulletinstance.yield then
        local reversalFLG = bullettarget:getisPlayer();
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

class:publish();

return class;