--@additionalEnemy,2024604
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超神級ボール", version=1.3, id=2024601});
class:inheritFromUnit("unitBossBase");


class.ATTACK_REEL = {
    [1] = {
        INDEX1 = 100,
        INDEX3 = 100
    },
    [2] = {
        INDEX2 = 100,
        INDEX3 = 100
    },
    [3] = {
        INDEX1 = 100,
        INDEX2 = 100,
        INDEX3 = 100
    }
}



--使用する奥義とその確率
class.SKILL_REEL = {
    [1] = {
        INDEX4 = 100,
        INDEX5 = 100
    },
    [2] = {
        INDEX4 = 100
    },
    [3] = {
        INDEX5 = 100
    }
}



class.ATTACK_INFO = {
    [1] = {
        animationNumber = 4,
        activeSkill = 1,
        isSkill = false,
        sp = 20
    },
    [2] = {
        animationNumber = 5,
        activeSkill = 2,
        isSkill = false,
        sp = 20
    },
    [3] = {
        animationNumber = 6,
        activeSkill = 3,
        isSkill = false,
        sp = 20
    },
    [4] = {
        animationNumber = 4,
        activeSkill = 4,
        isSkill = true,
        sp = 0
    },
    [5] = {
        animationNumber = 5,
        activeSkill = 5,
        isSkill = true,
        sp = 0
    },
    [6] = {
        animationNumber = 7,
        activeSkill = 6,
        isSkill = true,
        sp = 0
    }
}
--怒り時にかかるバフ内容

class.DEBUFF_ARGS = {
    {
        ID = -40078,
        EFID = 61,         --属性耐性
        VALUE = -65,        --効果量
        DURATION = 9999999,
        ICON = 0
    },
    {
        ID = -40079,
        EFID = 62,         --属性耐性
        VALUE = -65,        --効果量
        DURATION = 9999999,
        ICON = 0
    },
    {
        ID = -40080,
        EFID = 63,         --属性耐性
        VALUE = -65,        --効果量
        DURATION = 9999999,
        ICON = 0
    },
    {
        ID = -40081,
        EFID = 64,         --属性耐性
        VALUE = -65,        --効果量
        DURATION = 9999999,
        ICON = 0
    },
    {
        ID = -40082,
        EFID = 65,         --属性耐性
        VALUE = -65,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}

class.START_BUFF_ARGS = {
    {
        ID = 40083,
        EFID = 13,         --攻撃力
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 3
    }, 
    {
        ID = 40084,
        EFID = 17,         --与ダメ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}





-- class.INVINCIBLE_BUFF_ARGS = {
--     {
--         ID = 40078,
--         EFID = 21,         --被ダメ
--         VALUE = -1000,        --効果量
--         DURATION = 8,
--         ICON = 0
--     },
--     {
--         ID = 40079,
--         EFID = 27,         --被ブレイク
--         VALUE = -1000,        --効果量
--         DURATION = 8,
--         ICON = 0
--     },
-- }


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.forceSkillIndex = 0;
    self.forceAttackIndex = 0;
    self.hitstopReduceLevel = 200;
    self.hitStopReduceRate = 1;
    self.attackCounter = -1;--最初に変形があるのでその分ずらす
    self.skillCounter = 0;
    self.isDie = false;
    self.specialHPAttackRate = 0;
    self.mode = 1;
    self.deadTimer = 10;
    self.timeLimit = 300;
    self.isBattleEnd = false;
    self.beforeBreakPoint = 1000000;

    self.currentActiveSkill = 0;

    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 0.001,
            trigger = "HP0",
            isActive = true
        }
    }

     self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "侵入者ヲ駆除スル",
            COLOR = Color.white,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "全属性耐性",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイクするたびに全属性耐性低下",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.ARTS1_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.ARTS1_MESSAGE1 or "主砲展開・魔導エネルギー充填——",
            COLOR = Color.white,
            DURATION = 10
        }
    }

    self.ARTS2_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.ARTS2_MESSAGE1 or "シールド展開・全砲門最大出力——",
            COLOR = Color.white,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.ARTS2_MESSAGE2 or "全属性耐性上昇",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.BREAK_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.BREAK_MESSAGE1 or "シールド出力低下",
            COLOR = Color.white,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.BREAK_MESSAGE2 or "全属性耐性低下",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }


    self.HP0_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP0_MESSAGE1 or "警告：自壊システム起動、拠点ハ破棄スル",
            COLOR = Color.red,
            DURATION = 10
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setSkin("Nomal")


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
    
    return 1;
end

function class:startWave(event)
    if event.unit:getHP() > 1 then
        self:showMessage(self.START_MESSAGES);
    end
    self:addBuffs(event.unit,self.START_BUFF_ARGS);
    self.mode = 1;
    if self.getIsHost() and event.unit:getHP() > 1  then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.mode);
        self:modeChange(event.unit,1);
    end
    event.unit:setSetupAnimationName("setUp2");
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    return 1;
end

function class:modeChange(unit)
    self.mode = 1;
    unit:takeAnimation(0,"barrier_off",false);
    unit:takeAnimationEffect(0,"barrier_off",false);
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:reduceHitStop(event.unit);
    if self.isAttack5 then
        self:attack5ArmControll(event.unit);
    end
    if table.maxn(self.missiles) > 0 then
        for i = 1,table.maxn(self.missiles) do
            self:missileControll(self.missiles[i]);
        end
    end
    if self.isDie and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self.deadTimer = self.deadTimer - event.deltaTime;
        if self.deadTimer < 0 then
            event.unit:setHP(0);
        end
    end

    self:countDown(event.deltaTime);
    self:breakCheck(event.unit);

    return 1;
end

function class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 then
        self.gameUnit:addSP(100);
        self.gameUnit:setInvincibleTime(10);
        self.forceSkillIndex = 5;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self.isBattleEnd = true;

        -- for i = 0,3 do
        --      local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        --      if teamUnit ~= nil then
        --         teamUnit:setHP(0)
        --      end 
        -- end
        -- megast.Battle:getInstance():endBattle(false);
    end
end

function class:reduceHitStop(unit)
    local level = self.hitstopReduceLevel;
    if unit:getTeamUnitCondition():findConditionValue(27) <= - 500 then
        level = 100;
    end
   unit:setReduceHitStop(level, self.hitStopReduceRate);
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_REEL[self.attackCounter % table.maxn(self.ATTACK_REEL) + 1]);
    local attackIndex = string.gsub(attackStr,"INDEX","");
    self.attackCounter = self.attackCounter + 1;

    if self.forceAttackIndex ~= 0 then
        attackIndex = self.forceAttackIndex;
        self.forceAttackIndex = 0;
    end

    attackIndex = tonumber(attackIndex);

    self.currentActiveSkill = self.ATTACK_INFO[attackIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[attackIndex].sp;

    if not self.ATTACK_INFO[attackIndex].isSkill then
        unit:takeAttack(self.ATTACK_INFO[attackIndex].animationNumber);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        self.attackCheckFlg = false;
        unit:takeSkill(self.ATTACK_INFO[attackIndex].animationNumber);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(attackIndex));
    end

    return 0;
end

function class:takeAttack(event)
    self.specialHPAttackRate = 0;
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    event.unit:setActiveSkill(self.currentActiveSkill);
    self:addSP(event.unit);
    if event.index == 5 then
        self.isAttack5 = true;
    end
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_REEL[self.skillCounter % table.maxn(self.SKILL_REEL) + 1]);
    local skillIndex = string.gsub(skillStr,"INDEX","");
    self.skillCounter = self.skillCounter + 1;

    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end

    skillIndex = tonumber(skillIndex);

    self.currentActiveSkill = self.ATTACK_INFO[skillIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[skillIndex].sp;

    self.currentActiveSkill =  self.ATTACK_INFO[skillIndex].activeSkill;
    unit:takeSkill(self.ATTACK_INFO[skillIndex].animationNumber);

    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    

    return 0;
end


function class:takeSkill(event)
    self.specialHPAttackRate = 0;
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,0);
        event.unit:setInvincibleTime(10);

        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    event.unit:setActiveSkill(self.currentActiveSkill);

    -- if event.index >= 2 then
    --     self.attackCounter = 0;
    -- end

    self:addSP(event.unit);
    if event.index == 4 then
        self:showMessage(self.ARTS1_MESSAGES);
        self:summon(event.unit);
    end
    if event.index == 5 then
            self:showMessage(self.ARTS2_MESSAGES);
    end
    if event.index == 7 then
        self.isDie = true;
    end
    return 1
end


function class:attackDamageValue(event)
    if self.isBattleEnd then
        return 9999999;
    end
    return event.value;
end


function class:run(event)
    if event.spineEvent == "missile" then self:missile(event.unit) end
    if event.spineEvent == "onDestroyMissile" then self:onDestroyMissile(event.unit) end
    if event.spineEvent == "laserHit2" then self:laserHit(event.unit) end
    return 1;
end

function class:takeIdle(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("idle2");
    end
    return 1;
end

function class:takeBack(event)
    if self.mode == 1 then
        event.unit:setNextAnimationName("back2");
    else
        event.unit:setNextAnimationName("back1");
    end
    return 1;
end

function class:takeBreake(event)
    
    return 1;
end

function class:breakCheck(unit)
    
    if self.beforeBreakPoint > 0 and unit:getBreakPoint() <= 0 then
        if self.getIsHost() then
            self:takeDebuff(unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
        end
    end

    self.beforeBreakPoint = unit:getBreakPoint();
end

function class:takeDebuff(unit)
    -- self.mode = 0;
    self:showMessage(self.BREAK_MESSAGES);
    self:addBuffs(unit,self.DEBUFF_ARGS);

end

function class:takeDamage(event)
    event.unit:setNextAnimationName("damage_S");
    return 1;
end

function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:excuteAction(event)
    self.isAttack5 = false;
    if self.isDie and self.deadTimer < 5 then
        self.deadTimer = 0;
    end
    return 1;
end


function class:dead(event)
    if self.deadTimer > 0 then
        event.unit:setHP(1);
        return 0;
    end
    for i = 0,7 do
         local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
         if teamUnit ~= nil then
            teamUnit:setHP(0)
         end 
    end
    return 1;
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)

    if trigger == "HP70" then
        self:HP70(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end

    if trigger == "HP50" then
        self:HP50(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end
    if trigger == "HP10" then
        self:HP10(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        return true;
    end
    if trigger == "HP0" then
        self:HP0(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
        return true;
    end
    return false;
end

function class:removeAllStopStatus(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
        end
    end
end

--===================================================================================================================
--怒り関係


function class:HP70(unit)
    unit:excuteAction();

    self:addBuffs(unit,self.HP70_BUFF_ARGS);
    self:showMessage(self.HP70_MESSAGES);
    self.forceSkillIndex = 4;
    
    -- self:addBuffs(unit,self.INVINCIBLE_BUFF_ARGS);
    unit:addSP(unit:getNeedSP());

end


function class:HP50(unit)
    unit:excuteAction();
    self:showMessage(self.HP50_MESSAGES);
    self:addBuffs(unit,self.HP50_BUFF_ARGS);
    self.forceSkillIndex = 5;
    self.forceAttackIndex = 7;
    
    -- self:addBuffs(unit,self.INVINCIBLE_BUFF_ARGS);
    unit:addSP(unit:getNeedSP());

end

function class:HP10(unit)
    unit:excuteAction();
    self:addBuffs(unit,self.HP10_BUFF_ARGS);
    self:showMessage(self.HP10_MESSAGES);
    self.forceSkillIndex = 5;
    self.forceAttackIndex = 8;

    -- self:addBuffs(unit,self.INVINCIBLE_BUFF_ARGS);

    unit:addSP(unit:getNeedSP());
end

function class:HP0(unit)
    self:removeAllStopStatus(self.gameUnit);
    self:showMessage(self.HP0_MESSAGES);
    self.forceSkillIndex = 6;
    unit:addSP(unit:getNeedSP());
    unit:setInvincibleTime(9);
    self.deadTimer = 10;
    unit:excuteAction();
    unit:setSetupAnimationName("setUp1");
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end




function class:summon(unit)
    if not self:getIsHost() then
        return 1;
    end

    local otherCnt = 0;
    for i=0,7 do
        if unit:getTeam():getTeamUnit(i) ~= nil and i ~= unit:getIndex() then
            otherCnt = otherCnt + 1; 
        end
    end

    if otherCnt >= 5 then
        return;
    end

    local counter = 0;
    --0~1の場所が空席ならユニット召喚
    for i=0,4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            unit:getTeam():addUnit(i,2024604);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            counter = counter + 1;
            if counter >= 2 or otherCnt + counter >= 5 then
                return;
            end
        end
    end
end

function class:laserHit()
    if self.gameUnit:getTargetUnit() == nil then
        return;
    end

    local hit = self.gameUnit:addOrbitSystem("laserHit",0);
    local x = self.gameUnit:getTargetUnit():getPositionX();
    local y = self.gameUnit:getTargetUnit():getPositionY();
    local xb = self.gameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = self.gameUnit:getTargetUnit():getSkeleton():getBoneWorldPositionY("MAIN");
    hit:setActiveSkill(2);
    
    hit:setPosition(x + xb , y + yb);
   
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

--===================================================================================================================
-- バフ、デバフ追加系
--[[
addBuffs(<event.unit> unit,<table> buffs)
   unit :
      必須。バフを与える対象
   buffs :
      必須。以下のようなバフ用の配列を用意して投げる
      HP70_BUFFS = {
         {
            <number> ID = 必須。一意のID
            <number> EFID = 必須。バフの効果ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> VALUE = 必須。バフ効果量
            <number> DURATION = 必須。持続時間
            <number> ICON = 必須。アイコンID。IDの一覧は企画*多部署連携用シート.バフ・デバフアイコン参照
            <number> EFFECT = 任意。エフェクトID。IDの一覧は企画*多部署連携用シート.スキル効果アニメーション参照
            <number> SCRIPT = 任意。skill_effect内の関数用ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> SCRIPTVALUE1 = 任意。skill_effectの第一引数の値
         }
      }
]]
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

end




function class:attack5ArmControll(unit)
    self:boneRotation(unit,"R_weapon_gunbarrel_upper",360);
    self:boneRotation(unit,"R_weapon_arm_gunbarre_center",360);
    self:boneRotation(unit,"R_weapon_gunbarrel_lower",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_upper",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_canter",360);
    self:boneRotation(unit,"L_weapon_gunbarrel_lower",360);
end

function class:boneRotation(unit,boneName,maxdeg)
    unit:getSkeleton():setBoneRotation(boneName,self:calcDeg(unit,boneName));
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
    return 0;
end

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
    return deg * 3.14159/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14159;
end

--=====================================================================================================================================

function class:receive1(args)
    local attackIndex = args.arg;
    self.currentActiveSkill = self.ATTACK_INFO[attackIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[attackIndex].sp;
    self.fromHost = true;
    self.gameUnit:takeAttack(self.ATTACK_INFO[attackIndex].animationNumber);

    return 1;
end


function class:receive2(args)
    self:removeAllStopStatus(self.gameUnit);
    local skillIndex = args.arg;
    self.currentActiveSkill = self.ATTACK_INFO[skillIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[skillIndex].sp;
    self.fromHost = true;
    self.gameUnit:takeSkill(self.ATTACK_INFO[skillIndex].animationNumber);
    return 1;
end

function class:receive3(args)
    self:HP70(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:HP50(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:HP10(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:HP0(self.gameUnit);
    return 1;
end

function class:receive7(args)
    self:modeChange(self.gameUnit);
    return 1;
end

function class:receive8(args)
    self:takeDebuff(self.gameUnit);
    return 1;
end


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;