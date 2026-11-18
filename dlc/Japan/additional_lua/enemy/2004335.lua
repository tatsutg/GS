--@additionalItem,104162100
--todo アイテムを正規品に　infoを正規品に
local class = summoner.Bootstrap.createUnitClass({label="氷ドラゴン", version=1.3, id=500122213});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS = {
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}

--定数
class.RAGE_COOLTIME = 25;
class.MESSAGES = summoner.Text:fetchByEnemyID(2004335);



--======================================================================================================================================
function class:start(event)
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;

    self.gameUnit = nil;
    self.rageTimer = 25;
    self.iceOrbit = nil;
    self.isRage = false;
    self.rageAttackNum = 6;
    self.isFreeze = false;
    self.itemTimer = 28;

    event.unit:setSPGainValue(0);
    self.gameUnit = event.unit;

    self.items = {};

    --使うアイテム
    self.items[0] = {
        NAME = self.TEXT.ITEM1,
        ID = 104162100,
        INVINCIBLE = 0
    }

    self:setItems(event.unit);
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.MESSAGES.mess7,5,summoner.Color.cyan,21);
    summoner.Utility.messageByEnemy(self.MESSAGES.mess8,5,summoner.Color.red);
    self:setConditionBuff(event.unit);
    return 1;
end

function class:update(event)
    if not self.isRage then
        self.rageTimer = self.rageTimer + event.deltaTime;
    end
    if not self.isFreeze then
        local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
        if ice ~= nil then
            self.isFreeze = true;
            self:showFreezeMessage();
        end
    else
        local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
        if ice == nil then
            self.isFreeze = false;
        end
    end
    self:countDownItem(event.unit,event.deltaTime);
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if not self.isRage and summoner.Utility.getUnitHealthRate(unit) < 0.8 and self.rageTimer >= self.RAGE_COOLTIME then
        attackIndex = self.rageAttackNum;
    end
    unit:takeAttack(tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    self:itemCheck(event.unit);
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    if event.index == 6 then
        event.unit:showPopText(self.MESSAGES.mess6);
    end
    return 1
end

function class:takeDamageValue(event)
    local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
    if ice ~= nil then
        return 1;
    end
    return event.value;
end

function class:takeBreakDamageValue(event)
    local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
    if ice ~= nil then
        return 1;
    end
    return event.value;
end

function class:takeBreake(event)
    self:removeIce(event.unit);
    self.isRage = false;
    return 1;
end

function class:run (event)
    if event.spineEvent == "addSP" then  self:addSP(event.unit) end
    
    if event.spineEvent == "addIce" then 
        if megast.Battle:getInstance():isHost() then
            self:addIce(event.unit)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        end
    end
    
    if event.spineEvent == "iceControll" then self:iceControll(event.unit) end
    
    if event.spineEvent == "selfFreeze" then 
        if megast.Battle:getInstance():isHost() then
            self:selfFreeze(event.unit)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        end
    end
    return 1;
end

function class:addIce(unit)
    if self.iceOrbit ~= nil then
        return;
    end
    self:getRage(unit);
    self.iceOrbit = unit:addOrbitSystem("ice_floor_in",0);
    self.iceOrbit:takeAnimation(0,"ice_floor_in",true);
    self.iceOrbit:setZOrder(0);
    self.iceOrbit:setActiveSkill(8);
end

function class:iceControll(orbit)
    if self.iceOrbit ~= nil then
        self.iceOrbit:takeAnimation(0,"ice_floor_cur",true);
    end
end

function class:removeIce(unit)
    if self.iceOrbit ~= nil then
        self.iceOrbit:takeAnimation(0,"ice_floor_out",false);
        self.iceOrbit = nil;
        summoner.Utility.messageByEnemy(self.MESSAGES.mess2,5,summoner.Color.cyan);
    end
end

function class:getRage(unit)
   self.isRage = true;
   self.rageTimer = 0;
   summoner.Utility.messageByEnemy(self.MESSAGES.mess1,5,summoner.Color.cyan);
end

function class:selfFreeze(unit)
    self:addIce(unit);
    unit:getTeamUnitCondition():addCondition(500121,96,1,15,86,7);
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2020","attack1");
    orbit:getSkeleton():setScaleX(-1);
    orbit:setActiveSkill(5);

end

function class:showFreezeMessage()
    summoner.Utility.messageByEnemy(self.MESSAGES.mess3,5,summoner.Color.cyan,20);
    summoner.Utility.messageByEnemy(self.MESSAGES.mess4,5,summoner.Color.cyan,20);
    summoner.Utility.messageByEnemy(self.MESSAGES.mess5,5,summoner.Color.cyan,35);
end


--===================================================================================================================

--===================================================================================================================
--マルチ同期//
--//////////
function class:receive1(args)
    self:addIce(self.gameUnit);
    return 1;
end


function class:receive2(args)
    self:selfFreeze(self.gameUnit);
    return 1;
end


function class:receive3(args)
    self:useItem(self.gameUnit,args.arg);
    return 1;
end
--=====================================================================================================
--アイテム使用関連のメソッド

function class:countDownItem(unit,delta)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    self.itemTimer = self.itemTimer + delta;
    if self.itemTimer >= 30 then
        unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　9.5割軽減
    end
end

function class:itemCheck(unit)
    if self.itemTimer >= 30 and megast.Battle:getInstance():isHost() then
        self.itemTimer = 0;
        self:useItem(unit,0);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
end

function class:setItems(unit)
  for i = 0,table.maxn(self.items) do
    unit:setItemSkill(i,self.items[i].ID);
  end
end

function class:useItem(unit,index)
    unit:takeItemSkill(index);
    unit:takeAttack(0);
    local infoText = self.items[index].NAME;
    -- summoner.Utility.messageByEnemy(infoText,5,self.MESSAGE_COLOR);
    if self.items[index].INVINCIBLE > unit:getInvincibleTime() then
        unit:setInvincibleTime(self.items[index].INVINCIBLE);
    end
end

--=====================================================================================================
--特定状態異常時以外ダメージを受けない能力関連のメソッド
function class:setConditionBuff(unit)
    -- unit:getTeamUnitCondition():addCondition(500122,21,-100,9999999,0);
    -- local buff = unit:getTeamUnitCondition():addCondition(500123,21,100,9999999,0);
    -- buff:setScriptID(18);
    -- buff:setValue1(97);
end


--===================================================================================================================

class:publish();

return class;