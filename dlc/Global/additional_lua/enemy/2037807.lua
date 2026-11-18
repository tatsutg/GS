local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超襲来待機ギンゾウ", version=1.3, id=2037807});
class:inheritFromEnemy("2037806");

function class:setMessageBoxList()

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "影のシノビを撃破！",
            COLOR = Color.yellow
        })
    }

end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(7);---アタックディレイ
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

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    --self:showMessage(self.START_MESSAGE_LIST)
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    self.isIdle = true

    self.gameUnit:setInvincibleTime(99999)

    self.posX = event.unit:getPositionX() - 150
    self.posY = event.unit:getPositionY() + 100

    self.limitTimer = 0
    self.limitTime = 60

    event.unit:setHPBarHeightOffset(10000);

    ---カイガンオーラ関係
    self.isAura = true
    self.timer = 0
    self.AURA_INTERVAL = 99999
    return 1
end

class:publish();

return class;