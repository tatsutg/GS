local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ノギア", version=1.3, id=2007705});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

class.BUFF_VALUE = 30;

function class:setMessageBoxList()
    self.MESSAGE_BOX_LIST = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "闇・炎属性キラー",
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル耐性",
            COLOR = Color.red,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "全状態異常耐性",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [0] = {
            ID = 40075,
            BUFF_ID = 17,         --ダメージアップ
            VALUE = 50,        --効果量
            DURATION = 9999999,
            ICON = 26,
            COUNT = 1,
            COUNT_MAX = 5
        },
        [1] = {
            ID = 40076,
            BUFF_ID = 15,         --防御力アップ
            VALUE = 50,        --効果量
            DURATION = 9999999,
            ICON = 5,
            COUNT = 1,
            COUNT_MAX = 5
        }
    }
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "HP_FLG_50"
    }

    self.skill3flg = false
    self.buffValue_0 = 50
    self.buffValue_1 = 50
    self.hitStop = 0
    self:setBuffBoxList()
    self:setMessageBoxList()
    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    event.unit:setSPGainValue(0);

    return 1;
end
---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    event.unit:takeSkill(2)
    self:showMessage(event.unit,self.MESSAGE_BOX_LIST)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.hitStop = 0
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
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.hitStop = 0
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 2 then
        self:addBuff(event.unit,self.BUFF_BOX_LIST)
        if self:checkBuffTimes() then
            self:addBuffValue(self.BUFF_BOX_LIST[0],self.buffValue_0)
            self:addBuffValue(self.BUFF_BOX_LIST[1],self.buffValue_1)
        end
    end

    if event.index == 3 and not self.skillCheckFlg2 then
        self.hitStop = 0.5
        self.skillCheckFlg2 = true;
        if self.skill3flg then
            self.skill3flg = false
        end
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.HP_TRIGGERS[50] == nil then
        skillIndex = 3
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:addSP(unit)  
    unit:addSP(self.spValue);
    return 1;
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    unit:setReduceHitStop(2,self.hitStop)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

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
    if trigger == "HP_FLG_50" then
        self:hp_50(unit)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
    return true
end

function class:hp_50(unit)
    self.skill3flg = true
end

--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffRange(unit,buffBoxList,0,table.maxn(buffBoxList))
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
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
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buffBox.COUNT = buffBox.COUNT + 1
        end
    end
end


function class:addBuffValue(buffBox,value)
    buffBox.VALUE = buffBox.VALUE + value
end

function class:checkBuffTimes()
    if self.BUFF_BOX_LIST[0].VALUE >= self.buffValue_0 * 5 
        or self.BUFF_BOX_LIST[1].VALUE >= self.buffValue_1 * 5 then
        return false
    end
    return true
end

--=====================================================================================================================================

function class:showMessage(unit,messageBoxList,index)
    if index == nil then 
        self:showMessageRange(unit,messageBoxList,0,table.maxn(messageBoxList))
        return
    end
    self:execShowMessage(unit,messageBoxList[index])
end

function class:showMessageRange(unit,messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(unit,messageBoxList[i])
    end
end

function class:execShowMessage(unit,messageBox)
    summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end

function class:receive3(args)
    if 0 == args.args then
        self:hp_50(self.gameUnit);
    end

    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;