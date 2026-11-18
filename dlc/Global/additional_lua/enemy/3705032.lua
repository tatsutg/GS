local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="メイン37章 エクスフォーゼレイアス_NORMAL", version=2.4, id=3705032});
class:inheritFromEnemy("3705033");

-- SKILL5（HP0専用）は不要
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 5,
        attackDelay = 10,
        hitStop = 100
    })
    self:dump(self.GD)

    self.fromHost = false
    self.gameUnit = event.unit

    self.spValue = self.GD.addSP
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay)
    end

    self.attackCheckFlg = false
    self.skillCheckFlg = false
    self.cutInFLG = false
    event.unit:setSPGainValue(0)
    event.unit:setSkillInvocationWeight(0)

    self.addSpSkipFLG = true
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0
    self.targetUnitList = {}

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self:showMessage(self.START_MESSAGE_LIST)

    return 1
end

function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end

    event.unit:setReduceHitStop(self.GD.hitStop, 1)

    return 1
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {}
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "お前は、敵…なのか！？", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "騎士の剣よ…応えて…くれ…", COLOR = Color.white})
    }
end

function class:setTriggerList()
    self.TRIGGERS = {
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index, trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:execSkill2(unit)
end

function class:execSkill3(unit)
end

function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

function class:takeBreake(event)
    for i = 1, table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

class:publish();

return class;
