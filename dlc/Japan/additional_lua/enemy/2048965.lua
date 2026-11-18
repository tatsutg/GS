local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ後編_EX2_黒化英霊セイバー", version=1.3, id=2048965});
class:inheritFromEnemy("2048960");


function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self.hpSkill = 3
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    --self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self.addSpSkipFLG = false ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    --summoner.Utility.messageByEnemy(event.spineEvent)
    if string.find(event.spineEvent,"SHOT") ~= nil then
        local strN = string.sub(event.spineEvent,5)
        local slash = event.unit:addOrbitSystem("SHOT"..strN,0)
        if tonumber(strN) >= 2 then
            slash:setDamageRateOffset(0.5)
            slash:setBreakRate(0.5)
        end
    end
    return 1
end


class:publish();

return class;