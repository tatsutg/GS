local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="BRS_真EX_CODE XTF:ERASER", version=1.3, id=2040970});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50},
        { ATTACK2 = 50},
        { ATTACK3 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 5
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = 0000,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "機族からの被ダメージアップ",COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ユニットが奥義・真奥義を使用するたび奥義ゲージアップ",COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        --self.isRage = true
        self.gameUnit:addSP(100)
        --self.gameUnit:setInvincibleTime(7)
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
    self.afterSkillFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true

    self.isDead = false
    self.deathCount = 0
    self.LIMIT = 8

    ---奥義カウンタ
    self.unitCounterFlg = false
    self.enemyTable = {}
    for i = 0, 6 do
        self.enemyTable[i] = false
    end

    event.unit:setSkin("Nomal")
    ---アーム関係
    self.isArm = true
    ---ミサイル関係
    self.missiles = {}
    self.missileinfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
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
        end
    }
    ---ボール関係
    self.balls = {}
    self.ballinfo = {
        new = function (_ball,_targetUnit,_uniqueID)
            return {
                bullet = _ball,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1,
                isPlayer = false
            }
        end
    }

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    event.unit:takeAnimation(0,"barrier_off",false)
    event.unit:takeAnimationEffect(0,"barrier_off",false)
    self:initAttackWeight({DEFAULT = 100})
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    --event.unit:setReduceHitStop(2,1)---ヒットストップ無効or時止め無効

    self:checkDeath(event.unit,event.deltaTime)
    ---アーム
    self:attack5ArmControll(event.unit);
    ---ミサイル
    if table.maxn(self.missiles) > 0 then
        for i = 1,table.maxn(self.missiles) do
            self:missileControll(self.missiles[i]);
        end
    end
    ---ボール
    if table.maxn(self.balls) > 0 then
        for i = 1,table.maxn(self.balls) do
            self:ballControll(self.balls[i]);
        end
    end
    ---奥義カウンタ
    if self.gameUnit:getUnitState() ~= kUnitState_skill then
        self:playerUnitSkillCount()
    else
        self:mySkillCount()
    end

    return 1
end

function class:checkDeath(unit,deltaTime)
    if self.isDead then
        if self.deathCount < self.LIMIT then
            self.deathCount = self.deathCount + deltaTime
            return
        end
        unit:setHP(0)
    end
end

function class:playerUnitSkillCount()   --プレイヤーユニットが奥義中か判定
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local skill = myTeamUnit:getActiveBattleSkill();
            ---前回奥義判定されたユニットの場合
            if self.enemyTable[i] then
                if myTeamUnit:getUnitState() ~= kUnitState_skill then
                    ---奥義終了を確認
                    self.enemyTable[i] = false
                end
            elseif skill ~= nil then
                if skill:getIndex() == 1 or skill:getIndex() == 2 then
                    if self.unitCounterFlg then
                        ---奥義をしているユニットを奥義判定,その奥義が終了するまで判定されない
                        self.enemyTable[i] = true
                    else
                        self.gameUnit:addSP(20)
                        self.enemyTable[i] = true
                        break
                    end
                end
            end
        end
    end
end

function class:mySkillCount()   --自身がSKILL発動中か判定
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local skill = myTeamUnit:getActiveBattleSkill();
            ---前回奥義判定されたユニットの場合
            if self.enemyTable[i] then
                if myTeamUnit:getUnitState() ~= kUnitState_skill then
                    ---奥義終了を確認
                    self.enemyTable[i] = false
                end
            elseif skill ~= nil then
                if skill:getIndex() == 1 or skill:getIndex() == 2 then
                    if self.unitCounterFlg then
                        ---奥義をしているユニットを奥義判定,その奥義が終了するまで判定されない
                        self.enemyTable[i] = true
                    else
                        self.gameUnit:addSP(-20)
                        self.enemyTable[i] = true
                        break
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "missile" then self:missile(event.unit) end
    if event.spineEvent == "onDestroyMissile" then self:onDestroyMissile(event.unit) end

    if event.spineEvent == "ball" then self:ball(event.unit) end
    if event.spineEvent == "onDestroyball" then self:onDestroyball(event.unit) end

    if event.spineEvent == "laserHit2" then self:laserHit2(event.unit) end

    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    event.unit:setNextAnimationName("idle2");
    return 1
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    event.unit:setNextAnimationName("back2");
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    event.unit:setNextAnimationName("damage_S");
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

    if event.index == 1 then
        event.unit:setNextAnimationName("attack4")
        event.unit:setNextAnimationEffectName("1-attack4") ---EFのアニメーション名に気をつける
    end

    if event.index == 2 then
        event.unit:setNextAnimationName("attack5")
        event.unit:setNextAnimationEffectName("1-attack5") ---EFのアニメーション名に気をつける
    end

    if event.index == 3 then
        event.unit:setNextAnimationName("attack6")
        event.unit:setNextAnimationEffectName("1-attack6") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
    self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
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

    if event.index == 1 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3") ---EFのアニメーション名に気をつける
    end

    if event.index == 2 then
        event.unit:setNextAnimationName("skill7")
        event.unit:setNextAnimationEffectName("1-skill7") ---EFのアニメーション名に気をつける
    end

    if event.index == 2 and self.isRage then
        self.isRage = false
    elseif event.index == 3 and self.isFury then
        self.isFury = false
    end
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 2
    elseif self.isFury then
        skillIndex = 3
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end


function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return self:calcDamageValue(unit,stopBorder,value)
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

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.isDead then
        self.isDead = true
        self.isRage = true
        event.unit:setInvincibleTime(10)
        event.unit:takeSkill()
        event.unit:setHP(1)
        return 0
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

    self.TRIGGERS[index].used = true
    self.TRIGGERS[index].action(action)
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
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
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


---CODE XTF:ERASER用
-------------------------------------------------------------
--=====================================================================================================================================
--アームコントロール
--=====================================================================================================================================
function class:attack5ArmControll(unit)
    if not self.isArm then
        return
    end
    self:boneRotation(unit,"R_weapon_gunbarrel_upper",360);
    self:boneRotation(unit,"R_weapon_arm_gunbarre_center",360);
    self:boneRotation(unit,"R_weapon_gunbarrel_lower",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_upper",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_canter",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_lower",360);
end

function class:boneRotation(unit,boneName,maxdeg)
    unit:getSkeleton():setBoneRotation(boneName,self:calcDeg(unit,boneName));
    return 1;
end

function class:calcDeg(unit,boneName)
    local target = unit:getTargetUnit();
    if target ~= nil then
        local x = unit:getPositionX();
        local y = unit:getPositionY();
        local xb = unit:getSkeleton():getBoneWorldPositionX(boneName);
        local yb = unit:getSkeleton():getBoneWorldPositionY(boneName);
        local tx = target:getPositionX();
        local ty = target:getPositionY();
        local txb = target:getSkeleton():getBoneWorldPositionX("MAIN");
        local tyb = target:getSkeleton():getBoneWorldPositionY("MAIN");
        return self:getDeg(x+xb,y+yb,tx+txb,ty+tyb);
    end
    return 0
end


--=====================================================================================================================================
--ミサイル関係
--=====================================================================================================================================
function class:missile(unit)
    local shot = unit:addOrbitSystem("missile",1)
    shot:setHitCountMax(1)
    shot:setEndAnimationName("missileExplosion")
    -- shot:EnabledFollow = true;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("C_weapon_maingun");
    local yb = unit:getSkeleton():getBoneWorldPositionY("C_weapon_maingun");
    shot:setPosition(x+xb,y+yb);
    shot:takeAnimation(0,"missile",true);
    shot:setAutoZOrder(true);
    shot:setZOderOffset(-5030);

    local target = unit:getTargetUnit();

    if target == nil then
        shot:takeAnimation(0,"missileExplosion",false);
        return 1;
    end

    local tama = self.missileinfo.new(shot,target:getIndex(),0);

    tama.isPlayer = unit:getisPlayer();
    table.insert(self.missiles,tama)
    return 1;
end

function class:missileControll(missileinstance)
    local framecnt = missileinstance.frame;
    local currentmissile = missileinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then
        missileinstance.angle = 0;
        missileinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        missileinstance.posx = missileinstance.bullet:getPositionX();
        missileinstance.posy = missileinstance.bullet:getPositionY();
    end

    missileinstance.frame = missileinstance.frame + 1 * unitManagerDeltaTime/0.016666667;
    if framecnt <= 1 then

    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*12;
        missileinstance.angle = 45;
    elseif framecnt < 120 then
        sp = 1 + math.abs(framecnt - 30)/30 * speedOrigin*12;
    elseif framecnt >= 120 and framecnt <= 125 then
        local missiletarget = megast.Battle:getInstance():getTeam(not missileinstance.isPlayer):getTeamUnit(missileinstance.targetUnit);
        if missiletarget ~= nil then
            sp = 0;
            missileinstance.bullet:setPositionX(missiletarget:getPositionX());
            missileinstance.posx = missiletarget:getPositionX();
            missileinstance.angle = -90;
        end
    elseif framecnt < 600 then
        sp = speedOrigin*40;
        local missiletarget = megast.Battle:getInstance():getTeam(not missileinstance.isPlayer):getTeamUnit(missileinstance.targetUnit);
        if missiletarget ~= nil then
            local targetangle = self:getDeg(currentmissile:getPositionX(),currentmissile:getPositionY(),missiletarget:getPositionX(),missiletarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - missileinstance.angle;
            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 3 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                missileinstance.angle = missileinstance.angle + dir;
            end

            if missileinstance.posy < missiletarget:getPositionY() then
                missileinstance.bullet:takeAnimation(0,"missileExplosion",false);
            end
        end
    else
        missileinstance.bullet:takeAnimation(0,"missileExplosion",false);
    end
    missileinstance.bullet:setRotation(360 - missileinstance.angle);
    self:moveByFloat(missileinstance,self:calcXDir(self:degToRad(missileinstance.angle),sp * unitManagerDeltaTime/0.016666667),self:calcYDir(self:degToRad(missileinstance.angle),sp * unitManagerDeltaTime/0.016666667));
end

function class:onDestroyMissile(unit)
    local  atari = 0;
    for i = 1,table.maxn(self.missiles) do
        print("Destroy")
        if self.missiles[i].bullet == unit then
            atari = i
        end
    end

    if atari ~= 0 then
        table.remove(self.missiles,atari);
    end
    return 1;
end


--=====================================================================================================================================
--レーザー関係
--=====================================================================================================================================
function class:laserHit2(unit)
    local bulletTarget = unit:getTargetUnit();
    if bulletTarget ~= nil then
        local hit = unit:addOrbitSystem("laserHit",0);
        local x = bulletTarget:getPositionX();
        local y = bulletTarget:getPositionY();
        local xb = bulletTarget:getSkeleton():getBoneWorldPositionX("MAIN");
        local yb = bulletTarget:getSkeleton():getBoneWorldPositionY("MAIN");
        hit:setPosition(x + xb , y + yb);
    end
    return 1;
end


--=====================================================================================================================================
--ボール関係
--=====================================================================================================================================
function class:ball(unit)
    local shot = unit:addOrbitSystem("ball",1)
    shot:setHitCountMax(1)
    shot:setDamageRateOffset(0.2);
    shot:setEndAnimationName("ballExplosion")
    -- shot:EnabledFollow = true;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("L_barrier_hand_root");
    local yb = unit:getSkeleton():getBoneWorldPositionY("L_barrier_hand_root");
    shot:setPosition(x+xb -50,y+yb);
    shot:takeAnimation(0,"ball",true);
    local target = unit:getTargetUnit();
    local targetIndex = 0;
    if target ~= nil then
        targetIndex = target:getIndex();
    end
    local tama = self.ballinfo.new(shot,targetIndex,0);
    tama.isPlayer = unit:getisPlayer();
    table.insert(self.balls,tama)
    return 1;
end

function class:ballControll(ballinstance)
    local framecnt = ballinstance.frame;
    local currentball = ballinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then

        local rand = math.random(360);
        ballinstance.angle = rand;
        ballinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        ballinstance.posx = ballinstance.bullet:getPositionX();
        ballinstance.posy = ballinstance.bullet:getPositionY();
    end

    ballinstance.frame = ballinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

    if framecnt <= 1 then


    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    end
    if framecnt < 600 then
        sp = 2;

        local balltarget = megast.Battle:getInstance():getTeam(not ballinstance.isPlayer):getTeamUnit(ballinstance.targetUnit);
        if balltarget ~= nil then
            local targetangle = self:getDeg(currentball:getPositionX(),currentball:getPositionY(),balltarget:getPositionX(),balltarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - ballinstance.angle;

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
                ballinstance.angle = ballinstance.angle + dir;
            end

        end
    else
        ballinstance.bullet:takeAnimation(0,"ballExplosion",false);
    end

    self:moveByFloat(ballinstance,self:calcXDir(self:degToRad(ballinstance.angle),sp * unitManagerDeltaTime/0.016666667),self:calcYDir(self:degToRad(ballinstance.angle),sp * unitManagerDeltaTime/0.016666667));
end

function class:onDestroyball(unit)
    local  atari = 0;
    for i = 1,table.maxn(self.balls) do
        print("Destroy")
        if self.balls[i].bullet == unit then
            atari = i
        end
    end

    if atari ~= 0 then
        table.remove(self.balls,atari);
    end
    return 1;
end


--=====================================================================================================================================
function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end


--=====================================================================================================================================
--数学系
--=====================================================================================================================================
function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
    return deg * 3.14159/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14159;
end

function class:dot(vec1,vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y;
end

function class:closs(vec1,vec2)
    return vec1.x * vec2.y - vec1.y * vec2.x;
end

function class:calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function class:calcYDir(rad,speed)
    return math.sin(rad)*speed;
end


-------------------------------------------------------------

class:publish();

return class;