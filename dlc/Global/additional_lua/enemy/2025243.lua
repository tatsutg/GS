local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX/極　死神", version=1.3, id=2025243});
class:inheritFromUnit("unitBossBase");


class.ATTACK_REEL = {
    [1] = {
        INDEX1 = 100
    },
    [2] = {
        INDEX2 = 100
    },
    [3] = {
        INDEX1 = 100
    },
    [4] = {
        INDEX4 = 100
    }
}



--使用する奥義とその確率
class.SKILL_REEL = {
    [1] = {
        INDEX5 = 100
    },
    [2] = {
        INDEX6 = 100
    }
}



class.ATTACK_INFO = {
    [1] = {
        animationNumber = 1,
        activeSkill = 1,
        isSkill = false,
        sp = 20
    },
    [2] = {
        animationNumber = 2,
        activeSkill = 2,
        isSkill = false,
        sp = 20
    },
    [3] = {
        animationNumber = 3,
        activeSkill = 3,
        isSkill = false,
        sp = 20
    },
    [4] = {
        animationNumber = 4,
        activeSkill = 4,
        isSkill = false,
        sp = 20
    },
    [5] = {
        animationNumber = 1,
        activeSkill = 5,
        isSkill = true,
        sp = 0
    },
    [6] = {
        animationNumber = 3,
        activeSkill = 6,
        isSkill = true,
        sp = 0
    }
}


class.DODGE_BUFF_ARGS = {
    {
        ID = 40078,
        EFID = 31,         --攻撃力固定値
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 16
    }   
}


class.DARK_BUFF_ARGS = {
    {
        ID = 40079,
        EFID = 93,         --攻撃力固定値
        VALUE = 100,        --効果量
        DURATION = 12,
        ICON = 83
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


class.FIXED_DAMAGE_RATE = 0.33;


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
    self.hitstopReduceLevel = 2;
    self.hitStopReduceRate = 1;
    self.attackCounter = 0;
    self.skillCounter = 0;
    self.isDie = false;
    self.specialHPAttackRate = 0;
    self.isCountDown = false;
    self.saftyTimer = 12;
    self.darkCheckTimer = 0;
    self.isDark = false;
    self.isCutIn = false;

    self.currentActiveSkill = 0;

    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 50,
            trigger = "HP50",
            isActive = true
        }
    }
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }

     self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "聴こえル…魂ノ軋む音ガ…",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "暗闇状態の相手に対してクリティカル率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "炎・光属性耐性",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP70_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "我が鎌ヲ恐れヨ…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }


    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "圧壊セヨ…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.HP10_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP10_MESSAGE1 or "全て…壊れテしまエ…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }




    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);

    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:reduceHitStop(event.unit);
    self:deadCountDown(event);
    self:checkDark(event.unit,event.deltaTime);
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1;
end

function class:deadCountDown(event)
    if self.isCountDown and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self.saftyTimer = self.saftyTimer - event.deltaTime;
    end
    if self.saftyTimer < 0 then
        self.isDie = true;
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
    -- self:addSP(event.unit);
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
    if self.isCutIn and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(event.index,1);
        self.isCutIn = false;

        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    event.unit:setActiveSkill(self.currentActiveSkill);


    self.attackCounter = 0;


    -- self:addSP(event.unit);
    return 1
end


function class:attackDamageValue(event)
    if self.specialHPAttackRate > 0 then
        return event.enemy:getCalcHPMAX() * self.specialHPAttackRate;
    end
    return event.value;
end

function class:run(event)
    if event.spineEvent == "death" then self:death(event.unit); end
    if event.spineEvent == "addSP" then self:addSP(event.unit); end
    return 1;
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end


function class:dead(event)
    -- if not self.isDie then
    --     event.unit:setHP(1);
    --     return 0;
    -- end
    return 1;
end

function class:death(unit)

    if not self:getIsHost() then
        return;
    end

    local team = megast.Battle:getInstance():getTeam(true);
    local targets = {}


    for i = 0, 4 do
        local unit = team:getTeamUnit(i);
        if unit ~= nil then
            table.insert(targets,unit);
        end
    end

    local rand = Random.range(0,table.maxn(targets));
    local targetUnit = targets[rand + 1]

    self:excution(targetUnit:getIndex());
    megast.Battle:getInstance():sendEventToLua(self.scriptID,7,targetUnit:getIndex());

    return 1;
end

function class:excution(index)
    local targetUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);

    targetUnit:setHP(targetUnit:getHP() - targetUnit:getCalcHPMAX() * self.FIXED_DAMAGE_RATE);
end

function class:checkDark(unit,deltaTime)
    if self.darkCheckTimer < 0.5 then
        self.darkCheckTimer = self.darkCheckTimer + deltaTime;
        return;
    end
    self.darkCheckTimer = 0;
    if self:getUnitDark() then
        if not self.isDark then
            self.isDark = true;
            self:addBuffs(unit,self.DODGE_BUFF_ARGS);
        end
    else
        if self.isDark then
            self.isDark = false;
            self:removeBuffs(unit,self.DODGE_BUFF_ARGS);
        end
    end
end


function class:getUnitDark()
    local team = megast.Battle:getInstance():getTeam(true);
    local targets = {}

    for i = 0, 4 do
        local unit = team:getTeamUnit(i);
        if unit ~= nil and unit:getTeamUnitCondition():findConditionValue(93) > 0 then
            return true;
        end
    end
    return false;
end

function class:forceDark()
    if not self:getIsHost() then
        return ;
    end

    local team = megast.Battle:getInstance():getTeam(true);
    local targets = {}

    for i = 0, 4 do
        local unit = team:getTeamUnit(i);
        if unit ~= nil then
            local darkRegist = unit:getTeamUnitCondition():findConditionValue(105) + unit:getTeamUnitCondition():findConditionValue(113);
            local rand = Random.range(0,100);
            if rand - darkRegist > 0 then
                self:makeDark(unit:getIndex());
                megast.Battle:getInstance():sendEventToLua(self.scriptID,8,unit:getIndex()); 
            end
        end

    end
end

function class:makeDark(index)
    local team = megast.Battle:getInstance():getTeam(true);
    local unit = team:getTeamUnit(index);
    if unit ~= nil then
        self:addBuffs(unit,self.DARK_BUFF_ARGS);
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

    self:showMessage(self.HP70_MESSAGES);
    self.forceSkillIndex = 6;
    
    -- self:addBuffs(unit,self.INVINCIBLE_BUFF_ARGS);
    unit:addSP(unit:getNeedSP());

end


function class:HP50(unit)
    unit:excuteAction();
    self:showMessage(self.HP50_MESSAGES);
    self.forceSkillIndex = 5;
    self:forceDark();
    self.isCutIn = true;
    -- self:addBuffs(unit,self.INVINCIBLE_BUFF_ARGS);
    unit:addSP(unit:getNeedSP());

end

function class:HP10(unit)
    unit:excuteAction();
    self:showMessage(self.HP10_MESSAGES);
    self.forceSkillIndex = 6;
    -- self:addBuffs(unit,self.INVINCIBLE_BUFF_ARGS);

    unit:addSP(unit:getNeedSP());
end

function class:HP0(unit)
    self:removeAllStopStatus(self.gameUnit);
    self:showMessage(self.HP0_MESSAGES);
    self.forceSkillIndex = 6;
    unit:addSP(unit:getNeedSP());
    self.isCountDown = true;
    self.hitstopReduceLevel = 200;
    unit:setInvincibleTime(5);
    unit:setHitStopTimeSelf(0);
    unit:setRange_Max(100000);
    unit:excuteAction();
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
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

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
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
    self:excution(args.arg);
    return 1;
end

function class:receive8(args)
    self:makeDark(args.arg);
    return 1;
end


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;