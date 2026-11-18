local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="金巨人", version=1.3, id=2004340});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK5 = 25
}

class.ATTACK_RAGE = {
    ATTACK4 = 100;
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}



--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL2 = 6
}

class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 7
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 7
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 7
    },
    POIZON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}

--ブレイク時にかかるバフ内容
class.BREAK_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 97,         --燃焼
        VALUE = 100,        --効果量
        DURATION = 1,
        ICON = 0
    }
}

--ハンマー時にかかるバフ内容
class.HUMMER_BUFF_ARGS = {
    {
        ID = 40080,
        EFID = 17,         --与ダメアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26,
        SCRIPT = 8
    }
}



class.HP_60_BUFF_ARGS = {
    {
        ID = 40081,
        EFID = 17,         --被ダメカット
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}


class.RAGE_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 17,         --ダメアップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40077,
        EFID = 13,         --攻撃アップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 3
    }
}

class.RAGE_BUFF_ARGS_FOR_PLAYER = {
    {
        ID = 40078,
        EFID = 21,         --被ダメアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 139
    }
}

--===============================================================================================================================================
--定数
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;


class.RAGE_HP = 0.4;
class.RAGE_ATTACK_INDEX = 3;
class.GRENADE_RECAST = 10;

class.WEAPON_HP = 100000000;

class.SUMMON_ENEMY_ID = 48924;
class.SUMMON_DELAY = 20;


--===============================================================================================================================================
--デフォルトのイベント/
------------------
function class:start(event)

    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;

    self.gameUnit = event.unit;
    
    --つかみ関連の変数たち

    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;

    --投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;

    --武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();

    --召喚用タイマー
    self.summonTimer = 0;


    -- self.subBar =  BattleControl:get():createSubBar();
    -- self.subBar:setWidth(200); --バーの全体の長さを指定
    -- self.subBar:setHeight(13);--バーの幅を指定
    -- self.subBar:setPercent(0); --バーの残量を0%に指定
    -- self.subBar:setVisible(false);

    self.endTimer = 0;
    self.forceAttackIndex = 0;
    self.hitStopRate = 0;


    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    event.unit:setSPGainValue(0);

    self.HP_TRIGGERS = {
        [0] = {
            HP = 80,
            trigger = "getRage",
            isActive = true
        },
        [1] = {
            HP = 60,
            trigger = "hp60",
            isActive = true
        },
        [2] = {
            HP = 50,
            trigger = "hp50",
            isActive = true
        },
        [3] = {
            HP = 40,
            trigger = "getRage",
            isActive = true
        },
        [4] = {
            HP = 20,
            trigger = "hp20",
            isActive = true
        }
    }
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[self.HP_TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.HP_TRIGGERS[index].HP * 0.01)
    end


    --怒り時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "クリティカルダメージ無効・防御力アップ",
            COLOR = Color.red,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "ブレイク時燃焼ダメージアップ",
            COLOR = Color.red,
            DURATION = 15
        }
    }

    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.red,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 15
        },
        [2] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "味方ユニットの被ダメージアップ",
            COLOR = Color.red,
            DURATION = 15
        }
    }

    self.HP_80_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP_80_MESSAGE1 or "ブレイクでハンマー破壊",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.HP_80_MESSAGE2 or "ハンマー装備時、奥義ダメージアップ",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }

    self.HP_60_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP_60_MESSAGE1 or "ダメージアップ",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }

    self.HP_50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP_50_MESSAGE1 or "行動速度アップ",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }

    self.HP_20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP_20_MESSAGE1 or "奥義ゲージ速度アップ",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }

    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", 300 ,30, 620 , -100 ,0.8);
    return 1;
end


function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = event.enemy:getIndex();
            self:checkGlabSucsess(event.unit);
        end
    end
    return event.value;
end


function class:run (event)
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
    return 1;
end

function class:update(event)
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    if self.state == self.WEAPON_STATES.HUMMER then
        
        self:weaponCheck(event.unit);
    end
    event.unit:setReduceHitStop(2,self.hitStopRate);
    self:summon(event.unit,event.deltaTime);
    self:grenadeCheck(event.deltaTime);
    self:countDown(event.unit,event.deltaTime);
    self:HPTriggersCheck(event.unit);

    if event.unit:getBreakPoint() <= 0 then
        local burn = event.unit:getTeamUnitCondition():findConditionValue(97);
        if burn ~= 0 and event.unit:getTeamUnitCondition():findConditionWithID(self.BREAK_BUFF_ARGS[1].ID) == nil then
            self.BREAK_BUFF_ARGS[1].VALUE = burn * 99;
            self:addBuffs(event.unit,self.BREAK_BUFF_ARGS);
        end
    end
    return 1;
end

function class:attackBranch(unit)
    local waightsTable = self.ATTACK_WEIGHTS;

    if self.state == self.WEAPON_STATES.HUMMER then
        waightsTable = self.ATTACK_RAGE;
    end

    local attackStr = summoner.Random.sampleWeighted(waightsTable);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.forceAttackIndex ~= 0 then
        attackIndex = self.forceAttackIndex;
        self.forceAttackIndex = 0;
    end
    
    unit:takeAttack(tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    if event.index == self.RAGE_ATTACK_INDEX then
        event.unit:setSkin("1");
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1
end

function class:takeDamage(event)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1;
end

function class:dead(event)
    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
    return 1;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if self.state == self.WEAPON_STATES.HUMMER then
        self:addBuffs(event.unit,self.HUMMER_BUFF_ARGS);
    end
    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1
end
--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    self.forceAttackIndex = self.RAGE_ATTACK_INDEX;
    unit:setAttackDelay(0);
    self.startBreakPoint = unit:getRecordBreakPoint();
    self:showMessage(self.HP_80_MESSAGES);
end

function class:weaponCheck(unit)
    -- local weaponDamage = unit:getRecordBreakPoint() - self.startBreakPoint;
    -- self:subBarControll(unit,weaponDamage);
    -- if weaponDamage >= self.WEAPON_HP and self:getIsHost() and unit.m_breaktime <= 0 then
    --     self:weaponBreak(unit);
    --     megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    -- end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    -- self.subBar:setVisible(false);
    unit:setAttackDelay(self.attackDelayDefault);
    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setReduceHitStop(0,0);--ヒットストップ無効解除
    unit:setSkin("2");
end

function class:subBarControll(unit,damage)
    -- local x = unit:getSkeleton():getBoneWorldPositionX("weapon2");
    -- local y = unit:getSkeleton():getBoneWorldPositionY("weapon2");
    -- self.subBar:setPositionX(unit:getPositionX() + x);--位置を指定
    -- self.subBar:setPositionY(unit:getPositionY()+ y);
    -- self.subBar:setVisible(true);
    -- self.subBar:setPercent(100 * (self.WEAPON_HP - damage)/self.WEAPON_HP);
    -- if self.WEAPON_HP - damage <= 0 then
    --     self.subBar:setVisible(false);
    -- end
end

function class:takeBreake(event)
    if self.state == self.WEAPON_STATES.HUMMER then
        self:weaponBreak(event.unit);
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.HUMMER_BUFF_ARGS[1].ID);
        if buff ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(buff);
        end
    end
    
    return 1;
end

--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true; 
end



function class:checkGlabSucsess(unit)
    if not self:getIsHost() then
        return;
    end
    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    self:getUnitByIndex(index):getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

function class:throwEnd(unit)
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end
    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);

    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(9);
    
end

function class:glabFaild(unit)
    unit:setAnimation(0,"skill1_miss",false);
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end
    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end
--===============================================================================================================================================
--投擲物関連のメソッド/
------------------

function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GRENADE_RECAST and self:getIsHost() then
        self.grenadeTimer = 0;
        local rand = LuaUtilities.rand(0,100);
        if rand < 50 then
            self:takePoizonGrenadeAnimation(self.gameUnit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        else
            self:takeOtherAnimation(self.gameUnit,rand);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        end
    end
end

function class:takePoizonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack2",false);
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POIZON);
end

function class:lunchOther(unit)
    --何を投げるかランダムで決定
    local rand = LuaUtilities.rand(0,100);
    local arg = {};


    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    else
        arg = self.ORBIT_ARGS.IRON;
    end

    self:lunch(unit,arg);
end

function class:lunch(unit,arg)
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
    bullet:setActiveSkill(arg.activeSkill);
    
    local x = unit:getPositionX()
    local y = unit:getPositionY()
    local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
    local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
    bullet:setPosition(x+xb,y+yb);

    local counter = 0;
    local tgt = nil;
    while counter < 4 and tgt == nil do
        counter = counter + 1;
        tgt = self:getUnitByIndex(self.granedeTargetIndex%4);
        self.granedeTargetIndex = self.granedeTargetIndex + 1;
    end

    local targetx = 0;
    local targety = 0;
    

    if tgt ~= nil then
        targetx = tgt:getAnimationPositionX();
        targety = tgt:getAnimationPositionY();
    end


    LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
end

--===============================================================================================================================================
function class:summon(unit,deltaTime)
    -- self.summonTimer = self.summonTimer + deltaTime;
    -- if self.summonTimer < self.SUMMON_DELAY then
    --     return 1;
    -- else
    --     self.summonTimer = 0;
    -- end
    -- if not self:getIsHost() then
    --     return 1;
    -- end
    -- --0~1の場所が空席ならユニット召喚
    -- for i=0,1 do
    --     if unit:getTeam():getTeamUnit(i) == nil then
    --         unit:getTeam():addUnit(i,self.SUMMON_ENEMY_ID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
    --     end
    -- end
    
    return 1;
end

--===============================================================================================================================================

function class:countDown(unit,deltaTime)
    local beforTimer = self.endTimer;
    self.endTimer = self.endTimer + deltaTime;

    if self.endTimer > 300 and beforTimer <= 300 then
        for i=0,4 do
            local targetUnit = Battle:getInstance():getTeam(true):getTeamUnit(i);
            if targetUnit ~= nil then
                self:addBuffs(targetUnit,self.RAGE_BUFF_ARGS_FOR_PLAYER);
            end
        end
        self:addBuffs(unit,self.RAGE_BUFF_ARGS);
        self:showMessage(self.RAGE_MESSAGES);
    end
end

--===============================================================================================================================================



function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end


function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

    if args.SCRIPTVALUE2 ~= nil then
        buff:setValue2(args.SCRIPTVALUE2);
    end

end
--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
                self.gameUnit:removeHpMarker(self.hpMarkers[self.HP_TRIGGERS[i].HP])
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        return true;
    end

    if trigger == "hp60" then
        self:hp60(unit);
        return true;
    end

    if trigger == "hp50" then
        self:hp50(unit);
        return true;
    end

    if trigger == "hp20" then
        self:hp20(unit);
        return true;
    end

    return false;
end

function class:hp60(unit)
    self:addBuffs(unit,self.HP_60_BUFF_ARGS);
    self:showMessage(self.HP_60_MESSAGES);
end

function class:hp50(unit)
    self.hitStopRate = 1;
    self:showMessage(self.HP_50_MESSAGES);
end

function class:hp20(unit)
    self.spValue = self.spValue * 2;
    self:showMessage(self.HP_20_MESSAGES);
end

--===================================================================================================================
-- メッセージ表示系
--[[
showMessage(<table> messageBoxList,<number> index)
   messageBoxList : 
      必須。以下のようなメッセージ表示用のテーブルを用意して投げる
      TEKITOUNA_MESSAGES = [
         [0] = [
            <String> MESSAGE = 本文,
            <Color> COLOR = 色,
            <number> DURATION = 表示期間(秒)]

         ],
         [1] = ...
      ]
   index : 
      任意。messageBoxList[index]の内容を表示する。
      この引数がない場合、messageBoxListの全ての内容を表示する。
]]
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
   return
   end
   self:execShowMessage(messageBoxList[index])
end

--[[
showMessageRange(<table> messageBoxList,<number> start,<number> last)
   messageBoxList : 
      必須。
   start,last : 
      必須。messageBoxList[start]からmessageBoxList[last]の内容を表示する。
      この引数がない場合、何も表示しない。
]]
function class:showMessageRange(messageBoxList,start,last)
   for i = start,last do
      self:execShowMessage(messageBoxList[i])
   end
end

--[[
showMessageRange(<table> messageBox)
   敵側のメッセージ欄にmessageBoxの内容を表示する
]]
function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end


--===============================================================================================================================================
--マルチ同期/
----------

function class:receive1(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive3(args)
    self:takePoizonGrenadeAnimation(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:takeOtherAnimation(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:weaponBreak(self.gameUnit);
    return 1;
end

--===============================================================================================================================================

function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end




class:publish();

return class;
