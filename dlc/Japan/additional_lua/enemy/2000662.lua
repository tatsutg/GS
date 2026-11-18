--@additionalEnemy,2000661
--@additionalItem,104822500,104832500,104842500
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="No.2", version=1.3, id=2000662});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 3
}

--１度に召喚される敵の数
class.SUMMON_CNT_MAX = 1;

--[召喚される敵のエネミーID] = 重み
class.ENEMYS = {
    [2000661] = 100
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40001174,
        EFID = 28,         --速度アップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 17
    },
    {
        ID = 40001173,
        EFID = 17,         --攻撃アップ
        VALUE = 60,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--怒り時のメッセージ
class.RAGE_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess1 or "no text",
        COLOR = Color.red,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess2 or "no text",
        COLOR = Color.red,
        DURATION = 5
    }
};

class.MESSAGE_COLOR = summoner.Color.magenta;

class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;                  --ユニットボスは攻撃が自動同期されないためゲスト側が攻撃を待つためのフラグ
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;            --真奥義の際に真奥義用カットインをいれるためのフラグ
    event.unit:setSkillInvocationWeight(0);
    self.items = {}

    --使うアイテム
    -- 真『ノブルバーミント』
    self.items[0] = {
        INFO = "self.TEXT.ITEM1",   --今回は不使用だけど一応アイテム使用時にinfoを出す機能は残しておく
        INFO_COLOR = Color.magenta, --そのとき出すinfoの文字色
        ID = 104822500,             --アイテムID
        INVINCIBLE = 0,             --アイテムを使う際に無敵時間を与えたい場合の時間
        MOTION = "idle"        --アイテム使用のモーションを指定
    }

    -- 魔装『オブスクリタス』
    self.items[1] = {
        INFO = "self.TEXT.ITEM2",
        INFO_COLOR = Color.magenta,
        ID = 104832500,
        INVINCIBLE = 0,
        MOTION = "attack1"
    }

    -- 真『アルケミア』
    self.items[2] = {
        INFO = "self.TEXT.ITEM3",
        INFO_COLOR = Color.magenta,
        ID = 104842500,
        INVINCIBLE = 0,
        MOTION = "Rinascita"
    }

    self.HP_TRIGGERS = {
        [30] = "getRage"
    };

    self:setItems(event.unit);
    event.unit:addSP(400);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    return 1;
end

function class:startWave(event)
    for i = 0,6 do
        local myTeamUnit = event.unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit == event.unit then
                self:setMessageBoxList()
                self:showMessage(self.START_MESSAGE_LIST)
            end
            break;
        end
    end
    return 1;
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 10,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "物理耐性"
        })
    }
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
    for i,messageBox in ipairs(messageBoxList) do
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

function class:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　100%軽減
    return 1;
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    
    unit:takeAttack(tonumber(attackIndex));
 
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
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
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    self:skillActiveSkillSetter(event.unit,event.index);
    self.skillCheckFlg2 = false;
    self.fromHost = false;

    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:run(event)
    if event.spineEvent == "takeItem1" then
        self:useItem(event.unit,0);
    end
    if event.spineEvent == "takeItem2" then
        self:useItem(event.unit,1);
    end
    if event.spineEvent == "takeItem3" then
        self:useItem(event.unit,2);
    end
    if event.spineEvent == "summon" then
        self:summon(event.unit);
    end
    return 1;
end


--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addRageBuff(unit);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
end

function class:addRageBuff(unit)
    for i, v in ipairs(self.RAGE_BUFF_ARGS) do
        self:addBuff(unit, v);
    end
end

function class:addBuff(unit,args)
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end

function class:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

--=====================================================================================================
--アイテム使用関連のメソッド

function class:setItems(unit)
  for i = 0,table.maxn(self.items) do
    unit:setItemSkill(i,self.items[i].ID);
  end
end

function class:useItem(unit,index)
    unit:takeItemSkill(index);
    unit:takeAnimation(0,self.items[index].MOTION,false);
    -- local infoText = self.items[index].INFO;                                 --今回は不使用だけど一応アイテム仕様時にinfoを出す機能は残しておく
    -- summoner.Utility.messageByEnemy(infoText,5,self.items[index].INFO_COLOR);
    if self.items[index].INVINCIBLE > unit:getInvincibleTime() then
        unit:setInvincibleTime(self.items[index].INVINCIBLE);
    end
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
                if self.hpMarkers[i] ~= nil then
                    self.gameUnit:removeHpMarker(self.hpMarkers[i])
                end
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "summon" then
        self:summon(unit);
        return true;
    end
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end


--=====================================================================================================
--ユニットを召喚
function class:summon(unit)
    if not self:getIsHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
             unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
             cnt = cnt + 1; 
             if cnt >= self.SUMMON_CNT_MAX then
                break;
             end
        end
    end
end


function class:creanUpEnemy(unit)
    for i = 0, 5 do
        local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
end

--=====================================================================================================

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


--=====================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

class:publish();

return class;