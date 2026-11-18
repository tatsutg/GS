local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="地獄楽_真EX_キサラギ", version=1.3, id=2050670});
class:inheritFromEnemy("2050675");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
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
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL4 = 5
}

class.cutInSkill = {
    --[5] = 1
}

function class:setBuffBoxList(duration)
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20506701,
            BUFF_ID = 4001, -- カイガン
            VALUE = 0,
            DURATION = 99999999,
            ICON = 190
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,  --攻撃力UP
            VALUE = 3,
            DURATION = 99999999,
            ICON = 3
        }
    }
end


function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.hpSkill = 4
    end
end


---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:showMessage(self.START_WAVE_MESSAGE_LIST)
    self.gameUnit:addSP(100)
    self.hpSkill = 3
    self.gameUnit:setInvincibleTime(1)

    --if not self.isAura then
    --    self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,0)
    --    event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    --end
    return 1
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

    if event.index == 2 then
        event.unit:setActiveSkill(3)
        event.unit:getActiveBattleSkill():setSkillname("刀舞「炎月衝」")
    elseif event.index == 3 then
        if not self.isAura then
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
            self.isAura = true
            self.timer = 0
            self.isBeforeSkill = true
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
            for i,v in ipairs(self.kaiganBuffIconList.conds) do
                self:searchUnitEffect(event.unit,self.kaiganScriptIDList,4001,v)
            end
        else
            event.unit:setNextAnimationName("skill3_2")
            event.unit:setNextAnimationEffectName("skill3b")
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
        end
    elseif event.index == 4 then
        self.hpSkillFlg = true
        event.unit:setNextAnimationName("skill3_2")
        event.unit:setNextAnimationEffectName("skill3b") ---EFのアニメーション名に気をつける
        self:showMessage(self.SKILL_MESSAGE_LIST,1)
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
    return 1
end


---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    local type = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 1 then
        local orbit = event.enemy:addOrbitSystemWithFile("10287ef","empty");
        self:setOrbitPosition(event.enemy,orbit)
        orbit:setAnimation(0,"hit",false)
    end

    return event.value
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "md1Start" then
        self:setAura(event.unit)
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"Kaigan_loop",true);
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan_in",true);
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan1","Kaigan_in");
    self.aura:takeAnimation(0,"Kaigan_in",true);
    self:auraPosition(unit)
end


class:publish();

return class;