local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="リゼロ前半_EX1_エミリア（ウェディングver）", version=2.8, id=2081360});
class:inheritFromEnemy("2081370");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
}

class.cutInSkill = {
    [2] = 0,
    [3] = 1,
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "頑張って、やり遂げましょう。", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ低下耐性", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "これは私からの絶縁状だと思って。", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "状態異常耐性ダウン", COLOR = Color.red, isPlayer = true}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "油断……しちゃった……", COLOR = Color.cyan}),
    }
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 3;
        -- self.saveBP = self.gameUnit:getBurstPoint();
        self.gameUnit:addSP(100);
        -- self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
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

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100});---奥義使用後はリセットでスキル1からスタート
    return 1
end



class:publish();

return class;