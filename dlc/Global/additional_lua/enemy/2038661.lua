local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX2ミヅキ", version=1.3, id=2038661});
class:inheritFromEnemy("2038651");

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "出陣ッ！",
            COLOR = Color.cyan
        })
    }

    self.HP100_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP100_MESSAGE1 or "イマリの願いよこの身に宿れ",
            COLOR = Color.cyan
        })
    }

    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "術式、七天の技――",
            COLOR = Color.cyan
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "不覚…！",
            COLOR = Color.cyan
        })
    }

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

    if event.index == 3 then
        self:showMessage(self.HP100_MESSAGE_LIST)
        event.unit:setNextAnimationName("shin_skill3")
    end

    if event.index == 4 then
        self.vanishFLG = true
        event.unit:setNextAnimationName("skill3b")
        event.unit:setNextAnimationEffectName("shin_skill3b")
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
    return 1
end

function class:shinSetAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan2_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan2_in");
    self.aura:takeAnimation(0,"Kaigan2_in",true);
    self:auraPosition(unit)
end

function class:auraTimer(deltaTime,unit)
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            self.isAura = false
            self.timer = 0
            self:setBuffBoxList()
            -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
            unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
            self.aura:takeAnimation(0,"empty",true);
            self.shinMode = false
        else
            self.timer = self.timer + deltaTime
            if self.vanishFLG and not self.emptyFLG then
                self.emptyFLG = true
                self.aura:takeAnimation(0,"empty",true);
            elseif not self.vanishFLG and self.emptyFLG then
                self.emptyFLG = false
                self.aura:takeAnimation(0,"Kaigan2_loop",true);
            end
        end
    end
end

class:publish();

return class;