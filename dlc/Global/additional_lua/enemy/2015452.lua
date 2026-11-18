local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX/極　ガロウ", version=1.3, id=2015452});
class:inheritFromUnit("unitBossBase");


class.ATTACK_REEL = {
    [1] = {
        INDEX1 = 100
    },
    [2] = {
        INDEX2 = 100
    },
    [3] = {
        INDEX1 = 50,
        INDEX2 = 50
    }
}



--使用する奥義とその確率
class.SKILL_REEL = {
    [1] = {
        INDEX3 = 100
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
        animationNumber = 1,
        activeSkill = 2,
        isSkill = true,
        sp = 20
    },
    [3] = {
        animationNumber = 2,
        activeSkill = 3,
        isSkill = true,
        sp = 0
    },
    [4] = {
        animationNumber = 3,
        activeSkill = 4,
        isSkill = true,
        sp = 0
    }
}
--怒り時にかかるバフ内容

class.HP50_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 17,         --与ダメアップ
        VALUE = 25,        --効果量
        DURATION = 9999999,
        ICON = 26
    }   
}


class.HP10_BUFF_ARGS = {
    {
        ID = 40077,
        EFID = 13,         --速度
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 3
    }   
}


class.INVINCIBLE_BUFF_ARGS = {
    {
        ID = 40078,
        EFID = 21,         --被ダメ
        VALUE = -1000,        --効果量
        DURATION = 8,
        ICON = 0
    },
    {
        ID = 40079,
        EFID = 27,         --被ブレイク
        VALUE = -1000,        --効果量
        DURATION = 8,
        ICON = 0
    },
}


class.BUFF_VALUE = 30;

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp10(status) end,
            HP = 10,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp50(status)
    if status ==  "use3" then
        self.gameUnit:excuteAction();
        self:showMessage(self.HP50_MESSAGES);
        self:addBuffs(self.gameUnit,self.HP50_BUFF_ARGS);
        self.forceSkillIndex = 4;
        self:addBuffs(self.gameUnit,self.INVINCIBLE_BUFF_ARGS);
        self.gameUnit:addSP(self.gameUnit:getNeedSP());
    end
end

function class:hp10(status)
    if status ==  "use3" then
        self.gameUnit:excuteAction();
        self:addBuffs(self.gameUnit,self.HP10_BUFF_ARGS);
        self:showMessage(self.HP10_MESSAGES);
        self.forceSkillIndex = 4;
        self:addBuffs(self.gameUnit,self.INVINCIBLE_BUFF_ARGS);
        self.gameUnit:addSP(self.gameUnit:getNeedSP());
    end
end

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.forceSkillIndex = 0;
    self.hitstopReduceLevel = 2;
    self.hitStopReduceRate = 1;
    self.attackCounter = 0;
    self.skillCounter = 0;
    self.isDie = false;

    self.currentActiveSkill = 0;

    event.unit:setSkillInvocationWeight(0);

     self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "悪を執行する",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }


    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "少しはやるな",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP10_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP10_MESSAGE1 or "まだまだ！",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP10_MESSAGE2 or "攻撃力アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP0_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP0_MESSAGE1 or "油断しちまったぜ…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }


    self.gameUnit = event.unit;
    self:setTriggerList()
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
    return 1;
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
        event.unit:takeSkillWithCutin(3,1);
        self:addBuffs(event.unit,self.INVINCIBLE_BUFF_ARGS);
        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    event.unit:setActiveSkill(self.currentActiveSkill);

    self:addSP(event.unit);
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end


function class:dead(event)
    self:showMessage(self.HP0_MESSAGES);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1;
end

function class:receive4(args)
    self:showMessage(self.HP0_MESSAGES);
    return 1
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
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                if not unit:isBreak() then
                    self:execTrigger(index)
                end
            else
                self:execTrigger(index)
            end
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
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    self.TRIGGERS[index].action(action)
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
---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
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


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;